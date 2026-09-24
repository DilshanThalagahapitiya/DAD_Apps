// ============================================================
// Terms Acceptance Gate
// ============================================================
// Hard block shown when the backend says the signed-in user still has to
// accept the published Terms & Conditions (termsAcceptanceRequired):
//   * a customer / driver / rider who signed up before the terms existed,
//   * anyone who signed in with Google straight from the login screen.
//
// The user must tick the box and press "I agree & continue" (POST
// /api/terms/accept) before the app shows their dashboard — so a customer
// cannot request a driver without accepting. If the admin published a newer
// version in the meantime the backend answers 409 and the latest text is
// reloaded, so consent always matches what was on screen.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/simple_html_view.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/terms_provider.dart';
import '../widgets/terms_language_selector.dart';
import '../widgets/terms_version_chips.dart';

class TermsAcceptanceScreen extends StatefulWidget {
  /// True when the screen was pushed (offer a back button); false when it is a
  /// hard block that replaces the whole app.
  final bool showBackButton;
  const TermsAcceptanceScreen({super.key, this.showBackButton = false});

  @override
  State<TermsAcceptanceScreen> createState() => _TermsAcceptanceScreenState();
}

class _TermsAcceptanceScreenState extends State<TermsAcceptanceScreen> {
  bool _agreed = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TermsProvider>().load(force: true);
    });
  }

  Future<void> _accept(TermsDocument doc, String language) async {
    setState(() => _saving = true);
    final auth = context.read<AuthProvider>();
    final messenger = ScaffoldMessenger.of(context);

    // [language] is what the user actually read on screen — the backend stores
    // it with the acceptance row.
    final ok = await auth.acceptTerms(version: doc.version, language: language);
    if (!mounted) return;
    setState(() => _saving = false);

    if (ok) return; // the gate closes as soon as the flag clears

    // Most likely the admin published a new version meanwhile (409)
    await context.read<TermsProvider>().load(force: true);
    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(context.l10n.termsUpdatedPleaseReview),
        backgroundColor: context.statusColors.warning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final terms = context.watch<TermsProvider>();
    final doc = terms.terms;
    final locale = Localizations.localeOf(context);
    final language = terms.languageFor(locale);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.termsAcceptanceRequiredTitle),
        automaticallyImplyLeading: widget.showBackButton,
        actions: [
          // Way out for someone who does not want to accept
          TextButton(
            onPressed: () => context.read<AuthProvider>().logout(),
            child: Text(context.l10n.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: terms.loading && doc == null
            ? const Center(child: CircularProgressIndicator())
            : doc == null
                ? _LoadFailed(onRetry: () => context.read<TermsProvider>().load(force: true))
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: context.statusColors.warningContainer,
                          borderRadius: BorderRadius.circular(AppRadius.card),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.gavel_rounded, color: context.statusColors.warning),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                context.l10n.termsAcceptanceRequiredBody,
                                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TermsVersionChips(document: doc),
                      const SizedBox(height: 14),
                      // Read the terms in any language the admin has published
                      const TermsLanguageSelector(),
                      const SizedBox(height: 14),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18),
                          child: SimpleHtmlView(html: doc.htmlFor(Locale(language))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Material(
                        type: MaterialType.transparency,
                        child: CheckboxListTile(
                          value: _agreed,
                          onChanged:
                              _saving ? null : (value) => setState(() => _agreed = value ?? false),
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                          title: Text(
                            context.l10n.iAgreeToTerms,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      FilledButton.icon(
                        onPressed: (!_agreed || _saving) ? null : () => _accept(doc, language),
                        icon: _saving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.check_circle_outline_rounded),
                        label: Text(context.l10n.iAgreeAndContinue,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _LoadFailed extends StatelessWidget {
  final VoidCallback onRetry;
  const _LoadFailed({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 40, color: context.statusColors.warning),
            const SizedBox(height: 10),
            Text(
              context.l10n.termsLoadFailed,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: context.statusColors.warning),
            ),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onRetry, child: Text(context.l10n.retry)),
          ],
        ),
      ),
    );
  }
}
