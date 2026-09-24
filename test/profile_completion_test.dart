// ============================================================
// Profile completion → dashboard hand-off tests
// ============================================================
// The shells (DriverRiderShell / CustomerShell) show a "Complete your
// profile" screen while userDetailsComplete / driverProfileComplete is false,
// and switch to the dashboard tabs as soon as that state turns true.
//
// The save screens publish the updated user straight from the
// PATCH /api/auth/me response via AuthProvider.applyUser(), so the gate flips
// without a second request that could fail silently. These tests pin that
// behaviour (the actual navigation is the shell rebuilding on notifyListeners).
// ============================================================

import 'package:dad_app/features/auth/providers/auth_provider.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> driverJson(Map<String, dynamic>? driverProfile) => {
      'id': 'u1',
      'email': 'driver@dad.com',
      'fullName': 'Dilshan Driver',
      'role': 'DRIVER',
      'status': 'APPROVED',
      'phone': '0771234567',
      'nic': '199012345678',
      if (driverProfile != null) 'driverProfile': driverProfile,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a saved driver profile opens the dashboard gate', () async {
    final auth = AuthProvider();

    // Right after a Google sign-up the DriverProfile row is empty -> gate closed
    await auth.applyUser(driverJson({
      'licenseNumber': '',
      'licenseFrontImage': '',
      'licenseBackImage': '',
      'vehicleType': '',
      'licenseCategory': 'LIGHT_WEIGHT',
    }));
    expect(auth.user!.driverProfileComplete, isFalse,
        reason: 'the complete-profile screen stays visible');

    // After "Save" the response carries everything the gate needs
    await auth.applyUser(driverJson({
      'licenseNumber': 'B1234567',
      'licenseFrontImage': '/uploads/front.jpg',
      'licenseBackImage': '/uploads/back.jpg',
      'vehicleType': 'CAR',
      'licenseCategory': 'LIGHT_WEIGHT',
      'licenseLightExpiryDate': '2028-01-01T00:00:00.000Z',
    }));

    expect(auth.user!.driverProfileComplete, isTrue,
        reason: 'the shell rebuilds into the dashboard tabs');
  });

  test('the save response notifies listeners so the shell rebuilds', () async {
    final auth = AuthProvider();
    var notifications = 0;
    auth.addListener(() => notifications++);

    final applied = await auth.applyUser(driverJson({
      'licenseNumber': 'B1234567',
      'licenseFrontImage': '/uploads/front.jpg',
      'licenseBackImage': '/uploads/back.jpg',
      'vehicleType': 'CAR',
      'licenseCategory': 'LIGHT_WEIGHT',
      'licenseLightExpiryDate': '2028-01-01T00:00:00.000Z',
    }));

    expect(applied, isTrue);
    expect(notifications, 1, reason: 'exactly one notify -> one rebuild');
  });

  test('a response without a user leaves the state untouched', () async {
    final auth = AuthProvider();
    final applied = await auth.applyUser(null);

    expect(applied, isFalse, reason: 'caller then falls back to refreshUser()');
    expect(auth.user, isNull);
  });

  test('personal details gate opens once name/phone/nic are saved', () async {
    final auth = AuthProvider();

    await auth.applyUser({
      'id': 'u2',
      'email': 'new@dad.com',
      'fullName': '',
      'firstName': '',
      'role': 'RIDER',
      'status': 'APPROVED',
      'phone': '',
      'nic': null,
    });
    expect(auth.user!.userDetailsComplete, isFalse);

    await auth.applyUser({
      'id': 'u2',
      'email': 'new@dad.com',
      'fullName': 'Nimal Rider',
      'role': 'RIDER',
      'status': 'APPROVED',
      'phone': '0771234567',
      'nic': '199512345678',
    });
    expect(auth.user!.userDetailsComplete, isTrue);
  });
}
