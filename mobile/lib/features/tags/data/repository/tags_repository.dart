import 'dart:async';

import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/network/sync_requester.dart';
import '../../domain/tag.dart' as domain;

part 'tags_repository.g.dart';

@riverpod
TagsRepository tagsRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return TagsRepository(db);
}

/// Tags on the device. Nothing here talks to the server.
class TagsRepository {
  final AppDatabase _db;

  TagsRepository(this._db);

  // Watch all tags (excluding deleted) with note counts
  // This watches both tags and noteTags tables so counts update in realtime
  Stream<List<domain.Tag>> watchTags() {
    // Use a custom query or a join to count notes per tag
    // Drift doesn't support aggregation in simple joins easily in dart objects
    // But we can use a join and count in memory since tag list is usually small

    final query =
        _db.select(_db.tags).join([
            drift.leftOuterJoin(
              _db.noteTags,
              _db.noteTags.tagId.equalsExp(_db.tags.id),
            ),
            drift.leftOuterJoin(
              _db.notes,
              _db.notes.id.equalsExp(_db.noteTags.noteId),
            ),
          ])
          ..where(_db.tags.isDeleted.equals(false))
          ..orderBy([
            drift.OrderingTerm(
              expression: _db.tags.name,
              mode: drift.OrderingMode.asc,
            ),
          ]);

    return query.watch().map((rows) {
      final tagMap = <String, domain.Tag>{};
      final tagCounts = <String, int>{};

      for (final row in rows) {
        final tag = row.readTable(_db.tags);
        final noteTag = row.readTableOrNull(_db.noteTags);
        final note = row.readTableOrNull(_db.notes);

        if (!tagMap.containsKey(tag.id)) {
          tagMap[tag.id] = _mapToDomain(tag);
        }

        // Only count active, non-archived notes
        if (noteTag != null && note != null) {
          final isActive = note.state == 'active' && !note.isArchived;
          if (isActive) {
            tagCounts[tag.id] = (tagCounts[tag.id] ?? 0) + 1;
          }
        }
      }

      // Update counts
      return tagMap.values.map((tag) {
        return tag.copyWith(
          count: domain.TagCount(notes: tagCounts[tag.id] ?? 0),
        );
      }).toList();
    });
  }

  // Get all tags (for dropdowns, etc)
  Future<List<domain.Tag>> getTags() async {
    final query = _db.select(_db.tags)
      ..where((tbl) => tbl.isDeleted.equals(false))
      ..orderBy([
        (t) => drift.OrderingTerm(
          expression: t.name,
          mode: drift.OrderingMode.asc,
        ),
      ]);
    final rows = await query.get();
    return rows.map((row) => _mapToDomain(row)).toList();
  }

  // Get tag by id
  Future<domain.Tag?> getTag(String id) async {
    final row = await _tagRow(id);
    return row != null ? _mapToDomain(row) : null;
  }

  // Create tag - strictly local first
  Future<domain.Tag> createTag(domain.Tag tag) async {
    final created = tag.copyWith(updatedAt: DateTime.now().toUtc());

    await _db
        .into(_db.tags)
        .insert(
          TagsCompanion.insert(
            id: created.id,
            name: created.name,
            color: drift.Value(created.color),
            updatedAt: drift.Value(created.updatedAt),
            isSynced: const drift.Value(false),
            localRev: const drift.Value(1),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );

    scheduleAppSync(trigger: 'TagsRepo.createTag');

    return created;
  }

  // Update tag
  Future<void> updateTag(domain.Tag tag) async {
    await _db.transaction(() async {
      final prior = await _tagRow(tag.id);
      if (prior == null) return;

      await (_db.update(_db.tags)..where((tbl) => tbl.id.equals(tag.id))).write(
        TagsCompanion(
          name: drift.Value(tag.name),
          color: drift.Value(tag.color),
          updatedAt: drift.Value(DateTime.now().toUtc()),
          isSynced: const drift.Value(false),
          localRev: drift.Value(prior.localRev + 1),
        ),
      );
    });

    scheduleAppSync(trigger: 'TagsRepo.updateTag');
  }

  // Kept, marked deleted, until the server has been told.
  Future<void> deleteTag(String id) async {
    await _db.transaction(() async {
      final prior = await _tagRow(id);
      if (prior == null) return;

      await (_db.update(_db.tags)..where((tbl) => tbl.id.equals(id))).write(
        TagsCompanion(
          isDeleted: const drift.Value(true),
          updatedAt: drift.Value(DateTime.now().toUtc()),
          isSynced: const drift.Value(false),
          localRev: drift.Value(prior.localRev + 1),
        ),
      );
      await (_db.delete(
        _db.noteTags,
      )..where((tbl) => tbl.tagId.equals(id))).go();
    });

    scheduleAppSync(trigger: 'TagsRepo.deleteTag');
  }

  // Get tags for a note
  Future<List<String>> getTagIdsForNote(String noteId) async {
    final rows = await (_db.select(
      _db.noteTags,
    )..where((tbl) => tbl.noteId.equals(noteId))).get();
    return rows.map((row) => row.tagId).toList();
  }

  // Watch tags for a note
  Stream<List<domain.Tag>> watchTagsForNote(String noteId) {
    final query =
        _db.select(_db.noteTags).join([
            drift.innerJoin(
              _db.tags,
              _db.tags.id.equalsExp(_db.noteTags.tagId),
            ),
          ])
          ..where(_db.noteTags.noteId.equals(noteId))
          ..where(_db.tags.isDeleted.equals(false));

    return query.watch().map((rows) {
      return rows.map((row) => _mapToDomain(row.readTable(_db.tags))).toList();
    });
  }

  // Set tags for a note
  Future<void> setTagsForNote(String noteId, List<String> tagIds) async {
    await _db.transaction(() async {
      // Delete existing associations
      await (_db.delete(
        _db.noteTags,
      )..where((tbl) => tbl.noteId.equals(noteId))).go();

      if (tagIds.isEmpty) return;

      // Use batch insert for better performance
      await _db.batch((batch) {
        batch.insertAll(
          _db.noteTags,
          tagIds
              .map(
                (tagId) => NoteTagsCompanion(
                  noteId: drift.Value(noteId),
                  tagId: drift.Value(tagId),
                ),
              )
              .toList(),
          mode: drift.InsertMode.insertOrReplace,
        );
      });
    });
  }

  Future<Tag?> _tagRow(String id) => (_db.select(
    _db.tags,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  domain.Tag _mapToDomain(Tag row, {int noteCount = 0}) {
    return domain.Tag(
      id: row.id,
      name: row.name,
      color: row.color,
      updatedAt: row.updatedAt,
      isSynced: row.isSynced,
      isDeleted: row.isDeleted,
      count: domain.TagCount(notes: noteCount),
    );
  }
}
