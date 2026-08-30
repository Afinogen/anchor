import 'package:flutter/material.dart';

import 'app_page_bar.dart';
import 'gradient_background.dart';

/// A pushed sub-page whose wash runs the full height, behind an [AppPageBar].
///
/// Scroll views in [body] must add [topInset] to their leading padding.
class AppPageScaffold extends StatelessWidget {
  const AppPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.wash = PageWash.gradient,
  });

  final Widget title;
  final Widget body;
  final List<Widget>? actions;
  final PageWash wash;

  /// Height the bar covers, including the status bar.
  static double topInset(BuildContext context) =>
      kToolbarHeight + MediaQuery.paddingOf(context).top;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppPageBar(title: title, actions: actions),
      body: wash.wrap(body),
    );
  }
}
