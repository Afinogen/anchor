import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../app_bottom_sheet.dart';

enum LinkAction { open, copy, edit, remove }

class LinkActionsSheet extends StatelessWidget {
  final String text;
  final String url;

  const LinkActionsSheet({super.key, required this.text, required this.url});

  static Future<LinkAction?> show(
    BuildContext context, {
    required String text,
    required String url,
  }) {
    return AppBottomSheet.show<LinkAction>(
      context,
      builder: (_) => LinkActionsSheet(text: text, url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = text.trim().isEmpty ? url : text;
    final showSubtitle = url.isNotEmpty && url != title;

    return AppBottomSheet(
      icon: LucideIcons.link,
      iconColor: theme.colorScheme.tertiary,
      title: title,
      subtitle: showSubtitle ? url : null,
      trailing: IconButton(
        icon: const Icon(LucideIcons.x, size: AppIconSizes.md),
        color: theme.colorScheme.onSurface.withValues(
          alpha: AppOpacity.secondary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Action(
            icon: LucideIcons.externalLink,
            label: 'Open',
            onTap: () => Navigator.pop(context, LinkAction.open),
          ),
          _Action(
            icon: LucideIcons.copy,
            label: 'Copy link',
            onTap: () => Navigator.pop(context, LinkAction.copy),
          ),
          _Action(
            icon: LucideIcons.pencil,
            label: 'Edit',
            onTap: () => Navigator.pop(context, LinkAction.edit),
          ),
          _Action(
            icon: LucideIcons.unlink,
            label: 'Remove',
            destructive: true,
            onTap: () => Navigator.pop(context, LinkAction.remove),
          ),
          SizedBox(height: context.dims.md),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool destructive;
  final VoidCallback onTap;

  const _Action({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;
    final color = destructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: dims.xl, vertical: dims.sm),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppIconSizes.md,
              color: color.withValues(alpha: AppOpacity.strong),
            ),
            SizedBox(width: dims.sm),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
