// ============================================================
// App Constants
// ============================================================
// Central configuration for the SafeRide application.
// ============================================================

class AppConstants {
  // Backend API base URL (Next.js backend running on port 3000)
  // static const String baseUrl = 'http://localhost:3000';
    static const String baseUrl = 'https://endowment-slideshow-panorama.ngrok-free.dev';

  // Tenant-wise theming ------------------------------------------------
  // The tenant this app build belongs to. The admin panel saves a separate
  // brand color theme per tenant, and the backend returns the matching one
  // for whatever key this app sends in the `X-Tenant-Id` header.
  //
  // Set it at build time:
  //   flutter build apk --dart-define=TENANT_ID=hotel-abc
  //
  // Leave it unset ("") to use the global (default) brand colors.
  static const String tenantId = String.fromEnvironment('TENANT_ID', defaultValue: '');

  // App info
  static const String appName = 'Safe Ride';
  static const String appTagline = 'Drink and Drive Safe';
}

// User roles
class UserRole {
  static const String admin = 'ADMIN';
  static const String driver = 'DRIVER';
  static const String rider = 'RIDER';
  static const String customer = 'CUSTOMER';
  static const String hotel = 'HOTEL';
}