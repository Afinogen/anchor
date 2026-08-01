import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anchor/features/notes/domain/note.dart';
import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:anchor/core/widgets/confirm_dialog.dart';
import 'package:anchor/core/widgets/app_snackbar.dart';
import 'package:anchor/features/notes/presentation/widgets/note_card.dart';
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
    final trashAsync = ref.watch(trashControllerProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
        title: Text(
          context.l10n.trash,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: trashAsync.when(
          data: (notes) {
            if (notes.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(LucideIcons.trash2, size: 64, color: theme.hintColor),
                    const SizedBox(height: 16),
                    Text(
                      context.l10n.trashEmpty,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                final note = notes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NoteCard(
                    note: note,
                    datePrefix: context.l10n.movedToTrashPrefix,
                    onTap: () => context.push('/note/${note.id}', extra: note),
                    trailingActions: [
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
                        onPressed: () =>
                            _showPermanentDeleteDialog(context, ref, note),
                        tooltip: context.l10n.deleteForever,
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, stack) =>
              Center(child: Text(context.l10n.errorWithMessage(err.toString()))),
        ),
      ),
    );
  }
}
