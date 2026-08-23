import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_icon_sizes.dart';
import '../theme/tokens/app_opacity.dart';
import '../theme/tokens/app_radius.dart';
import 'app_bar_scrim.dart';

/// Collapsing app bar with a large serif title and a tinted back button, for
/// full-page screens pushed on top of another — settings, account, history.
class LargeTitleAppBar extends StatelessWidget {
  const LargeTitleAppBar({super.key, required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  /// Width of the leading button, kept clear on both sides of the title.
  static const double titleInset = 56;

  /// How much the title grows when the bar is fully expanded.
  static const double expandedTitleScale = 1.2;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;

    return SliverAppBar(
      backgroundColor: Colors.transparent,
      floating: true,
      pinned: true,
      expandedHeight: dims.largeAppBarHeight,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          padding: EdgeInsets.all(dims.xs),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(
              alpha: AppOpacity.strong,
            ),
            borderRadius: AppRadius.smBorder,
          ),
          child: Icon(
            LucideIcons.arrowLeft,
            size: AppIconSizes.md,
            color: theme.colorScheme.onSurface,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: actions,
      flexibleSpace: Stack(
        fit: StackFit.expand,
        children: [
          const AppBarScrim(),
          FlexibleSpaceBar(
            centerTitle: Platform.isIOS,
            expandedTitleScale: expandedTitleScale,
            titlePadding: EdgeInsets.only(
              left: titleInset,
              right: Platform.isIOS ? titleInset : 0,
              bottom: dims.sm,
            ),
            title: Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
