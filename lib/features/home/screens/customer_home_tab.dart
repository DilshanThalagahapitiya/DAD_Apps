// ============================================================
// Customer Home Tab
// ============================================================
// The customer's "Home" tab inside CustomerShell: onboarding
// checks, latest ride status, rate table, and the primary
// "Request Driver" / "Call Us" actions. Extracted from the old
// HomeScreen._CustomerDashboard so it can live inside the
// bottom-tab-bar shell instead of a Drawer-based single screen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/screens/complete_profile_screen.dart';
import '../../auth/screens/complete_user_details_screen.dart';
import '../../legal/screens/terms_acceptance_screen.dart';
import 'request_driver_screen.dart';
import 'my_vehicle_screen.dart';
import '../widgets/rate_table_card.dart';
import '../widgets/latest_ride_status_card.dart';

class CustomerHomeTab extends StatefulWidget {
  final String name;
  /// Called after an action that may have changed ride state, so a sibling
  /// tab (e.g. My Rides) can be told to refresh next time it's shown.
  final VoidCallback? onRideActivity;
  const CustomerHomeTab({super.key, required this.name, this.onRideActivity});

  @override
  State<CustomerHomeTab> createState() => _CustomerHomeTabState();
}

class _CustomerHomeTabState extends State<CustomerHomeTab> {
  int _refreshTrigger = 0;

  bool _vehiclePromptShown = false;
  bool _vehicleDialogOpen = false;
  bool _detailsPromptShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkProfile());
  }

  Future<void> _checkProfile() async {
    if (!mounted) return;
    try {
      await context.read<AuthProvider>().refreshUser();
    } catch (_) {}
    if (!mounted) return;

    if (!_areUserDetailsComplete()) {
      if (!_detailsPromptShown) {
        _detailsPromptShown = true;
        await _openUserDetailsForm();
      }
      if (!mounted) return;
      if (!_areUserDetailsComplete()) return;
    }

    if (_vehiclePromptShown) return;
    if (!_isProfileComplete(context)) {
      _vehiclePromptShown = true;
      _showVehicleDetailsDialog();
    }
  }

  Future<bool> _openUserDetailsForm() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const CompleteUserDetailsScreen()),
    );
    if (!mounted) return saved ?? false;
    await context.read<AuthProvider>().refreshUser();
    if (mounted) setState(() {});
    return saved ?? false;
  }

  void _showVehicleDetailsDialog() {
    if (_vehicleDialogOpen || !mounted) return;
    _vehicleDialogOpen = true;
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sheet)),
        icon: Icon(Icons.directions_car_filled_rounded, color: context.statusColors.warning, size: 44),
        title: Text(context.l10n.addYourVehicleDetails, textAlign: TextAlign.center),
        content: Text(context.l10n.addVehicleDetailsBody, textAlign: TextAlign.center),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.l10n.later)),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _openVehicleDetailsForm();
            },
            icon: const Icon(Icons.directions_car_rounded, size: 18),
            label: Text(context.l10n.addVehicleDetails),
          ),
        ],
      ),
    ).whenComplete(() => _vehicleDialogOpen = false);
  }

  Future<void> _openVehicleDetailsForm() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MyVehicleScreen()),
    );
    if (!mounted) return;
    await context.read<AuthProvider>().refreshUser();
    if (mounted) setState(() {});
  }

  static Future<String?> _fetchContactPhone() async {
    try {
      final res = await ApiClient.instance.get('/api/rates');
      return res['data']['rate']?['contactPhone'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(context.l10n.welcomeName(widget.name),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: -0.4)),
          const SizedBox(height: 4),
          Text(context.l10n.customerPortal,
              style: TextStyle(fontSize: 14, color: scheme.onSurfaceVariant)),
          const SizedBox(height: 18),

          if (!_areUserDetailsComplete()) ...[
            _Banner(
              color: context.statusColors.danger,
              container: context.statusColors.dangerContainer,
              icon: Icons.assignment_ind_rounded,
              title: context.l10n.completeDetailsBanner,
              body: context.l10n.completeDetailsBannerBody,
              actionLabel: context.l10n.fillDetails,
              onAction: _openUserDetailsForm,
            ),
            const SizedBox(height: 14),
          ],

          if (_areUserDetailsComplete() && !(_isProfileComplete(context))) ...[
            _Banner(
              color: context.statusColors.warning,
              container: context.statusColors.warningContainer,
              icon: Icons.warning_amber_rounded,
              title: context.l10n.pleaseCompleteProfile,
              body: context.l10n.addVehicleLocationDetails,
              actionLabel: context.l10n.complete,
              onAction: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CompleteProfileScreen()),
                );
                if (mounted) {
                  context.read<AuthProvider>().refreshUser();
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 14),
          ],

          LatestRideStatusCard(refreshTrigger: _refreshTrigger),
          const SizedBox(height: 16),

          FilledButton.icon(
            onPressed: () async {
              final auth = context.read<AuthProvider>();
              final navigator = Navigator.of(context);
              // Terms & Conditions are required before a ride can be requested:
              // send the customer to the acceptance gate first.
              if (auth.termsAcceptanceRequired) {
                await navigator.push(
                  MaterialPageRoute(builder: (_) => const TermsAcceptanceScreen()),
                );
                // Still unaccepted (they backed out) — nothing to request
                if (auth.termsAcceptanceRequired) return;
              }
              await navigator.push(
                MaterialPageRoute(builder: (_) => const RequestDriverScreen()),
              );
              if (!mounted) return;
              setState(() => _refreshTrigger++);
              widget.onRideActivity?.call();
            },
            icon: const Icon(Icons.airport_shuttle_rounded),
            label: Text(context.l10n.requestDriver, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(backgroundColor: scheme.primary, foregroundColor: scheme.onPrimary),
          ),
          const SizedBox(height: 12),

          const RateTableCard(),
          const SizedBox(height: 12),

          FutureBuilder<String?>(
            future: _fetchContactPhone(),
            builder: (ctx, snap) {
              final phone = snap.data ?? '0763003678';
              return OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.l10n.callUsAt(phone)),
                      action: SnackBarAction(label: context.l10n.call, onPressed: () {}),
                    ),
                  );
                },
                icon: Icon(Icons.call_rounded, color: context.statusColors.success),
                label: Text(context.l10n.callUsLabel(phone), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.statusColors.success,
                  side: BorderSide(color: context.statusColors.success.withValues(alpha: 0.4)),
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

  bool _areUserDetailsComplete() {
    final user = context.read<AuthProvider>().user;
    if (user == null) return true;
    return user.userDetailsComplete;
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final Color container;
  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  const _Banner({
    required this.color,
    required this.container,
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: container,
        borderRadius: BorderRadius.circular(AppRadius.card - 4),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: color)),
                const SizedBox(height: 2),
                Text(body, style: TextStyle(fontSize: 11.5, color: color.withValues(alpha: 0.85))),
              ],
            ),
          ),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(foregroundColor: color),
            child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
