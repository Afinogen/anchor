import 'package:drift/drift.dart';

// How far back a note's history has been read from the server. No row means
// the next read starts at the newest version; a row with no cursor means the
// whole history is here.
class NoteHistoryState extends Table {
  TextColumn get noteId => text()();
  TextColumn get cursor => text().nullable()();

  @override
  Set<Column> get primaryKey => {noteId};
}
