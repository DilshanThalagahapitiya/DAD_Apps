// ============================================================
// Floating tab bar inset tests
// ============================================================
// The shells draw the glass tab bar on top of the body (extendBody: true), so
// without a reserved inset the last rows of every tab are hidden behind the bar.
// These tests pin both the metric and its use in the shell.
// ============================================================

import 'dart:convert';

import 'package:dad_app/core/localization/locale_provider.dart';
import 'package:dad_app/core/network/api_client.dart';
import 'package:dad_app/core/theme/app_theme.dart';
import 'package:dad_app/core/theme/theme_provider.dart';
import 'package:dad_app/core/widgets/tab_bar_metrics.dart';
import 'package:dad_app/features/auth/providers/auth_provider.dart';
import 'package:dad_app/features/legal/providers/terms_provider.dart';
import 'package:dad_app/features/shell/driver_rider_shell.dart';
import 'package:dad_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the inset covers the bar, its gap and the device safe area',
      (tester) async {
    late double inset;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
        child: Builder(
          builder: (context) {
            inset = floatingTabBarInset(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(inset, kFloatingTabBarHeight + kFloatingTabBarBottomGap + kFloatingTabBarClearance + 34);
  });

  testWidgets('the driver shell leaves room for the floating tab bar',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    ApiClient.instance.setHttpClient(
      MockClient((_) async => http.Response(
            jsonEncode({
              'success': true,
              'message': 'ok',
              'data': {'rides': []},
            }),
            200,
            headers: {'content-type': 'application/json'},
          )),
    );

    final auth = AuthProvider();
    await auth.applyUser({
      'id': 'd1',
      'email': 'driver@dad.com',
      'fullName': 'Driver One',
      'role': 'DRIVER',
      'status': 'APPROVED',
      'phone': '0771234567',
      'nic': '199012345678',
      'driverProfile': {
        'licenseNumber': 'B1234567',
        'licenseCategory': 'LIGHT_WEIGHT',
        'licenseLightExpiryDate': '2028-01-01T00:00:00.000Z',
        'licenseFrontImage': '/uploads/front.jpg',
        'licenseBackImage': '/uploads/back.jpg',
        'vehicleType': 'CAR',
        'preferredGear': 'AUTO',
      },
    });

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
          ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
          // The Settings tab shows the admin-published Terms & Conditions
          ChangeNotifierProvider<TermsProvider>(create: (_) => TermsProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const DriverRiderShell(role: 'driver'),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final padding = tester.widget<Padding>(find.byKey(const Key('tabBarInset')));
    expect(
      padding.padding,
      const EdgeInsets.only(
        bottom: kFloatingTabBarHeight + kFloatingTabBarBottomGap + kFloatingTabBarClearance,
      ),
    );

    // The tab content must end above the tab bar, so nothing is hidden.
    final contentBottom = tester.getBottomLeft(find.byType(IndexedStack)).dy;
    final barTop = tester.getTopLeft(find.byType(NavigationBar)).dy;
    expect(contentBottom, lessThanOrEqualTo(barTop + 0.5),
        reason: 'tab content ends above the floating tab bar');
  });
}
