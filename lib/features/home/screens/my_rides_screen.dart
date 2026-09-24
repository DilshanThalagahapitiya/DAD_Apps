// ============================================================
// My Rides / Tickets Screen (Driver & Rider)
// ============================================================
// Shows received tickets (ASSIGNED), can Accept or Cancel.
// Displays all rides: ASSIGNED, UPCOMING, ONGOING, COMPLETED.
// Works for both driver and rider roles.
// When `embedded` is true, this renders as a tab inside
// DriverRiderShell (no own Scaffold/AppBar) with a plain title
// instead — see `title`.
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ride_status_chip.dart';
import '../../../core/widgets/fare_breakdown_card.dart';
import 'ride_edit_screen.dart';

class MyRidesScreen extends StatefulWidget {
  final String? statusFilter; // Optional: "UPCOMING", "COMPLETED", "ASSIGNED", etc.
  final String role; // "driver" or "rider" — determines which API endpoint to use
  final bool embedded;
  /// Overrides the title shown when embedded (falls back to the role's
  /// "My Rides / Tickets" label). Ignored when not embedded.
  final String? title;
  /// Optional "Welcome, {name}" line shown above the title when embedded
  /// (e.g. on the Dashboard/Home tab). Ignored when not embedded.
  final String? greeting;
  /// True while this list is the tab the user is looking at. The shells keep
  /// every tab alive in an IndexedStack, so a list that was built before a ride
  /// changed would otherwise keep showing stale data — it re-fetches when it
  /// becomes the visible tab.
  final bool isActive;
  /// Optional widget shown under the title when embedded — e.g. the earnings
  /// summary tiles on the Dashboard tab. Ignored when not embedded.
  final Widget? summary;
  const MyRidesScreen({
    super.key,
    this.statusFilter,
    this.role = 'driver',
    this.embedded = false,
    this.title,
    this.greeting,
    this.isActive = true,
    this.summary,
  });
  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  List<dynamic> _rides = [];
  bool _loading = true;
  String _error = '';

  // API endpoints based on role
  String get _ticketsEndpoint =>
      widget.role == 'rider' ? '/api/rider/rides' : '/api/driver/rides';

  @override
  void initState() {
    super.initState();
    // Re-fetch whenever the server reports a ride change (new assignment,
    // acceptance, start, completion) — only while this tab is visible.
    NotificationService.instance.ridesRevision.addListener(_onRidesChanged);
    _fetchRides();
  }

  @override
  void didUpdateWidget(covariant MyRidesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // This tab was built earlier and has stale data: refresh as soon as it
    // becomes the visible tab. This is how the Dashboard shows a ride that was
    // just accepted in the Upcoming tab.
    if (!oldWidget.isActive && widget.isActive) _fetchRides();
  }

  void _onRidesChanged() {
    if (widget.isActive) _fetchRides();
  }

  @override
  void dispose() {
    NotificationService.instance.ridesRevision.removeListener(_onRidesChanged);
    super.dispose();
  }

  List<dynamic> get _filteredRides {
    if (widget.statusFilter == null || widget.statusFilter!.isEmpty) return _rides;
    final statuses = widget.statusFilter!
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return _rides.where((r) => statuses.contains(r['status'] ?? '')).toList();
  }

