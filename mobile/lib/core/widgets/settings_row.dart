import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme/context_extensions.dart';
import '../theme/tokens/app_durations.dart';
import '../theme/tokens/app_icon_sizes.dart';
import '../theme/tokens/app_opacity.dart';
import '../theme/tokens/app_radius.dart';
import 'app_icon_chip.dart';

/// Selectable row with an animated check circle — one option of a
/// radio-style group inside a settings card.
class SettingsSelectRow extends StatelessWidget {
  const SettingsSelectRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dims = context.dims;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Padding(
          padding: dims.settingsRowPadding,
          child: Row(
            children: [
              AppIconChip(
                icon: icon,
                selected: isSelected,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withValues(
                        alpha: AppOpacity.secondary,
                      ),
              ),
              SizedBox(width: dims.md),
              Expanded(
                child: _RowLabels(
                  title: title,
                  subtitle: subtitle,
                  titleColor: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              AnimatedContainer(
                duration: AppDurations.medium,
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(
                            alpha: AppOpacity.border,
                          ),
                    width: isSelected ? 2 : 1.5,
                  ),
                  color: isSelected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                ),
                child: isSelected
                    ? Icon(
                        LucideIcons.check,
                        size: AppIconSizes.xs,
                        color: isDark ? Colors.black : Colors.white,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row ending in an adaptive switch, with haptic feedback on toggle.
class SettingsSwitchRow extends StatelessWidget {
  const SettingsSwitchRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;

    return Padding(
      padding: dims.settingsRowPadding,
      child: Row(
        children: [
          AppIconChip(icon: icon),
          SizedBox(width: dims.md),
          Expanded(
            child: _RowLabels(title: title, subtitle: subtitle),
          ),
          Switch.adaptive(
            value: value,
            onChanged: (newValue) {
              HapticFeedback.selectionClick();
              onChanged(newValue);
            },
            activeTrackColor: theme.colorScheme.primary,
            activeThumbColor: theme.colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}

/// Tappable row with a chevron, for navigation and one-shot actions.
class SettingsActionRow extends StatelessWidget {
  const SettingsActionRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.onSurface;
    final dims = context.dims;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdBorder,
        child: Padding(
          padding: dims.settingsRowPadding,
          child: Row(
            children: [
              AppIconChip(icon: icon, color: color),
              SizedBox(width: dims.md),
              Expanded(
                child: _RowLabels(
                  title: title,
                  subtitle: subtitle,
                  titleColor: color,
                ),
              ),
              Icon(
                LucideIcons.chevronRight,
                size: AppIconSizes.md,
                color: color.withValues(alpha: AppOpacity.disabled),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hairline divider between rows in a settings card.
class SettingsDivider extends StatelessWidget {
  const SettingsDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.dims.lg),
      child: const Divider(),
    );
  }
}

class _RowLabels extends StatelessWidget {
  const _RowLabels({
    required this.title,
    required this.subtitle,
    this.titleColor,
  });

  final String title;
  final String subtitle;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: titleColor ?? theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: context.dims.xxs / 2),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(
              alpha: AppOpacity.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
