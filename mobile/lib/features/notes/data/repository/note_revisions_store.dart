import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/app_database.dart';
import '../../../auth/domain/user.dart';
import '../../../auth/presentation/auth_controller.dart';
import '../../domain/note_revision.dart';

part 'note_revisions_store.g.dart';

/// Successive edits by the same person fold into one version inside this
/// window.
const Duration _collapseWindow = Duration(minutes: 10);

const Duration _retention = Duration(days: 90);
const int _capPerNote = 200;

@riverpod
NoteRevisionsStore noteRevisionsStore(Ref ref) {
  final db = ref.watch(appDatabaseProvider);
  return NoteRevisionsStore(db, () => ref.read(authControllerProvider).value);
}

/// How far back a note's history has been read from the server.
class NoteHistoryPosition {
  const NoteHistoryPosition({this.cursor, this.isRead = false});

  final String? cursor;
  final bool isRead;

  bool get isComplete => isRead && cursor == null;
}

/// The earlier versions this device holds. Everything here is local: versions
/// recorded as the note is edited, and versions read from the server.
class NoteRevisionsStore {
  NoteRevisionsStore(this._db, this._currentUser);

  final AppDatabase _db;
  final User? Function() _currentUser;

  /// Keeps what a note said before this device changed it. Meant to run inside
  /// the write's own transaction. [synced] keeps the version off the wire.
  Future<void> record(
    Note prior, {
    RevisionCause cause = RevisionCause.edit,
    bool synced = false,
  }) async {
    final author = _currentUser();
    if (cause == RevisionCause.edit && await _collapsesInto(prior.id, author)) {
      return;
    }

    await _db
        .into(_db.noteRevisions)
        .insert(
          NoteRevisionsCompanion.insert(
            id: const Uuid().v7(),
            noteId: prior.id,
            version: Value(prior.version ?? 0),
            title: prior.title,
            content: Value(prior.content),
            cause: Value(cause.name),
            createdAt: DateTime.now().millisecondsSinceEpoch,
            authorId: Value(author?.id),
            authorName: Value(author?.name),
            authorEmail: Value(author?.email),
            authorProfileImage: Value(author?.profileImage),
            isSynced: Value(synced),
          ),
        );

    await prune(prior.id);
  }

  Stream<List<NoteRevision>> watch(String noteId) {
    return (_db.select(_db.noteRevisions)
          ..where((tbl) => tbl.noteId.equals(noteId))
          ..orderBy([
            (tbl) => OrderingTerm(
              expression: tbl.createdAt,
              mode: OrderingMode.desc,
            ),
            (tbl) => OrderingTerm(expression: tbl.id, mode: OrderingMode.desc),
          ]))
        .watch()
        .map((rows) => rows.map(_toDomain).toList());
  }

  /// Versions recorded here that the server has not been told about, oldest
  /// first.
  Future<List<NoteRevision>> pending(
    String noteId, {
    required int limit,
  }) async {
    final rows =
        await (_db.select(_db.noteRevisions)
              ..where(
                (tbl) => tbl.noteId.equals(noteId) & tbl.isSynced.equals(false),
              )
              ..orderBy([
                (tbl) => OrderingTerm(expression: tbl.createdAt),
                (tbl) => OrderingTerm(expression: tbl.id),
              ])
              ..limit(limit))
            .get();
    return rows.map(_toDomain).toList();
  }

  /// Notes with versions recorded here that the server has not been told
  /// about.
  Future<List<String>> noteIdsWithPending() async {
    final rows =
        await (_db.selectOnly(_db.noteRevisions, distinct: true)
              ..addColumns([_db.noteRevisions.noteId])
              ..where(_db.noteRevisions.isSynced.equals(false)))
            .get();
    return [for (final row in rows) row.read(_db.noteRevisions.noteId)!];
  }

  Future<void> markSynced(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    await (_db.update(_db.noteRevisions)..where((tbl) => tbl.id.isIn(ids)))
        .write(const NoteRevisionsCompanion(isSynced: Value(true)));
  }

  /// Where the next read of this note's history starts.
  Future<NoteHistoryPosition> position(String noteId) async {
    return _toPosition(await _positionRow(noteId).getSingleOrNull());
  }

  Stream<NoteHistoryPosition> watchPosition(String noteId) {
    return _positionRow(noteId).watchSingleOrNull().map(_toPosition);
  }

  /// Sends the next read back to the newest version.
  Future<void> markStale(String noteId) async {
    await (_db.delete(
      _db.noteHistoryState,
    )..where((tbl) => tbl.noteId.equals(noteId))).go();
  }

  /// Keeps a page read from the server together with where the next one
  /// starts.
  Future<void> savePage(
    String noteId,
    List<NoteRevision> revisions, {
    required String? cursor,
    required String? nextCursor,
  }) async {
    final isComplete = nextCursor == null;

    await _db.transaction(() async {
      final stale =
          cursor != null &&
          (await _positionRow(noteId).getSingleOrNull())?.cursor != cursor;

      if (cursor == null) {
        await _dropMissing(noteId, revisions, isComplete: isComplete);
      }

      await _db.batch((batch) {
        batch.insertAllOnConflictUpdate(_db.noteRevisions, [
          for (final revision in revisions)
            NoteRevisionsCompanion.insert(
              id: revision.id,
              noteId: noteId,
              version: Value(revision.version),
              title: revision.title,
              content: Value(revision.content),
              cause: Value(revision.cause.name),
              createdAt: revision.createdAt.millisecondsSinceEpoch,
              authorId: Value(revision.author?.id),
              authorName: Value(revision.author?.name),
              authorEmail: Value(revision.author?.email),
              authorProfileImage: Value(revision.author?.profileImage),
              isSynced: const Value(true),
            ),
        ]);
      });

      await prune(noteId);
      if (stale) return;

      await _db
          .into(_db.noteHistoryState)
          .insertOnConflictUpdate(
            NoteHistoryStateCompanion.insert(
              noteId: noteId,
              cursor: Value(nextCursor),
            ),
          );
    });
  }

