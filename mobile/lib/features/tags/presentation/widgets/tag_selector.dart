import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../domain/tag.dart';
import '../tags_controller.dart';
import 'tag_chip.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../core/theme/tokens/app_durations.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_opacity.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';

class TagSelector extends ConsumerStatefulWidget {
  final List<String> selectedTagIds;
  final ValueChanged<List<String>> onTagsChanged;
  final bool readOnly;

  const TagSelector({
    super.key,
    required this.selectedTagIds,
    required this.onTagsChanged,
    this.readOnly = false,
  });

  @override
  ConsumerState<TagSelector> createState() => _TagSelectorState();
}

class _TagSelectorState extends ConsumerState<TagSelector> {
  void _showTagPickerSheet() {
    if (widget.readOnly) return;

    AppBottomSheet.show(
      context,
      builder: (context) => TagPickerSheet(
        selectedTagIds: widget.selectedTagIds,
        onTagsChanged: widget.onTagsChanged,
      ),
    );
  }

  /// Height of the chip strip, which a horizontal scroller has to be given.
  static const double _stripHeight = 40;

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsControllerProvider);
    final theme = Theme.of(context);
    final dims = context.dims;
    final inset = dims.editorPadding.left;

    if (widget.readOnly && widget.selectedTagIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final selectedTags = (tagsAsync.value ?? const <Tag>[])
        .where((t) => widget.selectedTagIds.contains(t.id))
        .toList();

    return Padding(
      padding: EdgeInsets.only(top: dims.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.readOnly) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: inset),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.tags,
                    size: AppIconSizes.sm,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: dims.xs),
                  Text(
                    'Tags',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: dims.xs),
          ],
          SizedBox(
            height: _stripHeight,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: inset),
              children: [
                for (final tag in selectedTags)
                  Padding(
                    padding: EdgeInsets.only(right: dims.xs),
                    child: TagChip(
                      tag: tag,
                      selected: !widget.readOnly,
                      showDelete: !widget.readOnly,
                      onDelete: () {
                        final newIds = List<String>.from(widget.selectedTagIds)
                          ..remove(tag.id);
                        widget.onTagsChanged(newIds);
                      },
                    ),
                  ),
                if (!widget.readOnly) _AddTagButton(onTap: _showTagPickerSheet),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Outlined counterpart to a [TagChip] that opens the tag picker.
class _AddTagButton extends StatelessWidget {
  const _AddTagButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgBorder,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: dims.sm,
          vertical: TagChip.verticalPadding,
        ),
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgBorder,
          border: Border.all(
            color: theme.colorScheme.outline.withValues(
              alpha: AppOpacity.disabled,
            ),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.plus,
              size: AppIconSizes.xs,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: dims.xxs),
            Text(
              'Add tag',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagPickerSheet extends ConsumerStatefulWidget {
  final List<String> selectedTagIds;
  final ValueChanged<List<String>> onTagsChanged;

  const TagPickerSheet({
    super.key,
    required this.selectedTagIds,
    required this.onTagsChanged,
  });

  @override
  ConsumerState<TagPickerSheet> createState() => _TagPickerSheetState();
}

class _TagPickerSheetState extends ConsumerState<TagPickerSheet> {
  late List<String> _selectedIds;
  final _newTagController = TextEditingController();
  bool _isCreatingTag = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedIds = List.from(widget.selectedTagIds);
    _newTagController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _newTagController.removeListener(_onTextChanged);
    _newTagController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    // Clear error when user starts typing
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  void _toggleTag(String tagId) {
    setState(() {
      if (_selectedIds.contains(tagId)) {
        _selectedIds.remove(tagId);
      } else {
        _selectedIds.add(tagId);
      }
    });
    widget.onTagsChanged(_selectedIds);
  }

  Future<void> _createTag() async {
    final name = _newTagController.text.trim();
    if (name.isEmpty) return;

    setState(() {
      _isCreatingTag = true;
      _errorMessage = null;
    });

    try {
      final tag = await ref
          .read(tagsControllerProvider.notifier)
          .createTag(name);
      _newTagController.clear();
      setState(() {
        _selectedIds.add(tag.id);
        _isCreatingTag = false;
        _errorMessage = null;
      });
      widget.onTagsChanged(_selectedIds);
    } catch (e) {
      setState(() {
        _isCreatingTag = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final tagsAsync = ref.watch(tagsControllerProvider);
    final theme = Theme.of(context);
    final dims = context.dims;
    return AppBottomSheet(
      avoidKeyboard: true,
      maxHeightFactor: 0.75,
      icon: LucideIcons.tags,
      title: 'Select Tags',
      subtitle: 'Organize your note',
      showDone: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Create new tag input
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dims.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _newTagController,
                  textCapitalization: TextCapitalization.words,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Create new tag...',
                    hintStyle: TextStyle(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    prefixIcon: Icon(
                      LucideIcons.plus,
                      size: 18,
                      color: _errorMessage != null
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
                    ),
                    suffixIcon: _isCreatingTag
                        ? Padding(
                            padding: EdgeInsets.all(dims.sm),
                            child: const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : _newTagController.text.isNotEmpty
                        ? IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(dims.xxs),
                              decoration: BoxDecoration(
                                color: _errorMessage != null
                                    ? theme.colorScheme.error
                                    : theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _errorMessage != null
                                    ? LucideIcons.x
                                    : LucideIcons.check,
                                size: AppIconSizes.xs,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                            onPressed: _errorMessage != null
                                ? () {
                                    setState(() => _errorMessage = null);
                                  }
                                : _createTag,
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.onSurface.withValues(
                      alpha: 0.05,
                    ),
                    errorText: _errorMessage,
                    errorStyle: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    border: const OutlineInputBorder(
                      borderRadius: AppRadius.buttonBorder,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: AppRadius.buttonBorder,
                      borderSide: BorderSide(
                        color: _errorMessage != null
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: AppRadius.buttonBorder,
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: AppRadius.buttonBorder,
                      borderSide: BorderSide(
                        color: theme.colorScheme.error,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: dims.md,
                      vertical: 14,
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _createTag(),
                ),
              ],
            ),
          ),

          SizedBox(height: dims.md),

          // Divider
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dims.xl),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: dims.sm),
                  child: Text(
                    'Available Tags',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: dims.sm),

          // Tags list
          Flexible(
            child: tagsAsync.when(
              data: (tags) {
                if (tags.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(dims.md),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.05,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            LucideIcons.tags,
                            size: 32,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                        ),
                        SizedBox(height: dims.md),
                        Text(
                          'No tags yet',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.8,
                            ),
                          ),
                        ),
                        SizedBox(height: dims.xxs),
                        Text(
                          'Create your first tag above',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  padding: EdgeInsets.fromLTRB(dims.md, 0, dims.md, dims.xxl),
                  itemCount: tags.length,
                  itemBuilder: (context, index) {
                    final tag = tags[index];
                    final isSelected = _selectedIds.contains(tag.id);
                    final tagColor = parseTagColor(
                      tag.color,
                      fallback: theme.colorScheme.primary,
                    );

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: AppRadius.smBorder,
                        child: InkWell(
                          onTap: () => _toggleTag(tag.id),
                          borderRadius: AppRadius.smBorder,
                          child: AnimatedContainer(
                            duration: AppDurations.medium,
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: dims.sm,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? tagColor.withValues(alpha: 0.12)
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.03,
                                    ),
                              borderRadius: AppRadius.smBorder,
                              border: Border.all(
                                color: isSelected
                                    ? tagColor.withValues(alpha: 0.3)
                                    : theme.colorScheme.onSurface.withValues(
                                        alpha: 0.06,
                                      ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(dims.xs),
                                  decoration: BoxDecoration(
                                    color: tagColor.withValues(alpha: 0.15),
                                    borderRadius: AppRadius.xsBorder,
                                  ),
                                  child: Icon(
                                    LucideIcons.hash,
                                    size: AppIconSizes.sm,
                                    color: tagColor,
                                  ),
                                ),
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
                                          : theme.colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                AnimatedSwitcher(
                                  duration: AppDurations.medium,
                                  child: isSelected
                                      ? Container(
                                          padding: EdgeInsets.all(dims.xxs),
                                          decoration: BoxDecoration(
                                            color: tagColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            LucideIcons.check,
                                            size: AppIconSizes.xs,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Container(
                                          width: 22,
                                          height: 22,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.2),
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => Center(
                child: Padding(
                  padding: EdgeInsets.all(dims.xxl),
                  child: const CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: EdgeInsets.all(dims.xxl),
                  child: Text('Error: $err'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
