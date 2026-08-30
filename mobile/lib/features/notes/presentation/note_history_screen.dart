import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/network/connectivity_provider.dart';
import '../../../core/providers/active_user_id_provider.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/context_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/widgets/app_section_header.dart';
import '../../../core/widgets/settings_card.dart';
import '../../../core/widgets/settings_row.dart';
import '../data/repository/note_history_repository.dart';
import '../data/repository/note_revisions_store.dart';
import '../data/repository/notes_repository.dart';
import '../domain/note.dart';
import '../domain/note_history.dart';
import '../domain/note_revision.dart';
import 'note_revision_screen.dart';
import 'package:anchor/core/theme/tokens/app_opacity.dart';
import 'package:anchor/core/widgets/app_page_scaffold.dart';

const double _minRowHeight = 48;
const double _badgeSize = 32;

/// Earlier versions of a note, newest first. Everything shown here is on the
/// device; the server is only asked for versions this device has not seen.
class NoteHistoryScreen extends ConsumerStatefulWidget {
  const NoteHistoryScreen({super.key, required this.noteId});

  final String noteId;

  @override
  ConsumerState<NoteHistoryScreen> createState() => _NoteHistoryScreenState();
}

class _NoteHistoryScreenState extends ConsumerState<NoteHistoryScreen> {
  final _scrollController = ScrollController();

  StreamSubscription<List<NoteRevision>>? _revisionsWatch;
  StreamSubscription<NoteHistoryPosition>? _positionWatch;
  StreamSubscription<Note?>? _noteWatch;

  List<NoteRevision> _revisions = const [];
  Note? _note;

  NoteHistoryPosition? _position;
  bool _isFetching = false;
  bool _fetchQueued = false;
  bool _fetchFailed = false;

  @override
  void initState() {
    super.initState();
    final store = ref.read(noteRevisionsStoreProvider);
    _revisionsWatch = store.watch(widget.noteId).listen((revisions) {
      if (mounted) setState(() => _revisions = revisions);
    });
    _positionWatch = store
        .watchPosition(widget.noteId)
        .listen(_onPositionChanged);
    _noteWatch = ref
        .read(notesRepositoryProvider)
        .watchNote(widget.noteId)
        .listen((note) {
          if (mounted) setState(() => _note = note);
        });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    unawaited(_revisionsWatch?.cancel());
    unawaited(_positionWatch?.cancel());
    unawaited(_noteWatch?.cancel());
    _scrollController.dispose();
    super.dispose();
  }

  void _onPositionChanged(NoteHistoryPosition position) {
    if (!mounted) return;
    final previous = _position;
    setState(() => _position = position);
    final wentStale = previous != null && previous.isRead && !position.isRead;
    if ((previous == null || wentStale) && !position.isComplete) {
      unawaited(_fetch());
    }
  }

  void _onScroll() {
    if (_fetchFailed) return;
    final scroll = _scrollController.position;
    if (scroll.pixels > scroll.maxScrollExtent - 300) unawaited(_fetch());
  }

  Future<void> _fetch({bool force = false}) async {
    if (_isFetching) {
      _fetchQueued = true;
      return;
    }
    if (!force && (_position?.isComplete ?? false)) return;
    if (!ref.read(isOnlineProvider)) {
      setState(() => _fetchFailed = true);
      return;
    }

    setState(() {
      _isFetching = true;
      _fetchFailed = false;
    });

    try {
      await ref.read(noteHistoryRepositoryProvider).fetch(widget.noteId);
    } catch (_) {
      if (mounted) setState(() => _fetchFailed = true);
    } finally {
      if (mounted) setState(() => _isFetching = false);
      if (_fetchQueued) {
        _fetchQueued = false;
        if (mounted) unawaited(_fetch());
      }
    }
  }

  /// Reads the history again from the newest version down.
  Future<void> _refresh() async {
    if (!ref.read(isOnlineProvider)) {
      setState(() => _fetchFailed = true);
      return;
    }
    await ref.read(noteRevisionsStoreProvider).markStale(widget.noteId);
    await _fetch(force: true);
  }

