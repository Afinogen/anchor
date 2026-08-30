import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:anchor/features/tags/data/repository/tags_repository.dart';
import 'package:anchor/features/tags/domain/tag.dart';
import 'package:anchor/features/tags/presentation/widgets/tag_chip.dart';
import 'package:anchor/features/tags/presentation/widgets/tag_selector.dart';

class MockTagsRepository extends Mock implements TagsRepository {}

const _tag = Tag(id: 't1', name: 'ideas', color: '#64B5F6');

/// The selector stacked above a marker, so the marker's offset is exactly
/// how much room the selector took.
Future<double> _heightOf(
  WidgetTester tester, {
  required List<String> selectedTagIds,
  required bool readOnly,
  required List<Tag> tags,
}) async {
  final repo = MockTagsRepository();
  when(repo.watchTags).thenAnswer((_) => Stream.value(tags));

  await tester.pumpWidget(
    ProviderScope(
      overrides: [tagsRepositoryProvider.overrideWithValue(repo)],
      child: MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              TagSelector(
                selectedTagIds: selectedTagIds,
                readOnly: readOnly,
                onTagsChanged: (_) {},
              ),
              const SizedBox(key: Key('marker'), height: 1),
            ],
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return tester.getTopLeft(find.byKey(const Key('marker'))).dy;
}

void main() {
  testWidgets('read-only with no tags takes up no room', (tester) async {
    final height = await _heightOf(
      tester,
      selectedTagIds: const [],
      readOnly: true,
      tags: const [],
    );

    expect(height, 0);
    expect(find.byType(TagChip), findsNothing);
  });

  testWidgets('read-only holds the strip open while its tags load', (
    tester,
  ) async {
    final repo = MockTagsRepository();
    when(repo.watchTags).thenAnswer((_) => const Stream<List<Tag>>.empty());

    await tester.pumpWidget(
      ProviderScope(
        overrides: [tagsRepositoryProvider.overrideWithValue(repo)],
        child: MaterialApp(
          home: Scaffold(
            body: TagSelector(
              selectedTagIds: const ['t1'],
              readOnly: true,
              onTagsChanged: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(TagSelector)).height, greaterThan(0));
  });

  testWidgets('editing shows the add button with no tags selected', (
    tester,
  ) async {
    final height = await _heightOf(
      tester,
      selectedTagIds: const [],
      readOnly: false,
      tags: const [_tag],
    );

    expect(height, greaterThan(0));
    expect(find.text('Add tag'), findsOneWidget);
    expect(find.byType(TagChip), findsNothing);
  });

  testWidgets('a selected tag is drawn as a chip', (tester) async {
    await _heightOf(
      tester,
      selectedTagIds: const ['t1'],
      readOnly: true,
      tags: const [_tag],
    );

    expect(find.byType(TagChip), findsOneWidget);
    expect(find.text('ideas'), findsOneWidget);
  });
}
