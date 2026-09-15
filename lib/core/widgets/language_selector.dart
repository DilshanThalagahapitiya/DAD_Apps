// ============================================================
// Language Selector — a compact button that switches app language
// ============================================================
// Shows the current language and opens a popup menu with English,
// Sinhala and Tamil. Used on the landing and home screens.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localization/locale_provider.dart';
import '../localization/l10n_ext.dart';

class LanguageSelector extends StatelessWidget {
  final Color foregroundColor;

  const LanguageSelector({super.key, this.foregroundColor = Colors.white});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    const languages = <({String code, String label})>[
      (code: 'en', label: 'English'),
      (code: 'si', label: 'සිංහල'),
      (code: 'ta', label: 'தமிழ்'),
    ];

    final current =
        languages.firstWhere(
          (l) => l.code == localeProvider.locale.languageCode,
          orElse: () => languages.first,
        );

    return PopupMenuButton<String>(
      tooltip: context.l10n.language,
      icon: Icon(Icons.language, color: foregroundColor),
      onSelected: (code) {
        context.read<LocaleProvider>().setLocale(Locale(code));
      },
      itemBuilder: (context) => [
        for (final lang in languages)
          PopupMenuItem<String>(
            value: lang.code,
            child: Row(
              children: [
                if (lang.code == current.code)
                  const Icon(Icons.check, size: 16)
                else
                  const SizedBox(width: 16),
                const SizedBox(width: 8),
                Text(lang.label),
              ],
            ),
          ),
      ],
    );
  }
}
