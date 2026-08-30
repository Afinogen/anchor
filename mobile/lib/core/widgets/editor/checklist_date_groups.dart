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
