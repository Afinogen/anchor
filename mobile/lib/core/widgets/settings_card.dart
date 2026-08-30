import 'package:flutter/material.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_radius.dart';

/// A reusable settings card widget with consistent styling
/// used across settings screens like Change Password and Edit Profile.
class SettingsCard extends StatelessWidget {
  final Widget child;

  const SettingsCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;

    return Container(
      decoration: BoxDecoration(
        color: tokens.cardFill,
        borderRadius: AppRadius.lgBorder,
        border: Border.all(color: tokens.subtleBorder),
        boxShadow: [tokens.cardShadow],
      ),
      child: child,
    );
  }
}
