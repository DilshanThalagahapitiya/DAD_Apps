// ============================================================
// Terms acceptance field (signup)
// ============================================================
// Shown after the personal-details step of every signup form: the published
// Terms & Conditions in a compact, scrollable preview plus a REQUIRED
// checkbox. The form listens to [onChanged] and refuses to submit until the
// user has ticked it, so nobody can create an account without agreeing.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/simple_html_view.dart';
import '../providers/terms_provider.dart';
import '../screens/terms_conditions_screen.dart';
import 'terms_language_selector.dart';

class TermsAcceptanceField extends StatefulWidget {
  /// Called whenever the tick changes (true = the user agreed).
  final ValueChanged<bool> onChanged;
  /// Shows "please accept the Terms & Conditions to continue" when the user
  /// tried to submit without ticking.
  final bool showError;

  const TermsAcceptanceField({
    super.key,
    required this.onChanged,
    this.showError = false,
  });

  @override
  State<TermsAcceptanceField> createState() => _TermsAcceptanceFieldState();
}

class _TermsAcceptanceFieldState extends State<TermsAcceptanceField> {
  bool _agreed = false;

  @override
  void initState() {
    super.initState();
    // Load the published terms (cached by the provider, so this is a no-op
    // once any other screen has fetched them).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TermsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final terms = context.watch<TermsProvider>();
    final doc = terms.terms;
    final locale = Localizations.localeOf(context);
    final language = terms.languageFor(locale);
    final ready = doc != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- Header ----
        Row(
          children: [
            Icon(Icons.description_outlined, size: 18, color: scheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                context.l10n.termsAndConditions,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ),
            if (ready)
              Text(
                context.l10n.termsVersionLabel(doc.version),
                style: TextStyle(fontSize: 11.5, color: scheme.onSurfaceVariant),
              ),
          ],
        ),
        const SizedBox(height: 8),
        // Switch the terms text between the languages the admin published
        const TermsLanguageSelector(dense: true),
        const SizedBox(height: 8),
        _previewBox(context, terms, doc, language, scheme),

        // ---- Open the full document ----
        if (ready)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsConditionsScreen()),
              ),
              icon: const Icon(Icons.open_in_new_rounded, size: 15),
              label: Text(context.l10n.viewFullTerms, style: const TextStyle(fontSize: 12.5)),
            ),
          ),

        // ---- Required agreement ----
        // Wrapped in a transparent Material: the signup screen paints the forms
        // on a white DecoratedBox, which would otherwise trip ListTile's
        // "ink splashes may be invisible" assertion in debug builds.
        Material(
          type: MaterialType.transparency,
          child: CheckboxListTile(
            value: _agreed,
            // Cannot agree to terms that could not be loaded
            onChanged: !ready
                ? null
                : (value) {
                    setState(() => _agreed = value ?? false);
                    widget.onChanged(_agreed);
                  },
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: VisualDensity.compact,
            title: Text(
              context.l10n.iAgreeToTerms,
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
          ),
        ),

        if (widget.showError && !_agreed)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              context.l10n.termsRequiredError,
              style: TextStyle(
                fontSize: 12,
                color: context.statusColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  /// Fixed-height, scrollable preview of the terms text — or the
  /// loading / couldn't-load state.
  Widget _previewBox(
    BuildContext context,
    TermsProvider terms,
    TermsDocument? doc,
    String language,
    ColorScheme scheme,
  ) {
    final ready = doc != null;

    return Container(
      height: 170,
      width: double.infinity,
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: terms.loading && !ready
          ? const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : !ready
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          context.l10n.termsLoadFailed,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: context.statusColors.warning),
                        ),
                        const SizedBox(height: 4),
                        TextButton(
                          onPressed: () => context.read<TermsProvider>().load(force: true),
                          child: Text(context.l10n.retry),
                        ),
                      ],
                    ),
                  ),
                )
              : Scrollbar(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: SimpleHtmlView(html: doc.htmlFor(Locale(language))),
                  ),
                ),
    );
  }
}
