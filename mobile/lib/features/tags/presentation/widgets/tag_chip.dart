import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../core/theme/tokens/app_durations.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../domain/tag.dart';

class TagChip extends StatelessWidget {
  final Tag tag;
  final bool selected;
  final bool showDelete;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TagChip({
    super.key,
    required this.tag,
    this.selected = false,
    this.showDelete = false,
    this.onTap,
    this.onDelete,
  });

  Color _getTagColor(BuildContext context) {
    return parseTagColor(
      tag.color,
      fallback: Theme.of(context).colorScheme.primary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _getTagColor(context);
    final theme = Theme.of(context);
    final dims = context.dims;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lgBorder,
        child: AnimatedContainer(
          duration: AppDurations.medium,
          padding: EdgeInsets.only(
            left: dims.sm,
            right: showDelete ? dims.xxs : dims.sm,
            top: 6,
            bottom: 6,
          ),
          decoration: BoxDecoration(
            color: selected
                ? color.withValues(alpha: 0.2)
                : color.withValues(alpha: 0.1),
            borderRadius: AppRadius.lgBorder,
            border: Border.all(
              color: selected ? color : color.withValues(alpha: 0.3),
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(LucideIcons.hash, size: AppIconSizes.xs, color: color),
              SizedBox(width: dims.xxs),
              Text(
                tag.name,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (showDelete) ...[
                SizedBox(width: dims.xxs),
                InkWell(
                  onTap: onDelete,
                  borderRadius: AppRadius.smBorder,
                  child: Padding(
                    padding: EdgeInsets.all(dims.xxs),
                    child: Icon(
                      LucideIcons.x,
                      size: AppIconSizes.xs,
                      color: color,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
