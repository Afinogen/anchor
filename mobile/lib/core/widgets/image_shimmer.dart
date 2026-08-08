import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/context_extensions.dart';

/// Shimmer placeholder for image loading states.
/// Adapts to theme for cards/grids, or use [dark] for lightbox/overlays.
class ImageShimmer extends StatelessWidget {
  const ImageShimmer({super.key, this.dark = false});

  /// Use [dark] on dark backgrounds (e.g. lightbox overlay).
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;

    final (base, highlight) = dark
        ? (
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.14),
          )
        : (tokens.shimmerBase, tokens.shimmerHighlight);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(color: base),
    );
  }
}
