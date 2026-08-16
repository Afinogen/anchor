import 'package:drift/drift.dart';

// Only ever holds one row; each user has their own database.
class SyncState extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  // Null means the next sync downloads everything from scratch.
  TextColumn get cursor => text().nullable()();
  BoolColumn get isSweeping => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// What we held when a full download started, minus what the server has sent
// back. Whatever is still listed at the end was deleted elsewhere.
class SyncSweep extends Table {
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();

  @override
  Set<Column> get primaryKey => {entityType, entityId};
}
