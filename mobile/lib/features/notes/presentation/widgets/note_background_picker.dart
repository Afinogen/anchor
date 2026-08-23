import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:anchor/features/notes/presentation/widgets/note_background.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';

class NoteBackgroundPicker extends StatefulWidget {
  final String? selectedColor;
  final ValueChanged<String?> onColorChanged;

  const NoteBackgroundPicker({
    super.key,
    required this.selectedColor,
    required this.onColorChanged,
  });

  @override
  State<NoteBackgroundPicker> createState() => _NoteBackgroundPickerState();
}

class _NoteBackgroundPickerState extends State<NoteBackgroundPicker> {
  late String? _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.selectedColor;
  }

  @override
  void didUpdateWidget(NoteBackgroundPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedColor != widget.selectedColor) {
      setState(() {
        _selectedColor = widget.selectedColor;
      });
    }
  }

  void _onColorSelected(String? color) {
    setState(() {
      _selectedColor = color;
    });
    widget.onColorChanged(color);
  }

  // Get only solid colors from styles
  List<NoteBackgroundData> get _solidColors => NoteBackgroundStyle.styles
      .where((s) => s.id.startsWith('color_'))
      .toList();

  // Get patterns from styles
  List<NoteBackgroundData> get _patterns => NoteBackgroundStyle.styles
      .where((s) => s.id.startsWith('pattern_'))
      .toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final dims = context.dims;

    return AppBottomSheet(
      avoidKeyboard: true,
      icon: LucideIcons.palette,
      title: 'Background',
      subtitle: 'Customize your note',
      showDone: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Content
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Colors Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: dims.xl,
                      vertical: dims.xs,
                    ),
                    child: Text(
                      'Color',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: dims.md),
                      physics: const BouncingScrollPhysics(),
                      children: [
                        // None / Default option
                        _buildOptionItem(
                          context: context,
                          isSelected: _selectedColor == null,
                          onTap: () => _onColorSelected(null),
                          child: Icon(
                            Icons.format_color_reset_outlined,
                            color: theme.colorScheme.onSurfaceVariant,
                            size: AppIconSizes.lg,
                          ),
                          color: theme.colorScheme.surfaceContainerHighest,
                          hasBorder: true,
                        ),

                        SizedBox(width: dims.sm),

                        // Solid Colors
                        ..._solidColors.map((style) {
                          final isSelected = _selectedColor == style.id;
                          final color = isDark
                              ? style.darkColor
                              : style.lightColor;
                          return Padding(
                            padding: EdgeInsets.only(right: dims.sm),
                            child: _buildOptionItem(
                              context: context,
                              isSelected: isSelected,
                              onTap: () => _onColorSelected(style.id),
                              child: isSelected
                                  ? Icon(
                                      Icons.check,
                                      color: color.computeLuminance() > 0.5
                                          ? Colors.black
                                          : Colors.white,
                                    )
                                  : null,
                              color: color,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),

                  SizedBox(height: dims.md),

                  // 2. Backgrounds Section
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: dims.xl,
                      vertical: dims.xs,
                    ),
                    child: Text(
                      'Background',
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: dims.md),
                      physics: const BouncingScrollPhysics(),
                      children: _patterns.map((style) {
                        final isSelected = _selectedColor == style.id;
                        return Padding(
                          padding: EdgeInsets.only(right: dims.sm),
                          child: _buildBackgroundItem(
                            context: context,
                            style: style,
                            isSelected: isSelected,
                            onTap: () => _onColorSelected(style.id),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(height: dims.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionItem({
    required BuildContext context,
    required bool isSelected,
    required VoidCallback onTap,
    required Widget? child,
    required Color color,
    bool hasBorder = false,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (hasBorder
                      ? theme.colorScheme.outlineVariant
                      : Colors.transparent),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: child != null ? Center(child: child) : null,
      ),
    );
  }

  Widget _buildBackgroundItem({
    required BuildContext context,
    required NoteBackgroundData style,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdBorder,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdBorder,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.buttonBorder,
          child: NoteBackground(
            styleId: style.id,
            child: isSelected
                ? Center(
                    child: Container(
                      padding: EdgeInsets.all(context.dims.xxs),
                      decoration: const BoxDecoration(
                        color: Colors.white54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: AppIconSizes.md,
                      ),
                    ),
                  )
                : const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class ColorItem {
  final String? value;
  final String label;
  final Color color;

  ColorItem(this.value, this.label, this.color);
}
