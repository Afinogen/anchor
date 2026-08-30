import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'link_utils.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_opacity.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../app_bottom_sheet.dart';

class LinkEditSheet extends StatefulWidget {
  final String initialText;
  final String initialUrl;
  final void Function(String text, String url) onSubmit;
  final VoidCallback? onRemove;

  const LinkEditSheet({
    super.key,
    this.initialText = '',
    this.initialUrl = '',
    required this.onSubmit,
    this.onRemove,
  });

  static Future<void> show(
    BuildContext context, {
    String initialText = '',
    String initialUrl = '',
    required void Function(String text, String url) onSubmit,
    VoidCallback? onRemove,
  }) {
    return AppBottomSheet.show(
      context,
      builder: (_) => LinkEditSheet(
        initialText: initialText,
        initialUrl: initialUrl,
        onSubmit: onSubmit,
        onRemove: onRemove,
      ),
    );
  }

  @override
  State<LinkEditSheet> createState() => _LinkEditSheetState();
}

class _LinkEditSheetState extends State<LinkEditSheet> {
  late final TextEditingController _textController;
  late final TextEditingController _urlController;
  late final FocusNode _urlFocus;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _urlController = TextEditingController(text: widget.initialUrl);
    _urlController.addListener(_onUrlChanged);
    _urlFocus = FocusNode();
    if (widget.initialUrl.isEmpty) {
      _maybePrefillFromClipboard();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _urlFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _urlController.removeListener(_onUrlChanged);
    _textController.dispose();
    _urlController.dispose();
    _urlFocus.dispose();
    super.dispose();
  }

  Future<void> _maybePrefillFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text ?? '';
      if (!mounted) return;
      if (_urlController.text.isEmpty && isLikelyUrl(text)) {
        _urlController.text = text.trim();
      }
    } catch (_) {}
  }

  void _onUrlChanged() => setState(() {});

  bool get _isEditing => widget.initialUrl.isNotEmpty;

  void _submit() {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;
    final text = _textController.text.trim().isEmpty
        ? url
        : _textController.text.trim();
    widget.onSubmit(text, url);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;
    final trimmedUrl = _urlController.text.trim();
    final canSubmit = trimmedUrl.isNotEmpty;

    return AppBottomSheet(
      avoidKeyboard: true,
      icon: LucideIcons.link,
      iconColor: theme.colorScheme.tertiary,
      title: _isEditing
          ? context.l10n.editLinkTitle
          : context.l10n.insertLinkTitle,
      trailing: IconButton(
        icon: const Icon(LucideIcons.x, size: AppIconSizes.md),
        color: theme.colorScheme.onSurface.withValues(
          alpha: AppOpacity.secondary,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TextField(
            controller: _textController,
            label: context.l10n.linkTextLabel,
            hint: trimmedUrl.isEmpty ? context.l10n.linkTextHint : trimmedUrl,
            icon: LucideIcons.type,
            padding: EdgeInsets.fromLTRB(dims.xl, 0, dims.xl, dims.xs),
          ),
          _TextField(
            controller: _urlController,
            focusNode: _urlFocus,
            label: context.l10n.urlLabel,
            hint: context.l10n.urlHint,
            icon: LucideIcons.globe,
            keyboardType: TextInputType.url,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(),
            padding: EdgeInsets.fromLTRB(dims.xl, dims.xs, dims.xl, dims.lg),
          ),
          _Actions(
            theme: theme,
            isEditing: _isEditing,
            canSubmit: canSubmit,
            onSubmit: _submit,
            onRemove: widget.onRemove == null
                ? null
                : () {
                    widget.onRemove!.call();
                    Navigator.pop(context);
                  },
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final EdgeInsets padding;

  const _TextField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.padding,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, size: 18),
          border: OutlineInputBorder(borderRadius: AppRadius.buttonBorder),
        ),
      ),
    );
  }
}

class _Actions extends StatelessWidget {
  final ThemeData theme;
  final bool isEditing;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback? onRemove;

  const _Actions({
    required this.theme,
    required this.isEditing,
    required this.canSubmit,
    required this.onSubmit,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final dims = context.dims;
    final showRemove = isEditing && onRemove != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(dims.xl, 0, dims.xl, dims.lg),
      child: Row(
        children: [
          if (showRemove) ...[
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onRemove,
                icon: const Icon(LucideIcons.unlink, size: AppIconSizes.sm),
                label: Text(
                  context.l10n.remove,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(
                    color: theme.colorScheme.error.withValues(alpha: 0.3),
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.buttonBorder,
                  ),
                ),
              ),
            ),
            SizedBox(width: context.dims.sm),
          ],
          Expanded(
            child: FilledButton(
              onPressed: canSubmit ? onSubmit : null,
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.tertiary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.buttonBorder,
                ),
              ),
              child: Text(
                isEditing ? context.l10n.save : context.l10n.insert,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
