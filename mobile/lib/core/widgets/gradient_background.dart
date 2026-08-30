import 'package:flutter/material.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_opacity.dart';

/// Which full-screen wash a page sits on.
enum PageWash {
  gradient,
  content;

  Widget wrap(Widget child) => switch (this) {
    PageWash.gradient => GradientBackground(child: child),
    PageWash.content => ContentBackground(child: child),
  };
}

/// Full-screen wash behind screens whose cards are glassy and translucent —
/// settings, auth, the drawer, note history.
class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(gradient: context.colorTokens.pageGradient),
      child: child,
    );
  }
}

/// Full-screen wash behind screens that list opaque note cards. Flatter and a
/// shade darker than [GradientBackground] so the cards read as raised.
class ContentBackground extends StatelessWidget {
  const ContentBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.surface,
            colorScheme.surfaceContainerHighest.withValues(
              alpha: AppOpacity.border,
            ),
          ],
        ),
      ),
      child: child,
    );
  }
}
