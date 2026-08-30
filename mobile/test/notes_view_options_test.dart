import 'package:anchor/features/notes/domain/note.dart';
import 'package:anchor/features/notes/presentation/notes_view_options.dart';
import 'package:flutter_test/flutter_test.dart';

/// Ordering of the notes list under each view option.
void main() {
  Note note(
    String id, {
    String title = 'note',
    DateTime? updatedAt,
    bool isPinned = false,
  }) => Note(
    id: id,
    title: title,
    isPinned: isPinned,
    updatedAt: updatedAt ?? DateTime.utc(2026, 7, 1),
  );

  List<String> order(List<Note> notes, NotesViewOptions options) =>
      (List<Note>.from(
        notes,
      )..sort(noteComparator(options))).map((n) => n.id).toList();

  const byDateDesc = NotesViewOptions();
  const byDateAsc = NotesViewOptions(isAscending: true);
  const byTitleAsc = NotesViewOptions(
    sortOption: SortOption.title,
    isAscending: true,
  );
  const byTitleDesc = NotesViewOptions(sortOption: SortOption.title);

  final notes = [
    note('n-a', title: 'Beta', updatedAt: DateTime.utc(2026, 7, 1)),
    note('n-z', title: 'Alpha', updatedAt: DateTime.utc(2026, 7, 3)),
  ];

  test('date modified still leads, in both directions', () {
    expect(order(notes, byDateDesc), ['n-z', 'n-a']);
    expect(order(notes, byDateAsc), ['n-a', 'n-z']);
  });

  test('title still leads, in both directions', () {
    expect(order(notes, byTitleAsc), ['n-z', 'n-a']);
    expect(order(notes, byTitleDesc), ['n-a', 'n-z']);
  });

  test('pinned notes stay on top under every option', () {
    final withPin = [
      ...notes,
      note('n-m', title: 'Zulu', updatedAt: DateTime.utc(2020), isPinned: true),
    ];

    for (final options in [byDateDesc, byDateAsc, byTitleAsc, byTitleDesc]) {
      expect(order(withPin, options).first, 'n-m');
    }
  });

  test('notes tied on the sort key fall back to the id, descending', () {
    final sameMoment = DateTime.utc(2026, 7, 2);
    final tied = [
      note('n-b', title: 'same', updatedAt: sameMoment),
      note('n-d', title: 'same', updatedAt: sameMoment),
      note('n-a', title: 'same', updatedAt: sameMoment),
      note('n-c', title: 'same', updatedAt: sameMoment),
    ];
    const expected = ['n-d', 'n-c', 'n-b', 'n-a'];

    for (final options in [byDateDesc, byDateAsc, byTitleAsc, byTitleDesc]) {
      expect(order(tied, options), expected);
      expect(order(tied.reversed.toList(), options), expected);
    }
  });
}
