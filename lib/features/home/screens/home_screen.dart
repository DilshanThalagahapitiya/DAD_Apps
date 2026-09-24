// ============================================================
// Home Screen - Role-Based Dashboard
// ============================================================
// Shows different dashboard based on user role:
//   - Admin: manage system
//   - Pending: awaiting approval
// Customers use CustomerShell, and Drivers/Riders use
// DriverRiderShell (both bottom-tab-bar shells) instead of this
// screen — see main.dart's StartupScreen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/widgets/language_selector.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/landing_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final role = auth.role;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.appName),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: LanguageSelector(),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, user?.fullName ?? '', role, scheme),
      body: _buildRoleDashboard(role, user?.fullName ?? ''),
    );
  }

  Widget _buildDrawer(BuildContext context, String name, String role, ColorScheme scheme) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: scheme.primary),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person_rounded, size: 36, color: scheme.primary),
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
            leading: const Icon(Icons.dashboard_rounded),
            title: Text(context.l10n.dashboard),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: Text(context.l10n.logout),
            onTap: () async {
              final auth = context.read<AuthProvider>();
              await auth.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LandingScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDashboard(String role, String name) {
    switch (role) {
      case UserRole.admin:
        return _AdminDashboard(name: name);
      default:
        return _PendingDashboard(name: name);
    }
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
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.welcomeNameAdmin(name),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
          const SizedBox(height: 6),
          Text(context.l10n.adminPortal,
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _DashboardCard(
                  icon: Icons.directions_car_rounded,
                  title: context.l10n.drivers,
                  subtitle: context.l10n.manageDrivers,
                  color: scheme.primary,
                ),
                _DashboardCard(
                  icon: Icons.person_pin_rounded,
                  title: context.l10n.riders,
                  subtitle: context.l10n.manageRiders,
                  color: context.statusColors.warning,
                ),
                _DashboardCard(
                  icon: Icons.local_taxi_rounded,
                  title: context.l10n.customers,
                  subtitle: context.l10n.manageCustomers,
                  color: context.statusColors.success,
                ),
                _DashboardCard(
                  icon: Icons.route_rounded,
                  title: context.l10n.rides,
                  subtitle: context.l10n.manageRides,
                  color: scheme.tertiary,
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
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: context.statusColors.warningContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.hourglass_top_rounded, size: 44, color: context.statusColors.warning),
            ),
            const SizedBox(height: 20),
            Text(context.l10n.welcomePlain(name),
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Text(
              context.l10n.pendingApproval,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
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

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 11.5, color: Theme.of(context).colorScheme.onSurfaceVariant)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
