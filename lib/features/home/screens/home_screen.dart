// ============================================================
// Home Screen - Role-Based Dashboard
// ============================================================
// Shows different dashboard based on user role:
//   - Driver: view rides
//   - Rider: book a ride
//   - Customer: request a driver
//   - Admin: manage system
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../auth/screens/complete_profile_screen.dart';
import 'request_driver_screen.dart';
import 'my_rides_screen.dart';
import 'customer_rides_screen.dart';
import 'my_vehicle_screen.dart';
import '../widgets/rate_table_card.dart';
import '../widgets/latest_ride_status_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final role = auth.role;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        title: Text(context.l10n.appName),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: LanguageSelector(foregroundColor: Colors.white),
          ),
          if (role == UserRole.customer)
            // Profile avatar at top-right (replaces logout icon position)
            GestureDetector(
              onTap: () => _showCustomerProfile(context, user?.fullName ?? '', role),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.red,
                  backgroundImage: (user?.googlePhotoUrl != null && user!.googlePhotoUrl!.isNotEmpty)
                      ? NetworkImage(user!.googlePhotoUrl!)
                      : null,
                  child: (user?.googlePhotoUrl != null && user!.googlePhotoUrl!.isNotEmpty)
                      ? null
                      : Text(
                          (user?.fullName ?? '').isEmpty ? '?' : user!.fullName![0].toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                        ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await auth.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
            ),
        ],
      ),
      drawer: _buildDrawer(context, user?.fullName ?? '', role),
      body: _buildRoleDashboard(role, user?.fullName ?? ''),
    );
  }

  Widget _buildDrawer(BuildContext context, String name, String role) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.indigo),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 36, color: Colors.indigo),
                ),
                const SizedBox(height: 12),
                Text(name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                Text(context.l10n.roleLabel(role),
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: Text(context.l10n.dashboard),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(context.l10n.logout),
            onTap: () async {
              final auth = context.read<AuthProvider>();
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  void _showCustomerProfile(BuildContext context, String fullName, String role) {
    // Get the Google photo URL from the auth provider (if signed in via Google)
    final user = context.read<AuthProvider>().user;
    final googlePhoto = user?.googlePhotoUrl;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.indigo,
                backgroundImage: (googlePhoto != null && googlePhoto.isNotEmpty)
                    ? NetworkImage(googlePhoto)
                    : null,
                child: (googlePhoto != null && googlePhoto.isNotEmpty)
                    ? null
                    : Text(
                        fullName.isEmpty ? '?' : fullName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 10),
              Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(context.l10n.roleLabel(role), style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.orange),
                title: Text(context.l10n.myVehicle),
                subtitle: Text(context.l10n.addOrEditVehicle),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyVehicleScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(context.l10n.logout),
                subtitle: Text(context.l10n.signOutOfAccount),
                onTap: () async {
                  Navigator.pop(ctx);
                  final auth = context.read<AuthProvider>();
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleDashboard(String role, String name) {
    switch (role) {
      case UserRole.driver:
        return _DriverDashboard(name: name);
      case UserRole.rider:
        return _RiderDashboard(name: name);
      case UserRole.customer:
        return _CustomerDashboard(name: name);
      case UserRole.admin:
        return _AdminDashboard(name: name);
      default:
        return _PendingDashboard(name: name);
    }
  }
}

// ============================================================
// Driver Dashboard
// ============================================================
class _DriverDashboard extends StatelessWidget {
  final String name;
  const _DriverDashboard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.welcomeNameDriver(name),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(context.l10n.driverPortal,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _DashboardCard(
                  icon: Icons.route,
                  title: context.l10n.myRides,
                  subtitle: context.l10n.confirmedRides,
                  color: Colors.indigo,
                  onTap: () {
                    // My Rides: only upcoming/ongoing rides (NOT completed — those go to History)
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyRidesScreen(statusFilter: 'UPCOMING,ONGOING')),
                    );
                  },
                ),
                _DashboardCard(
                  icon: Icons.event_available,
                  title: context.l10n.upcoming,
                  subtitle: context.l10n.pendingTicketsOnly,
                  color: Colors.orange,
                  onTap: () {
                    // Only pending tickets (ASSIGNED). Once both accept → UPCOMING → My Rides.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyRidesScreen(statusFilter: 'ASSIGNED')),
                    );
                  },
                ),
                _DashboardCard(
                  icon: Icons.history,
                  title: context.l10n.history,
                  subtitle: context.l10n.completedCancelledRides,
                  color: Colors.green,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyRidesScreen(statusFilter: 'COMPLETED,PENDING_REQUEST')),
                    );
                  },
                ),
                _DashboardCard(
                  icon: Icons.person,
                  title: context.l10n.profile,
                  subtitle: context.l10n.myDetails,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Rider Dashboard
// ============================================================
class _RiderDashboard extends StatelessWidget {
  final String name;
  const _RiderDashboard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.welcomeNameRider(name),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(context.l10n.riderPortal,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _DashboardCard(
                  icon: Icons.route,
                  title: context.l10n.myRides,
                  subtitle: context.l10n.confirmedRides,
                  color: Colors.indigo,
                  onTap: () {
                    // Only confirmed rides (both accepted → UPCOMING) show in My Rides
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyRidesScreen(role: 'rider', statusFilter: 'UPCOMING,ONGOING')),
                    );
                  },
                ),
                _DashboardCard(
                  icon: Icons.event_available,
                  title: context.l10n.upcomingRides,
                  subtitle: context.l10n.pendingTicketsOnly,
                  color: Colors.orange,
                  onTap: () {
                    // Only pending tickets (ASSIGNED). Once both accept → UPCOMING → My Rides.
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyRidesScreen(role: 'rider', statusFilter: 'ASSIGNED')),
                    );
                  },
                ),
                _DashboardCard(
                  icon: Icons.history,
                  title: context.l10n.completed,
                  subtitle: context.l10n.rideHistory,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyRidesScreen(role: 'rider', statusFilter: 'COMPLETED,PENDING_REQUEST')),
                    );
                  },
                ),
                _DashboardCard(
                  icon: Icons.person,
                  title: context.l10n.profile,
                  subtitle: context.l10n.myDetails,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Customer Dashboard
// ============================================================
class _CustomerDashboard extends StatefulWidget {
  final String name;
  const _CustomerDashboard({required this.name});

  @override
  State<_CustomerDashboard> createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<_CustomerDashboard> {
  int _refreshTrigger = 0;

  // Whether the "add vehicle details" popup has been shown already for this
  // dashboard session, so it doesn't nag repeatedly while the customer browses.
  bool _vehiclePromptShown = false;
  // Guards against opening the same dialog twice (auto-show + Request Driver tap).
  bool _vehicleDialogOpen = false;

  @override
  void initState() {
    super.initState();
    // After any signup/login the customer lands here. Refresh the profile from
    // the server so vehicle-detail status is accurate, then pop up the prompt.
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVehicleDetails());
  }

  /// Refresh the profile and, if the customer has not yet filled their own
  /// vehicle & location details, show the popup asking them to do so.
  Future<void> _checkVehicleDetails() async {
    if (!mounted) return;
    try {
      await context.read<AuthProvider>().refreshUser();
    } catch (_) {
      // Fall back to the locally cached profile if the refresh fails.
    }
    if (!mounted || _vehiclePromptShown) return;
    if (!_isProfileComplete(context)) {
      _vehiclePromptShown = true;
      _showVehicleDetailsDialog();
    }
  }

  /// Popup shown when the customer has no vehicle details yet — they must add
  /// them before they can hire (Request) a driver.
  void _showVehicleDetailsDialog() {
    if (_vehicleDialogOpen || !mounted) return;
    _vehicleDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.directions_car_filled,
            color: Colors.orange, size: 44),
        title: Text(context.l10n.addYourVehicleDetails,
            textAlign: TextAlign.center),
        content: Text(
          context.l10n.addVehicleDetailsBody,
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(context.l10n.later),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _openVehicleDetailsForm();
            },
            icon: const Icon(Icons.directions_car, size: 18),
            label: Text(context.l10n.addVehicleDetails),
          ),
        ],
      ),
    ).whenComplete(() => _vehicleDialogOpen = false);
  }

  /// Opens the vehicle details form (add/edit) and refreshes the profile
  /// afterwards so the completeness banner/dialog update correctly.
  Future<void> _openVehicleDetailsForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyVehicleScreen()),
    );
    if (!mounted) return;
    await context.read<AuthProvider>().refreshUser();
    if (mounted) setState(() {});
  }

  // We read the contact phone from the rate card (which fetches /api/rates).
  // For dial, use url_launcher via a simple approach — but to avoid adding deps,
  // store phone and let the rate card parse it. We'll refetch here with a small helper.
  static Future<String?> _fetchContactPhone() async {
    try {
      final res = await ApiClient.instance.get('/api/rates');
      return res['data']['rate']?['contactPhone'] as String?;
    } catch (_) {
      return null;
    }
  }

  void _openProfile(BuildContext context, String fullName, String role) {
    // Profile screen: shows avatar circle with first letter, logout, my vehicle.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.indigo,
                backgroundImage: (context.read<AuthProvider>().user?.googlePhotoUrl != null &&
                        context.read<AuthProvider>().user!.googlePhotoUrl!.isNotEmpty)
                    ? NetworkImage(context.read<AuthProvider>().user!.googlePhotoUrl!)
                    : null,
                child: (context.read<AuthProvider>().user?.googlePhotoUrl != null &&
                        context.read<AuthProvider>().user!.googlePhotoUrl!.isNotEmpty)
                    ? null
                    : Text(
                        fullName.isEmpty ? '?' : fullName[0].toUpperCase(),
                        style: const TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
              ),
              const SizedBox(height: 10),
              Text(fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(context.l10n.roleLabel(role), style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              // My Vehicle feature inside profile
              ListTile(
                leading: const Icon(Icons.directions_car, color: Colors.orange),
                title: Text(context.l10n.myVehicle),
                subtitle: Text(context.l10n.addOrEditVehicle),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MyVehicleScreen()),
                  );
                },
              ),
              // Logout inside profile
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: Text(context.l10n.logout),
                subtitle: Text(context.l10n.signOutOfAccount),
                onTap: () async {
                  Navigator.pop(ctx);
                  final auth = context.read<AuthProvider>();
                  await auth.logout();
                  if (context.mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.welcomeName(widget.name),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(context.l10n.customerPortal,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 16),

          // ⚠️ Profile Incomplete Notification
          if (!(_isProfileComplete(context))) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded,
                      color: Colors.orange.shade700, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.pleaseCompleteProfile,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.addVehicleLocationDetails,
                          style: TextStyle(
                              fontSize: 11, color: Colors.orange.shade800),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CompleteProfileScreen()),
                      );
                      // Refresh the profile status when returning
                      if (mounted) {
                        context.read<AuthProvider>().refreshUser();
                        setState(() {});
                      }
                    },
                    child: Text(context.l10n.complete,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ],
              ),
            ),
          ],

          // Latest Ride Request Status — shows driver/rider assignment & acknowledgement
          LatestRideStatusCard(refreshTrigger: _refreshTrigger),
          const SizedBox(height: 20),

          // My Rides — full ride history with fare amount & breakdown
          ElevatedButton.icon(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CustomerRidesScreen()),
              );
              // Refresh the latest status card when returning from ride history
              if (mounted) {
                setState(() => _refreshTrigger++);
              }
            },
            icon: const Icon(Icons.history, color: Colors.white),
            label: Text(context.l10n.myRidesAndFares, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),

          // Rate Table — prominent, full width
          const RateTableCard(),
          const SizedBox(height: 20),

          // Request Driver — FULL WIDTH button
          ElevatedButton.icon(
            onPressed: () async {
              // A customer must fill their own vehicle & location details
              // BEFORE they are allowed to hire a driver.
              final auth = context.read<AuthProvider>();
              // Ensure vehicle-detail status is fresh (login response may not
              // include customerProfile yet).
              if (auth.user?.customerProfile == null) {
                try {
                  await auth.refreshUser();
                } catch (_) {}
              }
              if (!context.mounted) return;
              final user = auth.user;
              if (user == null || !user.profileComplete) {
                _showVehicleDetailsDialog();
                return;
              }
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RequestDriverScreen()),
              );
              // Refresh the latest status card when returning from a new request
              if (mounted) {
                setState(() => _refreshTrigger++);
              }
            },
            icon: const Icon(Icons.airport_shuttle, color: Colors.white),
            label: Text(context.l10n.requestDriver, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),

          // Call Us — FULL WIDTH button (admin-set number from /api/rates contactPhone)
          FutureBuilder<String?>(
            future: _fetchContactPhone(),
            builder: (ctx, snap) {
              final phone = snap.data ?? '0763003678';
              return ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.callUsAt(phone)),
                      action: SnackBarAction(label: context.l10n.call, onPressed: () {}),
                    ),
                  );
                },
                icon: const Icon(Icons.call, color: Colors.white),
                label: Text(context.l10n.callUsLabel(phone), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isProfileComplete(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) return true;
    return user.profileComplete;
  }
}

