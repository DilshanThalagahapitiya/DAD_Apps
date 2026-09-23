// ============================================================
// Fare Breakdown Card
// ============================================================
// Single themed fare summary card, replacing the dark-gradient
// (0xFF1F2937 -> 0xFF374151) box duplicated across my_rides_screen,
// customer_rides_screen, latest_ride_status_card and ride_edit_screen.
// ============================================================

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FareBreakdownCard extends StatelessWidget {
  final String title;
  final num totalFare;
  final String totalLabel;
  /// Optional itemized rows, e.g. [("Base fare", "Rs. 500"), ...].
  final List<(String, String)> rows;

  const FareBreakdownCard({
    super.key,
    required this.totalFare,
    this.title = 'Fare summary',
    this.totalLabel = 'Total',
    this.rows = const [],
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF23262F), Color(0xFF14151A)]
              : const [Color(0xFF272B36), Color(0xFF171A21)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.card - 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: scheme.primary.withValues(alpha: 0.9), letterSpacing: 0.2)),
          if (rows.isNotEmpty) ...[
            const SizedBox(height: 10),
            for (final row in rows) _fareRow(row.$1, row.$2),
            const Divider(color: Colors.white24, height: 20),
          ] else
            const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(totalLabel, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white70)),
              Text('Rs. $totalFare',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22, color: Colors.white)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fareRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white60)),
            Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
          ],
        ),
      );
}
