import 'package:drift/drift.dart';

// Earlier versions of a note: the ones this device recorded and the ones it
// has read from the server.
@TableIndex(name: 'note_revisions_note_created', columns: {#noteId, #createdAt})
@DataClassName('NoteRevisionRow')
class NoteRevisions extends Table {
  TextColumn get id => text()();
  TextColumn get noteId => text()();
  // The server version this text belonged to; 0 for a note the server has
  // never seen.
  IntColumn get version => integer().withDefault(const Constant(0))();
  TextColumn get title => text()();
  TextColumn get content => text().nullable()();
  // 'edit', 'conflict' or 'restore'
  TextColumn get cause => text().withDefault(const Constant('edit'))();
  // Unix milliseconds.
  IntColumn get createdAt => integer()();
  TextColumn get authorId => text().nullable()();
  TextColumn get authorName => text().nullable()();
  TextColumn get authorEmail => text().nullable()();
  TextColumn get authorProfileImage => text().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
