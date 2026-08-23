import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/note_share.dart';
import '../../domain/note_share_permission.dart';
import '../../domain/user_search_result.dart';
import '../../data/repository/users_repository.dart';
import '../../data/repository/note_shares_repository.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/network/server_config_provider.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/theme/tokens/app_radius.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../core/widgets/app_icon_chip.dart';

class ShareNoteSheet extends ConsumerStatefulWidget {
  final String noteId;

  const ShareNoteSheet({super.key, required this.noteId});

  @override
  ConsumerState<ShareNoteSheet> createState() => _ShareNoteSheetState();
}

class _ShareNoteSheetState extends ConsumerState<ShareNoteSheet> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  List<UserSearchResult> _searchResults = [];
  List<UserSearchResult> _recentContacts = [];
  List<NoteShare> _shares = [];
  bool _isSearching = false;
  bool _isLoadingShares = true;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadShares();
    _loadRecentContacts();
    _searchController.addListener(_onSearchChanged);
  }

  /// Recent contacts that aren't already collaborators on this note.
  List<UserSearchResult> get _availableRecentContacts {
    final sharedUserIds = _shares.map((s) => s.sharedWithUser.id).toSet();
    return _recentContacts.where((u) => !sharedUserIds.contains(u.id)).toList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocus.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounceTimer?.cancel();
    final query = _searchController.text;

    if (query.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _searchUsers(query);
    });
  }

  Future<void> _loadShares() async {
    try {
      final repository = ref.read(noteSharesRepositoryProvider);
      final shares = await repository.getNoteShares(widget.noteId);
      if (mounted) {
        setState(() {
          _shares = shares;
          _isLoadingShares = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingShares = false);
        AppSnackbar.showError(context, message: 'Failed to load shares');
      }
    }
  }

  Future<void> _loadRecentContacts() async {
    try {
      final repository = ref.read(usersRepositoryProvider);
      final contacts = await repository.getRecentContacts();
      if (mounted) {
        setState(() => _recentContacts = contacts);
      }
    } catch (_) {
      // Recent contacts are a nice-to-have; ignore failures silently.
    }
  }

  Future<void> _searchUsers(String query) async {
    setState(() => _isSearching = true);
    try {
      final repository = ref.read(usersRepositoryProvider);
      final results = await repository.searchUsers(query);
      if (mounted) {
        final sharedUserIds = _shares.map((s) => s.sharedWithUser.id).toSet();
        setState(() {
          _searchResults = results
              .where((u) => !sharedUserIds.contains(u.id))
              .toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
      }
    }
  }

  Future<void> _shareWithUser(
    UserSearchResult user,
    NoteSharePermission permission,
  ) async {
    try {
      final repository = ref.read(noteSharesRepositoryProvider);
      await repository.shareNote(widget.noteId, user.id, permission);
      if (mounted) {
        _searchController.clear();
        setState(() => _searchResults = []);
        AppSnackbar.showSuccess(context, message: 'Shared with ${user.name}');
        _loadShares();
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: 'Failed to share');
      }
    }
  }

  Future<void> _updatePermission(
    String shareId,
    NoteSharePermission permission,
  ) async {
    try {
      final repository = ref.read(noteSharesRepositoryProvider);
      await repository.updateNoteSharePermission(
        widget.noteId,
        shareId,
        permission,
      );
      await _loadShares();
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: 'Failed to update');
      }
    }
  }

  Future<void> _revokeShare(NoteShare share) async {
    try {
      final repository = ref.read(noteSharesRepositoryProvider);
      await repository.revokeShare(widget.noteId, share.id);
      await _loadShares();
      if (mounted) {
        AppSnackbar.showSuccess(
          context,
          message: 'Removed ${share.sharedWithUser.name}',
        );
      }
    } catch (e) {
      if (mounted) {
        AppSnackbar.showError(context, message: 'Failed to remove');
      }
    }
  }

  void _showPermissionPicker(UserSearchResult user) {
    AppBottomSheet.show(
      context,
      builder: (ctx) => _PermissionPickerSheet(
        userName: user.name,
        onSelect: (permission) {
          Navigator.pop(ctx);
          _shareWithUser(user, permission);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final serverUrl = ref.watch(serverUrlProvider);
    final dims = context.dims;

    return AppBottomSheet(
      avoidKeyboard: true,
      maxHeightFactor: 0.7,
      icon: LucideIcons.userPlus,
      title: 'Share Note',
      subtitle: 'Collaborate with others',
      showDone: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dims.xl),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocus,
              style: theme.textTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                prefixIcon: Icon(
                  LucideIcons.search,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                suffixIcon: _isSearching
                    ? Padding(
                        padding: EdgeInsets.all(dims.sm),
                        child: const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(LucideIcons.x, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                filled: true,
                fillColor: context.colorTokens.inputFill,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.buttonBorder,
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.buttonBorder,
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: dims.md,
                  vertical: 14,
                ),
              ),
            ),
          ),

          SizedBox(height: dims.md),

          // Content
          Flexible(
            child: _searchResults.isNotEmpty
                ? _buildSearchResults(theme, serverUrl)
                : _buildDefaultContent(theme, serverUrl),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, ThemeData theme) {
    final dims = context.dims;
    return Padding(
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
              label,
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
    );
  }

  Widget _buildSearchResults(ThemeData theme, String? serverUrl) {
    final dims = context.dims;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Results', theme),
        SizedBox(height: dims.sm),
        ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.fromLTRB(dims.md, 0, dims.md, dims.xl),
          itemCount: _searchResults.length,
          itemBuilder: (context, index) {
            final user = _searchResults[index];
            return _UserTile(
              name: user.name,
              email: user.email,
              profileImage: user.profileImage,
              serverUrl: serverUrl,
              trailing: _addButton(theme, user),
              onTap: () => _showPermissionPicker(user),
            );
          },
        ),
      ],
    );
  }

  /// Trailing "+" button used to start sharing with a searched/recent user.
  Widget _addButton(ThemeData theme, UserSearchResult user) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          shape: BoxShape.circle,
        ),
        child: const Icon(LucideIcons.plus, size: AppIconSizes.sm),
      ),
      onPressed: () => _showPermissionPicker(user),
    );
  }

  /// Default (non-search) content: recent contacts followed by collaborators.
  Widget _buildDefaultContent(ThemeData theme, String? serverUrl) {
    if (_isLoadingShares) {
      return const Center(heightFactor: 3, child: CircularProgressIndicator());
    }

    final recent = _searchController.text.trim().length < 2
        ? _availableRecentContacts
        : <UserSearchResult>[];

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (recent.isNotEmpty) _buildRecentContacts(theme, serverUrl, recent),
          _buildSharesContent(theme, serverUrl),
        ],
      ),
    );
  }

  Widget _buildRecentContacts(
    ThemeData theme,
    String? serverUrl,
    List<UserSearchResult> recent,
  ) {
    final dims = context.dims;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Recently shared with', theme),
        SizedBox(height: dims.sm),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(dims.md, 0, dims.md, dims.sm),
          itemCount: recent.length,
          itemBuilder: (context, index) {
            final user = recent[index];
            return _UserTile(
              name: user.name,
              email: user.email,
              profileImage: user.profileImage,
              serverUrl: serverUrl,
              trailing: _addButton(theme, user),
              onTap: () => _showPermissionPicker(user),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSharesContent(ThemeData theme, String? serverUrl) {
    final dims = context.dims;
    if (_shares.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(dims.md),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                LucideIcons.users,
                size: 32,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
            SizedBox(height: dims.md),
            Text(
              'Not shared yet',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            SizedBox(height: dims.xxs),
            Text(
              'Search by name or email to invite collaborators',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Collaborators', theme),
        SizedBox(height: dims.sm),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(dims.md, 0, dims.md, dims.xl),
          itemCount: _shares.length,
          itemBuilder: (context, index) {
            final share = _shares[index];
            return _UserTile(
              name: share.sharedWithUser.name,
              email: share.sharedWithUser.email,
              profileImage: share.sharedWithUser.profileImage,
              serverUrl: serverUrl,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _PermissionChip(
                    permission: share.permission,
                    onTap: () => _showEditPermissionSheet(share),
                  ),
                  SizedBox(width: dims.xxs),
                  IconButton(
                    icon: Icon(
                      LucideIcons.x,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => _revokeShare(share),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _showEditPermissionSheet(NoteShare share) {
    AppBottomSheet.show(
      context,
      builder: (ctx) => _PermissionPickerSheet(
        userName: share.sharedWithUser.name,
        currentPermission: share.permission,
        onSelect: (permission) {
          Navigator.pop(ctx);
          _updatePermission(share.id, permission);
        },
      ),
    );
  }
}

// Permission picker bottom sheet
class _PermissionPickerSheet extends StatelessWidget {
  final String userName;
  final NoteSharePermission? currentPermission;
  final ValueChanged<NoteSharePermission> onSelect;

  const _PermissionPickerSheet({
    required this.userName,
    this.currentPermission,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final dims = context.dims;

    return AppBottomSheet(
      title: currentPermission == null
          ? 'Share with $userName'
          : 'Change permission',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PermissionOption(
            icon: LucideIcons.eye,
            title: 'Viewer',
            subtitle: 'Can view but not edit',
            isSelected: currentPermission == NoteSharePermission.viewer,
            onTap: () => onSelect(NoteSharePermission.viewer),
          ),
          _PermissionOption(
            icon: LucideIcons.edit3,
            title: 'Editor',
            subtitle: 'Can view and edit',
            isSelected: currentPermission == NoteSharePermission.editor,
            onTap: () => onSelect(NoteSharePermission.editor),
          ),
          SizedBox(height: dims.md),
        ],
      ),
    );
  }
}

class _PermissionOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _PermissionOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;

    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.xxs),
        padding: EdgeInsets.symmetric(horizontal: dims.md, vertical: dims.sm),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: AppRadius.buttonBorder,
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.3)
                : theme.colorScheme.onSurface.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            AppIconChip(
              icon: icon,
              selected: isSelected,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: dims.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                padding: EdgeInsets.all(dims.xxs),
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.check, size: AppIconSizes.xs),
              ),
          ],
        ),
      ),
    );
  }
}

