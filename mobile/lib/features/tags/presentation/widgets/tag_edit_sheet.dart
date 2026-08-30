import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/context_extensions.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../domain/tag.dart';
import '../tags_controller.dart';

/// Create/rename sheet for tags. Pass [tag] to rename; omit it to create.
class TagEditSheet extends ConsumerStatefulWidget {
  const TagEditSheet({super.key, this.tag});

  final Tag? tag;

  static Future<void> show(BuildContext context, {Tag? tag}) {
    return AppBottomSheet.show(context, builder: (_) => TagEditSheet(tag: tag));
  }

  @override
  ConsumerState<TagEditSheet> createState() => _TagEditSheetState();
}

class _TagEditSheetState extends ConsumerState<TagEditSheet> {
  late final TextEditingController _controller;
  String? _errorMessage;

  bool get _isRename => widget.tag != null;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tag?.name ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    final tag = widget.tag;
    if (tag != null && name == tag.name) {
      if (mounted) Navigator.pop(context);
      return;
    }

    try {
      final notifier = ref.read(tagsControllerProvider.notifier);
      if (tag != null) {
        await notifier.updateTag(tag.copyWith(name: name));
      } else {
        await notifier.createTag(name);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  OutlineInputBorder _border({Color? color}) => OutlineInputBorder(
    borderRadius: AppRadius.buttonBorder,
    borderSide: color == null
        ? BorderSide.none
        : BorderSide(color: color, width: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;
    final accent = _isRename
        ? parseTagColor(widget.tag!.color, fallback: theme.colorScheme.primary)
        : theme.colorScheme.primary;
    final hasError = _errorMessage != null;

    return AppBottomSheet(
      avoidKeyboard: true,
      contentPadding: EdgeInsets.fromLTRB(dims.xl, dims.xl, dims.xl, dims.xl),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _isRename ? 'Rename Tag' : 'New Tag',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!_isRename) ...[
            SizedBox(height: dims.xs),
            Text(
              'Create a tag to organize your notes',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
          SizedBox(height: dims.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            style: theme.textTheme.bodyLarge,
            onChanged: (_) {
              if (_errorMessage != null) {
                setState(() => _errorMessage = null);
              }
            },
            decoration: InputDecoration(
              hintText: 'Tag name',
              prefixIcon: Icon(
                LucideIcons.hash,
                color: hasError ? theme.colorScheme.error : accent,
              ),
              filled: true,
              fillColor: context.colorTokens.inputFill,
              errorText: _errorMessage,
              errorStyle: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              border: _border(),
              focusedBorder: _border(
                color: hasError ? theme.colorScheme.error : accent,
              ),
              errorBorder: _border(color: theme.colorScheme.error),
              focusedErrorBorder: _border(color: theme.colorScheme.error),
            ),
          ),
          SizedBox(height: dims.xl),
          SheetActionButtons(
            confirmText: _isRename ? 'Rename' : 'Create',
            onConfirm: _submit,
          ),
        ],
      ),
    );
  }
}
