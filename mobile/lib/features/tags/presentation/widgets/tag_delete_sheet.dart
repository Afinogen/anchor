import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/context_extensions.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../domain/tag.dart';
import '../tags_controller.dart';

/// Confirmation sheet that deletes the tag and removes it from all notes.
class TagDeleteSheet extends ConsumerWidget {
  const TagDeleteSheet({super.key, required this.tag});

  final Tag tag;

  static Future<void> show(BuildContext context, Tag tag) {
    return AppBottomSheet.show(
      context,
      builder: (_) => TagDeleteSheet(tag: tag),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dims = context.dims;

    return AppBottomSheet(
      contentPadding: EdgeInsets.fromLTRB(dims.xl, dims.xl, dims.xl, dims.xl),
      crossAxisAlignment: CrossAxisAlignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(dims.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              LucideIcons.alertTriangle,
              color: theme.colorScheme.error,
              size: 32,
            ),
          ),
          SizedBox(height: dims.lg),
          Text(
            'Delete Tag',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: dims.xs),
          Text(
            'Delete "${tag.name}"? This will remove it from all notes.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: dims.xl),
          SheetActionButtons(
            confirmText: 'Delete',
            isDestructive: true,
            onConfirm: () async {
              await ref.read(tagsControllerProvider.notifier).deleteTag(tag.id);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
