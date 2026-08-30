import 'package:anchor/core/widgets/editor/checklist_date_groups.dart';
import 'package:anchor/core/widgets/editor/checklist_lines.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

/// Document from (text, listType) lines; listType null = plain paragraph.
Document makeDocument(List<(String, String?)> lines) {
  final delta = Delta();
  for (final (text, list) in lines) {
    if (text.isNotEmpty) delta.insert(text);
    delta.insert('\n', list == null ? null : {'list': list});
  }
  return Document.fromDelta(delta);
}

void main() {
  group('formatDateKey', () {
    test('pads day and month to two digits', () {
      expect(formatDateKey(DateTime(2026, 8, 9)), '09.08.2026');
      expect(formatDateKey(DateTime(2026, 12, 31)), '31.12.2026');
    });
  });

  group('parseDateHeaderText', () {
    test('reads the bare form', () {
      expect(parseDateHeaderText('30.08.2026'), '30.08.2026');
    });

    test('reads the hand-written dashed form', () {
      expect(parseDateHeaderText('----- 29.08.2026 -------'), '29.08.2026');
    });

    test('normalises one-digit day and month', () {
      expect(parseDateHeaderText('9.8.2026'), '09.08.2026');
    });

    test('rejects anything else', () {
      expect(parseDateHeaderText(''), isNull);
      expect(parseDateHeaderText('купить шины 30.08.2026'), isNull);
      expect(parseDateHeaderText('30.08.26'), isNull);
      expect(parseDateHeaderText('- 30.08.2026 -'), isNull);
    });
  });

  group('dateHeaderKey', () {
    test('accepts a plain top-level date line', () {
      final doc = makeDocument([('a', 'unchecked'), ('30.08.2026', null)]);
      final lines = parseDocumentLines(doc);
      expect(dateHeaderKey(doc, lines, 1), '30.08.2026');
    });

    test('rejects a list line', () {
      final doc = makeDocument([('30.08.2026', 'checked')]);
      final lines = parseDocumentLines(doc);
      expect(dateHeaderKey(doc, lines, 0), isNull);
    });

    test('handles an empty line', () {
      final doc = makeDocument([('', null), ('a', 'unchecked')]);
      final lines = parseDocumentLines(doc);
      expect(dateHeaderKey(doc, lines, 0), isNull);
    });
  });

  group('sortableDateKey', () {
    test('orders keys chronologically as strings', () {
      final keys = ['29.08.2026', '31.12.2025', '01.09.2026']
        ..sort((a, b) => sortableDateKey(a).compareTo(sortableDateKey(b)));
      expect(keys, ['31.12.2025', '29.08.2026', '01.09.2026']);
    });
  });

  group('dateGroupBounds', () {
    test('covers a plain contiguous checklist', () {
      final doc = makeDocument([
        ('intro', null),
        ('a', 'unchecked'),
        ('b', 'checked'),
        ('outro', null),
      ]);
      expect(dateGroupBounds(doc, parseDocumentLines(doc), 1), (1, 2));
    });

    test('extends over a date header followed by a checklist line', () {
      final doc = makeDocument([
        ('a', 'unchecked'),
        ('30.08.2026', null),
        ('b', 'checked'),
      ]);
      expect(dateGroupBounds(doc, parseDocumentLines(doc), 0), (0, 2));
    });

    test('stops before a trailing header with nothing under it', () {
      final doc = makeDocument([
        ('a', 'unchecked'),
        ('30.08.2026', null),
        ('some note', null),
      ]);
      expect(dateGroupBounds(doc, parseDocumentLines(doc), 0), (0, 0));
    });

    test('walks up from a line below a header', () {
      final doc = makeDocument([
        ('a', 'unchecked'),
        ('30.08.2026', null),
        ('b', 'checked'),
      ]);
      expect(dateGroupBounds(doc, parseDocumentLines(doc), 2), (0, 2));
    });
  });

  group('dateGroupedItems', () {
    List<GroupItem> layout(
      List<(String, String?)> source,
      int toggled,
      String today,
    ) {
      final doc = makeDocument(source);
      final lines = parseDocumentLines(doc);
      final (start, end) = dateGroupBounds(doc, lines, toggled);
      return dateGroupedItems(doc, lines, start, end, toggled, today);
    }

    test("creates today's header for the toggled item", () {
      expect(
        layout([('a', 'unchecked'), ('b', 'checked')], 1, '30.08.2026'),
        [
          const ExistingLine(0),
          const NewHeader('30.08.2026'),
          const ExistingLine(1),
        ],
      );
    });

    test('reuses an existing header for the same day', () {
      expect(
        layout([
          ('a', 'unchecked'),
          ('30.08.2026', null),
          ('b', 'checked'),
          ('c', 'checked'),
        ], 3, '30.08.2026'),
        [
          const ExistingLine(0),
          const ExistingLine(1),
          const ExistingLine(2),
          const ExistingLine(3),
        ],
      );
    });

    test('orders dates newest first, under the unchecked items', () {
      expect(
        layout([
          ('29.08.2026', null),
          ('old', 'checked'),
          ('a', 'unchecked'),
          ('new', 'checked'),
        ], 3, '30.08.2026'),
        [
          const ExistingLine(2),
          const NewHeader('30.08.2026'),
          const ExistingLine(3),
          const ExistingLine(0),
          const ExistingLine(1),
        ],
      );
    });

    test('drops a header left with nothing under it', () {
      expect(
        layout([
          ('a', 'unchecked'),
          ('29.08.2026', null),
          ('b', 'unchecked'),
        ], 2, '30.08.2026'),
        [const ExistingLine(0), const ExistingLine(2)],
      );
    });

    test('keeps undated checked items as a tail below every date', () {
      expect(
        layout([
          ('a', 'unchecked'),
          ('stale', 'checked'),
          ('fresh', 'checked'),
        ], 2, '30.08.2026'),
        [
          const ExistingLine(0),
          const NewHeader('30.08.2026'),
          const ExistingLine(2),
          const ExistingLine(1),
        ],
      );
    });
  });

  group('buildChecklistDateGroupDelta', () {
    /// Applies the delta and reads back (text, listType, bold) per line.
    List<(String, String?, bool)> applied(
      List<(String, String?)> source,
      int toggled,
      String today,
    ) {
      final doc = makeDocument(source);
      final move = buildChecklistDateGroupDelta(doc, toggled, today);
      expect(move, isNotNull);
      final result = Document.fromDelta(doc.toDelta().compose(move!));
      final lines = parseDocumentLines(result);
      final out = <(String, String?, bool)>[];
      for (var i = 0; i < lines.length; i++) {
        final text = lineText(result, lines[i]);
        final bold = result
            .toDelta()
            .slice(lines[i].startOffset, lines[i].startOffset + lines[i].length - 1)
            .toList()
            .any((op) => op.attributes?['bold'] == true);
        out.add((text, lines[i].listType, bold));
      }
      return out;
    }

    test("writes today's header in bold above the checked item", () {
      expect(
        applied([('a', 'unchecked'), ('b', 'checked')], 1, '30.08.2026'),
        [
          ('a', 'unchecked', false),
          ('30.08.2026', null, true),
          ('b', 'checked', false),
        ],
      );
    });

    test('moves the checked item under an existing header', () {
      expect(
        applied([
          ('a', 'checked'),
          ('30.08.2026', null),
          ('done', 'checked'),
        ], 0, '30.08.2026'),
        [
          ('30.08.2026', null, false),
          ('done', 'checked', false),
          ('a', 'checked', false),
        ],
      );
    });

    test('removes a header left empty by unchecking', () {
      expect(
        applied([
          ('a', 'unchecked'),
          ('30.08.2026', null),
          ('b', 'unchecked'),
        ], 2, '31.08.2026'),
        [('a', 'unchecked', false), ('b', 'unchecked', false)],
      );
    });

    test('handles a group that ends the document', () {
      expect(
        applied([('a', 'checked'), ('b', 'unchecked')], 0, '30.08.2026'),
        [
          ('b', 'unchecked', false),
          ('30.08.2026', null, true),
          ('a', 'checked', false),
        ],
      );
    });

    test('returns null when the layout is already right', () {
      final doc = makeDocument([
        ('a', 'unchecked'),
        ('30.08.2026', null),
        ('b', 'checked'),
      ]);
      expect(buildChecklistDateGroupDelta(doc, 2, '30.08.2026'), isNull);
    });

    test('returns null for a nested item', () {
      final delta = Delta()
        ..insert('parent')
        ..insert('\n', {'list': 'unchecked'})
        ..insert('child')
        ..insert('\n', {'list': 'checked', 'indent': 1});
      final doc = Document.fromDelta(delta);
      expect(buildChecklistDateGroupDelta(doc, 1, '30.08.2026'), isNull);
    });
  });
}
