import 'dart:convert';
import 'dart:typed_data';

enum DiffKind { same, added, removed }

enum LineBlock { quote, code }

/// A run of text on a line with the inline formatting it carries.
class DiffSpan {
  const DiffSpan({required this.text, this.attributes});

  final String text;
  final Map<String, dynamic>? attributes;

  bool _flag(String name) => attributes?[name] == true;

  bool get isBold => _flag('bold');
  bool get isItalic => _flag('italic');
  bool get isUnderline => _flag('underline');
  bool get isStrike => _flag('strike');
  bool get isCode => _flag('code');
  bool get isLink => attributes?['link'] != null;
}

class DiffLine {
  const DiffLine({
    required this.kind,
    required this.text,
    required this.spans,
    this.listType,
    this.indent = 0,
    this.header,
    this.block,
  });

  final DiffKind kind;
  final String text;
  final List<DiffSpan> spans;

  /// 'checked' | 'unchecked' | 'ordered' | 'bullet', or null for plain lines.
  final String? listType;
  final int indent;

  /// Heading level 1-3, or null.
  final int? header;
  final LineBlock? block;

  bool get isChecklist => listType == 'checked' || listType == 'unchecked';
  bool get isChecked => listType == 'checked';
  bool get isOrdered => listType == 'ordered';
  bool get isBullet => listType == 'bullet';

  DiffLine _as(DiffKind kind) => DiffLine(
    kind: kind,
    text: text,
    spans: spans,
    listType: listType,
    indent: indent,
    header: header,
    block: block,
  );
}

class ContentDiff {
  const ContentDiff({
    required this.lines,
    required this.added,
    required this.removed,
  });

  final List<DiffLine> lines;
  final int added;
  final int removed;

  bool get isUnchanged => added == 0 && removed == 0;
}

const int _maxDiffCells = 1000000;

/// Lines of [before] against [after], newest text on top of what it replaced.
ContentDiff diffNoteContent(String? before, String? after) {
  final a = contentLines(before);
  final b = contentLines(after);
  final aKeys = a.map(_keyOf).toList();
  final bKeys = b.map(_keyOf).toList();

  var head = 0;
  while (head < a.length && head < b.length && aKeys[head] == bKeys[head]) {
    head++;
  }

  var tail = 0;
  while (tail < a.length - head &&
      tail < b.length - head &&
      aKeys[a.length - 1 - tail] == bKeys[b.length - 1 - tail]) {
    tail++;
  }

  final lines = <DiffLine>[
    for (final line in a.sublist(0, head)) line._as(DiffKind.same),
    ..._diffMiddle(
      a.sublist(head, a.length - tail),
      b.sublist(head, b.length - tail),
      aKeys.sublist(head, a.length - tail),
      bKeys.sublist(head, b.length - tail),
    ),
    for (final line in b.sublist(b.length - tail)) line._as(DiffKind.same),
  ];

  return ContentDiff(
    lines: lines,
    added: lines.where((line) => line.kind == DiffKind.added).length,
    removed: lines.where((line) => line.kind == DiffKind.removed).length,
  );
}

List<DiffLine> _diffMiddle(
  List<DiffLine> a,
  List<DiffLine> b,
  List<String> aKeys,
  List<String> bKeys,
) {
  final removed = [for (final line in a) line._as(DiffKind.removed)];
  final added = [for (final line in b) line._as(DiffKind.added)];

  if (a.isEmpty) return added;
  if (b.isEmpty) return removed;
  if ((a.length + 1) * (b.length + 1) > _maxDiffCells) {
    return [...removed, ...added];
  }

  final width = b.length + 1;
  final lcs = Uint32List((a.length + 1) * width);
  for (var i = a.length - 1; i >= 0; i--) {
    for (var j = b.length - 1; j >= 0; j--) {
      lcs[i * width + j] = aKeys[i] == bKeys[j]
          ? lcs[(i + 1) * width + j + 1] + 1
          : (lcs[(i + 1) * width + j] > lcs[i * width + j + 1]
                ? lcs[(i + 1) * width + j]
                : lcs[i * width + j + 1]);
    }
  }

  final lines = <DiffLine>[];
  var i = 0;
  var j = 0;
  while (i < a.length && j < b.length) {
    if (aKeys[i] == bKeys[j]) {
      lines.add(a[i]._as(DiffKind.same));
      i++;
      j++;
    } else if (lcs[(i + 1) * width + j] >= lcs[i * width + j + 1]) {
      lines.add(removed[i]);
      i++;
    } else {
      lines.add(added[j]);
      j++;
    }
  }
  lines
    ..addAll(removed.sublist(i))
    ..addAll(added.sublist(j));

  return lines;
}

/// Identity of a line for comparison: text plus the formatting that reads as
/// a change. Inline formatting is left out.
String _keyOf(DiffLine line) => [
  line.listType ?? '',
  line.header ?? '',
  line.block?.name ?? '',
  line.indent,
  line.text,
].join(' ');

/// Non-empty lines of stored Quill content, each carrying its formatting.
List<DiffLine> contentLines(String? content) {
  final lines = <DiffLine>[];
  var spans = <DiffSpan>[];

  void closeLine(Map<String, dynamic>? attributes) {
    final text = spans.map((span) => span.text).join().trim();
    if (text.isNotEmpty) {
      lines.add(
        DiffLine(
          kind: DiffKind.same,
          text: text,
          spans: spans,
          listType: _listTypeOf(attributes?['list']),
          indent: attributes?['indent'] is int
              ? attributes!['indent'] as int
              : 0,
          header: _headerOf(attributes?['header']),
          block: _blockOf(attributes),
        ),
      );
    }
    spans = <DiffSpan>[];
  }

  for (final op in _opsOf(content)) {
    if (op is! Map) continue;
    final insert = op['insert'];
    final attributes = op['attributes'] is Map
        ? Map<String, dynamic>.from(op['attributes'] as Map)
        : null;

    if (insert is! String) continue;
    if (!insert.contains('\n')) {
      if (insert.isNotEmpty) {
        spans.add(DiffSpan(text: insert, attributes: attributes));
      }
      continue;
    }

    final parts = insert.split('\n');
    for (var i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) {
        spans.add(DiffSpan(text: parts[i], attributes: attributes));
      }
      if (i < parts.length - 1) closeLine(attributes);
    }
  }
  closeLine(null);

  return lines;
}

List<dynamic> _opsOf(String? content) {
  if (content == null || content.isEmpty) return const [];
  try {
    final parsed = jsonDecode(content);
    if (parsed is Map && parsed['ops'] is List) return parsed['ops'] as List;
  } catch (_) {
    // Anything unreadable is treated as empty content.
  }
  return const [];
}

String? _listTypeOf(dynamic value) {
  return value == 'checked' ||
          value == 'unchecked' ||
          value == 'ordered' ||
          value == 'bullet'
      ? value as String
      : null;
}

int? _headerOf(dynamic value) =>
    value == 1 || value == 2 || value == 3 ? value as int : null;

LineBlock? _blockOf(Map<String, dynamic>? attributes) {
  if (attributes == null) return null;
  if (attributes['blockquote'] == true) return LineBlock.quote;
  if (attributes['code-block'] != null && attributes['code-block'] != false) {
    return LineBlock.code;
  }
  return null;
}
