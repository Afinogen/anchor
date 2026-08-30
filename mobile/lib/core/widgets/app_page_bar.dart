import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'app_bar_scrim.dart';

/// Plain app bar for a pushed sub-page: a back chevron and a bold title over
/// an [AppBarScrim]. [LargeTitleAppBar] is the collapsing counterpart.
class AppPageBar extends StatelessWidget implements PreferredSizeWidget {
  const AppPageBar({super.key, required this.title, this.actions});

  final Widget title;
  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      flexibleSpace: const AppBarScrim(),
      leading: IconButton(
        icon: const Icon(LucideIcons.chevronLeft),
        onPressed: () => context.pop(),
      ),
      titleTextStyle: theme.textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
      title: title,
      actions: actions,
    );
  }
}
