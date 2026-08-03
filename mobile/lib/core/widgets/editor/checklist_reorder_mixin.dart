import 'dart:async';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';

/// A line in the document: its offset range and newline (block) attributes.
class ParsedLine {
  final int startOffset;

  /// Length including the trailing newline.
  final int length;
  final Map<String, dynamic>? newlineAttributes;

  ParsedLine({
    required this.startOffset,
    required this.length,
    required this.newlineAttributes,
  });

  String? get listType => newlineAttributes?[Attribute.list.key] as String?;
  bool get isChecklist => listType == 'checked' || listType == 'unchecked';
  bool get isChecked => listType == 'checked';
}

/// Keeps checklists sorted: unchecked items on top, checked items at the
/// bottom of their group. Toggles are detected on the document change stream
/// and the item is moved by composing a delta onto the live document.
mixin ChecklistReorderMixin<T extends StatefulWidget> on State<T> {
  /// Override to provide the QuillController
  QuillController get controller;

  /// Override to check if sorting is enabled
  bool get sortChecklistItems;

  StreamSubscription<DocChange>? _changesSub;
  bool _isSorting = false;

  /// Start watching [controller] for checkbox toggles. Call again after the
  /// controller instance changes.
  void attachChecklistSorting() {
    _changesSub?.cancel();
    _changesSub = controller.changes.listen(_onDocChange);
  }

  void detachChecklistSorting() {
    _changesSub?.cancel();
    _changesSub = null;
  }

  void _onDocChange(DocChange change) {
    if (!sortChecklistItems || _isSorting || !mounted) return;
    if (change.source != ChangeSource.local) return;

    final offset = _toggledNewlineOffset(change.change);
    if (offset == null) return;

    // A microtask runs before the editor's post-frame selection restore.
    scheduleMicrotask(() {
      if (!mounted || _isSorting) return;
      _sortToggledLine(offset);
    });
  }

  /// Returns the offset of the single newline whose `list` attribute was set
  /// to checked/unchecked by [delta], or null for any other kind of change.
  int? _toggledNewlineOffset(Delta delta) {
    var position = 0;
    int? found;
    for (final op in delta.toList()) {
      if (!op.isRetain) return null;
      final list = op.attributes?[Attribute.list.key];
      if (list == 'checked' || list == 'unchecked') {
        if (found != null || op.length != 1) return null;
        found = position;
      }
      position += op.length!;
    }
    return found;
  }

  void _sortToggledLine(int newlineOffset) {
    final lines = _parseDocumentLines();

    var lineIndex = -1;
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (newlineOffset >= line.startOffset &&
          newlineOffset < line.startOffset + line.length) {
        lineIndex = i;
        break;
      }
    }
    if (lineIndex == -1) return;

    final line = lines[lineIndex];
    if (!line.isChecklist) return;

    var groupStart = lineIndex;
    var groupEnd = lineIndex;
    while (groupStart > 0 && lines[groupStart - 1].isChecklist) {
      groupStart--;
    }
    while (groupEnd < lines.length - 1 && lines[groupEnd + 1].isChecklist) {
      groupEnd++;
    }

    int targetIndex;
    if (line.isChecked) {
      if (lineIndex == groupEnd) return;
      targetIndex = groupEnd;
    } else {
      var firstCheckedIndex = -1;
      for (var i = groupStart; i <= groupEnd; i++) {
        if (lines[i].isChecked) {
          firstCheckedIndex = i;
          break;
        }
      }
      if (firstCheckedIndex == -1 || lineIndex < firstCheckedIndex) return;
      targetIndex = firstCheckedIndex;
    }
    if (targetIndex == lineIndex) return;

    // Document.compose (and the history inverses of deltas) cannot delete
    // the final newline or insert after it; end-of-document moves retain it
    // and patch its attributes.
    final srcStart = line.startOffset;
    final srcLength = line.length;
    final delta = controller.document.toDelta();
    final docLength = controller.document.length;

    final move = Delta();
    if (targetIndex > lineIndex) {
      // Move down = pull the lines below it up in front of it.
      final blockLast = lines[targetIndex];
      final blockStart = srcStart + srcLength;
      final blockEnd = blockLast.startOffset + blockLast.length;
      if (blockEnd < docLength) {
        move.retain(srcStart);
        delta.slice(blockStart, blockEnd).toList().forEach(move.push);
        move
          ..retain(srcLength)
          ..delete(blockEnd - blockStart);
      } else {
        move
          ..retain(srcStart)
          ..delete(srcLength)
          ..retain(blockEnd - blockStart - 1)
          ..insert('\n', blockLast.newlineAttributes);
        delta.slice(srcStart, srcStart + srcLength - 1).toList().forEach(
          move.push,
        );
        move.retain(
          1,
          _attributeDiff(blockLast.newlineAttributes, line.newlineAttributes),
        );
      }
    } else {
      final insertAt = lines[targetIndex].startOffset;
      final srcEnd = srcStart + srcLength;
      if (srcEnd < docLength) {
        move.retain(insertAt);
        delta.slice(srcStart, srcEnd).toList().forEach(move.push);
        move
          ..retain(srcStart - insertAt)
          ..delete(srcLength);
      } else {
        // Toggled line is the last line of the document.
        final lineAbove = lines[lineIndex - 1];
        move.retain(insertAt);
        delta.slice(srcStart, srcEnd - 1).toList().forEach(move.push);
        move
          ..insert('\n', line.newlineAttributes)
          ..retain(srcStart - insertAt - 1)
          ..delete(srcLength)
          ..retain(
            1,
            _attributeDiff(line.newlineAttributes, lineAbove.newlineAttributes),
          );
      }
    }

    _isSorting = true;
    try {
      controller.compose(move, controller.selection, ChangeSource.local);
    } finally {
      _isSorting = false;
    }
  }

  /// Attribute map that turns [from] into [to] when applied via retain.
  Map<String, dynamic>? _attributeDiff(
    Map<String, dynamic>? from,
    Map<String, dynamic>? to,
  ) {
    final diff = <String, dynamic>{};
    for (final key in {...?from?.keys, ...?to?.keys}) {
      final before = from?[key];
      final after = to?[key];
      if (before != after) diff[key] = after;
    }
    return diff.isEmpty ? null : diff;
  }

  List<ParsedLine> _parseDocumentLines() {
    final lines = <ParsedLine>[];
    var offset = 0;
    var lineStart = 0;

    for (final op in controller.document.toDelta().toList()) {
      final data = op.data;
      if (data is! String) {
        // Embeds occupy one position and never contain a newline.
        offset += 1;
        continue;
      }

      var searchFrom = 0;
      while (true) {
        final newlineIndex = data.indexOf('\n', searchFrom);
        if (newlineIndex == -1) {
          offset += data.length - searchFrom;
          break;
        }
        offset += newlineIndex - searchFrom + 1;
        lines.add(
          ParsedLine(
            startOffset: lineStart,
            length: offset - lineStart,
            newlineAttributes: op.attributes,
          ),
        );
        lineStart = offset;
        searchFrom = newlineIndex + 1;
      }
    }

    return lines;
  }
}
