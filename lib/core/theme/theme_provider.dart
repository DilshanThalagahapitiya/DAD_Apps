// ============================================================
// Theme Provider - loads the admin-configured brand colors
// ============================================================
// Mirrors LocaleProvider: caches the last-known primary/secondary
// color in shared_preferences (so the app doesn't flash back to
// the default color on every cold start) and refreshes them from
// GET /api/rates, which the admin panel's Appearance settings page
// writes to.
//
// When the colors change, notifyListeners() rebuilds the MaterialApp
// with the new seed, so the app updates *live* — no reinstall needed.
//
// Refreshes happen:
//   * at every app start (main() calls refresh()),
//   * whenever the app returns to the foreground (see didChangeAppLifecycleState),
//   * every [refreshInterval] while the app is running,
//   * on demand: context.read<ThemeProvider>().refresh()
//
// Failures keep whatever color is currently applied, and are logged so
// they are visible in `flutter run` output instead of silently ignored.
// ============================================================

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../network/api_client.dart';
import 'app_theme.dart';

class ThemeProvider extends ChangeNotifier with WidgetsBindingObserver {
  // Cache keys are per tenant — the same device may run app builds that belong
  // to different tenants, and each must keep its own last-known colors.
  String get _cacheSuffix {
    final tenant = ApiClient.instance.tenantId;
    return (tenant == null || tenant.isEmpty) ? '' : '_$tenant';
  }

  String get _primaryKey => 'dad_theme_primary$_cacheSuffix';
  String get _secondaryKey => 'dad_theme_secondary$_cacheSuffix';

  Color _seed = AppTheme.defaultSeed;
  Color? _secondarySeed;

  Color get seed => _seed;
  Color? get secondarySeed => _secondarySeed;

  // ---- Sync status (shown in Profile → the small theme footer) ----
  bool _isSyncing = false;
  bool _lastSyncOk = false;
  DateTime? _lastSyncAt;

  bool get isSyncing => _isSyncing;
  bool get lastSyncOk => _lastSyncOk;
  DateTime? get lastSyncAt => _lastSyncAt;

  /// The exact color currently applied to the app, e.g. "#1D2FBF".
  /// Handy to confirm what the admin panel sent actually reached the app.
  String get primaryHex => _toHex(_seed);
  String? get secondaryHex => _secondarySeed == null ? null : _toHex(_secondarySeed!);

  Timer? _timer;

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

  /// Keep the brand colors in sync with the admin panel for the whole app
  /// lifetime: re-check when the app comes back to the foreground and every
  /// [interval] while it is running (15s — the same cadence as the
  /// notification poll, so an admin color change shows up almost immediately).
  /// Call once, right after runApp().
  void startAutoRefresh({Duration interval = const Duration(seconds: 15)}) {
    WidgetsBinding.instance.addObserver(this);
    _timer?.cancel();
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Opening the app again (from recent apps) must pick up admin changes too
    if (state == AppLifecycleState.resumed) refresh();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Fetch the current brand colors from the backend and apply them.
  /// Safe to call at any time — a new theme is published (and the UI rebuilt)
  /// only when the colors actually changed. Retries a couple of times so a
  /// slow connection at app start does not leave the old color on screen.
  Future<void> refresh({int attempts = 3}) async {
    _isSyncing = true;

    for (var attempt = 1; attempt <= attempts; attempt++) {
      try {
        final res = await ApiClient.instance.get('/api/rates', auth: false);
        if (res is! Map) {
          debugPrint('[Theme] Unexpected /api/rates response: $res');
          break;
        }
        final rate = res['data'] is Map ? res['data']['rate'] : null;
        if (rate is! Map) {
          debugPrint('[Theme] /api/rates response has no rate object: $res');
          break;
        }
        await _apply(rate['primaryColor'] as String?, rate['secondaryColor'] as String?);
        _lastSyncOk = true;
        _lastSyncAt = DateTime.now();
        _isSyncing = false;
        debugPrint('[Theme] brand color synced: $primaryHex');
        notifyListeners();
        return;
      } catch (error) {
        debugPrint('[Theme] Brand color refresh failed (attempt $attempt/$attempts): $error');
        if (attempt < attempts) {
          await Future.delayed(Duration(milliseconds: 400 * attempt));
        }
      }
    }

    _lastSyncOk = false;
    _isSyncing = false;
    notifyListeners();
  }

  /// Apply the colors returned by the backend and persist them. Only the
  /// values actually sent are used, so a partial response can never wipe the
  /// currently applied colors.
  Future<void> _apply(String? primaryHex, String? secondaryHex) async {
    final primary = primaryHex == null ? null : _parseHex(primaryHex);
    final secondary = secondaryHex == null ? null : _parseHex(secondaryHex);

    var changed = false;
    if (primary != null && primary != _seed) {
      _seed = primary;
      changed = true;
    }
    if (secondary != null && secondary != _secondarySeed) {
      _secondarySeed = secondary;
      changed = true;
    }
    if (!changed) return;

    // Rebuilds MaterialApp with the new seed — the live color change
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (primaryHex != null) await prefs.setString(_primaryKey, primaryHex);
      if (secondaryHex != null) await prefs.setString(_secondaryKey, secondaryHex);
    } catch (_) {
      // Caching is best-effort only
    }
  }

  Color? _parseHex(String hex) {
    final cleaned = hex.replaceFirst('#', '').trim();
    if (cleaned.length != 6) return null;
    final value = int.tryParse(cleaned, radix: 16);
    if (value == null) return null;
    return Color(0xFF000000 | value);
  }

  /// "#1D2FBF" style representation of a color (for the Profile footer).
  static String _toHex(Color color) =>
      '#${(color.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase()}';
}

