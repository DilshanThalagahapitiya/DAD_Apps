// ============================================================
// Terms version chips
// ============================================================
// "Version 1.2" + "Updated 05 Jan 2026" pills shown above the terms text on
// every screen that displays the published document.
// ============================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/localization/l10n_ext.dart';
import '../providers/terms_provider.dart';

class TermsVersionChips extends StatelessWidget {
  final TermsDocument document;
  const TermsVersionChips({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final publishedAt = document.publishedAt;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _Chip(
          icon: Icons.verified_outlined,
          label: context.l10n.termsVersionLabel(document.version),
          scheme: scheme,
        ),
        if (publishedAt != null)
          _Chip(
            icon: Icons.event_available_outlined,
            label: context.l10n.termsUpdatedLabel(
              DateFormat('dd MMM yyyy').format(publishedAt.toLocal()),
            ),
            scheme: scheme,
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme scheme;

  const _Chip({required this.icon, required this.label, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: scheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: scheme.primary.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: scheme.primary),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: scheme.primary)),
        ],
      ),
    );
  }
}