  Future<void> _open(String revisionId) async {
    unawaited(HapticFeedback.selectionClick());
    final restored = await context.push<bool>(
      '/note/${widget.noteId}/${AppRoutes.noteHistory}/$revisionId',
    );
    if (restored == true && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(isOnlineProvider, (previous, next) {
      if (next && previous != true) {
        unawaited(_fetchFailed ? _refresh() : _fetch());
      }
    });

    final theme = Theme.of(context);

    return AppPageScaffold(
      title: Text(context.l10n.history),
      body: RefreshIndicator.adaptive(
        onRefresh: _refresh,
        edgeOffset: AppPageScaffold.topInset(context),
        color: theme.colorScheme.primary,
        child: _buildBody(theme),
      ),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_revisions.isEmpty) {
      if (_isFetching) return const Center(child: CircularProgressIndicator());
      return _EmptyHistory(
        onRetry: _fetchFailed ? () => unawaited(_refresh()) : null,
      );
    }

    final dims = context.dims;
    final l10n = context.l10n;
    final showAuthors = historyHasMultipleAuthors(_revisions);
    final currentUserId = ref.read(activeUserIdProvider);
    final note = _note;

    return ListView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        dims.screenGutter,
        AppPageScaffold.topInset(context) + dims.md,
        dims.screenGutter,
        dims.xxl,
      ),
      children: [
        if (note != null) ...[
          _EntryCard(
            children: [
              _EntryTile(
                title: l10n.currentVersion,
                subtitle: note.updatedAt == null
                    ? null
                    : dayTimeLabel(note.updatedAt!, l10n: l10n),
                isCurrent: true,
                onTap: () => _open(currentVersionId),
              ),
            ],
          ),
          SizedBox(height: dims.lg),
        ],
        for (final day in groupRevisionsByDay(_revisions, l10n: l10n)) ...[
          AppSectionHeader(title: day.label),
          SizedBox(height: dims.xs),
          _EntryCard(
            children: [
              for (final revision in day.revisions)
                _EntryTile(
                  title: revisionTime(revision, l10n: l10n),
                  subtitle: _entrySubtitle(
                    revision,
                    showAuthors,
                    currentUserId,
                    l10n,
                  ),
                  author: showAuthors ? revision.author : null,
                  onTap: () => _open(revision.id),
                ),
            ],
          ),
          SizedBox(height: dims.lg),
        ],
        if (_isFetching)
          Padding(
            padding: EdgeInsets.all(dims.md),
            child: const Center(child: CircularProgressIndicator()),
          )
        else if (_fetchFailed)
          _ListFooter(
            text: l10n.historyUnreadFailed,
            onRetry: () => unawaited(_refresh()),
          )
        else if (_position?.isComplete ?? false)
          _ListFooter(text: l10n.historyRetention),
      ],
    );
  }
}

String? _entrySubtitle(
  NoteRevision revision,
  bool showAuthors,
  String? currentUserId,
  AppLocalizations l10n,
) {
  final parts = [
    if (revision.cause != RevisionCause.edit)
      revisionLabel(revision.cause, l10n: l10n),
    if (showAuthors) revisionAuthorName(revision, currentUserId, l10n: l10n),
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

class _EntryCard extends StatelessWidget {
  const _EntryCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      child: ClipRRect(
        borderRadius: AppRadius.lgBorder,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SettingsDivider(),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.title,
    this.subtitle,
    this.author,
    this.isCurrent = false,
    required this.onTap,
  });

  final String title;
  final String? subtitle;
  final NoteRevisionAuthor? author;
  final bool isCurrent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dims.lg, vertical: dims.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: _minRowHeight),
            child: Row(
              children: [
                if (isCurrent)
                  const _NoteBadge()
                else if (author != null)
                  _AuthorBadge(author: author!),
                if (isCurrent || author != null) SizedBox(width: dims.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: AppIconSizes.sm,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter({required this.text, this.onRetry});

  final String text;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          text,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        if (onRetry != null)
          TextButton(onPressed: onRetry, child: Text(context.l10n.tryAgain)),
      ],
    );
  }
}

class _NoteBadge extends StatelessWidget {
  const _NoteBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: _badgeSize,
      height: _badgeSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: AppRadius.smBorder,
      ),
      child: Icon(
        LucideIcons.fileText,
        size: AppIconSizes.sm,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

class _AuthorBadge extends StatelessWidget {
  const _AuthorBadge({required this.author});

  final NoteRevisionAuthor author;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: _badgeSize,
      height: _badgeSize,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          revisionAuthorInitial(author),
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;
    final unread = onRetry != null;

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: dims.xl,
              vertical: dims.lg,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  unread ? LucideIcons.cloudOff : LucideIcons.history,
                  size: 64,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
                ),
                SizedBox(height: dims.md),
                Text(
                  unread
                      ? context.l10n.historyCheckFailed
                      : context.l10n.historyEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(
                      alpha: AppOpacity.secondary,
                    ),
                  ),
                ),
                SizedBox(height: dims.xs),
                Text(
                  unread
                      ? context.l10n.historyOfflineHint
                      : context.l10n.historyEmptyHint,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (onRetry != null) ...[
                  SizedBox(height: dims.md),
                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(
                      LucideIcons.refreshCw,
                      size: AppIconSizes.sm,
                    ),
                    label: Text(context.l10n.tryAgain),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
