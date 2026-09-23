// ============================================================
// Customer Rides Screen — Ride History + Fare Breakdown
// ============================================================
// Shows ALL rides requested by the customer.
// Completed rides display the total fare + full fare breakdown
// (base fare, distance, waiting) so the customer knows exactly
// how the amount was calculated.
// When `embedded` is true, this renders as the "My Rides" tab
// inside CustomerShell (no own Scaffold/AppBar).
// ============================================================

import 'package:flutter/material.dart';
import 'dart:convert';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ride_status_chip.dart';
import '../../../core/widgets/fare_breakdown_card.dart';

class CustomerRidesScreen extends StatefulWidget {
  final bool embedded;
  const CustomerRidesScreen({super.key, this.embedded = false});

  @override
  State<CustomerRidesScreen> createState() => _CustomerRidesScreenState();
}

class _CustomerRidesScreenState extends State<CustomerRidesScreen> {
  List<dynamic> _rides = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchRides();
  }

  Future<void> _fetchRides() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.get('/api/customer/rides');
      setState(() {
        _rides = (res['data']['rides'] as List? ?? []);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = context.l10n.failed(e.toString()); _loading = false; });
    }
  }

  String _formatDate(String d) {
    final dt = DateTime.tryParse(d);
    if (dt == null) return d;
    final local = dt.toLocal();
    final date = '${local.year}-${local.month.toString().padLeft(2, '0')}-${local.day.toString().padLeft(2, '0')}';
    final time = '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    return '$date  $time';
  }

  // Parse the fare breakdown JSON stored on the ride
  Map<String, dynamic>? _parseBreakdown(dynamic raw) {
    if (raw == null || raw.toString().isEmpty) return null;
    try {
      final decoded = jsonDecode(raw.toString());
      return decoded is Map<String, dynamic> ? decoded : null;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error.isNotEmpty) {
      body = Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.error_outline_rounded, size: 48, color: context.statusColors.danger),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_error, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _fetchRides, child: Text(context.l10n.retry)),
        ]),
      );
    } else if (_rides.isEmpty) {
      body = Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.inbox_rounded, size: 64, color: scheme.onSurfaceVariant),
          const SizedBox(height: 12),
          Text(context.l10n.noRideRequests),
          const SizedBox(height: 4),
          Text(
            context.l10n.requestToGetStarted,
            textAlign: TextAlign.center,
            style: TextStyle(color: scheme.onSurfaceVariant),
          ),
        ]),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: _fetchRides,
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(20, widget.embedded ? 4 : 16, 20, 16),
          itemCount: _rides.length,
          itemBuilder: (ctx, i) {
            final ride = _rides[i] as Map<String, dynamic>;
            final status = ride['status']?.toString() ?? '';
            final totalFare = ride['totalFare'];
            final breakdown = _parseBreakdown(ride['fareBreakdown']);

            return Card(
              margin: const EdgeInsets.only(bottom: 14),
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
                          _formatDate(ride['startTime']?.toString() ?? ride['createdAt']?.toString() ?? ''),
                          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    Row(children: [
                      Icon(Icons.trip_origin_rounded, size: 18, color: context.statusColors.success),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${ride['pickupLocation'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                    ]),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(Icons.flag_rounded, size: 18, color: context.statusColors.danger),
                      const SizedBox(width: 6),
                      Expanded(child: Text('${ride['dropLocation'] ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                    ]),
                    const SizedBox(height: 8),

                    Text('${ride['vehicleType'] ?? '-'} • ${ride['transmission'] ?? '-'}',
                        style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                    if (ride['specialNote'] != null && ride['specialNote'].toString().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text('${ride['specialNote']}',
                            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                      ),

                    if ((ride['driver'] as Map?) != null || (ride['rider'] as Map?) != null) ...[
                      const SizedBox(height: 8),
                      Row(children: [
                        if ((ride['driver'] as Map?) != null) ...[
                          Icon(Icons.person_rounded, size: 15, color: scheme.primary),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text('${(ride['driver'] as Map?)?['fullName'] ?? '-'}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: scheme.primary)),
                          ),
                          const SizedBox(width: 10),
                        ],
                        if ((ride['rider'] as Map?) != null) ...[
                          Icon(Icons.person_pin_rounded, size: 15, color: context.statusColors.warning),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text('${(ride['rider'] as Map?)?['fullName'] ?? '-'}',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 12, color: context.statusColors.warning)),
                          ),
                        ],
                      ]),
                    ],

                    if (status == 'COMPLETED' && totalFare != null) ...[
                      const SizedBox(height: 14),
                      FareBreakdownCard(
                        title: context.l10n.fareSummary,
                        totalLabel: context.l10n.totalAmount,
                        totalFare: totalFare,
                        rows: [
                          if (breakdown != null) ...[
                            (context.l10n.baseFare, 'Rs. ${breakdown['baseFare'] ?? 0}'),
                            (context.l10n.distanceKm('${breakdown['distanceKm'] ?? 0}'), 'Rs. ${breakdown['distanceCost'] ?? 0}'),
                            if ((breakdown['waitingMin'] ?? 0) > 0)
                              (context.l10n.waitingMin('${breakdown['waitingMin']}'), 'Rs. ${breakdown['waitingCost'] ?? 0}'),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      );
    }

    if (widget.embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(context.l10n.myRides,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          ),
          Expanded(child: body),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.myRides)),
      body: body,
    );
  }
}