  Future<void> _fetchRides() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.get(_ticketsEndpoint);
      setState(() {
        _rides = (res['data']['rides'] as List? ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = context.l10n.failed(e.toString()); _loading = false; });
    }
  }

  Future<void> _action(String rideId, String action) async {
    try {
      await ApiClient.instance.patch('$_ticketsEndpoint/$rideId', {'action': action});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(action == 'ACCEPT' ? context.l10n.ticketAccepted : context.l10n.ticketCancelled),
          backgroundColor: action == 'ACCEPT' ? context.statusColors.success : context.statusColors.danger,
        ),
      );
      _fetchRides();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.failed(e.toString())), backgroundColor: context.statusColors.danger),
      );
    }
  }

  String _formatDate(String d) {
    final dt = DateTime.tryParse(d);
    return dt == null ? d : dt.toLocal().toString().replaceRange(16, 19, '');
  }

  @override
  Widget build(BuildContext context) {
    final isRider = widget.role == 'rider';
    final scheme = Theme.of(context).colorScheme;

    final body = _loading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.error_outline_rounded, size: 48, color: context.statusColors.danger),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(_error, textAlign: TextAlign.center),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(onPressed: _fetchRides, child: Text(context.l10n.retry)),
                ]))
              : _filteredRides.isEmpty
                  ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.inbox_rounded, size: 64, color: scheme.onSurfaceVariant),
                      const SizedBox(height: 12),
                      const Text('No rides in this section'),
                      const SizedBox(height: 4),
                      Text(
                        widget.statusFilter == null || widget.statusFilter!.isEmpty
                            ? 'When admin assigns you a ride, it will appear here.'
                            : 'No ${widget.statusFilter!.toLowerCase().replaceAll('_', ' ')} rides yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ]))
                  : RefreshIndicator(
                      onRefresh: _fetchRides,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredRides.length,
                        itemBuilder: (ctx, i) {
                          final ride = _filteredRides[i];
                          final status = ride['status'] ?? '';
                          return InkWell(
                            // ASSIGNED tickets are ONLY for Accept/Cancel — not viewable.
                            // Only non-ASSIGNED rides (UPCOMING/ONGOING/COMPLETED) open the edit screen.
                            onTap: status == 'ASSIGNED'
                                ? null
                                : () async {
                                    // Refresh rides when returning from the edit/workflow screen
                                    // so COMPLETED status is always up to date (no stale Complete button).
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => RideEditScreen(ride: ride, role: widget.role),
                                      ),
                                    );
                                    _fetchRides();
                                  },
                            borderRadius: BorderRadius.circular(AppRadius.card),
                            child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      RideStatusChip(status: status),
                                      Text(
                                        _formatDate(ride['startTime'] ?? ''),
                                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Icon(Icons.trip_origin_rounded, size: 18, color: context.statusColors.success),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text('${ride['pickupLocation'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600))),
                                  ]),
                                  const SizedBox(height: 4),
                                  Row(children: [
                                    Icon(Icons.flag_rounded, size: 18, color: context.statusColors.danger),
                                    const SizedBox(width: 6),
                                    Expanded(child: Text('${ride['dropLocation'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600))),
                                  ]),
                                  const SizedBox(height: 10),
                                  Text('Customer: ${ride['customerName'] ?? '-'} • ${ride['customerNumber'] ?? ''}', style: const TextStyle(fontSize: 13)),
                                  Text('${ride['vehicleType'] ?? '-'} • ${ride['transmission'] ?? '-'}', style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                                  // Show fare amount directly on the list for completed rides
                                  if (status == 'COMPLETED' && (ride['totalFare'] ?? 0) > 0) ...[
                                    const SizedBox(height: 10),
                                    FareBreakdownCard(totalLabel: context.l10n.totalFare, totalFare: ride['totalFare']),
                                  ],
                                  // Show other side's status
                                  if (isRider) ...[
                                    Text(context.l10n.driverLabel(ride['driver']?['fullName'] ?? 'N/A'), style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                                    if (ride['driverCancelled'] == true)
                                      Text(context.l10n.driverCancelled, style: TextStyle(fontSize: 12, color: context.statusColors.danger, fontWeight: FontWeight.w600))
                                    else if (ride['driverAccepted'] == true)
                                      Text(context.l10n.driverAccepted, style: TextStyle(fontSize: 12, color: context.statusColors.success, fontWeight: FontWeight.w600))
                                    else if (status == 'ASSIGNED')
                                      Text(context.l10n.driverNotAccepted, style: TextStyle(fontSize: 12, color: context.statusColors.warning, fontWeight: FontWeight.w600)),
                                  ] else ...[
                                    Text(context.l10n.riderLabel(ride['rider']?['fullName'] ?? 'N/A'), style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                                    if (ride['riderCancelled'] == true)
                                      Text(context.l10n.riderCancelled, style: TextStyle(fontSize: 12, color: context.statusColors.danger, fontWeight: FontWeight.w600))
                                    else if (ride['riderAccepted'] == true)
                                      Text(context.l10n.riderAccepted, style: TextStyle(fontSize: 12, color: context.statusColors.success, fontWeight: FontWeight.w600))
                                    else if (status == 'ASSIGNED')
                                      Text(context.l10n.riderNotAccepted, style: TextStyle(fontSize: 12, color: context.statusColors.warning, fontWeight: FontWeight.w600)),
                                  ],
                                  if (ride['specialNote'] != null && ride['specialNote'].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text('${ride['specialNote']}', style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                    ),

                                  // Accept/Cancel buttons for ASSIGNED tickets.
                                  // If THIS user already accepted, show a waiting message instead.
                                  if (status == 'ASSIGNED') ...[
                                    const SizedBox(height: 12),
                                    if ((isRider && ride['riderAccepted'] == true) ||
                                        (!isRider && ride['driverAccepted'] == true))
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        decoration: BoxDecoration(
                                          color: context.statusColors.successContainer,
                                          borderRadius: BorderRadius.circular(AppRadius.card - 8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle_rounded, color: context.statusColors.success, size: 18),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                isRider
                                                    ? context.l10n.youAcceptedWaitingDriver
                                                    : context.l10n.youAcceptedWaitingRider,
                                                textAlign: TextAlign.center,
                                                style: TextStyle(color: context.statusColors.success, fontWeight: FontWeight.w600, fontSize: 13),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else ...[
                                      Row(children: [
                                        Expanded(
                                          child: FilledButton(
                                            onPressed: () => _action(ride['id'], 'ACCEPT'),
                                            style: FilledButton.styleFrom(backgroundColor: context.statusColors.success),
                                            child: Text(context.l10n.acceptTicket),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: OutlinedButton(
                                            onPressed: () => _action(ride['id'], 'CANCEL'),
                                            style: OutlinedButton.styleFrom(
                                              foregroundColor: context.statusColors.danger,
                                              side: BorderSide(color: context.statusColors.danger),
                                            ),
                                            child: Text(context.l10n.cancel),
                                          ),
                                        ),
                                      ]),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                        },
                      ),
                    );

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.greeting != null) ...[
                  Text(
                    widget.greeting!,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: scheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  widget.title ?? (isRider ? context.l10n.myRidesTicketsRider : context.l10n.myRidesTickets),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5),
                ),
                if (widget.summary != null) ...[
                  const SizedBox(height: 12),
                  widget.summary!,
                ],
              ],
            ),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isRider ? context.l10n.myRidesTicketsRider : context.l10n.myRidesTickets),
      ),
      body: body,
    );
  }
}