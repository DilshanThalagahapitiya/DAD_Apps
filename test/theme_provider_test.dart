// ============================================================
// ThemeProvider tests - the app must pick up admin color changes
// ============================================================
// Proves the behaviour the admin panel depends on:
//   * the colors returned by GET /api/rates are applied to the theme,
//   * a change made later (app already running) is applied too,
//   * the whole MaterialApp theme is rebuilt with the new color,
//   * a broken/partial response never wipes the current colors.
//
// The network is stubbed with package:http's MockClient, so no real
// server is needed.
// ============================================================

import 'dart:convert';

import 'package:dad_app/core/network/api_client.dart';
import 'package:dad_app/core/theme/app_theme.dart';
import 'package:dad_app/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Stub /api/rates with the given colors (omit a color by passing null).
void stubRates(String? primary, String? secondary) {
  ApiClient.instance.setHttpClient(
    MockClient((request) async {
      expect(request.url.path, '/api/rates');
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Rate table retrieved successfully',
          'data': {
            'rate': {
              'id': 'test',
              'baseFare': 100,
              'perKmRate': 50,
              'contactPhone': '000',
              if (primary != null) 'primaryColor': primary,
              if (secondary != null) 'secondaryColor': secondary,
            },
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('applies the admin-configured colors from /api/rates', () async {
    stubRates('#1d2fbf', '#22c55e');

    final themeProvider = ThemeProvider();
    await themeProvider.loadCached();
    expect(themeProvider.seed, AppTheme.defaultSeed, reason: 'starts on the default');

    await themeProvider.refresh();

    expect(themeProvider.seed, const Color(0xFF1D2FBF));
    expect(themeProvider.secondarySeed, const Color(0xFF22C55E));
  });

  test('applies a color changed while the app is running', () async {
    stubRates('#1d2fbf', null);
    final themeProvider = ThemeProvider();
    await themeProvider.refresh();
    expect(themeProvider.seed, const Color(0xFF1D2FBF));

    // Admin picks a different color; the running app must follow
    stubRates('#FF7F50', null);
    await themeProvider.refresh();
    expect(themeProvider.seed, const Color(0xFFFF7F50));
  });

  test('notifies listeners so the UI rebuilds', () async {
    stubRates(null, null);
    final themeProvider = ThemeProvider();
    await themeProvider.refresh(); // no colors yet -> nothing to apply
    var notifications = 0;
    themeProvider.addListener(() => notifications++);

    stubRates('#1d2fbf', '#22c55e');
    await themeProvider.refresh();

    expect(notifications, greaterThan(0), reason: 'the UI is told to rebuild');
    expect(themeProvider.seed, const Color(0xFF1D2FBF));
  });

  test('reports the applied color and sync status (Profile footer)', () async {
    stubRates('#1d2fbf', '#22c55e');
    final themeProvider = ThemeProvider();
    expect(themeProvider.lastSyncOk, isFalse, reason: 'nothing synced yet');

    await themeProvider.refresh();

    expect(themeProvider.primaryHex, '#1D2FBF');
    expect(themeProvider.secondaryHex, '#22C55E');
    expect(themeProvider.lastSyncOk, isTrue);
    expect(themeProvider.lastSyncAt, isNotNull);
    expect(themeProvider.isSyncing, isFalse);
  });

  test('marks a failed sync but keeps the color already applied', () async {
    stubRates('#1d2fbf', null);
    final themeProvider = ThemeProvider();
    await themeProvider.refresh();
    expect(themeProvider.lastSyncOk, isTrue);

    ApiClient.instance.setHttpClient(
      MockClient((_) async => http.Response('{"success":false}', 500)),
    );
    await themeProvider.refresh(attempts: 1);

    expect(themeProvider.lastSyncOk, isFalse);
    expect(themeProvider.primaryHex, '#1D2FBF');
  });

  test('caches the colors for the next app start', () async {
    stubRates('#1d2fbf', '#22c55e');
    await ThemeProvider().refresh();

    // A fresh provider (cold start) restores the cached values
    final restarted = ThemeProvider();
    await restarted.loadCached();
    expect(restarted.seed, const Color(0xFF1D2FBF));
    expect(restarted.secondarySeed, const Color(0xFF22C55E));
  });

  test('a partial response keeps the colors already applied', () async {
    stubRates('#1d2fbf', '#22c55e');
    final themeProvider = ThemeProvider();
    await themeProvider.refresh();

    stubRates(null, null); // backend sent no colors (old/broken server)
    await themeProvider.refresh();

    expect(themeProvider.seed, const Color(0xFF1D2FBF));
    expect(themeProvider.secondarySeed, const Color(0xFF22C55E));
  });

  test('a server error keeps the colors already applied', () async {
    stubRates('#1d2fbf', '#22c55e');
    final themeProvider = ThemeProvider();
    await themeProvider.refresh();

    ApiClient.instance.setHttpClient(
      MockClient((_) async => http.Response('{"success":false,"message":"boom"}', 500)),
    );
    await themeProvider.refresh(attempts: 1);

    expect(themeProvider.seed, const Color(0xFF1D2FBF));
  });

  testWidgets('the MaterialApp theme rebuilds with the new color', (tester) async {
    stubRates('#1d2fbf', null);
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider<ThemeProvider>.value(
        value: themeProvider,
        child: Consumer<ThemeProvider>(
          builder: (context, provider, _) => MaterialApp(
            theme: AppTheme.light(seed: provider.seed),
            home: Builder(
              builder: (context) => Text(
                '${Theme.of(context).colorScheme.primary.toARGB32()}',
                key: const Key('primary'),
              ),
            ),
          ),
        ),
      ),
    );

    final before = tester.widget<Text>(find.byKey(const Key('primary'))).data;

    await themeProvider.refresh();
    await tester.pumpAndSettle();

    final after = tester.widget<Text>(find.byKey(const Key('primary'))).data;

    expect(after, isNot(before), reason: 'the rendered theme color changed');
    expect(
      after,
      AppTheme.light(seed: const Color(0xFF1D2FBF)).colorScheme.primary.toARGB32().toString(),
      reason: 'the rendered theme uses the admin-configured color',
    );
  });
}
