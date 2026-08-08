import 'package:flutter/material.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_icon_sizes.dart';
import '../theme/tokens/app_radius.dart';

/// Shared chrome for modal bottom sheets: gradient surface, rounded top,
/// drag handle, and an optional icon/title header.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    this.icon,
    this.iconColor,
    this.title,
    this.subtitle,
    this.trailing,
    this.showDone = false,
    this.contentPadding = EdgeInsets.zero,
    this.maxHeightFactor,
    this.avoidKeyboard = false,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    required this.child,
  });

  final IconData? icon;

  /// Accent for the header icon chip; defaults to the primary color.
  final Color? iconColor;
  final String? title;
  final String? subtitle;
  final Widget? trailing;

  /// Shows a tonal "Done" button that pops the sheet.
  final bool showDone;
  final EdgeInsetsGeometry contentPadding;

  /// Caps the sheet at a fraction of screen height.
  final double? maxHeightFactor;

  /// Lifts the sheet above the keyboard (sheets with text input).
  final bool avoidKeyboard;
  final CrossAxisAlignment crossAxisAlignment;
  final Widget child;

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: builder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = context.colorTokens;
    final hasHeader = title != null || icon != null;

    Widget sheet = Container(
      constraints: maxHeightFactor != null
          ? BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * maxHeightFactor!,
            )
          : null,
      decoration: BoxDecoration(
        gradient: tokens.sheetGradient,
        borderRadius: AppRadius.sheetTopBorder,
        boxShadow: [tokens.sheetShadow],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Center(
              child: Container(
                margin: EdgeInsets.only(top: context.dims.sm),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: AppRadius.handleBorder,
                ),
              ),
            ),
            if (hasHeader) _buildHeader(theme, context),
            Flexible(
              child: Padding(padding: contentPadding, child: child),
            ),
          ],
        ),
      ),
    );

    if (avoidKeyboard) {
      sheet = Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: sheet,
      );
    }
    return sheet;
  }

  Widget _buildHeader(ThemeData theme, BuildContext context) {
    final accent = iconColor ?? theme.colorScheme.primary;
    final hasTrailing = trailing != null || showDone;
    final dims = context.dims;
    final headerPadding = dims.sheetHeaderPadding;

    return Padding(
      padding: hasTrailing
          ? headerPadding.copyWith(right: dims.md)
          : headerPadding,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.1),
                borderRadius: AppRadius.smBorder,
              ),
              child: Icon(icon, color: accent, size: AppIconSizes.md),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null)
            trailing!
          else if (showDone)
            FilledButton.tonal(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: dims.md,
                  vertical: dims.xs,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.smBorder,
                ),
              ),
              child: const Text('Done'),
            ),
        ],
      ),
    );
  }
}

/// Cancel/confirm button pair used at the bottom of action sheets.
class SheetActionButtons extends StatelessWidget {
  const SheetActionButtons({
    super.key,
    this.cancelText = 'Cancel',
    required this.confirmText,
    required this.onConfirm,
    this.isDestructive = false,
  });

  final String cancelText;
  final String confirmText;
  final VoidCallback onConfirm;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.smBorder,
              ),
              side: BorderSide(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            child: Text(cancelText),
          ),
        ),
        SizedBox(width: context.dims.sm),
        Expanded(
          child: FilledButton(
            onPressed: onConfirm,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              backgroundColor: isDestructive ? theme.colorScheme.error : null,
              shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.smBorder,
              ),
            ),
            child: Text(confirmText),
          ),
        ),
      ],
    );
  }
}
