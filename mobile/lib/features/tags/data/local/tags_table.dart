import 'package:drift/drift.dart';

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  // The server version this tag was written against; null until it exists there.
  IntColumn get version => integer().nullable()();
  // Counts up on every local edit, so an upload can tell if it was overtaken.
  IntColumn get localRev => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// Junction table for note-tag relationship
class NoteTags extends Table {
  TextColumn get noteId => text()();
  TextColumn get tagId => text()();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}
