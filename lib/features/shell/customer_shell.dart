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
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_surface.dart';
import '../../core/widgets/tab_bar_metrics.dart';
import '../auth/providers/auth_provider.dart';
import '../home/screens/customer_home_tab.dart';
import '../home/screens/customer_rides_screen.dart';
import '../legal/screens/terms_conditions_screen.dart';
import '../profile/screens/profile_screen.dart';

class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    // Refresh once on entry so the server's Terms & Conditions flag (and any
    // since-completed profile) is reflected immediately — a customer can only
    // request a driver after accepting the published terms.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<AuthProvider>().refreshUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final name = auth.user?.fullName ?? '';
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final tabs = [
      CustomerHomeTab(name: name),
      // isActive keeps the list fresh: a tab built before a ride changed
      // re-fetches the moment it becomes the visible tab.
      CustomerRidesScreen(embedded: true, isActive: _index == 1),
      const TermsConditionsScreen(embedded: true),
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
          // Tab bar itself carries the admin brand color (tinted glass)
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
                icon: const Icon(Icons.route_outlined),
                selectedIcon: const Icon(Icons.route_rounded),
                label: context.l10n.myRides,
              ),
              NavigationDestination(
                icon: const Icon(Icons.description_outlined),
                selectedIcon: const Icon(Icons.description_rounded),
                label: context.l10n.terms,
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
