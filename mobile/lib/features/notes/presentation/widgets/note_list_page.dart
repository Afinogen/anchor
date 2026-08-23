import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:anchor/core/theme/context_extensions.dart';
import 'package:anchor/core/widgets/app_empty_state.dart';
import 'package:anchor/core/widgets/app_page_scaffold.dart';
import 'package:anchor/core/widgets/gradient_background.dart';
import 'package:anchor/features/notes/domain/note.dart';
import 'package:anchor/features/notes/presentation/widgets/note_card.dart';
import 'package:anchor/features/sync/presentation/sync_warning.dart';

/// A titled, back-navigable list of [NoteCard]s with per-row actions.
class NoteListPage extends StatelessWidget {
  const NoteListPage({
    super.key,
    required this.title,
    required this.notes,
    required this.emptyIcon,
    required this.emptyMessage,
    required this.datePrefix,
    required this.trailingActions,
  });

  final String title;
  final AsyncValue<List<Note>> notes;
  final IconData emptyIcon;
  final String emptyMessage;

  /// Prefix for the timestamp on each card, e.g. 'Archived'.
  final String datePrefix;

  /// Row actions for a given note, shown at the trailing edge of its card.
  final List<Widget> Function(Note note) trailingActions;

  @override
  Widget build(BuildContext context) {
    return AppPageScaffold(
      title: Text(title),
      wash: PageWash.content,
      body: notes.when(
        data: (notes) {
          if (notes.isEmpty) {
            return AppEmptyState(icon: emptyIcon, message: emptyMessage);
          }
          final dims = context.dims;
          return ListView.builder(
            padding: dims.screenInsets.copyWith(
              top: AppPageScaffold.topInset(context) + dims.screenGutter,
            ),
            itemCount: notes.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) return const SyncWarning();
              final note = notes[index - 1];
              return Padding(
                padding: EdgeInsets.only(bottom: dims.listItemSpacing),
                child: NoteCard(
                  note: note,
                  datePrefix: datePrefix,
                  onTap: () => context.push('/note/${note.id}', extra: note),
                  trailingActions: trailingActions(note),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
