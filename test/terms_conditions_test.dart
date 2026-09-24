// ============================================================
// Terms & Conditions tests
// ============================================================
// Covers the whole app-side terms flow:
//   * the tiny HTML renderer (the admin authors terms in the panel)
//   * TermsProvider (fetch, language fallback, failure)
//   * the customer/embedded terms screen
//   * the signup checkbox — signup MUST NOT go out until it is ticked
// ============================================================

import 'dart:convert';

import 'package:dad_app/core/network/api_client.dart';
import 'package:dad_app/core/localization/locale_provider.dart';
import 'package:dad_app/core/theme/app_theme.dart';
import 'package:dad_app/core/theme/theme_provider.dart';
import 'package:dad_app/core/widgets/simple_html_view.dart';
import 'package:dad_app/features/auth/models/user_model.dart';
import 'package:dad_app/features/auth/providers/auth_provider.dart';
import 'package:dad_app/features/auth/screens/signup_screen.dart';
import 'package:dad_app/features/auth/widgets/customer_signup_form.dart';
import 'package:dad_app/features/auth/widgets/driver_signup_form.dart';
import 'package:dad_app/features/auth/widgets/rider_signup_form.dart';
import 'package:dad_app/features/legal/providers/terms_provider.dart';
import 'package:dad_app/features/legal/screens/terms_acceptance_screen.dart';
import 'package:dad_app/features/legal/screens/terms_conditions_screen.dart';
import 'package:dad_app/features/legal/widgets/terms_acceptance_field.dart';
import 'package:dad_app/features/legal/widgets/terms_language_selector.dart';
import 'package:dad_app/features/shell/customer_shell.dart';
import 'package:dad_app/l10n/app_localizations.dart';
import 'package:dad_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The HTML the admin's editor produces (already sanitized by the backend).
const String _termsHtml = '<h1>Terms &amp; Conditions</h1>'
    '<p>Please read these Terms.</p>'
    '<h2>1. Introduction</h2>'
    '<ul><li><strong>Customer</strong> – a person who books</li>'
    '<li>Driver — drives the vehicle</li></ul>'
    '<h2>2. Fares</h2>'
    '<ol><li>First rule</li><li>Second rule<br>and its detail</li></ol>'
    '<blockquote>Quoted clause</blockquote>'
    '<hr><p>Unknown <video>kept</video> text</p>';

