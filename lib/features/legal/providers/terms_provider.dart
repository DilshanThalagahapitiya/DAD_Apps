// ============================================================
// Terms & Conditions provider
// ============================================================
// Loads the currently PUBLISHED terms the admin maintains
// (GET /api/terms) and shares them with:
//   * the signup step (compact preview + required checkbox),
//   * the customer "Terms" tab,
//   * the driver/rider Settings entry.
//
// One fetch is cached for the whole app; `load(force: true)` refreshes it.
// The document carries all three languages, so switching language in the app
// immediately shows the matching text (English is the fallback).
// ============================================================

import 'package:flutter/widgets.dart';
import '../../../core/network/api_client.dart';

/// The languages the backend stores, in display order.
const List<String> languageOrder = ['en', 'si', 'ta'];

/// Endonyms — each language is named in itself, so the picker reads the same
/// no matter which app language the user is on.
const Map<String, String> languageNames = {
  'en': 'English',
  'si': 'සිංහල',
  'ta': 'தமிழ்',
};

class TermsDocument {
  final String id;
  final String version;
  final String status;
  final DateTime? publishedAt;
  final DateTime? updatedAt;
  final Map<String, String> content; // "en" | "si" | "ta" -> sanitized HTML

  const TermsDocument({
    required this.id,
    required this.version,
    required this.status,
    required this.content,
    this.publishedAt,
    this.updatedAt,
  });

  factory TermsDocument.fromJson(Map<String, dynamic> json) {
    final rawContent = json['content'] as Map?;
    return TermsDocument(
      id: '${json['id'] ?? ''}',
      version: '${json['version'] ?? ''}',
      status: '${json['status'] ?? ''}',
      publishedAt: DateTime.tryParse('${json['publishedAt'] ?? ''}'),
      updatedAt: DateTime.tryParse('${json['updatedAt'] ?? ''}'),
      content: {
        for (final entry in (rawContent?.entries ?? const <MapEntry>[]).toList())
          '${entry.key}': '${entry.value}',
      },
    );
  }

  /// Terms HTML for [locale], falling back to English and then to whatever
  /// language actually has text.
  String htmlFor(Locale locale) {
    final preferred = content[locale.languageCode];
    if (preferred != null && preferred.trim().isNotEmpty) return preferred;
    final english = content['en'];
    if (english != null && english.trim().isNotEmpty) return english;
    for (final value in content.values) {
      if (value.trim().isNotEmpty) return value;
    }
    return '';
  }

  /// Languages the admin has actually written (en / si / ta order).
  List<String> get availableLanguages => [
        for (final code in languageOrder)
          if ((content[code] ?? '').trim().isNotEmpty) code,
      ];

  /// The language to show/record for [locale]: the app language when the admin
  /// wrote it, else English, else whatever exists.
  String preferredLanguage(Locale locale) {
    final available = availableLanguages;
    if (available.contains(locale.languageCode)) return locale.languageCode;
    if (available.contains('en')) return 'en';
    return available.isEmpty ? locale.languageCode : available.first;
  }
}

class TermsProvider extends ChangeNotifier {
  TermsDocument? _terms;
  bool _loading = false;
  bool _failed = false;
  String? _language; // explicit pick from a terms language selector

  TermsDocument? get terms => _terms;
  bool get loading => _loading;
  bool get failed => _failed;
  bool get hasTerms => _terms != null;
  String get version => _terms?.version ?? '';

  /// The terms language the user picked with the on-screen selector (null =
  /// follow the app language). Kept on the provider so every terms surface —
  /// the customer tab, Settings, the acceptance gate and the signup preview —
  /// shows the same language, and so an acceptance records what was read.
  String? get selectedLanguage => _language;

  void selectLanguage(String code) {
    if (_language == code) return;
    _language = code;
    notifyListeners();
  }

  /// Language to display (and record on acceptance) for [locale]: an explicit
  /// pick while it still has text, else the app language if the admin wrote
  /// it, else English.
  String languageFor(Locale locale) {
    final doc = _terms;
    final picked = _language;
    if (picked != null && (doc == null || doc.availableLanguages.contains(picked))) {
      return picked;
    }
    return doc?.preferredLanguage(locale) ?? locale.languageCode;
  }

  /// Fetches the published terms once (or again with [force]).
  Future<void> load({bool force = false}) async {
    if (_loading) return;
    if (!force && _terms != null) return;

    _loading = true;
    _failed = false;
    notifyListeners();

    try {
      final res = await ApiClient.instance.get('/api/terms', auth: false);
      final data = res['data'] is Map ? res['data']['terms'] : null;
      if (data is Map) {
        _terms = TermsDocument.fromJson(Map<String, dynamic>.from(data));
        _failed = false;
      } else {
        _terms = null;
        _failed = true;
      }
    } catch (e) {
      debugPrint('[Terms] Failed to load Terms & Conditions: $e');
      _failed = true;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
