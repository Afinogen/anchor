import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../features/tags/domain/tag.dart';
import '../../features/tags/presentation/tags_controller.dart';
import '../../features/tags/presentation/widgets/tag_delete_sheet.dart';
import '../../features/tags/presentation/widgets/tag_edit_sheet.dart';
import '../../features/tags/presentation/widgets/tag_options_sheet.dart';
import '../../core/network/server_config_provider.dart';
import '../theme/app_typography.dart';
import 'anchor_icon.dart';
import 'gradient_background.dart';
import '../theme/context_extensions.dart';
import '../theme/tokens/app_durations.dart';
import '../theme/tokens/app_icon_sizes.dart';
import '../theme/tokens/app_radius.dart';

class AppDrawer extends ConsumerStatefulWidget {
  const AppDrawer({super.key});

  @override
  ConsumerState<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends ConsumerState<AppDrawer> {
  bool _tagsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;
    final tagsAsync = ref.watch(tagsControllerProvider);
    final selectedTagId = ref.watch(selectedTagFilterProvider);

    return Drawer(
      backgroundColor: Colors.transparent,
      child: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header with branding
              _buildHeader(theme),

              SizedBox(height: dims.xs),

              // Main navigation
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: dims.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Primary Navigation
                      _buildNavItem(
                        icon: LucideIcons.fileText,
                        label: context.l10n.allNotes,
                        isSelected: selectedTagId == null,
                        onTap: () {
                          ref.read(selectedTagFilterProvider.notifier).clear();
                          Navigator.pop(context);
                        },
                        theme: theme,
                      ),

                      _buildNavItem(
                        icon: LucideIcons.archive,
                        label: context.l10n.archive,
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/archive');
                        },
                        theme: theme,
                      ),

                      _buildNavItem(
                        icon: LucideIcons.trash2,
                        label: context.l10n.trash,
                        onTap: () {
                          Navigator.pop(context);
                          context.push('/trash');
                        },
                        theme: theme,
                      ),

                      SizedBox(height: dims.md),

                      // Tags Section
                      _buildTagsSection(
                        theme: theme,
                        tagsAsync: tagsAsync,
                        selectedTagId: selectedTagId,
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom section with settings
              _buildBottomSection(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final dims = context.dims;
    return Container(
      padding: EdgeInsets.fromLTRB(dims.lg, dims.lg, dims.lg, dims.md),
      child: Row(
        children: [
          const SizedBox(width: 52, height: 52, child: AnchorIcon(size: 48)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Anchor',
                  style: AppTypography.serif(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  context.l10n.appTagline,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ThemeData theme,
    bool isSelected = false,
    bool enabled = true,
    Color? activeColor,
    Widget? trailing,
  }) {
    final color = activeColor ?? theme.colorScheme.primary;
    final dims = context.dims;

    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: Container(
        margin: EdgeInsets.only(bottom: dims.xxs),
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadius.smBorder,
          child: InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: AppRadius.smBorder,
            child: Container(
              padding: dims.drawerItemPadding,
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: AppRadius.smBorder,
                border: isSelected
                    ? Border.all(color: color.withValues(alpha: 0.2), width: 1)
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    size: AppIconSizes.md,
                    color: isSelected
                        ? color
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                        color: isSelected
                            ? color
                            : theme.colorScheme.onSurface.withValues(
                                alpha: 0.85,
                              ),
                      ),
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTagsSection({
    required ThemeData theme,
    required AsyncValue<List<Tag>> tagsAsync,
    required String? selectedTagId,
  }) {
    final dims = context.dims;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tags header with expand/collapse
        InkWell(
          onTap: () => setState(() => _tagsExpanded = !_tagsExpanded),
          borderRadius: AppRadius.xsBorder,
          child: Padding(
            padding: EdgeInsets.fromLTRB(14, dims.xs, dims.xs, dims.xxs),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: _tagsExpanded ? 0.25 : 0,
                  duration: AppDurations.medium,
                  child: Icon(
                    LucideIcons.chevronRight,
                    size: AppIconSizes.xs,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  context.l10n.tagsSectionLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    LucideIcons.plus,
                    size: AppIconSizes.sm,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                  onPressed: () => TagEditSheet.show(context),
                  tooltip: context.l10n.newTagTooltip,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tags list
        AnimatedCrossFade(
          firstChild: tagsAsync.when(
            data: (tags) {
              if (tags.isEmpty) {
                return _buildEmptyTagsState(theme);
              }
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: tags.length,
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  final isSelected = selectedTagId == tag.id;
                  final tagColor = parseTagColor(
                    tag.color,
                    fallback: theme.colorScheme.primary,
                  );
                  return _TagItemWidget(
                    tag: tag,
                    isSelected: isSelected,
                    tagColor: tagColor,
                    theme: theme,
                    onTap: () {
                      ref
                          .read(selectedTagFilterProvider.notifier)
                          .select(tag.id);
                      Navigator.pop(context);
                    },
                    onLongPress: () => _showTagOptionsSheet(tag),
                  );
                },
              );
            },
            loading: () => Padding(
              padding: EdgeInsets.all(dims.md),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
          secondChild: const SizedBox.shrink(),
          crossFadeState: _tagsExpanded
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: AppDurations.medium,
        ),
      ],
    );
  }

  Widget _buildEmptyTagsState(ThemeData theme) {
    final dims = context.dims;
    return Padding(
      padding: EdgeInsets.fromLTRB(14, dims.xs, 14, dims.xs),
      child: Container(
        padding: EdgeInsets.all(dims.md),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: AppRadius.smBorder,
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              LucideIcons.tags,
              size: 18,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
            SizedBox(width: dims.sm),
            Expanded(
              child: Text(
                context.l10n.createTagsHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSection(ThemeData theme) {
    final userAsync = ref.watch(authControllerProvider);
    final serverUrl = ref.watch(serverUrlProvider);
    final dims = context.dims;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: dims.sm, vertical: dims.xs),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: userAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNavItem(
              icon: LucideIcons.settings,
              label: context.l10n.settingsTitle,
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
              theme: theme,
            );
          }

          // Build profile image URL
          String? profileImageUrl;
          if (user.profileImage != null) {
            if (user.profileImage!.startsWith('http')) {
              profileImageUrl = user.profileImage;
            } else {
              final url = serverUrl;
              if (url != null) {
                profileImageUrl = '$url${user.profileImage}';
              }
            }
          }

          return Material(
            color: Colors.transparent,
            borderRadius: AppRadius.smBorder,
            child: InkWell(
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
              borderRadius: AppRadius.smBorder,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: dims.sm,
                  vertical: dims.xs,
                ),
                child: Row(
                  children: [
                    // Profile Avatar
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: theme.colorScheme.surface,
                      backgroundImage: profileImageUrl != null
                          ? CachedNetworkImageProvider(profileImageUrl)
                          : null,
                      child: profileImageUrl == null
                          ? Icon(
                              LucideIcons.user,
                              size: 18,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    // Profile Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            user.name,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.email,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Settings Icon
                    Icon(
                      LucideIcons.settings,
                      size: AppIconSizes.sm,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => _buildNavItem(
          icon: LucideIcons.settings,
          label: context.l10n.settingsTitle,
          onTap: () {
            Navigator.pop(context);
            context.push('/settings');
          },
          theme: theme,
        ),
        error: (_, _) => _buildNavItem(
          icon: LucideIcons.settings,
          label: context.l10n.settingsTitle,
          onTap: () {
            Navigator.pop(context);
            context.push('/settings');
          },
          theme: theme,
        ),
      ),
    );
  }

  Future<void> _showTagOptionsSheet(Tag tag) async {
    final action = await TagOptionsSheet.show(context, tag);
    if (!mounted) return;
    switch (action) {
      case TagSheetAction.rename:
        TagEditSheet.show(context, tag: tag);
      case TagSheetAction.delete:
        TagDeleteSheet.show(context, tag);
      case null:
        break;
    }
  }
}

class _TagItemWidget extends StatelessWidget {
  final Tag tag;
  final bool isSelected;
  final Color tagColor;
  final ThemeData theme;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _TagItemWidget({
    required this.tag,
    required this.isSelected,
    required this.tagColor,
    required this.theme,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final dims = context.dims;
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: dims.drawerTagPadding,
            decoration: BoxDecoration(
              color: isSelected
                  ? tagColor.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.hash, size: AppIconSizes.sm, color: tagColor),
                SizedBox(width: dims.sm),
                Expanded(
                  child: Text(
                    tag.name,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: isSelected
                          ? tagColor
                          : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                Text(
                  '${tag.noteCount}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
