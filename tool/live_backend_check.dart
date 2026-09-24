// ignore_for_file: avoid_print — this is a developer diagnostic script, the
// printed colors are its entire purpose.
// ============================================================
// MANUAL live check — app ⇄ backend brand-color round trip
// ============================================================
// Hit the *real* API (AppConstants.baseUrl) with the exact client and parsing
// the app uses, and print the color that gets applied to the theme.
//
// Run it explicitly (it needs network access, so it is NOT part of
// `flutter test`):
//
//   cd DAD_Apps/DAD_Apps
//   flutter test tool/live_backend_check.dart
//
// Use it whenever the app "does not show the color set in the admin panel":
//   * the printed "seed after refresh" must match the color saved in
//     Admin → Appearance (and the "secondary" line the accent color),
//   * if it stays on the default (#4C5FE8) the device/point cannot reach the
//     backend URL printed in the first line.
// ============================================================

import 'dart:io';

import 'package:dad_app/core/constants/app_constants.dart';
import 'package:dad_app/core/network/api_client.dart';
import 'package:dad_app/core/theme/theme_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('live: app fetches and applies the admin brand colors', () async {
    // flutter_test installs an HttpOverrides that fakes every network call with
    // an empty response — undo it so this check hits the real backend.
    HttpOverrides.global = null;

    // No shared_preferences setup needed: ThemeProvider treats caching as
    // best-effort, so a missing plugin never breaks the refresh.
    print('[live] backend: ${AppConstants.baseUrl}');
    print('[live] tenant:  ${ApiClient.instance.tenantId ?? "(none -> global colors)"}');

    final themeProvider = ThemeProvider();
    await themeProvider.loadCached();
    print('[live] seed before refresh: ${themeProvider.seed}');

    await themeProvider.refresh(attempts: 1);

    print('[live] seed after refresh:  ${themeProvider.seed}');
    print('[live] secondary after:     ${themeProvider.secondarySeed}');
  });
}
