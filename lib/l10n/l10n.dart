import 'package:flutter/material.dart';
import 'app_localizations.dart';

// Export für einfacheren Zugriff
export 'app_localizations.dart';

class L10n {
  static final all = [
    const Locale('de'),
    const Locale('en'),
  ];
}

// Extension für einfacheren Zugriff mit Locale-Information
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
  Locale get currentLocale => Localizations.localeOf(this);
  bool get isGerman => currentLocale.languageCode == 'de';
}
