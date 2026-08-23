import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../../core/theme/context_extensions.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/widgets/quill_preview.dart';
import '../../domain/note.dart';
import '../../domain/note_diff.dart';

/// The note's title in a version, with the title that replaced it when it
/// changed.
class NoteDiffTitle extends StatelessWidget {
  const NoteDiffTitle({super.key, required this.title, this.replacedBy});

  final String title;
  final String? replacedBy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.bold,
    );
    final replacement = replacedBy;

    if (replacement == null) {
      return Padding(
        padding: EdgeInsets.only(left: noteDiffGutter, bottom: context.dims.sm),
        child: Text(displayTitleOf(title), style: style),
      );
    }

    return Padding(
      padding: EdgeInsets.only(bottom: context.dims.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DiffRow(
            kind: DiffKind.removed,
            child: Text(
              displayTitleOf(title),
              style: style?.copyWith(decoration: TextDecoration.lineThrough),
            ),
          ),
          const SizedBox(height: 2),
          _DiffRow(
            kind: DiffKind.added,
            child: Text(displayTitleOf(replacement), style: style),
          ),
        ],
      ),
    );
  }
}

/// The note's text in a version. Lines that came or went are marked in the
/// margin; everything else reads as the note does.
class NoteDiffBody extends StatelessWidget {
  const NoteDiffBody({super.key, required this.diff});

  final ContentDiff diff;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final beforeMarkers = OrderedMarkerCounter();
    final afterMarkers = OrderedMarkerCounter();
    final rows = <Widget>[];

    for (final line in diff.lines) {
      // Each side of the diff numbers its own version of the list; unchanged
      // lines advance both and read as the note does now.
      String? ordered;
      if (line.kind != DiffKind.added) {
        ordered = beforeMarkers.markerFor(
          listType: line.listType,
          indent: line.indent,
        );
      }
      if (line.kind != DiffKind.removed) {
        ordered = afterMarkers.markerFor(
          listType: line.listType,
          indent: line.indent,
        );
      }
      final marker = ordered ?? (line.isBullet ? '•' : '');

      rows.add(
        _DiffRow(
          kind: line.kind,
          child: Padding(
            padding: EdgeInsets.only(left: line.indent * 16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (line.isChecklist)
                  Padding(
                    padding: const EdgeInsets.only(right: 8, top: 3),
                    child: Icon(
                      line.isChecked
                          ? LucideIcons.checkSquare
                          : LucideIcons.square,
                      size: AppIconSizes.sm,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  )
                else if (marker.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: SizedBox(
                      width: 18,
                      child: Text(marker, style: _lineStyle(context, line)),
                    ),
                  ),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        for (final span in line.spans)
                          TextSpan(
                            text: span.text,
                            style: _spanStyle(context, span, line),
                          ),
                      ],
                    ),
                    style: _lineStyle(context, line),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      rows.add(const SizedBox(height: 2));
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: rows);
  }
}

const double _barWidth = 3;
const double _rowGap = 10;

/// Left inset that lines plain text up with the text inside a diff row.
const double noteDiffGutter = _barWidth + _rowGap;

class _DiffRow extends StatelessWidget {
  const _DiffRow({required this.kind, required this.child});

  final DiffKind kind;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tokens = context.colorTokens;
    final accent = switch (kind) {
      DiffKind.same => null,
      DiffKind.added => tokens.success,
      DiffKind.removed => Theme.of(context).colorScheme.error,
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(_rowGap, 3, 6, 3),
      decoration: BoxDecoration(
        color: accent?.withValues(alpha: 0.08),
        border: Border(
          left: BorderSide(
            color: accent ?? Colors.transparent,
            width: _barWidth,
          ),
        ),
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(AppRadius.xs),
        ),
      ),
      child: child,
    );
  }
}

TextStyle _lineStyle(BuildContext context, DiffLine line) {
  final theme = Theme.of(context);
  var style =
      theme.textTheme.bodyMedium?.copyWith(height: 1.45) ?? const TextStyle();

  style = switch (line.header) {
    1 => style.copyWith(fontSize: 20, fontWeight: FontWeight.bold),
    2 => style.copyWith(fontSize: 18, fontWeight: FontWeight.bold),
    3 => style.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
    _ => style,
  };

  style = switch (line.block) {
    LineBlock.quote => style.copyWith(
      fontStyle: FontStyle.italic,
      color: theme.colorScheme.onSurface.withValues(alpha: 0.75),
    ),
    LineBlock.code => style.copyWith(fontFamily: 'monospace', fontSize: 13),
    null => style,
  };

  if (line.kind == DiffKind.removed) {
    style = style.copyWith(decoration: TextDecoration.lineThrough);
  }
  return style;
}

TextStyle _spanStyle(BuildContext context, DiffSpan span, DiffLine line) {
  final theme = Theme.of(context);
  final decorations = <TextDecoration>[
    if (line.kind == DiffKind.removed || span.isStrike)
      TextDecoration.lineThrough,
    if (span.isUnderline || span.isLink) TextDecoration.underline,
  ];

  return TextStyle(
    fontWeight: span.isBold ? FontWeight.bold : null,
    fontStyle: span.isItalic ? FontStyle.italic : null,
    decoration: decorations.isEmpty
        ? null
        : TextDecoration.combine(decorations),
    color: span.isLink ? theme.colorScheme.tertiary : null,
    fontFamily: span.isCode ? 'monospace' : null,
    backgroundColor: span.isCode
        ? theme.colorScheme.onSurface.withValues(alpha: 0.06)
        : null,
  );
}
