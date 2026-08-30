import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:anchor/features/tags/domain/tag.dart';
import 'package:anchor/features/tags/presentation/widgets/tag_chip.dart';

const _longTag = Tag(
  id: 't1',
  name: 'a-very-long-tag-name-that-will-not-fit',
  color: '#64B5F6',
);

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('a long name is ellipsized inside a narrow parent', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 120,
          child: Wrap(children: const [TagChip(tag: _longTag)]),
        ),
      ),
    );

    expect(tester.takeException(), isNull);

    final text = tester.widget<Text>(find.text(_longTag.name));
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.getSize(find.byType(TagChip)).width, lessThanOrEqualTo(120));
  });

  testWidgets('a long name keeps its full width when scrolled horizontally', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SizedBox(
          width: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [TagChip(tag: _longTag)],
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(TagChip)).width, greaterThan(120));
  });
}
