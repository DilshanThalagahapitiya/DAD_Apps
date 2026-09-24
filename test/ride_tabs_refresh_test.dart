// ============================================================
// Ride tab freshness tests (driver/rider shells)
// ============================================================
// The shells keep every tab alive in an IndexedStack, so a list built before a
// ride changed used to keep showing stale data — a new admin assignment never
// appeared and an accepted ride never reached the Dashboard.
//
// These tests pin the fix:
//   * a tab that becomes visible re-fetches (Dashboard shows a ride that was
//     just accepted in the Upcoming tab),
//   * a server-reported ride change re-fetches the visible tab,
//   * hidden tabs stay quiet until they are shown.
// ============================================================

import 'dart:convert';

import 'package:dad_app/core/network/api_client.dart';
import 'package:dad_app/core/services/notification_service.dart';
import 'package:dad_app/core/theme/app_theme.dart';
import 'package:dad_app/features/home/screens/my_rides_screen.dart';
import 'package:dad_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

Map<String, dynamic> rideJson(String status) => {
      'id': 'r1',
      'status': status,
      'pickupLocation': 'Colombo Fort',
      'dropLocation': 'Nugegoda',
      'startTime': '2026-10-01T10:00:00.000Z',
      'customerName': 'Nimal',
      'customerNumber': '0771234567',
      'driverAccepted': true,
      'riderAccepted': true,
      'driver': {'id': 'd1', 'fullName': 'Driver One'},
      'rider': {'id': 'r2', 'fullName': 'Rider One'},
      'createdAt': '2026-09-30T09:00:00.000Z',
      'updatedAt': '2026-09-30T09:00:00.000Z',
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late int calls;
  late List<String> serverStatuses;

  setUp(() {
    calls = 0;
    serverStatuses = [];
    ApiClient.instance.setHttpClient(MockClient((request) async {
      calls++;
      return http.Response(
        jsonEncode({
          'success': true,
          'message': 'ok',
          'data': {'rides': serverStatuses.map(rideJson).toList()},
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    }));
  });

  Widget harness({required bool isActive}) => MaterialApp(
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
          body: MyRidesScreen(
            role: 'driver',
            statusFilter: 'UPCOMING,ONGOING', // the Dashboard tab
            embedded: true,
            isActive: isActive,
          ),
        ),
      );

  testWidgets('a tab that becomes visible re-fetches and shows the ride',
      (tester) async {
    // Nothing confirmed yet when the Dashboard tab was built in the background
    await tester.pumpWidget(harness(isActive: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(calls, 1);
    expect(find.textContaining('Colombo Fort'), findsNothing);

    // Both sides accepted in the Upcoming tab -> the user taps Dashboard
    serverStatuses = ['UPCOMING'];
    await tester.pumpWidget(harness(isActive: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, 2, reason: 're-fetched when it became the visible tab');
    expect(find.textContaining('Colombo Fort'), findsOneWidget);
  });

  testWidgets('a server-reported ride change re-fetches the visible tab',
      (tester) async {
    await tester.pumpWidget(harness(isActive: true));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(calls, 1);

    // What NotificationService does when its poll sees a status change
    serverStatuses = ['UPCOMING'];
    NotificationService.instance.ridesRevision.value++;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, 2, reason: 'the new ticket appears without restarting the app');
    expect(find.textContaining('Colombo Fort'), findsOneWidget);
  });

  testWidgets('a hidden tab does not re-fetch on a ride change', (tester) async {
    await tester.pumpWidget(harness(isActive: false));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(calls, 1);

    NotificationService.instance.ridesRevision.value++;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(calls, 1, reason: 'hidden tabs wait until they are shown');
  });
}
