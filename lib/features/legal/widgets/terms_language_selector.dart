// ============================================================
// Terms language selector
// ============================================================
// Lets the reader switch the Terms & Conditions between the languages the
// admin has actually written (English / Sinhala / Tamil) without changing the
// app language. The choice is stored on TermsProvider, so every terms surface
// follows it and an acceptance records the language that was on screen.
//
// Renders nothing when only one language exists (nothing to switch to).
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../providers/terms_provider.dart';

class TermsLanguageSelector extends StatelessWidget {
  /// Compact variant used inside the signup preview.
  final bool dense;

  const TermsLanguageSelector({super.key, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final terms = context.watch<TermsProvider>();
    final doc = terms.terms;
    if (doc == null) return const SizedBox.shrink();

    final languages = doc.availableLanguages;
    if (languages.length < 2) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final selected = terms.languageFor(Localizations.localeOf(context));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Tooltip(
          message: context.l10n.language,
          child: Icon(Icons.translate_rounded, size: 16, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final code in languages)
                ChoiceChip(
                  label: Text(
                    languageNames[code] ?? code.toUpperCase(),
                    style: TextStyle(
                      fontSize: dense ? 11.5 : 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: code == selected,
                  visualDensity: dense ? VisualDensity.compact : null,
                  labelPadding: dense ? const EdgeInsets.symmetric(horizontal: 4) : null,
                  onSelected: (_) => context.read<TermsProvider>().selectLanguage(code),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
