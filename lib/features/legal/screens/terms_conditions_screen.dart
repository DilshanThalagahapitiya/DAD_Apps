// ============================================================
// Terms & Conditions Screen
// ============================================================
// Shows the terms the admin publishes from
// Admin > Terms & Conditions (GET /api/terms — versioned, one language per
// locale). Used in three places:
//   * customer "Terms" tab           → TermsConditionsScreen(embedded: true)
//   * driver / rider / customer Settings → pushed (own app bar + back button)
//   * the signup step's "View full terms" → pushed
//
// The provider caches the document, so opening this from several places costs
// a single request. Pull down to refresh (e.g. after the admin publishes a new
// version); the screen re-reads it the next time it is opened.
// ============================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/localization/l10n_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/simple_html_view.dart';
import '../providers/terms_provider.dart';
import '../widgets/terms_language_selector.dart';
import '../widgets/terms_version_chips.dart';

class TermsConditionsScreen extends StatefulWidget {
  final bool embedded;
  const TermsConditionsScreen({super.key, this.embedded = false});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen> {
  @override
  void initState() {
    super.initState();
    // Refresh on open so a newly published version is picked up immediately.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<TermsProvider>().load(force: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final terms = context.watch<TermsProvider>();
    final doc = terms.terms;
    final locale = Localizations.localeOf(context);
    final language = terms.languageFor(locale);

    final body = SafeArea(
      child: RefreshIndicator(
        onRefresh: () => context.read<TermsProvider>().load(force: true),
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, widget.embedded ? 24 : 8, 20, 32),
          children: [
            if (widget.embedded) ...[
              Text(context.l10n.termsAndConditions,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.5)),
              const SizedBox(height: 6),
            ],
            if (doc != null) ...[
              TermsVersionChips(document: doc),
              const SizedBox(height: 14),
              // Read the terms in any language the admin has published
              const TermsLanguageSelector(),
              const SizedBox(height: 16),
            ],
            if (terms.loading && doc == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (doc == null)
              _LoadFailed(onRetry: () => context.read<TermsProvider>().load(force: true))
            else
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: SimpleHtmlView(html: doc.htmlFor(Locale(language))),
                ),
              ),
          ],
        ),
      ),
    );

    if (widget.embedded) return body;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.termsAndConditions),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: body,
    );
  }
}

class _LoadFailed extends StatelessWidget {
  final VoidCallback onRetry;
  const _LoadFailed({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
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
    );
  }
}
