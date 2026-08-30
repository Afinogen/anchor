import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:anchor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../core/theme/tokens/app_dimensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/editor/link_utils.dart';
import '../../../core/widgets/gradient_background.dart';
import '../../../core/widgets/settings_card.dart';
import '../../../core/widgets/settings_row.dart';
import '../../../core/widgets/large_title_app_bar.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/network/server_config_provider.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/server_info_provider.dart';
import 'controllers/editor_preferences_controller.dart';
import 'controllers/theme_preferences_controller.dart';
import '../../sync/data/sync_compatibility.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = packageInfo.version;
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => ConfirmDialog(
        icon: LucideIcons.logOut,
        title: context.l10n.logOut,
        message: context.l10n.logoutDialogMessage,
        cancelText: context.l10n.stay,
        confirmText: context.l10n.logOut,
        onConfirm: () async {
          await ref.read(authControllerProvider.notifier).logout();
          // Navigation is handled by the router redirect logic
        },
      ),
    );
  }

  /// Built per-build so the labels follow the current locale.
  static List<(ThemeMode, String, String, IconData)> _themeModes(
    AppLocalizations l10n,
  ) => [
    (
      ThemeMode.system,
      l10n.themeSystem,
      l10n.themeSystemSubtitle,
      LucideIcons.smartphone,
    ),
    (
      ThemeMode.light,
      l10n.themeLight,
      l10n.themeLightSubtitle,
      LucideIcons.sun,
    ),
    (ThemeMode.dark, l10n.themeDark, l10n.themeDarkSubtitle, LucideIcons.moon),
  ];

  static const _densities = [
    (DisplayDensity.standard, LucideIcons.alignLeft),
    (DisplayDensity.compact, LucideIcons.alignJustify),
  ];

  @override
  Widget build(BuildContext context) {
    final dims = context.dims;
    final currentThemeMode = ref.watch(themeModeControllerProvider);
    final currentDensity = ref.watch(displayDensityControllerProvider);
    final editorPrefs = ref.watch(editorPreferencesControllerProvider);
    final serverUrl = ref.watch(serverUrlProvider);
    final serverInfoAsync = ref.watch(serverInfoProvider);

    return Scaffold(
      body: GradientBackground(
        child: CustomScrollView(
          slivers: [
            LargeTitleAppBar(title: context.l10n.settingsTitle),

            SliverPadding(
              padding: EdgeInsets.all(dims.pagePadding),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: context.l10n.appearance,
                      icon: LucideIcons.palette,
                      children: [
                        for (final (mode, title, subtitle, icon) in _themeModes(
                          context.l10n,
                        ))
                          SettingsSelectRow(
                            title: title,
                            subtitle: subtitle,
                            icon: icon,
                            isSelected: currentThemeMode == mode,
                            onTap: () => ref
                                .read(themeModeControllerProvider.notifier)
                                .setThemeMode(mode),
                          ),
                      ],
                    ),

                    _Section(
                      title: context.l10n.displayDensity,
                      icon: LucideIcons.scaling,
                      children: [
                        for (final (density, icon) in _densities)
                          SettingsSelectRow(
                            title: density.label(context.l10n),
                            subtitle: density.subtitle(context.l10n),
                            icon: icon,
                            isSelected: currentDensity == density,
                            onTap: () => ref
                                .read(displayDensityControllerProvider.notifier)
                                .setDensity(density),
                          ),
                      ],
                    ),

                    _Section(
                      title: context.l10n.editor,
                      icon: LucideIcons.edit3,
                      children: [
                        SettingsSwitchRow(
                          title: context.l10n.sortChecklistItems,
                          subtitle: context.l10n.sortChecklistItemsSubtitle,
                          icon: LucideIcons.listChecks,
                          value: editorPrefs.sortChecklistItems,
                          onChanged: (value) => ref
                              .read(
                                editorPreferencesControllerProvider.notifier,
                              )
                              .setSortChecklistItems(value),
                        ),
                        SettingsSwitchRow(
                          title: context.l10n.groupCheckedByDate,
                          subtitle: editorPrefs.sortChecklistItems
                              ? context.l10n.groupCheckedByDateSubtitle
                              : context.l10n.groupCheckedByDateDisabledSubtitle,
                          icon: LucideIcons.calendarDays,
                          enabled: editorPrefs.sortChecklistItems,
                          value: editorPrefs.groupCheckedByDate,
                          onChanged: (value) => ref
                              .read(
                                editorPreferencesControllerProvider.notifier,
                              )
                              .setGroupCheckedByDate(value),
                        ),
                      ],
                    ),

                    _Section(
                      title: context.l10n.account,
                      icon: LucideIcons.user,
                      children: [
                        SettingsActionRow(
                          title: context.l10n.editProfile,
                          subtitle: context.l10n.editProfileSubtitle,
                          icon: LucideIcons.user,
                          onTap: () => context.push(
                            '/${AppRoutes.settings}/${AppRoutes.editProfile}',
                          ),
                        ),
                        SettingsActionRow(
                          title: context.l10n.changePassword,
                          subtitle: context.l10n.changePasswordSubtitle,
                          icon: LucideIcons.lock,
                          onTap: () => context.push(
                            '/${AppRoutes.settings}/${AppRoutes.changePassword}',
                          ),
                        ),
                        SettingsActionRow(
                          title: context.l10n.viewLogs,
                          subtitle: context.l10n.viewLogsSubtitle,
                          icon: LucideIcons.fileText,
                          onTap: () => context.push(
                            '/${AppRoutes.settings}/${AppRoutes.viewLogs}',
                          ),
                        ),
                        SettingsActionRow(
                          title: context.l10n.logOut,
                          subtitle: context.l10n.logOutSubtitle,
                          icon: LucideIcons.logOut,
                          isDestructive: true,
                          onTap: _showLogoutDialog,
                        ),
                      ],
                    ),

                    _Section(
                      title: context.l10n.support,
                      icon: LucideIcons.heart,
                      children: [
                        SettingsActionRow(
                          title: context.l10n.buyMeCoffee,
                          subtitle: context.l10n.buyMeCoffeeSubtitle,
                          icon: LucideIcons.coffee,
                          onTap: () => launchExternal(
                            context,
                            'https://www.buymeacoffee.com/zahid',
                          ),
                        ),
                      ],
                    ),

                    _AboutFooter(
                      appVersion: _appVersion,
                      serverUrl: serverUrl,
                      serverInfo: serverInfoAsync,
                    ),
                    SizedBox(height: dims.pagePadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A titled settings group: header, card, and dividers between the rows.
class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dims = context.dims;
    return Padding(
      padding: EdgeInsets.only(bottom: dims.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: title, icon: icon),
          SizedBox(height: dims.sm),
          SettingsCard(
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) const SettingsDivider(),
                  children[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// App version, and where the app is pointed, in fine print.
class _AboutFooter extends StatelessWidget {
  const _AboutFooter({
    required this.appVersion,
    required this.serverUrl,
    required this.serverInfo,
  });

  final String appVersion;
  final String? serverUrl;
  final AsyncValue<ServerInfo?> serverInfo;

  @override
  Widget build(BuildContext context) {
    final dims = context.dims;
    final url = serverUrl;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dims.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AboutRow(
            icon: LucideIcons.info,
            text: context.l10n.appVersion(
              appVersion.isNotEmpty ? appVersion : '...',
            ),
          ),
          if (url != null) ...[
            SizedBox(height: dims.xxs),
            serverInfo.when(
              loading: () => _AboutRow(
                icon: LucideIcons.package,
                text: context.l10n.serverVersionLoading,
              ),
              error: (_, _) => _AboutRow(
                icon: LucideIcons.serverOff,
                text: context.l10n.serverUnreachable(url),
              ),
              data: (info) => info == null
                  ? _AboutRow(
                      icon: LucideIcons.serverOff,
                      text: context.l10n.serverUnreachable(url),
                    )
                  : Column(
                      children: [
                        _AboutRow(
                          icon: LucideIcons.package,
                          text: context.l10n.serverVersion(info.version),
                        ),
                        SizedBox(height: dims.xxs),
                        _AboutRow(
                          icon: LucideIcons.server,
                          text: context.l10n.connectedTo(url),
                        ),
                        if (compatibilityFor(info.protocols).isMismatch) ...[
                          SizedBox(height: dims.xxs),
                          _AboutRow(
                            icon: LucideIcons.triangleAlert,
                            text: context.l10n.syncPausedIncompatible,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ],
                      ],
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.icon, required this.text, this.color});

  final IconData icon;
  final String text;

  /// Overrides the muted default.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = color ?? theme.colorScheme.onSurface;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: AppIconSizes.xs,
          color: onSurface.withValues(alpha: AppOpacity.disabled),
        ),
        SizedBox(width: context.dims.xxs),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.labelSmall?.copyWith(
              color: onSurface.withValues(alpha: AppOpacity.secondary),
              fontFamily: 'monospace',
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
