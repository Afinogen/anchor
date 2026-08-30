import 'package:flutter/material.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_icon_sizes.dart';

/// Uppercased section label used above settings cards and sheet sections.
class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.icon,
    this.padding = const EdgeInsets.only(left: 4),
  });

  final String title;
  final IconData? icon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: AppIconSizes.sm, color: theme.colorScheme.primary),
            SizedBox(width: context.dims.xs),
          ],
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
