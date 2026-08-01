import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/extensions/build_context_l10n.dart';

class EmptyNotesState extends StatelessWidget {
  const EmptyNotesState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.sparkles, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(context.l10n.captureIdeasHere),
          ],
        ),
      ),
    );
  }
}

class EmptySearchState extends StatelessWidget {
  const EmptySearchState({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.search, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(context.l10n.noMatchingNotes),
          ],
        ),
      ),
    );
  }
}
