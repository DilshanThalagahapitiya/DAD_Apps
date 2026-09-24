// ============================================================
// Driver / Rider Shell
// ============================================================
// Root scaffold for the DRIVER and RIDER roles: an IndexedStack
// of four tabs plus the same floating glass bottom tab bar used
// by CustomerShell. Mirrors the driver/rider dashboard's old
// card layout (My Rides / Upcoming / History) as tabs, with a
// Settings tab (profile + logout) replacing the old Drawer.
//
// If personal details are incomplete (e.g. signed up via Google,
// which leaves phone/NIC empty), this renders CompleteUserDetailsScreen
// instead of the tabs — a hard block until the details are saved.
// For drivers, a second gate follows: license/authorization + vehicle
// preparation details (CompleteDriverProfileScreen) must also be
// complete before the tabs are shown.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/l10n_ext.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_surface.dart';
import '../../core/widgets/tab_bar_metrics.dart';
import '../auth/providers/auth_provider.dart';
import '../auth/screens/complete_driver_profile_screen.dart';
import '../auth/screens/complete_user_details_screen.dart';
import '../home/screens/my_rides_screen.dart';
import '../home/widgets/earnings_summary.dart';
import '../profile/screens/profile_screen.dart';

class DriverRiderShell extends StatefulWidget {
  /// "driver" or "rider" — determines the API endpoint / labels used
  /// throughout the tabs (see MyRidesScreen).
  final String role;
  const DriverRiderShell({super.key, required this.role});

  @override
  State<DriverRiderShell> createState() => _DriverRiderShellState();
}

class _DriverRiderShellState extends State<DriverRiderShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Refresh from the server once on entry so a Google sign-up's empty
    // phone/NIC (or a since-completed profile) is reflected immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().refreshUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // Hard block: personal details must be completed before the driver/
    // rider can use any part of the app.
    if (auth.user != null && !auth.user!.userDetailsComplete) {
      return const CompleteUserDetailsScreen(showBackButton: false);
    }

    // Second hard block, drivers only: license/authorization + vehicle
    // preparation details must also be complete.
    if (widget.role == 'driver' && auth.user != null && !auth.user!.driverProfileComplete) {
      return const CompleteDriverProfileScreen(showBackButton: false);
    }

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final name = auth.user?.fullName ?? '';
    final greeting = widget.role == 'rider'
        ? context.l10n.welcomeNameRider(name)
        : context.l10n.welcomeNameDriver(name);

    final tabs = [
      // Home — the confirmed/ongoing rides list (what used to be the
      // "My Rides" dashboard card), with a welcome greeting above it.
      // `isActive` keeps each list fresh: a tab that was built before a ride
      // changed re-fetches the moment it becomes the visible tab.
      MyRidesScreen(
        role: widget.role,
        statusFilter: 'UPCOMING,ONGOING',
        embedded: true,
        isActive: _index == 0,
        title: context.l10n.dashboard,
        greeting: greeting,
        // Earnings (their share of completed rides) + completed-ride count
        summary: EarningsSummary(role: widget.role),
      ),
      MyRidesScreen(
        role: widget.role,
        statusFilter: 'ASSIGNED',
        embedded: true,
        isActive: _index == 1,
        title: context.l10n.upcoming,
      ),
      MyRidesScreen(
        role: widget.role,
        statusFilter: 'COMPLETED,PENDING_REQUEST',
        embedded: true,
        isActive: _index == 2,
        title: context.l10n.history,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        // Reserve room for the floating tab bar, otherwise the last rows of
        // every tab are hidden behind it (extendBody draws the body under it).
        child: Padding(
          key: const Key('tabBarInset'),
          padding: EdgeInsets.only(bottom: floatingTabBarInset(context)),
          child: IndexedStack(index: _index, children: tabs),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom > 0 ? 8 : 16),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(28),
          tint: AppTheme.brandBarFill(scheme, isDark: isDark),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
          child: NavigationBar(
            backgroundColor: Colors.transparent,
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home_rounded),
                label: context.l10n.dashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_available_outlined),
                selectedIcon: const Icon(Icons.event_available_rounded),
                label: context.l10n.upcoming,
              ),
              NavigationDestination(
                icon: const Icon(Icons.history_rounded),
                selectedIcon: const Icon(Icons.history_rounded),
                label: context.l10n.history,
              ),
              NavigationDestination(
                icon: const Icon(Icons.settings_outlined),
                selectedIcon: const Icon(Icons.settings_rounded),
                label: context.l10n.settings,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
