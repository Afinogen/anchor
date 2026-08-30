import 'package:flutter_quill/flutter_quill.dart';

import 'checklist_lines.dart';

/// Bare `DD.MM.YYYY` — the form this module writes.
final _bareDate = RegExp(r'^(\d{1,2})\.(\d{1,2})\.(\d{4})$');

/// Hand-written divider: `----- DD.MM.YYYY -------`.
final _dashedDate = RegExp(r'^-{2,}\s*(\d{1,2})\.(\d{1,2})\.(\d{4})\s*-{2,}$');

/// `DD.MM.YYYY` of a local date. Locale-independent on purpose: clients in
/// different languages must produce the same key for the same day.
String formatDateKey(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  return '$day.$month.${date.year}';
}

/// Normalised `DD.MM.YYYY` key of a header text, or null when the text is not
/// a date header. Recognition is by text alone — bold is cosmetic and applied
/// only on write, so hand-written dividers count as headers too.
String? parseDateHeaderText(String text) {
  final trimmed = text.trim();
  final match = _bareDate.firstMatch(trimmed) ?? _dashedDate.firstMatch(trimmed);
  if (match == null) return null;
  final day = match.group(1)!.padLeft(2, '0');
  final month = match.group(2)!.padLeft(2, '0');
  return '$day.$month.${match.group(3)}';
}

/// Plain text of [line], without the trailing newline.
String lineText(Document document, ParsedLine line) =>
    line.length <= 1
        ? ''
        : document.getPlainText(line.startOffset, line.length - 1);

/// Key of the date header at [index], or null when that line is not one.
String? dateHeaderKey(
  Document document,
  List<ParsedLine> lines,
  int index,
) {
  final line = lines[index];
  if (line.listType != null) return null;
  if (line.indent != 0) return null;
  return parseDateHeaderText(lineText(document, line));
}

/// `YYYYMMDD` — a key that compares chronologically as a string.
String sortableDateKey(String key) {
  final parts = key.split('.');
  return '${parts[2]}${parts[1]}${parts[0]}';
}

/// Bounds of the checklist group containing [index] as `(start, end)`: the run
/// of checklist lines around it, extended over date headers that are directly
/// followed by a checklist line. A trailing header belongs to the text below,
/// not to the group.
(int, int) dateGroupBounds(
  Document document,
  List<ParsedLine> lines,
  int index,
) {
  var start = index;
  while (start > 0) {
    if (lines[start - 1].isChecklist) {
      start--;
      continue;
    }
    if (dateHeaderKey(document, lines, start - 1) != null &&
        lines[start].isChecklist) {
      start--;
      continue;
    }
    break;
  }

  var end = index;
  while (end < lines.length - 1) {
    if (lines[end + 1].isChecklist) {
      end++;
      continue;
    }
    if (end + 2 < lines.length &&
        dateHeaderKey(document, lines, end + 1) != null &&
        lines[end + 2].isChecklist) {
      end++;
      continue;
    }
    break;
  }

  return (start, end);
}

/// An item of the rebuilt group: an existing line, or a header to write.
sealed class GroupItem {
  const GroupItem();
}

/// A line already in the document, by index into the parsed lines.
class ExistingLine extends GroupItem {
  final int index;

  const ExistingLine(this.index);

  @override
  bool operator ==(Object other) =>
      other is ExistingLine && other.index == index;

  @override
  int get hashCode => index.hashCode;

  @override
  String toString() => 'ExistingLine($index)';
}

/// A header that has to be written, by date key.
class NewHeader extends GroupItem {
  final String key;

  const NewHeader(this.key);

  @override
  bool operator ==(Object other) => other is NewHeader && other.key == key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() => 'NewHeader($key)';
}

/// Target contents of the group [groupStart]..[groupEnd] after the block at
/// [toggledIndex] was toggled: unchecked blocks first, then date sections
/// newest first, then checked blocks that never had a header. The toggled
/// block is dated [today] and sits last within its section.
///
/// Children of a block keep their document order — a toggle at the top level
/// has no business reshuffling nesting the user did not touch.
List<GroupItem> dateGroupedItems(
  Document document,
  List<ParsedLine> lines,
  int groupStart,
  int groupEnd,
  int toggledIndex,
  String today,
) {
  final unchecked = <(int, int)>[];
  final dated = <String, List<(int, int)>>{};
  final undated = <(int, int)>[];
  // Existing header line per date key, so its text survives untouched.
  final headerLine = <String, int>{};
  (int, int)? toggled;
  String? currentDate;

  var i = groupStart;
  while (i <= groupEnd) {
    final header = dateHeaderKey(document, lines, i);
    if (header != null) {
      currentDate = header;
      headerLine.putIfAbsent(header, () => i);
      i++;
      continue;
    }

    final block = (i, checklistBlockEnd(lines, i, groupEnd));
    if (i == toggledIndex) {
      toggled = block;
    } else if (lines[i].isChecked) {
      if (currentDate == null) {
        undated.add(block);
      } else {
        dated.putIfAbsent(currentDate, () => []).add(block);
      }
    } else {
      unchecked.add(block);
    }
    i = block.$2 + 1;
  }

  if (toggled != null) {
    if (lines[toggled.$1].isChecked) {
      dated.putIfAbsent(today, () => []).add(toggled);
    } else {
      unchecked.add(toggled);
    }
  }

  final items = <GroupItem>[];
  void pushBlock((int, int) block) {
    for (var i = block.$1; i <= block.$2; i++) {
      items.add(ExistingLine(i));
    }
  }

  unchecked.forEach(pushBlock);

  final keys = dated.keys.toList()
    ..sort((a, b) => sortableDateKey(b).compareTo(sortableDateKey(a)));
  for (final key in keys) {
    final source = headerLine[key];
    items.add(source == null ? NewHeader(key) : ExistingLine(source));
    dated[key]!.forEach(pushBlock);
  }

  undated.forEach(pushBlock);

  return items;
}
