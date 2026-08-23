import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_durations.dart';
import '../theme/tokens/app_icon_sizes.dart';
import '../theme/tokens/app_opacity.dart';
import '../theme/tokens/app_radius.dart';

/// Global snackbar utility for consistent styling across the app.
class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.checkCircle,
  }) => _show(context, message, icon, context.colorTokens.success);

  static void showError(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.alertCircle,
  }) => _show(context, message, icon, Theme.of(context).colorScheme.error);

  static void showInfo(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.info,
  }) => _show(context, message, icon, Theme.of(context).colorScheme.primary);

  static void showWarning(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.alertTriangle,
  }) => _show(context, message, icon, context.colorTokens.warning);

  static void _show(
    BuildContext context,
    String message,
    IconData icon,
    Color iconColor,
  ) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final dims = context.dims;
    messenger.showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          icon: icon,
          iconColor: iconColor,
          message: message,
        ),
        // `margin` is only legal on a floating snackbar.
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        padding: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        duration: AppDurations.snackbar,
      ),
    );
  }
}

class _SnackbarContent extends StatelessWidget {
  const _SnackbarContent({
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: AppOpacity.activeFill),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: AppIconSizes.md),
        ),
        SizedBox(width: dims.sm),
        Expanded(
          child: Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
              height: 1.3,
              letterSpacing: -0.2,
            ),
          ),
        ),
        SizedBox(width: dims.xs),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            borderRadius: AppRadius.mdBorder,
            child: SizedBox(
              width: 28,
              height: 28,
              child: Icon(
                LucideIcons.x,
                size: AppIconSizes.sm,
                color: theme.colorScheme.onSurface.withValues(
                  alpha: AppOpacity.secondary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
