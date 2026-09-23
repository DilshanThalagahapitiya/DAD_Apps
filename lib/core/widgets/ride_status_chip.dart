// ============================================================
// Ride Status Chip
// ============================================================
// Single source of truth for ride-status color/icon/label,
// replacing the _statusColor/_statusIcon helpers that used to
// be duplicated in my_rides_screen, customer_rides_screen and
// latest_ride_status_card.
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RideStatusStyle {
  final Color color;
  final Color background;
  final IconData icon;
  const RideStatusStyle({required this.color, required this.background, required this.icon});
}

RideStatusStyle rideStatusStyle(BuildContext context, String status) {
  final s = context.statusColors;
  final scheme = Theme.of(context).colorScheme;
  switch (status) {
    case 'PENDING_REQUEST':
      return RideStatusStyle(color: s.warning, background: s.warningContainer, icon: Icons.hourglass_top_rounded);
    case 'ASSIGNED':
      return RideStatusStyle(color: s.warning, background: s.warningContainer, icon: Icons.event_available_rounded);
    case 'UPCOMING':
      return RideStatusStyle(color: scheme.primary, background: scheme.primaryContainer, icon: Icons.event_rounded);
    case 'ONGOING':
      return RideStatusStyle(color: s.success, background: s.successContainer, icon: Icons.directions_car_filled_rounded);
    case 'COMPLETED':
      return RideStatusStyle(color: scheme.onSurfaceVariant, background: scheme.surfaceContainerHighest, icon: Icons.check_circle_rounded);
    default:
      return RideStatusStyle(color: scheme.onSurfaceVariant, background: scheme.surfaceContainerHighest, icon: Icons.info_rounded);
  }
}

/// Compact pill chip showing a ride's status (icon + label).
class RideStatusChip extends StatelessWidget {
  final String status;
  final bool dense;
  const RideStatusChip({super.key, required this.status, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final style = rideStatusStyle(context, status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: dense ? 8 : 10, vertical: dense ? 3 : 5),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(AppRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: dense ? 12 : 14, color: style.color),
          const SizedBox(width: 4),
          Text(
            status.replaceAll('_', ' '),
            style: TextStyle(color: style.color, fontWeight: FontWeight.w700, fontSize: dense ? 10.5 : 11.5),
          ),
        ],
      ),
    );
  }
}
