import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anchor/features/notes/domain/note.dart';
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
        title: 'Unarchive Note',
        message: 'This note will be moved back to your notes.',
        cancelText: 'Cancel',
        confirmText: 'Unarchive',
        onConfirm: () async {
          try {
            await ref
                .read(archiveControllerProvider.notifier)
                .unarchiveNote(note.id);
            if (context.mounted) {
              AppSnackbar.showSuccess(context, message: 'Note unarchived');
            }
          } catch (e) {
            if (context.mounted) {
              AppSnackbar.showError(
                context,
                message: 'Failed to unarchive note',
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
      title: 'Archive',
      notes: ref.watch(archiveControllerProvider),
      emptyIcon: LucideIcons.archive,
      emptyMessage: 'Archive is empty',
      datePrefix: 'Archived',
      trailingActions: (note) => [
        IconButton(
          icon: const Icon(LucideIcons.archiveRestore),
          onPressed: () => _showUnarchiveDialog(context, ref, note),
          tooltip: 'Unarchive',
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
