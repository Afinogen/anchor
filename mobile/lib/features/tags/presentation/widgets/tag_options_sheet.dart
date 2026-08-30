import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/context_extensions.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../domain/tag.dart';

enum TagSheetAction { rename, delete }

/// Long-press menu for a tag. Pops with the chosen [TagSheetAction] so the
/// caller can present the follow-up sheet.
class TagOptionsSheet extends StatelessWidget {
  const TagOptionsSheet({super.key, required this.tag});

  final Tag tag;

  static Future<TagSheetAction?> show(BuildContext context, Tag tag) {
    return AppBottomSheet.show<TagSheetAction>(
      context,
      builder: (_) => TagOptionsSheet(tag: tag),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;
    final tagColor = parseTagColor(
      tag.color,
      fallback: theme.colorScheme.primary,
    );

    return AppBottomSheet(
      icon: LucideIcons.hash,
      iconColor: tagColor,
      title: tag.name,
      subtitle: '${tag.noteCount} notes',
      contentPadding: EdgeInsets.fromLTRB(dims.xl, 0, dims.xl, dims.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SheetAction(
            icon: LucideIcons.pencil,
            label: 'Rename tag',
            onTap: () => Navigator.pop(context, TagSheetAction.rename),
          ),
          SizedBox(height: dims.xs),
          _SheetAction(
            icon: LucideIcons.trash2,
            label: 'Delete tag',
            isDestructive: true,
            onTap: () => Navigator.pop(context, TagSheetAction.delete),
          ),
        ],
      ),
    );
  }
}

class _SheetAction extends StatelessWidget {
  const _SheetAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return Material(
      color: Colors.transparent,
      borderRadius: AppRadius.buttonBorder,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.buttonBorder,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: context.dims.md,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
            borderRadius: AppRadius.buttonBorder,
            border: Border.all(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppIconSizes.md,
                color: color.withValues(alpha: 0.8),
              ),
              const SizedBox(width: 14),
              Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Icon(
                LucideIcons.chevronRight,
                size: 18,
                color: color.withValues(alpha: 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