  Future<void> deleteForNote(String noteId) async {
    await (_db.delete(
      _db.noteRevisions,
    )..where((tbl) => tbl.noteId.equals(noteId))).go();
    await markStale(noteId);
  }

  /// Versions waiting to go up and fresh conflict copies are never dropped.
  Future<void> prune(String noteId) async {
    final cutoff = DateTime.now().subtract(_retention).millisecondsSinceEpoch;
    await (_db.delete(_db.noteRevisions)..where(
          (tbl) =>
              tbl.noteId.equals(noteId) &
              tbl.isSynced.equals(true) &
              tbl.cause.equals(RevisionCause.edit.name) &
              tbl.createdAt.isSmallerThanValue(cutoff),
        ))
        .go();

    final countOf = _db.noteRevisions.id.count();
    final total =
        await (_db.selectOnly(_db.noteRevisions)
              ..addColumns([countOf])
              ..where(_db.noteRevisions.noteId.equals(noteId)))
            .map((row) => row.read(countOf)!)
            .getSingle();
    if (total <= _capPerNote) return;

    final rows =
        await (_db.selectOnly(_db.noteRevisions)
              ..addColumns([
                _db.noteRevisions.id,
                _db.noteRevisions.cause,
                _db.noteRevisions.createdAt,
                _db.noteRevisions.isSynced,
              ])
              ..where(_db.noteRevisions.noteId.equals(noteId))
              ..orderBy([
                OrderingTerm(
                  expression: _db.noteRevisions.createdAt,
                  mode: OrderingMode.desc,
                ),
                OrderingTerm(
                  expression: _db.noteRevisions.id,
                  mode: OrderingMode.desc,
                ),
              ]))
            .get();
    if (rows.length <= _capPerNote) return;

    final doomed = [
      for (final row in rows.sublist(_capPerNote))
        if (row.read(_db.noteRevisions.isSynced)! &&
            !(row.read(_db.noteRevisions.cause) ==
                    RevisionCause.conflict.name &&
                row.read(_db.noteRevisions.createdAt)! >= cutoff))
          row.read(_db.noteRevisions.id)!,
    ];
    if (doomed.isEmpty) return;

    await (_db.delete(
      _db.noteRevisions,
    )..where((tbl) => tbl.id.isIn(doomed))).go();
  }

  SimpleSelectStatement<$NoteHistoryStateTable, NoteHistoryStateData>
  _positionRow(String noteId) {
    return _db.select(_db.noteHistoryState)
      ..where((tbl) => tbl.noteId.equals(noteId));
  }

  NoteHistoryPosition _toPosition(NoteHistoryStateData? row) {
    return row == null
        ? const NoteHistoryPosition()
        : NoteHistoryPosition(cursor: row.cursor, isRead: true);
  }

  Future<bool> _collapsesInto(String noteId, User? author) async {
    final newest =
        await (_db.select(_db.noteRevisions)
              ..where((tbl) => tbl.noteId.equals(noteId))
              ..orderBy([
                (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.desc,
                ),
                (tbl) =>
                    OrderingTerm(expression: tbl.id, mode: OrderingMode.desc),
              ])
              ..limit(1))
            .getSingleOrNull();

    if (newest == null || newest.cause != RevisionCause.edit.name) return false;
    if (newest.authorId != author?.id) return false;
    return DateTime.now().millisecondsSinceEpoch - newest.createdAt <
        _collapseWindow.inMilliseconds;
  }

  Future<void> _dropMissing(
    String noteId,
    List<NoteRevision> revisions, {
    required bool isComplete,
  }) async {
    final kept = revisions.map((revision) => revision.id).toList();
    final oldest = revisions.isEmpty
        ? null
        : revisions
              .map((revision) => revision.createdAt.millisecondsSinceEpoch)
              .reduce((a, b) => a < b ? a : b);

    await (_db.delete(_db.noteRevisions)..where((tbl) {
          final gone =
              tbl.noteId.equals(noteId) &
              tbl.isSynced.equals(true) &
              tbl.id.isNotIn(kept);
          return isComplete || oldest == null
              ? gone
              : gone & tbl.createdAt.isBiggerOrEqualValue(oldest);
        }))
        .go();
  }

  NoteRevision _toDomain(NoteRevisionRow row) => NoteRevision(
    id: row.id,
    noteId: row.noteId,
    version: row.version,
    title: row.title,
    content: row.content,
    cause: RevisionCause.fromName(row.cause),
    createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt, isUtc: true),
    author: row.authorId == null
        ? null
        : NoteRevisionAuthor(
            id: row.authorId!,
            name: row.authorName ?? '',
            email: row.authorEmail ?? '',
            profileImage: row.authorProfileImage,
          ),
  );
}
