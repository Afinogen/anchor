import 'package:anchor/features/notes/domain/note_history.dart';
import 'package:anchor/features/notes/domain/note_revision.dart';
import 'package:flutter_test/flutter_test.dart';

NoteRevision revisionOf({
  required String id,
  RevisionCause cause = RevisionCause.edit,
  DateTime? createdAt,
  NoteRevisionAuthor? author,
}) => NoteRevision(
  id: id,
  noteId: 'n1',
  version: 1,
  title: '',
  cause: cause,
  createdAt: createdAt ?? DateTime(2026, 8, 18, 10),
  author: author,
);

const ada = NoteRevisionAuthor(id: 'u1', name: 'Ada', email: 'ada@x.dev');
const bob = NoteRevisionAuthor(id: 'u2', name: 'Bob', email: 'bob@x.dev');

void main() {
  group('comparisonTarget', () {
    test('reads a version against the next newer one', () {
      final revisions = [revisionOf(id: 'r2'), revisionOf(id: 'r1')];

      expect(comparisonTarget(revisions, 'r1')?.id, 'r2');
    });

    test('reads the newest version against the note itself', () {
      final revisions = [revisionOf(id: 'r2'), revisionOf(id: 'r1')];

      expect(comparisonTarget(revisions, 'r2'), isNull);
    });

    test('skips versions that never reached the note', () {
      final revisions = [
        revisionOf(id: 'r3', cause: RevisionCause.conflict),
        revisionOf(id: 'r2', cause: RevisionCause.conflict),
        revisionOf(id: 'r1'),
      ];

      expect(comparisonTarget(revisions, 'r1'), isNull);
    });

    test('reads a version that was never saved against the note', () {
      final revisions = [
        revisionOf(id: 'r2'),
        revisionOf(id: 'r1', cause: RevisionCause.conflict),
      ];

      expect(comparisonTarget(revisions, 'r1'), isNull);
    });
  });

  group('historyHasMultipleAuthors', () {
    test('is false when one person wrote everything', () {
      expect(
        historyHasMultipleAuthors([
          revisionOf(id: 'r2', author: ada),
          revisionOf(id: 'r1', author: ada),
        ]),
        isFalse,
      );
    });

    test('is true once someone else appears', () {
      expect(
        historyHasMultipleAuthors([
          revisionOf(id: 'r2', author: bob),
          revisionOf(id: 'r1', author: ada),
        ]),
        isTrue,
      );
    });

    test('counts a missing author as its own', () {
      expect(
        historyHasMultipleAuthors([
          revisionOf(id: 'r2'),
          revisionOf(id: 'r1', author: ada),
        ]),
        isTrue,
      );
    });
  });

  test('revisionAuthorName says You for the reader', () {
    final revision = revisionOf(id: 'r1', author: ada);

    expect(revisionAuthorName(revision, 'u1'), 'You');
    expect(revisionAuthorName(revision, 'u2'), 'Ada');
    expect(revisionAuthorName(revisionOf(id: 'r1'), 'u1'), 'Someone');
  });

  group('day labels', () {
    final now = DateTime(2026, 8, 18, 15);

    test('names today, yesterday and older days', () {
      expect(dayLabel(DateTime(2026, 8, 18, 9), now), 'Today');
      expect(dayLabel(DateTime(2026, 8, 17, 23), now), 'Yesterday');
      expect(dayLabel(DateTime(2026, 8, 2), now), 'August 2, 2026');
    });

    test('reads a version as a day and a time', () {
      final revision = revisionOf(
        id: 'r1',
        createdAt: DateTime(2026, 8, 18, 16, 5),
      );

      expect(revisionDayTime(revision, now: now), 'Today at 4:05 PM');
      expect(revisionTime(revision), '4:05 PM');
    });
  });

  test('groupRevisionsByDay keeps the order and splits on the day', () {
    final now = DateTime(2026, 8, 18, 15);
    final days = groupRevisionsByDay([
      revisionOf(id: 'r3', createdAt: DateTime(2026, 8, 18, 10)),
      revisionOf(id: 'r2', createdAt: DateTime(2026, 8, 18, 9)),
      revisionOf(id: 'r1', createdAt: DateTime(2026, 8, 17, 9)),
    ], now: now);

    expect(days.map((day) => day.label), ['Today', 'Yesterday']);
    expect(days.first.revisions.map((r) => r.id), ['r3', 'r2']);
    expect(days.last.revisions.map((r) => r.id), ['r1']);
  });

  test('only unusual versions carry a hint', () {
    expect(revisionHint(RevisionCause.edit), isNull);
    expect(revisionHint(RevisionCause.conflict), isNotNull);
    expect(revisionLabel(RevisionCause.restore), 'Before a restore');
  });
}
