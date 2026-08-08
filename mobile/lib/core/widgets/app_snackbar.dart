import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_icon_sizes.dart';
import '../theme/tokens/app_radius.dart';

/// Global snackbar utility for consistent styling across the app
class AppSnackbar {
  AppSnackbar._();

  static void showSuccess(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.checkCircle,
  }) {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final successColor = context.colorTokens.success;
    final dims = context.dims;

    messenger.showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          icon: icon,
          iconColor: successColor,
          message: message,
          theme: theme,
        ),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        padding: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlBorder,
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        elevation: 0,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.alertCircle,
  }) {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final errorColor = context.colorTokens.error;
    final dims = context.dims;

    messenger.showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          icon: icon,
          iconColor: errorColor,
          message: message,
          theme: theme,
        ),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        padding: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlBorder,
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        elevation: 0,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.info,
  }) {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final dims = context.dims;

    messenger.showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          icon: icon,
          iconColor: theme.colorScheme.primary,
          message: message,
          theme: theme,
        ),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        padding: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlBorder,
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        elevation: 0,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    IconData icon = LucideIcons.alertTriangle,
  }) {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    final warningColor = context.colorTokens.warning;
    final dims = context.dims;

    messenger.showSnackBar(
      SnackBar(
        content: _SnackbarContent(
          icon: icon,
          iconColor: warningColor,
          message: message,
          theme: theme,
        ),
        backgroundColor: theme.colorScheme.surface,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        padding: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.xlBorder,
          side: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        elevation: 0,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

class _SnackbarContent extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String message;
  final ThemeData theme;

  const _SnackbarContent({
    required this.icon,
    required this.iconColor,
    required this.message,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final dims = context.dims;
    return Row(
      children: [
        // Icon container with subtle background
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        SizedBox(width: dims.sm),
        // Message text
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
        // Dismiss button
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
            borderRadius: AppRadius.mdBorder,
            child: Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              child: Icon(
                LucideIcons.x,
                size: AppIconSizes.sm,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
