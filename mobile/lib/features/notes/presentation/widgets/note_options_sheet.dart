import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/context_extensions.dart';
import '../../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../../core/widgets/app_bottom_sheet.dart';

class NoteOptionsSheet extends StatelessWidget {
  final bool isReadOnly;
  final bool isNew;
  final bool isOwner;
  final bool isArchived;
  final VoidCallback onBackgroundTap;
  final VoidCallback onAttachmentTap;
  final VoidCallback onArchiveTap;
  final VoidCallback onDeleteTap;

  /// Null hides the option, for notes that have no history to read.
  final VoidCallback? onHistoryTap;

  const NoteOptionsSheet({
    super.key,
    required this.isReadOnly,
    required this.isNew,
    required this.isOwner,
    required this.isArchived,
    required this.onBackgroundTap,
    required this.onAttachmentTap,
    required this.onArchiveTap,
    required this.onDeleteTap,
    this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dims = context.dims;

    return AppBottomSheet(
      icon: LucideIcons.moreHorizontal,
      title: context.l10n.moreOptions,
      subtitle: context.l10n.moreOptionsSubtitle,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Options Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: dims.xl),
            child: SizedBox(
              width: double.infinity,
              child: Wrap(
                spacing: dims.lg,
                runSpacing: dims.xl,
                alignment: WrapAlignment.start,
                children: [
                  if (!isReadOnly)
                    _GridOptionTile(
                      icon: LucideIcons.palette,
                      title: context.l10n.background,
                      onTap: () {
                        Navigator.pop(context);
                        onBackgroundTap();
                      },
                    ),

                  if (!isReadOnly)
                    _GridOptionTile(
                      icon: LucideIcons.paperclip,
                      title: context.l10n.attachment,
                      onTap: () {
                        Navigator.pop(context);
                        onAttachmentTap();
                      },
                    ),

                  if (onHistoryTap != null)
                    _GridOptionTile(
                      icon: LucideIcons.history,
                      title: context.l10n.history,
                      onTap: () {
                        Navigator.pop(context);
                        onHistoryTap!();
                      },
                    ),

                  if (!isReadOnly && isOwner && !isNew) ...[
                    _GridOptionTile(
                      icon: isArchived
                          ? LucideIcons.archiveRestore
                          : LucideIcons.archive,
                      title: isArchived
                          ? context.l10n.unarchive
                          : context.l10n.archive,
                      onTap: () {
                        Navigator.pop(context);
                        onArchiveTap();
                      },
                    ),
                    _GridOptionTile(
                      icon: LucideIcons.trash2,
                      title: context.l10n.delete,
                      iconColor: theme.colorScheme.error,
                      textColor: theme.colorScheme.error,
                      backgroundColor: theme.colorScheme.error.withValues(
                        alpha: 0.1,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        onDeleteTap();
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: dims.xxl),
        ],
      ),
    );
  }
}

class _GridOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;
  final Color? backgroundColor;

  const _GridOptionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.iconColor,
    this.textColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveIconColor = iconColor ?? theme.colorScheme.onSurfaceVariant;
    final effectiveTextColor = textColor ?? theme.colorScheme.onSurface;
    final effectiveBgColor = backgroundColor ?? theme.colorScheme.surface;

    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: effectiveBgColor,
            shape: CircleBorder(
              side: BorderSide(
                color: effectiveIconColor.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              highlightColor: effectiveIconColor.withValues(alpha: 0.1),
              splashColor: effectiveIconColor.withValues(alpha: 0.1),
              child: SizedBox(
                width: 60,
                height: 60,
                child: Center(
                  child: Icon(
                    icon,
                    size: AppIconSizes.lg,
                    color: effectiveIconColor,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              color: effectiveTextColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