/// The Sinhala translation of the same document
const String _termsSiHtml = '<h1>නියම සහ කොන්දේසි</h1>'
    '<p>කරුණාකර මෙම නියම කියවන්න.</p>';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final requestedPaths = <String>[];
  final signupBodies = <Map<String, dynamic>>[];
  final acceptBodies = <Map<String, dynamic>>[];

  /// Stubs the public terms endpoint (and a failing signup so the form stays
  /// on screen instead of navigating away).
  void stubNetwork({
    String version = '1.2',
    String si = '',
    bool failTerms = false,
    bool staleAccept = false,
  }) {
    requestedPaths.clear();
    signupBodies.clear();
    acceptBodies.clear();
    ApiClient.instance.setHttpClient(MockClient((request) async {
      requestedPaths.add(request.url.path);

      if (request.url.path == '/api/terms/accept') {
        acceptBodies.add(Map<String, dynamic>.from(jsonDecode(request.body) as Map));
        if (staleAccept) {
          return http.Response(
            jsonEncode({
              'success': false,
              'message': 'The Terms & Conditions have been updated. Please review and accept the latest version.',
            }),
            409,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Terms & Conditions accepted',
            'data': {
              'acceptance': {'version': version, 'language': 'en', 'acceptedAt': '2026-01-06T09:00:00.000Z'},
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.path == '/api/terms') {
        if (failTerms) {
          return http.Response('{"success":false,"message":"boom"}', 500,
              headers: {'content-type': 'application/json'});
        }
        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Terms & Conditions retrieved successfully',
            'data': {
              'terms': {
                'id': 'terms-1',
                'version': version,
                'status': 'PUBLISHED',
                'publishedAt': '2026-01-05T10:00:00.000Z',
                'updatedAt': '2026-01-05T10:00:00.000Z',
                'createdAt': '2026-01-05T10:00:00.000Z',
                'content': {'en': _termsHtml, 'si': si, 'ta': ''},
              },
              'acceptanceRequired': true,
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }

      if (request.url.path == '/api/auth/signup') {
        signupBodies.add(Map<String, dynamic>.from(jsonDecode(request.body) as Map));
        return http.Response('{"success":false,"message":"Registration failed"}', 400,
            headers: {'content-type': 'application/json'});
      }

      return http.Response('{"success":false,"message":"unexpected"}', 404,
          headers: {'content-type': 'application/json'});
    }));
  }

  Widget harness(Widget child, {TermsProvider? terms, AuthProvider? auth, bool scroll = true}) =>
      MultiProvider(
        providers: [
          ChangeNotifierProvider<TermsProvider>.value(value: terms ?? TermsProvider()),
          ChangeNotifierProvider<AuthProvider>.value(value: auth ?? AuthProvider()),
          ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
          ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ],
        child: MaterialApp(
          theme: AppTheme.light(),
          locale: const Locale('en'),
          supportedLocales: const [Locale('en')],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            // Screens that bring their own scroll view pass scroll: false
            body: scroll
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: child,
                  )
                : child,
          ),
        ),
      );

  /// Gives the test a phone-sized surface so long forms stay visible.
  void useTallSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  /// A signed-in customer as the backend describes one. [termsRequired] mirrors
  /// the `termsAcceptanceRequired` flag from login / signup / /api/auth/me.
  Future<AuthProvider> customer({required bool termsRequired}) async {
    SharedPreferences.setMockInitialValues({});
    final auth = AuthProvider();
    await auth.applyUser({
      'id': 'c1',
      'email': 'cust@dad.com',
      'fullName': 'Nimal Perera',
      'role': 'CUSTOMER',
      'status': 'APPROVED',
      'phone': '0771234567',
      'nic': '199012345678',
      'termsAcceptanceRequired': termsRequired,
    });
    return auth;
  }

  // ------------------------------------------------------------
  // The renderer for the admin-authored terms HTML
  // ------------------------------------------------------------
  group('SimpleHtmlView', () {
    testWidgets('renders headings, paragraphs, lists, quotes and rules', (tester) async {
      await tester.pumpWidget(harness(const SimpleHtmlView(html: _termsHtml)));

      expect(find.text('Terms & Conditions', findRichText: true), findsOneWidget);
      expect(find.text('Please read these Terms.', findRichText: true), findsOneWidget);
      expect(find.text('1. Introduction', findRichText: true), findsOneWidget);
      expect(find.text('2. Fares', findRichText: true), findsOneWidget);

      // Unordered bullets + ordered numbering
      expect(find.text('•'), findsNWidgets(2));
      expect(find.text('1.'), findsOneWidget);
      expect(find.text('2.'), findsOneWidget);

      // <br> keeps both lines inside the same paragraph
      expect(find.textContaining('Second rule\nand its detail', findRichText: true), findsOneWidget);

      expect(find.text('Quoted clause', findRichText: true), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);

      // Unknown tags are ignored but their text survives
      expect(find.textContaining('kept', findRichText: true), findsOneWidget);
    });

    testWidgets('applies bold / italic / underline / link styling to inline runs', (tester) async {
      await tester.pumpWidget(harness(const SimpleHtmlView(
        html: '<p>plain <strong>bold</strong> <em>ital</em> <u>und</u> '
            '<s>gone</s> <a href="https://example.lk">link</a></p>',
      )));

      final spans = <TextSpan>[];
      void collect(InlineSpan span) {
        if (span is TextSpan) {
          if ((span.text ?? '').isNotEmpty) spans.add(span);
          for (final child in span.children ?? const <InlineSpan>[]) {
            collect(child);
          }
        }
      }

      for (final rich in tester.widgetList<RichText>(
        find.descendant(of: find.byType(SimpleHtmlView), matching: find.byType(RichText)),
      )) {
        collect(rich.text);
      }
      TextSpan run(String text) => spans.firstWhere((s) => s.text == text);

      expect(run('bold').style?.fontWeight, FontWeight.w700);
      expect(run('ital').style?.fontStyle, FontStyle.italic);
      expect(run('und').style?.decoration, TextDecoration.underline);
      expect(run('gone').style?.decoration, TextDecoration.lineThrough);
      expect(run('link').style?.color, AppTheme.light().colorScheme.primary);
    });

    testWidgets('decodes entities and collapses whitespace', (tester) async {
      await tester.pumpWidget(harness(const SimpleHtmlView(
        html: '<p>Charges &amp; fees&nbsp;&#39;quoted&#39;</p><p>Line   with\n    spaces</p>',
      )));

      expect(find.textContaining("Charges & fees 'quoted'", findRichText: true), findsOneWidget);
      expect(find.text('Line with spaces', findRichText: true), findsOneWidget);
    });

    testWidgets('empty content renders a dash instead of throwing', (tester) async {
      await tester.pumpWidget(harness(const SimpleHtmlView(html: '<p>   </p>')));
      expect(find.text('—'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------
  // Fetching the published terms
  // ------------------------------------------------------------
  group('TermsProvider', () {
    test('fetches the published version and picks the language', () async {
      stubNetwork(version: '2.1', si: '<p>සිංහල</p>');
      final provider = TermsProvider();

      await provider.load();

      expect(requestedPaths, contains('/api/terms'));
      expect(provider.hasTerms, isTrue);
      expect(provider.failed, isFalse);
      expect(provider.version, '2.1');
      expect(provider.terms!.htmlFor(const Locale('si')), '<p>සිංහල</p>');
      // English is used when the language has no text yet
      expect(provider.terms!.htmlFor(const Locale('ta')), contains('Terms &amp; Conditions'));
    });

    test('loads once and caches until forced', () async {
      stubNetwork();
      final provider = TermsProvider();

      await provider.load();
      await provider.load();
      expect(requestedPaths.where((p) => p == '/api/terms').length, 1);

      await provider.load(force: true);
      expect(requestedPaths.where((p) => p == '/api/terms').length, 2);
    });

    test('a failed fetch leaves the provider empty and flagged', () async {
      stubNetwork(failTerms: true);
      final provider = TermsProvider();

      await provider.load();

      expect(provider.hasTerms, isFalse);
      expect(provider.failed, isTrue);
      expect(provider.loading, isFalse);
    });
  });

  // ------------------------------------------------------------
  // The customer tab / Settings screen
  // ------------------------------------------------------------
  group('TermsConditionsScreen', () {
    testWidgets('shows the version, date and the published content', (tester) async {
      stubNetwork(version: '3.0');
      useTallSurface(tester);

      await tester.pumpWidget(harness(const TermsConditionsScreen(embedded: true), scroll: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(requestedPaths, contains('/api/terms'));
      expect(find.text('Terms & Conditions'), findsWidgets);
      expect(find.textContaining('Version 3.0'), findsOneWidget);
      expect(find.textContaining('Updated'), findsOneWidget);
      expect(find.textContaining('Please read these Terms.', findRichText: true), findsOneWidget);
    });

    testWidgets('a failed load offers a retry that recovers', (tester) async {
      stubNetwork(failTerms: true);
      useTallSurface(tester);

      await tester.pumpWidget(harness(const TermsConditionsScreen(embedded: true), scroll: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text("Couldn't load the Terms & Conditions"), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Backend recovers — retry loads the document
      stubNetwork();
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('Please read these Terms.', findRichText: true), findsOneWidget);
      expect(find.text("Couldn't load the Terms & Conditions"), findsNothing);
    });
  });

  // ------------------------------------------------------------
  // The required checkbox on the signup forms
  // ------------------------------------------------------------
  group('TermsAcceptanceField (signup)', () {
    testWidgets('shows the terms and reports the tick', (tester) async {
      stubNetwork(version: '1.9');
      useTallSurface(tester);
      final changes = <bool>[];

      await tester.pumpWidget(harness(TermsAcceptanceField(onChanged: changes.add)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Terms & Conditions'), findsWidgets);
      expect(find.text('Version 1.9'), findsOneWidget);
      expect(find.textContaining('Please read these Terms.', findRichText: true), findsOneWidget);
      expect(find.text('I have read and agree to the Terms & Conditions'), findsOneWidget);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(changes, [true]);

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      expect(changes, [true, false]);
    });

    testWidgets('cannot be ticked when the terms failed to load', (tester) async {
      stubNetwork(failTerms: true);
      useTallSurface(tester);
      final changes = <bool>[];

      await tester.pumpWidget(harness(TermsAcceptanceField(onChanged: changes.add)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text("Couldn't load the Terms & Conditions"), findsOneWidget);
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).onChanged,
        isNull,
      );

      await tester.tap(find.byType(CheckboxListTile), warnIfMissed: false);
      await tester.pump();
      expect(changes, isEmpty);
    });
  });

  // ------------------------------------------------------------
  // Signup itself is blocked until the terms are accepted
  // ------------------------------------------------------------
  group('customer signup', () {
    Future<void> fillCustomerForm(WidgetTester tester) async {
      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Nimal');
      await tester.enterText(fields.at(1), 'nimal@example.com');
      await tester.enterText(fields.at(2), '199012345678');
      await tester.enterText(fields.at(3), '0771234567');
      await tester.pump();
    }

    testWidgets('does not reach the API until the checkbox is ticked', (tester) async {
      stubNetwork(version: '1.2');
      useTallSurface(tester);

      await tester.pumpWidget(harness(const CustomerSignupForm()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      await fillCustomerForm(tester);

      // --- Without ticking: blocked, with an inline error ---
      await tester.ensureVisible(find.text('Register as Customer'));
      await tester.tap(find.text('Register as Customer'));
      await tester.pump();

      expect(signupBodies, isEmpty);
      // Inline error + snack bar
      expect(find.text('Please accept the Terms & Conditions to continue'), findsWidgets);

      // --- After ticking: the consent version travels with the signup ---
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.ensureVisible(find.text('Register as Customer'));
      await tester.tap(find.text('Register as Customer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(signupBodies.length, 1);
      expect(signupBodies.single['role'], 'CUSTOMER');
      expect(signupBodies.single['termsVersion'], '1.2');
      expect(signupBodies.single['termsLanguage'], 'en');
    });
  });

  // ------------------------------------------------------------
  // Same gate on the driver and rider registration forms
  // ------------------------------------------------------------
  group('driver / rider signup', () {
    Future<void> gateTest(
      WidgetTester tester, {
      required Widget form,
      required List<String> values,
      required String button,
      required String role,
    }) async {
      stubNetwork(version: '4.2');
      useTallSurface(tester);

      await tester.pumpWidget(harness(form));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final fields = find.byType(TextFormField);
      for (var i = 0; i < values.length; i++) {
        await tester.enterText(fields.at(i), values[i]);
      }
      await tester.pump();

      // The terms step sits at the end of the personal details
      expect(find.text('I have read and agree to the Terms & Conditions'), findsOneWidget);

      // --- Blocked without the tick ---
      await tester.ensureVisible(find.text(button));
      await tester.tap(find.text(button));
      await tester.pump();

      expect(signupBodies, isEmpty, reason: '$role signup must not reach the API before accepting');
      expect(find.text('Please accept the Terms & Conditions to continue'), findsWidgets);

      // --- Allowed once ticked ---
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.ensureVisible(find.text(button));
      await tester.tap(find.text(button));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(signupBodies.length, 1);
      expect(signupBodies.single['role'], role);
      expect(signupBodies.single['termsVersion'], '4.2');
    }

    testWidgets('driver form', (tester) async {
      await gateTest(
        tester,
        form: const DriverSignupForm(),
        values: ['Nimal', 'Perera', 'nimal@example.com', '0771234567', '199012345678', 'Kandy',
          'B1234567', 'secret123'],
        button: 'Register as Driver',
        role: 'DRIVER',
      );
    });

    testWidgets('rider form', (tester) async {
      await gateTest(
        tester,
        form: const RiderSignupForm(),
        values: ['Kamal', 'Silva', 'kamal@example.com', '0779876543', '199512345678', 'No 5, Galle Rd',
          'Galle', 'R9876543', 'Sunil', '0712223344', 'secret123'],
        button: 'Register as Rider',
        role: 'RIDER',
      );
    });
  });

  // ------------------------------------------------------------
  // Google signup goes through the same consent gate
  // ------------------------------------------------------------
  group('signup screen (Google)', () {
    testWidgets('Google signup is blocked until the terms are ticked', (tester) async {
      stubNetwork(version: '5.0');
      useTallSurface(tester);

      await tester.pumpWidget(harness(const SignupScreen(), scroll: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      // Choosing an account type reveals the role form with the checkbox
      await tester.tap(find.text('Customer'));
      await tester.pump();
      expect(find.text('I have read and agree to the Terms & Conditions'), findsOneWidget);

      await tester.ensureVisible(find.text('Continue with Google'));
      await tester.tap(find.text('Continue with Google'));
      await tester.pump();

      // Nothing was sent to Google's endpoint and the user is told why
      expect(requestedPaths.where((p) => p == '/api/auth/google'), isEmpty);
      expect(find.text('Please accept the Terms & Conditions to continue'), findsWidgets);
    });
  });

  // ------------------------------------------------------------
  // Users who missed the checkbox (login / Google) are gated
  // ------------------------------------------------------------
  group('terms acceptance gate', () {
    test('UserModel reads the flag from the API payload', () {
      expect(UserModel.fromJson({'role': 'CUSTOMER'}).termsAcceptanceRequired, isFalse);
      expect(
        UserModel.fromJson({'role': 'CUSTOMER', 'termsAcceptanceRequired': true})
            .termsAcceptanceRequired,
        isTrue,
      );
    });

    testWidgets('a customer who never accepted sees the gate, not the dashboard', (tester) async {
      stubNetwork(version: '6.1');
      useTallSurface(tester);
      final auth = await customer(termsRequired: true);

      await tester.pumpWidget(harness(const StartupScreen(), auth: auth, scroll: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(TermsAcceptanceScreen), findsOneWidget);
      expect(find.byType(CustomerShell), findsNothing);
      expect(find.text('Terms & Conditions required'), findsOneWidget);
      expect(find.textContaining('Version 6.1'), findsOneWidget);

      // The only way forward is ticking the box
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, 'I agree & continue'))
            .onPressed,
        isNull,
      );
    });

    testWidgets('accepting posts the version and unblocks the app', (tester) async {
      stubNetwork(version: '7.3');
      useTallSurface(tester);
      final auth = await customer(termsRequired: true);

      await tester.pumpWidget(harness(const TermsAcceptanceScreen(), auth: auth, scroll: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.ensureVisible(find.text('I agree & continue'));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text('I agree & continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(acceptBodies.length, 1);
      expect(acceptBodies.single['version'], '7.3');
      expect(acceptBodies.single['language'], 'en');
      expect(auth.termsAcceptanceRequired, isFalse);
    });

    testWidgets('a stale version keeps the gate closed and shows the warning', (tester) async {
      stubNetwork(version: '9.0', staleAccept: true);
      useTallSurface(tester);
      final auth = await customer(termsRequired: true);

      await tester.pumpWidget(harness(const TermsAcceptanceScreen(), auth: auth, scroll: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.ensureVisible(find.text('I agree & continue'));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text('I agree & continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(auth.termsAcceptanceRequired, isTrue, reason: 'still gated after a 409');
      expect(find.textContaining('were updated'), findsOneWidget);
    });
  });

  // ------------------------------------------------------------
  // Language selection on the terms views
  // ------------------------------------------------------------
  group('terms language', () {
    test('the document knows which languages have text', () {
      const doc = TermsDocument(
        id: 't1',
        version: '1.0',
        status: 'PUBLISHED',
        content: {'en': '<p>English</p>', 'si': '', 'ta': '<p>தமிழ்</p>'},
      );

      expect(doc.availableLanguages, ['en', 'ta']);
      expect(doc.preferredLanguage(const Locale('ta')), 'ta');
      expect(doc.preferredLanguage(const Locale('si')), 'en'); // empty → English
      expect(doc.preferredLanguage(const Locale('fr')), 'en');

      const sinhalaOnly = TermsDocument(
        id: 't2',
        version: '1.0',
        status: 'PUBLISHED',
        content: {'si': '<p>සිංහල</p>'},
      );
      expect(sinhalaOnly.availableLanguages, ['si']);
      expect(sinhalaOnly.preferredLanguage(const Locale('en')), 'si');
    });

    test('an explicit pick wins until that language disappears', () async {
      stubNetwork(version: '1.0', si: _termsSiHtml);
      final provider = TermsProvider();
      await provider.load();

      expect(provider.languageFor(const Locale('en')), 'en');
      provider.selectLanguage('si');
      expect(provider.languageFor(const Locale('en')), 'si');

      // A new version without Sinhala text → safe fall back to English
      stubNetwork(version: '2.0');
      await provider.load(force: true);
      expect(provider.languageFor(const Locale('en')), 'en');
    });

    testWidgets('the picker only offers languages that have text', (tester) async {
      stubNetwork(version: '1.0', si: _termsSiHtml);
      final provider = TermsProvider();
      await provider.load();

      await tester.pumpWidget(harness(const TermsLanguageSelector(), terms: provider));
      await tester.pump();

      expect(find.byType(ChoiceChip), findsNWidgets(2)); // English + Sinhala
      expect(find.text('English'), findsOneWidget);
      expect(find.text('සිංහල'), findsOneWidget);
      expect(find.text('தமிழ்'), findsNothing); // no Tamil text → not offered

      await tester.tap(find.text('සිංහල'));
      await tester.pump();
      expect(provider.selectedLanguage, 'si');
    });

    testWidgets('the terms view switches language in place', (tester) async {
      stubNetwork(version: '3.0', si: _termsSiHtml);
      useTallSurface(tester);

      await tester.pumpWidget(harness(const TermsConditionsScreen(embedded: true), scroll: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.textContaining('Please read these Terms.', findRichText: true), findsOneWidget);

      await tester.ensureVisible(find.text('සිංහල'));
      await tester.tap(find.text('සිංහල'));
      await tester.pump();

      expect(find.textContaining('කරුණාකර', findRichText: true), findsOneWidget);
      expect(find.textContaining('Please read these Terms.', findRichText: true), findsNothing);
      expect(find.textContaining('Version 3.0'), findsOneWidget);
    });

    testWidgets('the acceptance records the language that was read', (tester) async {
      stubNetwork(version: '7.4', si: _termsSiHtml);
      useTallSurface(tester);
      final auth = await customer(termsRequired: true);

      await tester.pumpWidget(harness(const TermsAcceptanceScreen(), auth: auth, scroll: false));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      await tester.ensureVisible(find.text('සිංහල'));
      await tester.tap(find.text('සිංහල'));
      await tester.pump();

      await tester.ensureVisible(find.text('I agree & continue'));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.tap(find.text('I agree & continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(acceptBodies.single['version'], '7.4');
      expect(acceptBodies.single['language'], 'si');
    });

    testWidgets('the signup sends the language shown in the preview', (tester) async {
      stubNetwork(version: '8.0', si: _termsSiHtml);
      useTallSurface(tester);

      await tester.pumpWidget(harness(const CustomerSignupForm()));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Nimal');
      await tester.enterText(fields.at(1), 'nimal@example.com');
      await tester.enterText(fields.at(2), '199012345678');
      await tester.enterText(fields.at(3), '0771234567');
      await tester.pump();

      await tester.ensureVisible(find.text('සිංහල'));
      await tester.tap(find.text('සිංහල'));
      await tester.pump();

      await tester.tap(find.byType(Checkbox));
      await tester.pump();
      await tester.ensureVisible(find.text('Register as Customer'));
      await tester.tap(find.text('Register as Customer'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));

      expect(signupBodies.single['termsVersion'], '8.0');
      expect(signupBodies.single['termsLanguage'], 'si');
    });
  });
}


