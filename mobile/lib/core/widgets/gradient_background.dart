import 'package:flutter/material.dart';

import '../theme/context_extensions.dart';

/// Full-screen gradient behind scrollable pages and the drawer.
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
