// ============================================================
// Customer Shell
// ============================================================
// Root scaffold for the CUSTOMER role: an IndexedStack of the
// four primary tabs plus a floating glass bottom tab bar
// (iOS-26 "liquid glass" style). Each tab keeps its own scroll
// / form state alive while switching.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/localization/l10n_ext.dart';
import '../../core/widgets/glass_surface.dart';
import '../auth/providers/auth_provider.dart';
import '../home/screens/customer_home_tab.dart';
import '../home/screens/customer_rides_screen.dart';
import '../home/screens/my_vehicle_screen.dart';
import '../profile/screens/profile_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.fullName ?? '';
    final scheme = Theme.of(context).colorScheme;

    final tabs = [
      CustomerHomeTab(name: name),
      const CustomerRidesScreen(embedded: true),
      const MyVehicleScreen(embedded: true),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _index, children: tabs),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom > 0 ? 8 : 16),
        child: GlassSurface(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.4)),
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
                icon: const Icon(Icons.route_outlined),
                selectedIcon: const Icon(Icons.route_rounded),
                label: context.l10n.myRides,
              ),
              NavigationDestination(
                icon: const Icon(Icons.directions_car_outlined),
                selectedIcon: const Icon(Icons.directions_car_rounded),
                label: context.l10n.myVehicle,
              ),
              NavigationDestination(
                icon: const Icon(Icons.person_outline_rounded),
                selectedIcon: const Icon(Icons.person_rounded),
                label: context.l10n.profile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
