// ============================================================
// Latest Ride Request Status Card (Customer)
// ============================================================
// Shows the latest ride request's status on the customer home:
//   - Request submitted? (PENDING_REQUEST)
//   - Driver & Rider assigned? (ASSIGNED)
//   - Did the driver acknowledge? (driverAccepted)
//   - Did the rider acknowledge? (riderAccepted)
//   - Request cancelled? (driverCancelled / riderCancelled)
//   - Ride ongoing / completed (ONGOING / COMPLETED)
// Supports an external refreshTrigger to refetch when the parent
// knows the data changed (e.g. after submitting a new request).
// ============================================================

import 'package:flutter/material.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/ride_status_chip.dart';
import '../../../core/widgets/fare_breakdown_card.dart';

class LatestRideStatusCard extends StatefulWidget {
  final int refreshTrigger;
  const LatestRideStatusCard({super.key, this.refreshTrigger = 0});

  @override
  State<LatestRideStatusCard> createState() => _LatestRideStatusCardState();
}

class _LatestRideStatusCardState extends State<LatestRideStatusCard> {
  Map<String, dynamic>? _ride;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchLatest();
  }

  @override
  void didUpdateWidget(covariant LatestRideStatusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.refreshTrigger != oldWidget.refreshTrigger) {
      _fetchLatest();
    }
  }

  Future<void> _fetchLatest() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final res = await ApiClient.instance.get('/api/customer/rides?limit=1');
      final rides = res['data']['rides'] as List? ?? [];
      setState(() {
        _ride = rides.isEmpty ? null : (rides.first as Map<String, dynamic>);
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

  String _statusLabel(String status) {
    switch (status) {
      case 'PENDING_REQUEST': return context.l10n.waitingForAdminAssign;
      case 'ASSIGNED': return context.l10n.assignedWaitingAccept;
      case 'UPCOMING': return context.l10n.scheduledBothAccepted;
      case 'ONGOING': return context.l10n.rideInProgress;
      case 'COMPLETED': return context.l10n.rideCompleted;
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.notifications_active_rounded, color: scheme.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  context.l10n.latestRequestStatus,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.refresh_rounded, size: 18, color: scheme.onSurfaceVariant),
                  onPressed: _fetchLatest,
                  tooltip: context.l10n.refresh,
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Icon(Icons.error_outline_rounded, color: context.statusColors.danger, size: 32),
                    const SizedBox(height: 8),
                    Text(_error, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 8),
                    ElevatedButton(onPressed: _fetchLatest, child: Text(context.l10n.retry)),
                  ],
                ),
              )
            else if (_ride == null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.inbox_rounded, size: 40, color: scheme.onSurfaceVariant),
                      const SizedBox(height: 8),
                      Text(context.l10n.noRideRequestsFull),
                      Text(
                        context.l10n.yourLatestRequestStatus,
                        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              _buildStatusContent(_ride!),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusContent(Map<String, dynamic> ride) {
    final status = ride['status'] ?? 'PENDING_REQUEST';
    final driver = ride['driver'] as Map<String, dynamic>?;
    final rider = ride['rider'] as Map<String, dynamic>?;
    final driverAccepted = ride['driverAccepted'] == true;
    final riderAccepted = ride['riderAccepted'] == true;
    final driverCancelled = ride['driverCancelled'] == true;
    final riderCancelled = ride['riderCancelled'] == true;
    final isCancelled = driverCancelled || riderCancelled;
    final style = rideStatusStyle(context, status);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: BorderRadius.circular(AppRadius.card - 6),
          ),
          child: Row(
            children: [
              Icon(style.icon, color: style.color, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.replaceAll('_', ' '),
                      style: TextStyle(
                        color: style.color,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _statusLabel(status),
                      style: TextStyle(fontSize: 11, color: style.color.withValues(alpha: 0.8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        _InfoRow(icon: Icons.trip_origin_rounded, color: context.statusColors.success, text: '${ride['pickupLocation'] ?? '-'}'),
        _InfoRow(icon: Icons.flag_rounded, color: context.statusColors.danger, text: '${ride['dropLocation'] ?? '-'}'),
        _InfoRow(icon: Icons.schedule_rounded, color: Theme.of(context).colorScheme.primary, text: _formatDate('${ride['startTime'] ?? ''}')),
        if (ride['vehicleType'] != null && ride['vehicleType'].toString().isNotEmpty)
          _InfoRow(icon: Icons.directions_car_rounded, color: context.statusColors.warning, text: '${ride['vehicleType']} • ${ride['transmission'] ?? '-'}'),
        if (ride['specialNote'] != null && ride['specialNote'].toString().isNotEmpty)
          _InfoRow(icon: Icons.notes_rounded, color: Theme.of(context).colorScheme.onSurfaceVariant, text: '${ride['specialNote']}'),

        const SizedBox(height: 12),
        const Divider(height: 1),

        const SizedBox(height: 8),
        _AssignedUserTile(
          icon: Icons.person,
          label: 'Driver',
          name: driver?['fullName'] ?? 'Not assigned yet',
          accepted: driverAccepted,
          cancelled: driverCancelled,
          isAssigned: driver != null,
        ),

        const SizedBox(height: 6),
        _AssignedUserTile(
          icon: Icons.person_pin,
          label: 'Rider',
          name: rider?['fullName'] ?? 'Not assigned yet',
          accepted: riderAccepted,
          cancelled: riderCancelled,
          isAssigned: rider != null,
        ),

        if (isCancelled) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: context.statusColors.dangerContainer,
              borderRadius: BorderRadius.circular(AppRadius.card - 8),
            ),
            child: Row(
              children: [
                Icon(Icons.cancel_rounded, color: context.statusColors.danger, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    driverCancelled && riderCancelled
                        ? 'Driver and rider cancelled this request. Admin will re-assign.'
                        : driverCancelled
                            ? 'Driver cancelled this request. Admin will re-assign.'
                            : 'Rider cancelled this request. Admin will re-assign.',
                    style: TextStyle(fontSize: 12, color: context.statusColors.danger, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Total fare — shown to customer when the ride is completed
        if (status == 'COMPLETED' && (ride['totalFare'] ?? 0) > 0) ...[
          const SizedBox(height: 14),
          FareBreakdownCard(
            title: context.l10n.totalFare,
            totalLabel: 'Amount to pay',
            totalFare: ride['totalFare'],
          ),
        ],
      ],
    );
  }
}

// ============================================================
// Small info row (icon + text)
// ============================================================
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  const _InfoRow({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Assigned user tile — shows driver/rider + acknowledge status
// ============================================================
class _AssignedUserTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String name;
  final bool accepted;
  final bool cancelled;
  final bool isAssigned;

  const _AssignedUserTile({
    required this.icon,
    required this.label,
    required this.name,
    required this.accepted,
    required this.cancelled,
    required this.isAssigned,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 18, color: scheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
              Text(
                name,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (cancelled)
          Chip(
            label: Text(context.l10n.cancelled, style: const TextStyle(color: Colors.red, fontSize: 10)),
            backgroundColor: const Color(0xFFFFEBEE),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )
        else if (accepted)
          Chip(
            label: Text(context.l10n.accepted, style: const TextStyle(color: Colors.green, fontSize: 10)),
            backgroundColor: const Color(0xFFE8F5E9),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          )
        else if (!isAssigned)
          const SizedBox()
        else
          Chip(
            label: Text(context.l10n.awaiting, style: const TextStyle(color: Colors.amber, fontSize: 10)),
            backgroundColor: Colors.amber.shade50,
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
      ],
    );
  }
}
