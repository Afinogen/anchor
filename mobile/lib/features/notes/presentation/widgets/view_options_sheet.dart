import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../core/theme/tokens/app_durations.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../notes_view_options.dart';

class ViewOptionsSheet extends ConsumerWidget {
  const ViewOptionsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(notesViewOptionsProvider);
    final settings = settingsAsync.value ?? const NotesViewOptions();
    final notifier = ref.read(notesViewOptionsProvider.notifier);
    final isDateSort = settings.sortOption == SortOption.dateModified;

    final dims = context.dims;

    return AppBottomSheet(
      maxHeightFactor: 0.75,
      icon: LucideIcons.settings2,
      title: 'View Options',
      subtitle: 'Customize display',
      showDone: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Layout'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dims.xl),
            child: Row(
              children: [
                Expanded(
                  child: _ViewOptionCard(
                    icon: LucideIcons.layoutGrid,
                    label: 'Grid',
                    isSelected: settings.viewType == ViewType.grid,
                    onTap: () => notifier.setViewType(ViewType.grid),
                  ),
                ),
                SizedBox(width: dims.sm),
                Expanded(
                  child: _ViewOptionCard(
                    icon: LucideIcons.list,
                    label: 'List',
                    isSelected: settings.viewType == ViewType.list,
                    onTap: () => notifier.setViewType(ViewType.list),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: dims.xl),

          const _SectionHeader(title: 'Sort by'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dims.xl),
            child: Column(
              children: [
                _SortOptionTile(
                  title: 'Date Modified',
                  isSelected: settings.sortOption == SortOption.dateModified,
                  onTap: () => notifier.setSortOption(SortOption.dateModified),
                ),
                SizedBox(height: dims.xs),
                _SortOptionTile(
                  title: 'Title',
                  isSelected: settings.sortOption == SortOption.title,
                  onTap: () => notifier.setSortOption(SortOption.title),
                ),
              ],
            ),
          ),

          SizedBox(height: dims.xl),

          const _SectionHeader(title: 'Order'),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dims.xl),
            child: Row(
              children: [
                Expanded(
                  child: _ViewOptionCard(
                    icon: isDateSort
                        ? LucideIcons.arrowUp
                        : LucideIcons.arrowDownAZ,
                    label: isDateSort ? 'Oldest first' : 'A to Z',
                    isSelected: settings.isAscending,
                    onTap: () => notifier.setSortDirection(true),
                  ),
                ),
                SizedBox(width: dims.sm),
                Expanded(
                  child: _ViewOptionCard(
                    icon: isDateSort
                        ? LucideIcons.arrowDown
                        : LucideIcons.arrowUpAZ,
                    label: isDateSort ? 'Newest first' : 'Z to A',
                    isSelected: !settings.isAscending,
                    onTap: () => notifier.setSortDirection(false),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: dims.xl),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final dims = context.dims;
    return Padding(
      padding: EdgeInsets.fromLTRB(dims.xl, 0, dims.xl, dims.sm),
      child: AppSectionHeader(title: title, padding: EdgeInsets.zero),
    );
  }
}

class _ViewOptionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ViewOptionCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dims = context.dims;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: AppDurations.medium,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: dims.xs),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortOptionTile extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortOptionTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: AppDurations.medium,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.1)
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary.withValues(alpha: 0.5)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: AppDurations.medium,
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurface.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: isSelected
                    ? Icon(
                        LucideIcons.check,
                        size: 14,
                        color: theme.colorScheme.onPrimary,
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
