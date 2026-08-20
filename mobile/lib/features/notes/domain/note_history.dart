import 'package:intl/intl.dart';

import 'note_revision.dart';

/// Revisions from one calendar day, newest first.
class HistoryDay {
  const HistoryDay({required this.label, required this.revisions});

  final String label;
  final List<NoteRevision> revisions;
}

/// Time of day a version was kept, e.g. "4:05 PM".
String revisionTime(NoteRevision revision) =>
    DateFormat('h:mm a').format(revision.createdAtLocal);

/// Day and time of a version, e.g. "Yesterday at 4:05 PM".
String revisionDayTime(NoteRevision revision, {DateTime? now}) =>
    dayTimeLabel(revision.createdAtLocal, now: now);

String dayTimeLabel(DateTime date, {DateTime? now}) {
  final local = date.toLocal();
  final day = dayLabel(local, now ?? DateTime.now());
  return '$day at ${DateFormat('h:mm a').format(local)}';
}

String dayLabel(DateTime date, DateTime now) {
  if (_isSameDay(date, now)) return 'Today';
  if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return 'Yesterday';
  }
  return DateFormat('MMMM d, yyyy').format(date);
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String revisionLabel(RevisionCause cause) => switch (cause) {
  RevisionCause.edit => 'Earlier version',
  RevisionCause.conflict => 'Not saved',
  RevisionCause.restore => 'Before a restore',
};

String? revisionHint(RevisionCause cause) => switch (cause) {
  RevisionCause.edit => null,
  RevisionCause.conflict => 'Not saved. The note had already changed.',
  RevisionCause.restore => 'What the note said before a restore.',
};

bool historyHasMultipleAuthors(List<NoteRevision> revisions) =>
    revisions
        .map((revision) => revision.author?.id ?? 'unknown')
        .toSet()
        .length >
    1;

String revisionAuthorName(NoteRevision revision, String? currentUserId) {
  final author = revision.author;
  if (author == null) return 'Someone';
  return author.id == currentUserId ? 'You' : author.name;
}

String revisionAuthorInitial(NoteRevisionAuthor? author) {
  final name = author?.name.trim() ?? '';
  return name.isEmpty ? '?' : name[0].toUpperCase();
}

/// The version a revision is read against: the next newer one that reached
/// the note, or null for the note as it is now. Conflicts never reached it,
/// so they are skipped as targets and always read against the note.
NoteRevision? comparisonTarget(
  List<NoteRevision> revisions,
  String revisionId,
) {
  final index = revisions.indexWhere((revision) => revision.id == revisionId);
  if (index < 0 || revisions[index].cause == RevisionCause.conflict) {
    return null;
  }

  for (var i = index - 1; i >= 0; i--) {
    if (revisions[i].cause != RevisionCause.conflict) return revisions[i];
  }
  return null;
}

List<HistoryDay> groupRevisionsByDay(
  List<NoteRevision> revisions, {
  DateTime? now,
}) {
  final today = now ?? DateTime.now();
  final days = <HistoryDay>[];
  DateTime? currentDate;

  for (final revision in revisions) {
    final date = revision.createdAtLocal;
    if (currentDate != null && _isSameDay(currentDate, date)) {
      days.last.revisions.add(revision);
      continue;
    }
    currentDate = date;
    days.add(HistoryDay(label: dayLabel(date, today), revisions: [revision]));
  }

  return days;
}
