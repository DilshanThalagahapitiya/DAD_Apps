// ============================================================
// Theme Provider - loads the admin-configured brand colors
// ============================================================
// Mirrors LocaleProvider: caches the last-known primary/secondary
// color in shared_preferences (so the app doesn't flash back to
// the default color on every cold start) and refreshes them from
// GET /api/rates, which the admin panel's Appearance settings page
// writes to. Falls back silently to the built-in defaults if the
// fetch fails (e.g. offline).
// ============================================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _primaryKey = 'dad_theme_primary';
  static const String _secondaryKey = 'dad_theme_secondary';

  Color _seed = AppTheme.defaultSeed;
  Color? _secondarySeed;

  Color get seed => _seed;
  Color? get secondarySeed => _secondarySeed;

  /// Restore the last cached brand colors (call before runApp).
  Future<void> loadCached() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final primaryHex = prefs.getString(_primaryKey);
      final secondaryHex = prefs.getString(_secondaryKey);
      if (primaryHex != null) _seed = _parseHex(primaryHex) ?? _seed;
      if (secondaryHex != null) _secondarySeed = _parseHex(secondaryHex);
    } catch (_) {
      // Ignore — fall back to the default seed
    }
  }

  /// Fetch the current brand colors from the backend and persist them.
  /// Safe to call repeatedly (e.g. after login, or periodically) — it's a
  /// no-op UI-wise unless the colors actually changed.
  Future<void> refresh() async {
    try {
      final res = await ApiClient.instance.get('/api/rates', auth: false);
      final rate = res['data']?['rate'] as Map<String, dynamic>?;
      final primaryHex = rate?['primaryColor'] as String?;
      final secondaryHex = rate?['secondaryColor'] as String?;

      final primary = primaryHex != null ? _parseHex(primaryHex) : null;
      final secondary = secondaryHex != null ? _parseHex(secondaryHex) : null;

      var changed = false;
      if (primary != null && primary != _seed) {
        _seed = primary;
        changed = true;
      }
      if (secondary != _secondarySeed) {
        _secondarySeed = secondary;
        changed = true;
      }

      if (changed) {
        notifyListeners();
        final prefs = await SharedPreferences.getInstance();
        if (primaryHex != null) await prefs.setString(_primaryKey, primaryHex);
        if (secondaryHex != null) await prefs.setString(_secondaryKey, secondaryHex);
      }
    } catch (_) {
      // Offline or server error — keep whatever is currently applied
    }
  }

  Color? _parseHex(String hex) {
    final cleaned = hex.replaceFirst('#', '').trim();
    if (cleaned.length != 6) return null;
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }
}
