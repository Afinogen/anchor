import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anchor/features/notes/domain/note.dart';
import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:anchor/core/widgets/confirm_dialog.dart';
import 'package:anchor/core/widgets/quill_preview.dart'
    show extractPlainTextFromQuillContent;
import 'package:anchor/core/widgets/app_snackbar.dart';
import 'package:anchor/features/tags/presentation/widgets/tag_selector.dart';
import '../notes_controller.dart';

class SelectionAppBarActions extends ConsumerWidget {
  final Set<String> selectedNoteIds;
  final VoidCallback onExitSelectionMode;

  const SelectionAppBarActions({
    super.key,
    required this.selectedNoteIds,
    required this.onExitSelectionMode,
  });

  Future<void> _handleArchive(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        icon: LucideIcons.archive,
        iconColor: theme.colorScheme.primary,
        title: context.l10n.archiveNotesTitle,
        message: context.l10n.archiveNotesConfirm(ids.length),
        cancelText: context.l10n.cancel,
        confirmText: context.l10n.archive,
        onConfirm: () {},
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref.read(notesControllerProvider.notifier).bulkArchiveNotes(ids);
        onExitSelectionMode();
        if (context.mounted) {
          AppSnackbar.showSuccess(
            context,
            message: context.l10n.notesArchived(ids.length),
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(
            context,
            message: context.l10n.failedToArchiveNotes,
          );
        }
      }
    }
  }

  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        icon: LucideIcons.trash2,
        iconColor: theme.colorScheme.error,
        title: context.l10n.deleteNotesTitle,
        message: context.l10n.deleteNotesConfirm(ids.length),
        cancelText: context.l10n.cancel,
        confirmText: context.l10n.delete,
        onConfirm: () {},
      ),
    );
    if (confirmed == true && context.mounted) {
      try {
        await ref.read(notesControllerProvider.notifier).bulkDeleteNotes(ids);
        onExitSelectionMode();
        if (context.mounted) {
          AppSnackbar.showSuccess(
            context,
            message: context.l10n.notesDeleted(ids.length),
          );
        }
      } catch (e) {
        if (context.mounted) {
          AppSnackbar.showError(
            context,
            message: context.l10n.failedToDeleteNotes,
          );
        }
      }
    }
  }

  Future<void> _handlePin(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
    bool isPinned,
  ) async {
    try {
      await ref
          .read(notesControllerProvider.notifier)
          .bulkSetPinned(ids, isPinned);
      onExitSelectionMode();
      if (context.mounted) {
        AppSnackbar.showSuccess(
          context,
          message: isPinned
              ? context.l10n.notesPinned(ids.length)
              : context.l10n.notesUnpinned(ids.length),
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(
          context,
          message: context.l10n.failedToUpdatePins,
        );
      }
    }
  }

  Future<void> _handleTags(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) async {
    // TagPickerSheet reports the running selection; capture the latest set
    // and merge it into the notes once the sheet is dismissed.
    final selectedTagIds = <String>[];
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TagPickerSheet(
        selectedTagIds: const [],
        onTagsChanged: (tagIds) {
          selectedTagIds
            ..clear()
            ..addAll(tagIds);
        },
      ),
    );

    if (selectedTagIds.isEmpty || !context.mounted) return;

    try {
      await ref
          .read(notesControllerProvider.notifier)
          .bulkAddTags(ids, selectedTagIds);
      onExitSelectionMode();
      if (context.mounted) {
        AppSnackbar.showSuccess(
          context,
          message: context.l10n.notesTagged(ids.length),
        );
      }
    } catch (e) {
      if (context.mounted) {
        AppSnackbar.showError(context, message: context.l10n.failedToAddTags);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesControllerProvider);
    final query = ref.watch(searchQueryProvider);
    final theme = Theme.of(context);

    final filteredNotes = notes.maybeWhen(
      data: (notesList) {
        return notesList.where((note) {
          if (query.isEmpty) return true;
          final q = query.toLowerCase();
          final contentText = extractPlainTextFromQuillContent(
            note.content,
          ).toLowerCase();
          return note.title.toLowerCase().contains(q) ||
              contentText.contains(q);
        }).toList();
      },
      orElse: () => <Note>[],
    );

    final allSelected =
        filteredNotes.isNotEmpty &&
        selectedNoteIds.length == filteredNotes.length;

    // When every selected note is already pinned, the toggle unpins instead.
    final selectedNotes = filteredNotes
        .where((note) => selectedNoteIds.contains(note.id))
        .toList();
    final allSelectedPinned =
        selectedNotes.isNotEmpty && selectedNotes.every((n) => n.isPinned);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Add tags button
        if (selectedNoteIds.isNotEmpty)
          IconButton(
            icon: const Icon(LucideIcons.tag),
            onPressed: () => _handleTags(context, ref, selectedNoteIds.toList()),
            tooltip: context.l10n.addTags,
          ),
        // Pin / unpin toggle
        if (selectedNoteIds.isNotEmpty)
          IconButton(
            icon: Icon(
              allSelectedPinned ? LucideIcons.pinOff : LucideIcons.pin,
            ),
            onPressed: () => _handlePin(
              context,
              ref,
              selectedNoteIds.toList(),
              !allSelectedPinned,
            ),
            tooltip: allSelectedPinned ? context.l10n.unpin : context.l10n.pin,
          ),
        // Archive button
        if (selectedNoteIds.isNotEmpty)
          IconButton(
            icon: const Icon(LucideIcons.archive),
            onPressed: () =>
                _handleArchive(context, ref, selectedNoteIds.toList()),
            tooltip: context.l10n.archive,
          ),
        // Delete button
        if (selectedNoteIds.isNotEmpty)
          IconButton(
            icon: const Icon(LucideIcons.trash2),
            onPressed: () =>
                _handleDelete(context, ref, selectedNoteIds.toList()),
            tooltip: context.l10n.delete,
            color: theme.colorScheme.error,
          ),
        // Select all button
        IconButton(
          icon: Icon(
            allSelected ? LucideIcons.checkSquare : LucideIcons.square,
          ),
          onPressed: () {
            if (allSelected) {
              ref.read(selectedNoteIdsProvider.notifier).clear();
            } else {
              ref
                  .read(selectedNoteIdsProvider.notifier)
                  .selectAll(filteredNotes.map((n) => n.id).toList());
            }
          },
          tooltip: allSelected ? context.l10n.deselectAll : context.l10n.selectAll,
        ),
      ],
    );
  }
}
