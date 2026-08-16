import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:anchor/features/notes/domain/note.dart';

enum ViewType { grid, list }

enum SortOption { dateModified, title }

class NotesViewOptions {
  final ViewType viewType;
  final SortOption sortOption;
  final bool isAscending;

  const NotesViewOptions({
    this.viewType = ViewType.grid,
    this.sortOption = SortOption.dateModified,
    this.isAscending = false,
  });

  NotesViewOptions copyWith({
    ViewType? viewType,
    SortOption? sortOption,
    bool? isAscending,
  }) {
    return NotesViewOptions(
      viewType: viewType ?? this.viewType,
      sortOption: sortOption ?? this.sortOption,
      isAscending: isAscending ?? this.isAscending,
    );
  }
}

/// Pinned notes stay on top, then the chosen sort, then the id.
int Function(Note, Note) noteComparator(NotesViewOptions options) {
  return (a, b) {
    if (a.isPinned != b.isPinned) {
      return a.isPinned ? -1 : 1;
    }

    final int compare = switch (options.sortOption) {
      SortOption.dateModified => (a.updatedAt ?? DateTime(0)).compareTo(
        b.updatedAt ?? DateTime(0),
      ),
      SortOption.title => a.title.toLowerCase().compareTo(
        b.title.toLowerCase(),
      ),
    };

    final ordered = options.isAscending ? compare : -compare;
    return ordered != 0 ? ordered : b.id.compareTo(a.id);
  };
}

class NotesViewOptionsNotifier extends AsyncNotifier<NotesViewOptions> {
  static const _storage = FlutterSecureStorage();
  static const _keyViewType = 'notes_view_type';
  static const _keySortOption = 'notes_sort_option';
  static const _keyIsAscending = 'notes_is_ascending';

  @override
  Future<NotesViewOptions> build() async {
    return _loadOptions();
  }

  Future<NotesViewOptions> _loadOptions() async {
    try {
      final viewTypeStr = await _storage.read(key: _keyViewType);
      final sortOptionStr = await _storage.read(key: _keySortOption);
      final isAscendingStr = await _storage.read(key: _keyIsAscending);

      final viewType = viewTypeStr == 'list' ? ViewType.list : ViewType.grid;

      final sortOption = sortOptionStr == 'title'
          ? SortOption.title
          : SortOption.dateModified;

      final isAscending = isAscendingStr == 'true';

      return NotesViewOptions(
        viewType: viewType,
        sortOption: sortOption,
        isAscending: isAscending,
      );
    } catch (e) {
      return const NotesViewOptions();
    }
  }

  Future<void> _saveOptions(NotesViewOptions options) async {
    try {
      await _storage.write(
        key: _keyViewType,
        value: options.viewType == ViewType.list ? 'list' : 'grid',
      );
      await _storage.write(
        key: _keySortOption,
        value: options.sortOption == SortOption.title
            ? 'title'
            : 'dateModified',
      );
      await _storage.write(
        key: _keyIsAscending,
        value: options.isAscending.toString(),
      );
    } catch (e) {
      // Ignore storage errors
    }
  }

  Future<void> setViewType(ViewType viewType) async {
    final current = state.value ?? const NotesViewOptions();
    final newOptions = current.copyWith(viewType: viewType);
    state = AsyncData(newOptions);
    await _saveOptions(newOptions);
  }

  Future<void> setSortOption(SortOption sortOption) async {
    final current = state.value ?? const NotesViewOptions();
    final newOptions = current.copyWith(sortOption: sortOption);
    state = AsyncData(newOptions);
    await _saveOptions(newOptions);
  }

  Future<void> toggleSortDirection() async {
    final current = state.value ?? const NotesViewOptions();
    final newOptions = current.copyWith(isAscending: !current.isAscending);
    state = AsyncData(newOptions);
    await _saveOptions(newOptions);
  }

  Future<void> setSortDirection(bool isAscending) async {
    final current = state.value ?? const NotesViewOptions();
    final newOptions = current.copyWith(isAscending: isAscending);
    state = AsyncData(newOptions);
    await _saveOptions(newOptions);
  }
}

final notesViewOptionsProvider =
    AsyncNotifierProvider<NotesViewOptionsNotifier, NotesViewOptions>(
      NotesViewOptionsNotifier.new,
    );
