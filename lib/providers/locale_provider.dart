import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('de'); // Standard: Deutsch

  Locale get locale => _locale;

  /// Initialisierung - lade gespeicherte Sprache
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString('languageCode') ?? 'de';
      _locale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      // Fallback zu Deutsch bei Fehlern
      _locale = const Locale('de');
    }
  }

  /// Sprache wechseln
  Future<void> setLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    
    _locale = newLocale;
    notifyListeners();
    
    // Sprache speichern
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('languageCode', newLocale.languageCode);
    } catch (e) {
      debugPrint('Error saving locale: $e');
    }
  }

  /// Zu Deutsch wechseln
  Future<void> setGerman() async {
    await setLocale(const Locale('de'));
  }

  /// Zu Englisch wechseln
  Future<void> setEnglish() async {
    await setLocale(const Locale('en'));
  }

  /// Sprache umschalten (DE ↔ EN)
  Future<void> toggleLanguage() async {
    if (_locale.languageCode == 'de') {
      await setEnglish();
    } else {
      await setGerman();
    }
  }

  /// Aktuelle Sprache als Text
  String get currentLanguageName {
    switch (_locale.languageCode) {
      case 'de': return 'Deutsch';
      case 'en': return 'English';
      default: return 'Deutsch';
    }
  }

  /// Aktuelle Sprache als Flag-Emoji
  String get currentLanguageFlag {
    switch (_locale.languageCode) {
      case 'de': return '🇩🇪';
      case 'en': return '🇺🇸';
      default: return '🇩🇪';
    }
  }

  /// Prüfe ob aktuelle Sprache Deutsch ist
  bool get isGerman => _locale.languageCode == 'de';

  /// Prüfe ob aktuelle Sprache Englisch ist  
  bool get isEnglish => _locale.languageCode == 'en';

  /// Alle verfügbaren Sprachen
  static const List<Locale> supportedLocales = [
    Locale('de'),
    Locale('en'),
  ];

  /// Sprach-Informationen für UI
  static const Map<String, Map<String, String>> languageInfo = {
    'de': {
      'name': 'Deutsch',
      'flag': '🇩🇪',
      'code': 'DE',
    },
    'en': {
      'name': 'English', 
      'flag': '🇺🇸',
      'code': 'EN',
    },
  };
}