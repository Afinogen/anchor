import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../extensions/build_context_l10n.dart';
import '../../features/settings/presentation/controllers/locale_preferences_controller.dart';

/// Compact language switcher (English / Русский) for pre-auth screens where
/// there is no Settings access yet.
class LanguageToggleButton extends ConsumerWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeControllerProvider);
    final theme = Theme.of(context);

    return PopupMenuButton<Locale>(
      tooltip: context.l10n.language,
      initialValue: locale,
      onSelected: (value) =>
          ref.read(localeControllerProvider.notifier).setLocale(value),
      itemBuilder: (context) => [
        _item(
          context,
          const Locale('en'),
          context.l10n.languageEnglish,
          locale,
        ),
        _item(
          context,
          const Locale('ru'),
          context.l10n.languageRussian,
          locale,
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              LucideIcons.languages,
              size: 16,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              locale.languageCode.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              LucideIcons.chevronDown,
              size: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<Locale> _item(
    BuildContext context,
    Locale value,
    String label,
    Locale current,
  ) {
    final selected = current.languageCode == value.languageCode;
    return PopupMenuItem<Locale>(
      value: value,
      child: Row(
        children: [
          Expanded(child: Text(label)),
          if (selected)
            Icon(
              LucideIcons.check,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
        ],
      ),
    );
  }
}
