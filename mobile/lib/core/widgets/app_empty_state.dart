import 'package:flutter/material.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_opacity.dart';

/// Centred icon-over-message placeholder for an empty list or screen, with an
/// optional supporting line and a single action.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.description,
    this.action,
    this.padding,
  });

  final IconData icon;
  final String message;

  /// Supporting line under [message], in a smaller, dimmer style.
  final String? description;

  /// A single button below the text.
  final Widget? action;

  final EdgeInsetsGeometry? padding;

  static const double _iconSize = 64;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;
    final onSurface = theme.colorScheme.onSurface;
    final muted = onSurface.withValues(alpha: AppOpacity.disabled);

    return Center(
      child: Padding(
        padding:
            padding ??
            EdgeInsets.symmetric(horizontal: dims.xl, vertical: dims.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: _iconSize, color: muted),
            SizedBox(height: dims.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(color: muted),
            ),
            if (description != null) ...[
              SizedBox(height: dims.xs),
              Text(
                description!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: onSurface.withValues(alpha: AppOpacity.secondary),
                ),
              ),
            ],
            if (action != null) ...[SizedBox(height: dims.md), action!],
          ],
        ),
      ),
    );
  }
}

/// [AppEmptyState] filling the remaining space of a scroll view.
class SliverAppEmptyState extends StatelessWidget {
  const SliverAppEmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.description,
    this.action,
  });

  final IconData icon;
  final String message;
  final String? description;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: AppEmptyState(
        icon: icon,
        message: message,
        description: description,
        action: action,
      ),
    );
  }
}