// Permission chip widget
class _PermissionChip extends StatelessWidget {
  final NoteSharePermission permission;
  final VoidCallback onTap;

  const _PermissionChip({required this.permission, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditor = permission == NoteSharePermission.editor;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.xsBorder,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
          borderRadius: AppRadius.xsBorder,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isEditor ? LucideIcons.edit3 : LucideIcons.eye,
              size: AppIconSizes.xs,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(width: context.dims.xxs),
            Text(
              isEditor ? 'Editor' : 'Viewer',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              LucideIcons.chevronDown,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// Reusable user tile
class _UserTile extends StatelessWidget {
  final String name;
  final String email;
  final String? profileImage;
  final String? serverUrl;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _UserTile({
    required this.name,
    required this.email,
    this.profileImage,
    this.serverUrl,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.smBorder,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smBorder,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: dims.sm),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),
              borderRadius: AppRadius.smBorder,
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                _buildAvatar(theme),
                SizedBox(width: dims.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        email,
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
                ?trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme) {
    if (profileImage != null && profileImage!.isNotEmpty) {
      // Construct full URL if profileImage is a relative path
      String imageUrl = profileImage!;
      if (!imageUrl.startsWith('http') && serverUrl != null) {
        imageUrl = '$serverUrl$imageUrl';
      }
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => _fallbackAvatar(theme),
          errorWidget: (context, url, error) => _fallbackAvatar(theme),
        ),
      );
    }
    return _fallbackAvatar(theme);
  }

  Widget _fallbackAvatar(ThemeData theme) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