// ============================================================
// Admin Dashboard
// ============================================================
class _AdminDashboard extends StatelessWidget {
  final String name;
  const _AdminDashboard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.welcomeNameAdmin(name),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(context.l10n.adminPortal,
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _DashboardCard(
                  icon: Icons.directions_car,
                  title: context.l10n.drivers,
                  subtitle: context.l10n.manageDrivers,
                  color: Colors.indigo,
                ),
                _DashboardCard(
                  icon: Icons.person_pin,
                  title: context.l10n.riders,
                  subtitle: context.l10n.manageRiders,
                  color: Colors.orange,
                ),
                _DashboardCard(
                  icon: Icons.local_taxi,
                  title: context.l10n.customers,
                  subtitle: context.l10n.manageCustomers,
                  color: Colors.green,
                ),
                _DashboardCard(
                  icon: Icons.route,
                  title: context.l10n.rides,
                  subtitle: context.l10n.manageRides,
                  color: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Pending Approval Dashboard
// ============================================================
class _PendingDashboard extends StatelessWidget {
  final String name;
  const _PendingDashboard({required this.name});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(context.l10n.welcomePlain(name),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(
              context.l10n.pendingApproval,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Small Action Button — compact card for secondary actions
// ============================================================
class _SmallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _SmallAction({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 140,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
        ]),
      ),
    );
  }
}

// ============================================================
// Dashboard Card
// ============================================================
class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}