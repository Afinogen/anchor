import 'package:flutter/material.dart';

import '../theme/tokens/app_durations.dart';
import '../theme/tokens/app_icon_sizes.dart';
import '../theme/tokens/app_opacity.dart';
import '../theme/tokens/app_radius.dart';

/// Rounded, tinted square holding a single icon — the leading element of
/// settings rows, sheet headers and link actions.
class AppIconChip extends StatelessWidget {
  const AppIconChip({
    super.key,
    required this.icon,
    this.color,
    this.selected = false,
    this.size = AppIconSizes.md,
  });

  final IconData icon;

  /// Tint for the fill and the icon. Defaults to the primary color.
  final Color? color;

  /// Draws the chip at a stronger tint, and animates between the two states.
  final bool selected;

  final double size;

  static const double _inset = 10;

  @override
  Widget build(BuildContext context) {
    final accent = color ?? Theme.of(context).colorScheme.primary;

    return AnimatedContainer(
      duration: AppDurations.medium,
      padding: const EdgeInsets.all(_inset),
      decoration: BoxDecoration(
        color: accent.withValues(
          alpha: selected ? AppOpacity.activeFill : AppOpacity.subtleFill,
        ),
        borderRadius: AppRadius.smBorder,
      ),
      child: Icon(icon, size: size, color: accent),
    );
  }
}
