import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/dio_provider.dart';
import '../../domain/note_revision.dart';
import 'note_revisions_store.dart';

part 'note_history_repository.g.dart';

const int _pageSize = 30;

@riverpod
NoteHistoryRepository noteHistoryRepository(Ref ref) {
  return NoteHistoryRepository(
    ref.watch(dioProvider),
    ref.watch(noteRevisionsStoreProvider),
  );
}

/// Brings the versions kept on the server down to the device.
class NoteHistoryRepository {
  NoteHistoryRepository(this._dio, this._store);

  final Dio _dio;
  final NoteRevisionsStore _store;

  /// Reads the page the device is missing next and keeps it. Does nothing
  /// once the whole history is here.
  Future<void> fetch(String noteId) async {
    final position = await _store.position(noteId);
    if (position.isComplete) return;

    final response = await _dio.get(
      '/api/notes/$noteId/revisions',
      queryParameters: {
        'limit': _pageSize,
        'withContent': true,
        'cursor': ?position.cursor,
      },
    );

    final page = NoteRevisionPage.fromJson(
      response.data as Map<String, dynamic>,
    );

    // A cursor always has more versions behind it; an empty page means they
    // are gone from the server.
    if (position.cursor != null && page.revisions.isEmpty) {
      await _store.markStale(noteId);
      return;
    }

    await _store.savePage(
      noteId,
      page.revisions,
      cursor: position.cursor,
      nextCursor: page.nextCursor,
    );
  }
}
