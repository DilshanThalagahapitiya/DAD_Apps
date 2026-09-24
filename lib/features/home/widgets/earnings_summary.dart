// ============================================================
// Earnings Summary — driver / rider Dashboard tiles
// ============================================================
// "My Earnings" = the fares of this driver's / rider's COMPLETED rides × the
// profit-share percentage the admin set for them (50% drivers, 30% riders by
// default) — and how many rides that was.
//
// Data: GET /api/driver/earnings or GET /api/rider/earnings
// (`{ earnings, completedRides, sharePct, grossFare }`).
//
// Re-fetches whenever a ride changes (NotificationService.ridesRevision), so
// completing a ride updates the figures without restarting the app.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';

class EarningsSummary extends StatefulWidget {
  /// "driver" or "rider" — selects which endpoint to read.
  final String role;
  const EarningsSummary({super.key, required this.role});

  @override
  State<EarningsSummary> createState() => _EarningsSummaryState();
}

class _EarningsSummaryState extends State<EarningsSummary> {
  bool _loading = true;
  bool _failed = false;
  double _earnings = 0;
  int _rides = 0;
  double? _sharePct;

  String get _endpoint =>
      widget.role == 'rider' ? '/api/rider/earnings' : '/api/driver/earnings';

  @override
  void initState() {
    super.initState();
    NotificationService.instance.ridesRevision.addListener(_onRidesChanged);
    _fetch();
  }

  @override
  void dispose() {
    NotificationService.instance.ridesRevision.removeListener(_onRidesChanged);
    super.dispose();
  }

  void _onRidesChanged() {
    if (mounted) _fetch();
  }

  Future<void> _fetch() async {
    try {
      final res = await ApiClient.instance.get(_endpoint);
      final data = res['data'] is Map ? res['data']['earnings'] : null;
      if (!mounted) return;
      if (data is! Map) {
        setState(() {
          _loading = false;
          _failed = true;
        });
        return;
      }
      setState(() {
        _loading = false;
        _failed = false;
        _earnings = (data['earnings'] as num?)?.toDouble() ?? 0;
        _rides = (data['completedRides'] as num?)?.toInt() ?? 0;
        _sharePct = (data['sharePct'] as num?)?.toDouble();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  /// 12,345.5 -> "12,345.5" · 12000 -> "12,000" (no trailing .0)
  String _money(double value) => NumberFormat('#,##0.##').format(value);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    // IntrinsicHeight keeps both tiles the same height (the earnings tile has a
    // caption the rides tile does not) without forcing an infinite height.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- My Earnings ----
          Expanded(
            child: _Tile(
              background: scheme.primary.withValues(alpha: 0.10),
              border: scheme.primary.withValues(alpha: 0.30),
              iconBackground: scheme.primary.withValues(alpha: 0.18),
              icon: Icons.payments_rounded,
              iconColor: scheme.primary,
              label: context.l10n.myEarnings,
              value: _loading ? '…' : (_failed ? '—' : 'Rs. ${_money(_earnings)}'),
              valueColor: scheme.primary,
              caption: _sharePct == null
                  ? null
                  : context.l10n.earningsShareLabel(
                      _sharePct == _sharePct!.roundToDouble()
                          ? _sharePct!.toStringAsFixed(0)
                          : _sharePct!.toStringAsFixed(1),
                    ),
            ),
          ),
          const SizedBox(width: 10),
          // ---- Rides completed ----
          Expanded(
            child: _Tile(
              background: scheme.secondary.withValues(alpha: 0.10),
              border: scheme.secondary.withValues(alpha: 0.30),
              iconBackground: scheme.secondary.withValues(alpha: 0.18),
              icon: Icons.task_alt_rounded,
              iconColor: scheme.secondary,
              label: context.l10n.ridesCount,
              value: _loading ? '…' : (_failed ? '—' : '$_rides'),
              valueColor: scheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact dashboard tile: icon + label, big value, optional caption.
class _Tile extends StatelessWidget {
  final Color background;
  final Color border;
  final Color iconBackground;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final Color valueColor;
  final String? caption;

  const _Tile({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.valueColor,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 15, color: iconColor),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: valueColor),
          ),
          if (caption != null)
            Text(
              caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10.5, color: scheme.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}
