import 'dart:convert';

import 'package:anchor/features/notes/domain/note_diff.dart';
import 'package:flutter_test/flutter_test.dart';

String delta(List<Map<String, dynamic>> ops) => jsonEncode({'ops': ops});

List<String> textsOf(ContentDiff diff, DiffKind kind) => diff.lines
    .where((line) => line.kind == kind)
    .map((line) => line.text)
    .toList();

void main() {
  group('diffNoteContent', () {
    test('marks the lines that came and went', () {
      final before = delta([
        {'insert': 'milk\nbread\n'},
      ]);
      final after = delta([
        {'insert': 'milk\neggs\n'},
      ]);

      final diff = diffNoteContent(before, after);

      expect(textsOf(diff, DiffKind.same), ['milk']);
      expect(textsOf(diff, DiffKind.removed), ['bread']);
      expect(textsOf(diff, DiffKind.added), ['eggs']);
      expect(diff.removed, 1);
      expect(diff.added, 1);
      expect(diff.isUnchanged, isFalse);
    });

    test('sees a ticked box as a change', () {
      final before = delta([
        {'insert': 'milk'},
        {
          'insert': '\n',
          'attributes': {'list': 'unchecked'},
        },
      ]);
      final after = delta([
        {'insert': 'milk'},
        {
          'insert': '\n',
          'attributes': {'list': 'checked'},
        },
      ]);

      final diff = diffNoteContent(before, after);

      expect(diff.added, 1);
      expect(diff.removed, 1);
    });

    test('sees a line turned into a heading as a change', () {
      final before = delta([
        {'insert': 'Plans\n'},
      ]);
      final after = delta([
        {'insert': 'Plans'},
        {
          'insert': '\n',
          'attributes': {'header': 2},
        },
      ]);

      final diff = diffNoteContent(before, after);

      expect(diff.added, 1);
      expect(diff.removed, 1);
    });

    test('reads a bolded word as the same line', () {
      final before = delta([
        {'insert': 'buy milk\n'},
      ]);
      final after = delta([
        {'insert': 'buy '},
        {
          'insert': 'milk',
          'attributes': {'bold': true},
        },
        {'insert': '\n'},
      ]);

      final diff = diffNoteContent(before, after);

      expect(diff.isUnchanged, isTrue);
      expect(textsOf(diff, DiffKind.same), ['buy milk']);
    });

    test('carries a line formatting through for drawing', () {
      final content = delta([
        {'insert': 'buy '},
        {
          'insert': 'milk',
          'attributes': {'bold': true},
        },
        {
          'insert': '\n',
          'attributes': {'list': 'bullet', 'indent': 1},
        },
      ]);

      final line = diffNoteContent(content, content).lines.single;

      expect(line.listType, 'bullet');
      expect(line.indent, 1);
      expect(line.spans.map((span) => span.text), ['buy ', 'milk']);
      expect(line.spans.first.isBold, isFalse);
      expect(line.spans.last.isBold, isTrue);
    });

    test('reads a quote and a code block off the line', () {
      final content = delta([
        {'insert': 'stay calm'},
        {
          'insert': '\n',
          'attributes': {'blockquote': true},
        },
        {'insert': 'print(1)'},
        {
          'insert': '\n',
          'attributes': {'code-block': true},
        },
      ]);

      final lines = diffNoteContent(content, content).lines;

      expect(lines[0].block, LineBlock.quote);
      expect(lines[1].block, LineBlock.code);
    });

    test('drops blank lines and unreadable content', () {
      final content = delta([
        {'insert': 'milk\n\n   \nbread\n'},
      ]);

      expect(diffNoteContent(content, content).lines.map((line) => line.text), [
        'milk',
        'bread',
      ]);
      expect(diffNoteContent('not json', null).lines, isEmpty);
      expect(diffNoteContent(null, null).lines, isEmpty);
    });

    test('reads an empty note against a written one as all added', () {
      final after = delta([
        {'insert': 'milk\nbread\n'},
      ]);

      final diff = diffNoteContent(null, after);

      expect(textsOf(diff, DiffKind.added), ['milk', 'bread']);
      expect(diff.removed, 0);
    });
  });
}
