// ============================================================
// Earnings summary tests (driver / rider dashboard tiles)
// ============================================================
// The tiles show what the driver/rider earned (their share of completed rides'
// fares, set per person by the admin) plus the number of completed rides.
// ============================================================

import 'dart:convert';

import 'package:dad_app/features/home/widgets/earnings_summary.dart';
import 'package:dad_app/l10n/app_localizations.dart';
import 'package:dad_app/core/network/api_client.dart';
import 'package:dad_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> requestedPaths;

  void stubEarnings({required double earnings, required int rides, required double sharePct}) {
    requestedPaths = [];
    ApiClient.instance.setHttpClient(MockClient((request) async {
      requestedPaths.add(request.url.path);
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'Earnings retrieved successfully',
          'data': {
            'earnings': {
              'role': 'driver',
              'sharePct': sharePct,
              'completedRides': rides,
              'grossFare': earnings * 100 / sharePct,
              'earnings': earnings,
              'currency': 'LKR',
            },
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }));
  }

  Widget harness(String role) => MaterialApp(
        theme: AppTheme.light(),
        locale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: EarningsSummary(role: role),
          ),
        ),
      );

  testWidgets('driver sees their earnings and completed ride count', (tester) async {
    stubEarnings(earnings: 6250, rides: 5, sharePct: 50);

    await tester.pumpWidget(harness('driver'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(requestedPaths, contains('/api/driver/earnings'));
    expect(find.text('My Earnings'), findsOneWidget);
    expect(find.text('Rs. 6,250'), findsOneWidget);
    expect(find.text('Rides'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('50% share'), findsOneWidget);
  });

  testWidgets('rider reads the rider endpoint and shows a fractional share', (tester) async {
    stubEarnings(earnings: 1234.5, rides: 3, sharePct: 32.5);

    await tester.pumpWidget(harness('rider'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(requestedPaths, contains('/api/rider/earnings'));
    expect(find.text('Rs. 1,234.5'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('32.5% share'), findsOneWidget);
  });

  testWidgets('a failed fetch shows a dash instead of crashing', (tester) async {
    ApiClient.instance.setHttpClient(
      MockClient((_) async => http.Response('{"success":false,"message":"boom"}', 500)),
    );

    await tester.pumpWidget(harness('driver'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('My Earnings'), findsOneWidget);
    expect(find.text('—'), findsNWidgets(2));
  });
}
