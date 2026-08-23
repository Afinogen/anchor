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
        title: 'Log Out',
        message:
            'Are you sure you want to log out? Your unsynced notes will stay safe on this device.',
        cancelText: 'Stay',
        confirmText: 'Log Out',
        onConfirm: () async {
          await ref.read(authControllerProvider.notifier).logout();
          // Navigation is handled by the router redirect logic
        },
      ),
    );
  }

  static const _themeModes = [
    (
      ThemeMode.system,
      'System',
      'Follow device settings',
      LucideIcons.smartphone,
    ),
    (ThemeMode.light, 'Light', 'Always use light theme', LucideIcons.sun),
    (ThemeMode.dark, 'Dark', 'Always use dark theme', LucideIcons.moon),
  ];

  static const _densities = [
    (DisplayDensity.standard, 'More breathing room', LucideIcons.alignLeft),
    (DisplayDensity.compact, 'Fit more on screen', LucideIcons.alignJustify),
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
            LargeTitleAppBar(title: 'Settings'),

            SliverPadding(
              padding: EdgeInsets.all(dims.pagePadding),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Section(
                      title: 'Appearance',
                      icon: LucideIcons.palette,
                      children: [
                        for (final (mode, title, subtitle, icon) in _themeModes)
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
                      title: 'Display density',
                      icon: LucideIcons.scaling,
                      children: [
                        for (final (density, subtitle, icon) in _densities)
                          SettingsSelectRow(
                            title: density.label,
                            subtitle: subtitle,
                            icon: icon,
                            isSelected: currentDensity == density,
                            onTap: () => ref
                                .read(displayDensityControllerProvider.notifier)
                                .setDensity(density),
                          ),
                      ],
                    ),

                    _Section(
                      title: 'Editor',
                      icon: LucideIcons.edit3,
                      children: [
                        SettingsSwitchRow(
                          title: 'Sort checklist items',
                          subtitle:
                              'Automatically move checked checklist items to the bottom',
                          icon: LucideIcons.listChecks,
                          value: editorPrefs.sortChecklistItems,
                          onChanged: (value) => ref
                              .read(
                                editorPreferencesControllerProvider.notifier,
                              )
                              .setSortChecklistItems(value),
                        ),
                      ],
                    ),

                    _Section(
                      title: 'Account',
                      icon: LucideIcons.user,
                      children: [
                        SettingsActionRow(
                          title: 'Edit Profile',
                          subtitle: 'Update your name and profile image',
                          icon: LucideIcons.user,
                          onTap: () => context.push(
                            '/${AppRoutes.settings}/${AppRoutes.editProfile}',
                          ),
                        ),
                        SettingsActionRow(
                          title: 'Change Password',
                          subtitle: 'Update your account password',
                          icon: LucideIcons.lock,
                          onTap: () => context.push(
                            '/${AppRoutes.settings}/${AppRoutes.changePassword}',
                          ),
                        ),
                        SettingsActionRow(
                          title: 'View Logs',
                          subtitle: 'Diagnostic logs for support and debugging',
                          icon: LucideIcons.fileText,
                          onTap: () => context.push(
                            '/${AppRoutes.settings}/${AppRoutes.viewLogs}',
                          ),
                        ),
                        SettingsActionRow(
                          title: 'Log Out',
                          subtitle: 'Sign out of your account',
                          icon: LucideIcons.logOut,
                          isDestructive: true,
                          onTap: _showLogoutDialog,
                        ),
                      ],
                    ),

                    _Section(
                      title: 'Support',
                      icon: LucideIcons.heart,
                      children: [
                        SettingsActionRow(
                          title: 'Buy me a coffee',
                          subtitle: 'Support the development of Anchor',
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: dims.xxs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _AboutRow(
            icon: LucideIcons.info,
            text: 'App v${appVersion.isNotEmpty ? appVersion : '...'}',
          ),
          if (serverUrl != null) ...[
            SizedBox(height: dims.xxs),
            serverInfo.when(
              loading: () => const _AboutRow(
                icon: LucideIcons.package,
                text: 'Server v...',
              ),
              error: (_, _) => _AboutRow(
                icon: LucideIcons.serverOff,
                text: "Can't reach $serverUrl",
              ),
              data: (info) => info == null
                  ? _AboutRow(
                      icon: LucideIcons.serverOff,
                      text: "Can't reach $serverUrl",
                    )
                  : Column(
                      children: [
                        _AboutRow(
                          icon: LucideIcons.package,
                          text: 'Server v${info.version}',
                        ),
                        SizedBox(height: dims.xxs),
                        _AboutRow(
                          icon: LucideIcons.server,
                          text: 'Connected to $serverUrl',
                        ),
                        if (compatibilityFor(info.protocols).isMismatch) ...[
                          SizedBox(height: dims.xxs),
                          _AboutRow(
                            icon: LucideIcons.triangleAlert,
                            text: 'Sync paused, versions incompatible',
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
