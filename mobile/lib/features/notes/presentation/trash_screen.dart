import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anchor/features/notes/domain/note.dart';
import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:anchor/core/widgets/confirm_dialog.dart';
import 'package:anchor/core/widgets/app_snackbar.dart';
import 'package:anchor/features/notes/presentation/widgets/note_list_page.dart';
import 'notes_controller.dart';

class TrashScreen extends ConsumerWidget {
  const TrashScreen({super.key});

  void _showRestoreDialog(BuildContext context, WidgetRef ref, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        icon: LucideIcons.rotateCcw,
        iconColor: Theme.of(context).colorScheme.primary,
        title: context.l10n.restoreNoteTitle,
        message: context.l10n.noteMovedBack,
        cancelText: context.l10n.cancel,
        confirmText: context.l10n.restore,
        onConfirm: () async {
          try {
            await ref
                .read(trashControllerProvider.notifier)
                .restoreNote(note.id);
            if (context.mounted) {
              AppSnackbar.showSuccess(
                context,
                message: context.l10n.noteRestored,
              );
            }
          } catch (_) {
            if (context.mounted) {
              AppSnackbar.showError(
                context,
                message: context.l10n.failedToRestore,
              );
            }
          }
        },
      ),
    );
  }

  void _showPermanentDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    Note note,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        icon: LucideIcons.trash2,
        iconColor: Theme.of(context).colorScheme.error,
        title: context.l10n.deleteForever,
        message: context.l10n.deleteForeverMessage,
        cancelText: context.l10n.cancel,
        confirmText: context.l10n.deleteForever,
        confirmColor: Theme.of(context).colorScheme.error,
        onConfirm: () async {
          try {
            await ref
                .read(trashControllerProvider.notifier)
                .permanentDelete(note.id);
            if (context.mounted) {
              AppSnackbar.showSuccess(
                context,
                message: context.l10n.notePermanentlyDeleted,
              );
            }
          } catch (_) {
            if (context.mounted) {
              AppSnackbar.showError(
                context,
                message: context.l10n.failedToDeleteNote,
              );
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return NoteListPage(
      title: context.l10n.trash,
      notes: ref.watch(trashControllerProvider),
      emptyIcon: LucideIcons.trash2,
      emptyMessage: context.l10n.trashEmpty,
      datePrefix: context.l10n.movedToTrashPrefix,
      trailingActions: (note) => [
        IconButton(
          icon: const Icon(LucideIcons.rotateCcw),
          onPressed: () => _showRestoreDialog(context, ref, note),
          tooltip: context.l10n.restore,
          visualDensity: VisualDensity.compact,
        ),
        IconButton(
          icon: Icon(
            LucideIcons.trash2,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: () => _showPermanentDeleteDialog(context, ref, note),
          tooltip: context.l10n.deleteForever,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
