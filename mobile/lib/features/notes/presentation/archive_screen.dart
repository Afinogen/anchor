import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anchor/features/notes/domain/note.dart';
import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:anchor/core/widgets/confirm_dialog.dart';
import 'package:anchor/core/widgets/app_snackbar.dart';
import 'package:anchor/features/notes/presentation/widgets/note_list_page.dart';
import 'notes_controller.dart';

class ArchiveScreen extends ConsumerWidget {
  const ArchiveScreen({super.key});

  void _showUnarchiveDialog(BuildContext context, WidgetRef ref, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        icon: LucideIcons.archiveRestore,
        iconColor: Theme.of(context).colorScheme.primary,
        title: context.l10n.unarchiveNoteTitle,
        message: context.l10n.noteMovedBack,
        cancelText: context.l10n.cancel,
        confirmText: context.l10n.unarchive,
        onConfirm: () async {
          try {
            await ref
                .read(archiveControllerProvider.notifier)
                .unarchiveNote(note.id);
            if (context.mounted) {
              AppSnackbar.showSuccess(
                context,
                message: context.l10n.noteUnarchived,
              );
            }
          } catch (e) {
            if (context.mounted) {
              AppSnackbar.showError(
                context,
                message: context.l10n.failedToUnarchive,
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
      title: context.l10n.archive,
      notes: ref.watch(archiveControllerProvider),
      emptyIcon: LucideIcons.archive,
      emptyMessage: context.l10n.archiveEmpty,
      datePrefix: context.l10n.archivedPrefix,
      trailingActions: (note) => [
        IconButton(
          icon: const Icon(LucideIcons.archiveRestore),
          onPressed: () => _showUnarchiveDialog(context, ref, note),
          tooltip: context.l10n.unarchive,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
