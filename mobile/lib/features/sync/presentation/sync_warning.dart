import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/theme/context_extensions.dart';
import '../../../core/theme/tokens/app_radius.dart';
import '../data/sync_compatibility.dart';

class SyncWarning extends ConsumerWidget {
  const SyncWarning({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = ref.watch(syncCompatibilityProvider).value?.message;
    if (message == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final dims = context.dims;

    return Padding(
      padding: EdgeInsets.only(bottom: dims.sm),
      child: Container(
        padding: EdgeInsets.all(dims.sm),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: AppRadius.mdBorder,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.triangleAlert,
              size: 18,
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
          ],
        ),
      ),
    );
  }
}
