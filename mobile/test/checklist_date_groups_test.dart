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
}
