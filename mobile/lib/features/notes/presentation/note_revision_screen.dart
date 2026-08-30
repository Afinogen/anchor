import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/providers/active_user_id_provider.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../data/repository/note_revisions_store.dart';
import '../data/repository/notes_repository.dart';
import '../domain/note.dart';
import '../domain/note_diff.dart';
import '../domain/note_history.dart';
import '../domain/note_revision.dart';
import 'widgets/note_diff_view.dart';
import 'package:anchor/core/widgets/app_page_scaffold.dart';

/// Stands in for a revision id to read the note as it is now.
const String currentVersionId = 'current';

/// One version of a note, read against the version that followed it.
class NoteRevisionScreen extends ConsumerStatefulWidget {
  const NoteRevisionScreen({
    super.key,
    required this.noteId,
    required this.revisionId,
  });

  final String noteId;
  final String revisionId;

  @override
  ConsumerState<NoteRevisionScreen> createState() => _NoteRevisionScreenState();
}

class _NoteRevisionScreenState extends ConsumerState<NoteRevisionScreen> {
  StreamSubscription<List<NoteRevision>>? _revisionsWatch;
  StreamSubscription<Note?>? _noteWatch;

  List<NoteRevision> _revisions = const [];
  Note? _note;
  bool _hasRevisions = false;

  bool get _isCurrent => widget.revisionId == currentVersionId;

  @override
  void initState() {
    super.initState();
    _revisionsWatch = ref
        .read(noteRevisionsStoreProvider)
        .watch(widget.noteId)
        .listen((revisions) {
          if (!mounted) return;
          setState(() {
            _revisions = revisions;
            _hasRevisions = true;
          });
        });
    _noteWatch = ref
        .read(notesRepositoryProvider)
        .watchNote(widget.noteId)
        .listen((note) {
          if (mounted) setState(() => _note = note);
        });
  }

  @override
  void dispose() {
    unawaited(_revisionsWatch?.cancel());
    unawaited(_noteWatch?.cancel());
    super.dispose();
  }

  NoteRevision? get _revision {
    for (final revision in _revisions) {
      if (revision.id == widget.revisionId) return revision;
    }
    return null;
  }

  String? _diffedContent;
  String? _diffedCompared;
  ContentDiff? _diff;

  ContentDiff _diffFor(String? content, String? compared) {
    if (_diff == null ||
        content != _diffedContent ||
        compared != _diffedCompared) {
      _diffedContent = content;
      _diffedCompared = compared;
      _diff = diffNoteContent(content, compared);
    }
    return _diff!;
  }

  bool get _canRestore {
    final note = _note;
    return _revision != null && note != null && note.isActive && note.canEdit;
  }

  Future<void> _restore(NoteRevision revision) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      icon: LucideIcons.rotateCcw,
      title: context.l10n.restoreVersionTitle,
      message: context.l10n.restoreVersionMessage,
      confirmText: context.l10n.restore,
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref
          .read(notesRepositoryProvider)
          .restoreVersion(widget.noteId, revision);
      if (!mounted) return;
      unawaited(HapticFeedback.mediumImpact());
      AppSnackbar.showSuccess(context, message: context.l10n.versionRestored);
      context.pop(true);
    } catch (_) {
      if (!mounted) return;
      AppSnackbar.showError(
        context,
        message: context.l10n.versionRestoreFailed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final revision = _revision;

    return AppPageScaffold(
      title: _Title(
        revision: revision,
        isCurrent: _isCurrent,
        showAuthor: historyHasMultipleAuthors(_revisions),
        currentUserId: ref.read(activeUserIdProvider),
      ),
      actions: [
        if (!_isCurrent)
          TextButton.icon(
            onPressed: _canRestore ? () => _restore(revision!) : null,
            icon: const Icon(LucideIcons.rotateCcw, size: AppIconSizes.sm),
            label: Text(context.l10n.restore),
          ),
        SizedBox(width: context.dims.xxs),
      ],
      body: _buildBody(theme, revision),
    );
  }

  Widget _buildBody(ThemeData theme, NoteRevision? revision) {
    if (!_isCurrent && revision == null) {
      return _hasRevisions
          ? _Gone(theme: theme)
          : const Center(child: CircularProgressIndicator());
    }

    final note = _note;
    final compared = revision == null
        ? null
        : comparisonTarget(_revisions, revision.id);

    final title = revision?.title ?? note?.title ?? '';
    final content = revision == null ? note?.content : revision.content;
    final comparedTitle = compared == null ? note?.title : compared.title;
    final comparedContent = compared == null ? note?.content : compared.content;

    final titleChanged = comparedTitle != null && comparedTitle != title;
    final diff = _diffFor(content, comparedContent);
    final unchanged = revision != null && !titleChanged && diff.isUnchanged
        ? (compared != null
              ? context.l10n.versionSameAsNext
              : context.l10n.versionSameAsCurrent)
        : null;

    final dims = context.dims;
    return ListView(
      padding: EdgeInsets.fromLTRB(
        dims.md,
        AppPageScaffold.topInset(context) + dims.md,
        dims.md,
        dims.xxl,
      ),
      children: [
        if (unchanged != null)
          Padding(
            padding: EdgeInsets.only(bottom: dims.sm, left: noteDiffGutter),
            child: Text(
              unchanged,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        NoteDiffTitle(
          title: title,
          replacedBy: titleChanged ? comparedTitle : null,
        ),
        if (diff.lines.isEmpty)
          Padding(
            padding: const EdgeInsets.only(left: noteDiffGutter),
            child: Text(
              context.l10n.versionNoText,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          )
        else
          NoteDiffBody(diff: diff),
      ],
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({
    required this.revision,
    required this.isCurrent,
    required this.showAuthor,
    required this.currentUserId,
  });

  final NoteRevision? revision;
  final bool isCurrent;
  final bool showAuthor;
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final entry = revision;
    final subtitle = entry == null
        ? null
        : [
            if (showAuthor)
              revisionAuthorName(entry, currentUserId, l10n: l10n),
            ?revisionHint(entry.cause, l10n: l10n),
          ].join(' · ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isCurrent
              ? l10n.currentVersion
              : entry == null
              ? l10n.versionTitle
              : revisionDayTime(entry, l10n: l10n),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        if (subtitle != null && subtitle.isNotEmpty)
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _Gone extends StatelessWidget {
  const _Gone({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(context.dims.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.fileQuestion,
              size: 64,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
            ),
            SizedBox(height: context.dims.md),
            Text(
              context.l10n.versionGone,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
