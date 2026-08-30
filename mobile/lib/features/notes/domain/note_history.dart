import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import 'note_revision.dart';

/// Revisions from one calendar day, newest first.
class HistoryDay {
  const HistoryDay({required this.label, required this.revisions});

  final String label;
  final List<NoteRevision> revisions;
}

/// Time of day a version was kept, e.g. "4:05 PM".
///
/// [l10n] is optional so these helpers stay usable outside the widget tree
/// (and in tests); without it the English wording and format are used.
String revisionTime(NoteRevision revision, {AppLocalizations? l10n}) =>
    _timeOfDay(revision.createdAtLocal, l10n);

/// CLDR puts a narrow no-break space before AM/PM; upstream rendered a plain
/// one and the tests assert it, so normalize back.
String _timeOfDay(DateTime local, AppLocalizations? l10n) =>
    DateFormat.jm(l10n?.localeName).format(local).replaceAll('\u202f', ' ');

/// Day and time of a version, e.g. "Yesterday at 4:05 PM".
String revisionDayTime(
  NoteRevision revision, {
  DateTime? now,
  AppLocalizations? l10n,
}) => dayTimeLabel(revision.createdAtLocal, now: now, l10n: l10n);

String dayTimeLabel(DateTime date, {DateTime? now, AppLocalizations? l10n}) {
  final local = date.toLocal();
  final day = dayLabel(local, now ?? DateTime.now(), l10n: l10n);
  final time = _timeOfDay(local, l10n);
  return l10n?.dayAtTime(day, time) ?? '$day at $time';
}

String dayLabel(DateTime date, DateTime now, {AppLocalizations? l10n}) {
  if (_isSameDay(date, now)) return l10n?.today ?? 'Today';
  if (_isSameDay(date, now.subtract(const Duration(days: 1)))) {
    return l10n?.yesterday ?? 'Yesterday';
  }
  return DateFormat.yMMMMd(l10n?.localeName).format(date);
}

bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

String revisionLabel(RevisionCause cause, {AppLocalizations? l10n}) =>
    switch (cause) {
      RevisionCause.edit => l10n?.revisionCauseEdit ?? 'Earlier version',
      RevisionCause.conflict => l10n?.revisionCauseConflict ?? 'Not saved',
      RevisionCause.restore => l10n?.revisionCauseRestore ?? 'Before a restore',
    };

String? revisionHint(RevisionCause cause, {AppLocalizations? l10n}) =>
    switch (cause) {
      RevisionCause.edit => null,
      RevisionCause.conflict =>
        l10n?.revisionHintConflict ??
            'Not saved. The note had already changed.',
      RevisionCause.restore =>
        l10n?.revisionHintRestore ?? 'What the note said before a restore.',
    };

bool historyHasMultipleAuthors(List<NoteRevision> revisions) =>
    revisions
        .map((revision) => revision.author?.id ?? 'unknown')
        .toSet()
        .length >
    1;

String revisionAuthorName(
  NoteRevision revision,
  String? currentUserId, {
  AppLocalizations? l10n,
}) {
  final author = revision.author;
  if (author == null) return l10n?.revisionAuthorSomeone ?? 'Someone';
  if (author.id == currentUserId) return l10n?.revisionAuthorYou ?? 'You';
  return author.name;
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
  AppLocalizations? l10n,
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
    days.add(
      HistoryDay(
        label: dayLabel(date, today, l10n: l10n),
        revisions: [revision],
      ),
    );
  }

  return days;
}
