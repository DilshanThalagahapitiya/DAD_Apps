// ============================================================
// Locale Provider - persists the selected app language
// ============================================================
// Stores the user's chosen Locale in shared_preferences so the
// language selection survives app restarts. Defaults to the
// system locale on first launch.
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _prefsKey = 'dad_locale';

  // Supported languages (English, Sinhala, Tamil)
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('si'),
    Locale('ta'),
  ];

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  /// Load the saved locale (call before runApp or early in startup).
  Future<void> loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      if (saved != null) {
        _locale = Locale(saved);
        notifyListeners();
      }
    } catch (_) {
      // Ignore — fall back to the default English locale
    }
  }

  /// Change the app language and persist it.
  Future<void> setLocale(Locale locale) async {
    if (locale == _locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, locale.languageCode);
    } catch (_) {
      // Ignore persistence errors — the change still applies this session
    }
  }
}
