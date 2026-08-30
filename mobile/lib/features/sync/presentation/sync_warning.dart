import 'package:anchor/core/extensions/build_context_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/context_extensions.dart';
import '../../../core/theme/tokens/app_icon_sizes.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../data/sync_compatibility.dart';

/// Banner shown while a protocol mismatch is holding sync back.
class SyncWarning extends ConsumerWidget {
  const SyncWarning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compatibility = ref.watch(syncCompatibilityProvider).value;
    final message = compatibility?.localizedMessage(context.l10n);
    if (message == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final dims = context.dims;

    return Padding(
      padding: EdgeInsets.only(bottom: dims.sm),
      child: Material(
        color: theme.colorScheme.errorContainer,
        borderRadius: AppRadius.mdBorder,
        child: InkWell(
          borderRadius: AppRadius.mdBorder,
          onTap: () => _explain(context, compatibility!),
          child: Padding(
            padding: EdgeInsets.all(dims.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  LucideIcons.triangleAlert,
                  size: AppIconSizes.md,
                  color: theme.colorScheme.onErrorContainer,
                ),
                SizedBox(width: dims.sm),
                Expanded(
                  child: Text(
                    message,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  size: AppIconSizes.sm,
                  color: theme.colorScheme.onErrorContainer,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _explain(BuildContext context, SyncCompatibility compatibility) {
    final l10n = context.l10n;
    ConfirmDialog.show(
      context: context,
      icon: LucideIcons.triangleAlert,
      iconColor: Theme.of(context).colorScheme.error,
      title: compatibility.localizedTitle(l10n)!,
      message:
          '${compatibility.localizedMessage(l10n)}\n\n'
          '${l10n.syncWarningNotesStay}',
      cancelText: null,
      confirmText: l10n.gotIt,
    );
  }
}
