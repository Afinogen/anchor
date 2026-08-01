import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';

/// Convenience accessor so widgets can use `context.l10n.someKey` instead of
/// `AppLocalizations.of(context).someKey`.
extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
