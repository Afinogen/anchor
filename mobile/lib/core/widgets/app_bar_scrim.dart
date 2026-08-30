import 'package:flutter/material.dart';

/// App bar backdrop for `flexibleSpace`: opaque surface behind the toolbar,
/// fading to nothing at the bottom.
class AppBarScrim extends StatelessWidget {
  const AppBarScrim({super.key});

  /// Fraction of the height held opaque before the fade begins.
  static const double _solidStop = 0.55;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: const [0, _solidStop, 1],
          colors: [surface, surface, surface.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
