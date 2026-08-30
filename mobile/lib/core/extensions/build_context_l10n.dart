import 'package:flutter/widgets.dart';
import '../../l10n/app_localizations.dart';
import '../../l10n/app_localizations_en.dart';

/// Convenience accessor so widgets can use `context.l10n.someKey` instead of
/// `AppLocalizations.of(context).someKey`.
///
/// Falls back to English when the widget sits outside a `Localizations` scope.
/// In the app that never happens — `MaterialApp` installs the delegate — but
/// upstream's widget tests pump bare `MaterialApp`s, and a fallback keeps them
/// running unmodified instead of forcing a delegate into every test.
extension BuildContextL10n on BuildContext {
  AppLocalizations get l10n =>
      Localizations.of<AppLocalizations>(this, AppLocalizations) ??
      AppLocalizationsEn();
}
