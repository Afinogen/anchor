import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_opacity.dart';
import 'app_bottom_sheet.dart';

/// Confirm/cancel dialog with a large tinted icon.
class ConfirmDialog extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String title;
  final String message;
  final String cancelText;
  final String confirmText;
  final Color? confirmColor;
  final VoidCallback onConfirm;

  const ConfirmDialog({
    super.key,
    required this.icon,
    this.iconColor,
    required this.title,
    required this.message,
    this.cancelText = 'Cancel',
    required this.confirmText,
    this.confirmColor,
    required this.onConfirm,
  });

  static const double _iconChipSize = 64;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;
    final effectiveIconColor = iconColor ?? theme.colorScheme.primary;

    return Dialog(
      child: Padding(
        padding: EdgeInsets.all(dims.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: _iconChipSize,
              height: _iconChipSize,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(
                  alpha: AppOpacity.subtleFill,
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: _iconChipSize / 2,
              ),
            ),
            SizedBox(height: dims.lg),
            Text(
              title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: dims.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(
                  alpha: AppOpacity.secondary,
                ),
                height: 1.4,
              ),
            ),
            SizedBox(height: dims.xl),
            SheetActionButtons(
              cancelText: cancelText,
              confirmText: confirmText,
              confirmColor: confirmColor,
              onCancel: () => context.pop(false),
              onConfirm: () {
                context.pop(true);
                onConfirm();
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<bool?> show({
    required BuildContext context,
    required IconData icon,
    Color? iconColor,
    required String title,
    required String message,
    String cancelText = 'Cancel',
    required String confirmText,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => ConfirmDialog(
        icon: icon,
        iconColor: iconColor,
        title: title,
        message: message,
        cancelText: cancelText,
        confirmText: confirmText,
        confirmColor: confirmColor,
        onConfirm: () {},
      ),
    );
  }
}
