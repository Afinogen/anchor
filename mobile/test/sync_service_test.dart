import 'package:anchor/core/database/app_database.dart';
import 'package:anchor/features/notes/data/repository/note_attachments_repository.dart';
import 'package:anchor/features/sync/data/sync_api.dart';
import 'package:anchor/features/sync/data/sync_service.dart';
import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockDio extends Mock implements Dio {}

class MockAttachmentsRepo extends Mock implements NoteAttachmentsRepository {}

/// SyncService against a real in-memory Drift database, with only the network
/// and the attachment file store mocked.
void main() {
  late AppDatabase db;
  late MockDio dio;
  late MockAttachmentsRepo attachments;
  late SyncService service;
  late List<Map<String, dynamic>> requests;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dio = MockDio();
    attachments = MockAttachmentsRepo();
    requests = [];

    // Start up to date, so only the tests that want a full download get one.
    await db
        .into(db.syncState)
        .insert(SyncStateCompanion.insert(cursor: const Value('cursor-0')));

    when(() => attachments.sync()).thenAnswer((_) async {});
    when(
      () => attachments.evictCache(maxCacheBytes: any(named: 'maxCacheBytes')),
    ).thenAnswer((_) async {});
    when(() => attachments.evictCache()).thenAnswer((_) async {});
    when(
      () => attachments.deleteLocalFilesForNote(any()),
    ).thenAnswer((_) async {});
    when(() => attachments.deleteFiles(any())).thenAnswer((_) async {});
    when(
      () => attachments.applyServerAttachments(any(), any()),
    ).thenAnswer((_) async => <String>[]);

    service = SyncService(db, SyncApi(dio), attachments);
  });

  tearDown(() => db.close());

  Map<String, dynamic> response({
    List<Map<String, dynamic>> results = const [],
    List<Map<String, dynamic>> entries = const [],
    String? nextCursor,
    bool hasMore = false,
    bool resetRequired = false,
  }) {
    return {
      'protocol': 3,
      'results': results,
      'entries': entries,
      'nextCursor': nextCursor,
      'hasMore': hasMore,
      if (resetRequired) 'resetRequired': true,
    };
  }

  final drained = response();

  /// Replies with [replies] in order, then keeps returning a drained page.
  void stub(
    List<Map<String, dynamic>> replies, {
    Future<void> Function()? whileInFlight,
  }) {
    var index = 0;
    when(() => dio.post(any(), data: any(named: 'data'))).thenAnswer((
      invocation,
    ) async {
      requests.add(invocation.namedArguments[#data] as Map<String, dynamic>);
      await whileInFlight?.call();
      final body = index < replies.length ? replies[index] : drained;
      index++;
      return Response(
        requestOptions: RequestOptions(path: syncPath),
        statusCode: 200,
        data: body,
      );
    });
  }

  List<Map<String, dynamic>> changesOf(int request) =>
      ((requests[request]['changes'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

  Map<String, dynamic> serverNoteJson(
    String id, {
    String title = 'Server title',
    String? content,
    int version = 2,
    String state = 'active',
    String permission = 'owner',
    bool isPinned = false,
    List<String> tagIds = const [],
    List<String> shareIds = const [],
  }) {
    return {
      'id': id,
      'title': title,
      'content': content,
      'version': version,
      'isPinned': isPinned,
      'isArchived': false,
      'background': null,
      'state': state,
      'updatedAt': '2026-08-15T10:00:00.000Z',
      'createdAt': '2026-08-15T09:00:00.000Z',
      'userId': 'user-1',
      'tagIds': tagIds,
      'permission': permission,
      'shareIds': shareIds,
    };
  }

  Map<String, dynamic> serverTagJson(
    String id, {
    String name = 'Server tag',
    int version = 2,
  }) {
    return {
      'id': id,
      'name': name,
      'color': null,
      'version': version,
      'createdAt': '2026-08-15T09:00:00.000Z',
      'updatedAt': '2026-08-15T10:00:00.000Z',
    };
  }

  Map<String, dynamic> noteEntry(
    Map<String, dynamic> note, {
    String seq = '1',
  }) {
    return {
      'seq': seq,
      'entityType': 'note',
      'entityId': note['id'],
      'op': 'upsert',
      'note': note,
    };
  }

  Future<void> insertNote({
    required String id,
    String title = 'Local title',
    String? content,
    bool isSynced = false,
    int? version,
    int localRev = 1,
    String state = 'active',
    bool isPinned = false,
    bool isPinSynced = true,
    String permission = 'owner',
  }) {
    return db
        .into(db.notes)
        .insert(
          NotesCompanion.insert(
            id: id,
            title: title,
            content: Value(content),
            isSynced: Value(isSynced),
            version: Value(version),
            localRev: Value(localRev),
            state: Value(state),
            isPinned: Value(isPinned),
            isPinSynced: Value(isPinSynced),
            permission: Value(permission),
          ),
        );
  }

  Future<void> insertTag({
    required String id,
    String name = 'Local tag',
    bool isSynced = false,
    int? version,
    int localRev = 1,
    bool isDeleted = false,
  }) {
    return db
        .into(db.tags)
        .insert(
          TagsCompanion.insert(
            id: id,
            name: name,
            isSynced: Value(isSynced),
            version: Value(version),
            localRev: Value(localRev),
            isDeleted: Value(isDeleted),
          ),
        );
  }

  Future<Note?> note(String id) => (db.select(
    db.notes,
  )..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<Tag?> tag(String id) =>
      (db.select(db.tags)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  test(
    'pushes a locally edited note with the version it was based on',
    () async {
      await insertNote(id: 'n1', title: 'Edited', version: 4);
      stub([
        response(
          results: [
            {'type': 'note', 'id': 'n1', 'status': 'applied', 'version': 5},
          ],
        ),
      ]);

      await service.run();

      final change = changesOf(0).single;
      expect(change['type'], 'note');
      expect(change['id'], 'n1');
      expect(change['baseVersion'], 4);
      expect(change['title'], 'Edited');

      final row = await note('n1');
      expect(row!.version, 5);
      expect(row.isSynced, isTrue);
    },
  );

  test('a note created offline goes up without a base version', () async {
    await insertNote(id: 'n1', title: 'Brand new');
    stub([
      response(
        results: [
          {'type': 'note', 'id': 'n1', 'status': 'applied', 'version': 1},
        ],
      ),
    ]);

    await service.run();

    expect(changesOf(0).single.containsKey('baseVersion'), isFalse);
    expect((await note('n1'))!.version, 1);
  });

  test('a rejected push keeps the local text and goes again on the server '
      'version', () async {
    await insertNote(id: 'n1', title: 'Mine', version: 3);
    stub([
      response(
        results: [
          {
            'type': 'note',
            'id': 'n1',
            'status': 'conflict',
            'serverCopy': serverNoteJson('n1', title: 'Theirs', version: 7),
          },
        ],
      ),
      response(
        results: [
          {'type': 'note', 'id': 'n1', 'status': 'applied', 'version': 8},
        ],
      ),
    ]);

    await service.run();

    expect(changesOf(1).single['baseVersion'], 7);
    expect(changesOf(1).single['title'], 'Mine');

    final row = await note('n1');
    expect(row!.title, 'Mine', reason: 'the local edit must survive');
    expect(row.version, 8);
    expect(row.isSynced, isTrue);
  });

  test('a rejected push on a read-only note adopts the server copy', () async {
    await insertNote(id: 'n1', title: 'Mine', version: 3, permission: 'viewer');
    stub([
      response(
        results: [
          {
            'type': 'note',
            'id': 'n1',
            'status': 'conflict',
            'serverCopy': serverNoteJson(
              'n1',
              title: 'Theirs',
              version: 7,
              permission: 'viewer',
            ),
          },
        ],
      ),
    ]);

    await service.run();

    final row = await note('n1');
    expect(row!.title, 'Theirs');
    expect(row.version, 7);
    expect(row.isSynced, isTrue);
    expect(requests, hasLength(1));
  });

  test('a denied push drops the note instead of recreating it', () async {
    await insertNote(id: 'n1', version: 3);
    stub([
      response(
        results: [
          {'type': 'note', 'id': 'n1', 'status': 'denied'},
        ],
      ),
    ]);

    await service.run();

    expect(await note('n1'), isNull);
    verify(() => attachments.deleteLocalFilesForNote('n1')).called(1);
  });

  test('a transient failure leaves the note queued', () async {
    await insertNote(id: 'n1', version: 3);
    stub([
      response(
        results: [
          {'type': 'note', 'id': 'n1', 'status': 'failed'},
        ],
      ),
    ]);

    await service.run();

    final row = await note('n1');
    expect(row!.isSynced, isFalse);
    expect(row.version, 3, reason: 'nothing was applied server-side');
  });

  test('an edit made while the push is in flight stays queued', () async {
    await insertNote(id: 'n1', title: 'Uploaded', version: 4);
    stub(
      [
        response(
          results: [
            {'type': 'note', 'id': 'n1', 'status': 'applied', 'version': 5},
          ],
        ),
      ],
      whileInFlight: () async {
        await (db.update(db.notes)..where((tbl) => tbl.id.equals('n1'))).write(
          NotesCompanion(
            title: const Value('Kept typing'),
            localRev: const Value(2),
            isSynced: const Value(false),
          ),
        );
      },
    );

    await service.run();

    final row = await note('n1');
    expect(row!.title, 'Kept typing');
    expect(row.version, 5, reason: 'the next push must build on the new base');
    expect(row.isSynced, isFalse);
  });

  test('a tombstone the server acked is removed locally', () async {
    await insertNote(id: 'n1', state: 'deleted', version: 3);
    stub([
      response(
        results: [
          {'type': 'note', 'id': 'n1', 'status': 'applied', 'version': 4},
        ],
      ),
    ]);

    await service.run();

    expect(await note('n1'), isNull);
  });

  test('feed entries create notes and skip locally edited ones', () async {
    await insertNote(id: 'dirty', title: 'Mine', version: 3);
    stub([
      response(
        results: [
          {'type': 'note', 'id': 'dirty', 'status': 'failed'},
        ],
        entries: [
          noteEntry(serverNoteJson('fresh', title: 'From server')),
          noteEntry(serverNoteJson('dirty', title: 'Theirs', version: 9)),
        ],
        nextCursor: 'cursor-1',
      ),
    ]);

    await service.run();

    final fresh = await note('fresh');
    expect(fresh!.title, 'From server');
    expect(fresh.isSynced, isTrue);
    expect(fresh.version, 2);

    final dirty = await note('dirty');
    expect(dirty!.title, 'Mine');
    expect(dirty.version, 3);
  });

  test('a locally edited note still takes who it is shared with', () async {
    await insertNote(id: 'n1', title: 'Mine', version: 3);
    stub([
      response(
        results: [
          {'type': 'note', 'id': 'n1', 'status': 'failed'},
        ],
        entries: [
          noteEntry(
            serverNoteJson(
              'n1',
              title: 'Theirs',
              version: 9,
              shareIds: ['user-2'],
            ),
          ),
        ],
        nextCursor: 'cursor-1',
      ),
    ]);

    await service.run();

    final row = await note('n1');
    expect(row!.title, 'Mine');
    expect(row.version, 3);
    expect(row.isSynced, isFalse);
    expect(row.shareIds, '["user-2"]');
  });

  test(
    'a remove entry deletes the note and everything hanging off it',
    () async {
      await insertNote(id: 'n1', isSynced: true, version: 2);
      await db
          .into(db.noteTags)
          .insert(NoteTagsCompanion.insert(noteId: 'n1', tagId: 't1'));
      stub([
        response(
          entries: [
            {
              'seq': '4',
              'entityType': 'note',
              'entityId': 'n1',
              'op': 'remove',
            },
          ],
        ),
      ]);

      await service.run();

      expect(await note('n1'), isNull);
      final tagLinks = await (db.select(
        db.noteTags,
      )..where((tbl) => tbl.noteId.equals('n1'))).get();
      expect(tagLinks, isEmpty);
      verify(() => attachments.deleteLocalFilesForNote('n1')).called(1);
    },
  );

  test('the cursor is stored and sent on the next cycle', () async {
    stub([response(nextCursor: 'cursor-1')]);
    await service.run();
    expect(requests.single['cursor'], 'cursor-0');

    requests.clear();
    stub([response(nextCursor: 'cursor-2')]);
    await service.run();

    expect(requests.single['cursor'], 'cursor-1');
  });

  test('a snapshot drops rows the server no longer sends', () async {
    await db
        .update(db.syncState)
        .write(const SyncStateCompanion(cursor: Value(null)));
    await insertNote(id: 'kept', isSynced: true, version: 2);
    await insertNote(id: 'gone', isSynced: true, version: 2);
    await insertTag(id: 't-gone', isSynced: true, version: 2);
    stub([
      response(
        entries: [noteEntry(serverNoteJson('kept'))],
        nextCursor: 'cursor-1',
        hasMore: true,
      ),
      response(nextCursor: 'cursor-2'),
    ]);

    await service.run();

    expect(await note('kept'), isNotNull);
    expect(await note('gone'), isNull);
    expect(await tag('t-gone'), isNull);
  });

  test(
    'a snapshot drops attachment metadata the server no longer lists',
    () async {
      await db
          .update(db.syncState)
          .write(const SyncStateCompanion(cursor: Value(null)));
      await insertNote(id: 'n1', isSynced: true, version: 2);
      await db
          .into(db.noteAttachments)
          .insert(
            NoteAttachmentsCompanion.insert(
              id: 'gone',
              noteId: 'n1',
              type: 'image',
              originalFilename: 'gone.png',
              mimeType: 'image/png',
              fileSize: 10,
            ),
          );
      await db
          .into(db.noteAttachments)
          .insert(
            NoteAttachmentsCompanion.insert(
              id: 'queued',
              noteId: 'n1',
              type: 'image',
              originalFilename: 'queued.png',
              mimeType: 'image/png',
              fileSize: 10,
              syncStatus: const Value('pending_upload'),
            ),
          );
      stub([
        response(
          entries: [noteEntry(serverNoteJson('n1'))],
          nextCursor: 'cursor-1',
          hasMore: true,
        ),
        response(nextCursor: 'cursor-2'),
      ]);

      await service.run();

      final rows = await (db.select(
        db.noteAttachments,
      )..where((tbl) => tbl.noteId.equals('n1'))).get();
      expect(rows.map((row) => row.id), ['queued']);
    },
  );

  test('an expired cursor restarts from a snapshot', () async {
    stub([response(resetRequired: true), response(nextCursor: 'cursor-1')]);

    await service.run();

    expect(requests[0]['cursor'], 'cursor-0');
    expect(requests[1]['cursor'], isNull);
    final state = await db.select(db.syncState).getSingle();
    expect(state.cursor, 'cursor-1');
  });

  test('pins travel as their own change and leave the note alone', () async {
    await insertNote(
      id: 'n1',
      isSynced: true,
      version: 2,
      isPinned: true,
      isPinSynced: false,
    );
    stub([
      response(
        results: [
          {'type': 'pin', 'id': 'n1', 'status': 'applied'},
        ],
      ),
    ]);

    await service.run();

    final change = changesOf(0).single;
    expect(change['type'], 'pin');
    expect(change['isPinned'], isTrue);

    final row = await note('n1');
    expect(row!.isPinSynced, isTrue);
    expect(row.version, 2);
  });

  test('a tag that collides by name folds into the server copy', () async {
    await insertTag(id: 'local-tag', name: 'Work');
    await insertNote(id: 'n1', isSynced: true, version: 2);
    await db
        .into(db.noteTags)
        .insert(NoteTagsCompanion.insert(noteId: 'n1', tagId: 'local-tag'));
    stub([
      response(
        results: [
          {
            'type': 'tag',
            'id': 'local-tag',
            'status': 'conflict',
            'serverCopy': serverTagJson('server-tag', name: 'Work'),
          },
        ],
      ),
    ]);

    await service.run();

    expect(await tag('local-tag'), isNull);
    expect((await tag('server-tag'))!.name, 'Work');

    final links = await (db.select(
      db.noteTags,
    )..where((tbl) => tbl.noteId.equals('n1'))).get();
    expect(links.map((row) => row.tagId), ['server-tag']);
    expect(
      (await note('n1'))!.isSynced,
      isFalse,
      reason: 'the note now carries a different tag id',
    );
  });

  test('tags are pushed before the notes that reference them', () async {
    await insertTag(id: 't1');
    await insertNote(id: 'n1');
    stub([response()]);

    await service.run();

    expect(changesOf(0).map((change) => change['type']), ['tag', 'note']);
  });
}
