// ============================================================
// SafeRide - Mobile Application
// ============================================================
// Flutter app entry point.
// If a session is restored (Keep me logged in), routes to Home.
// Otherwise shows the Landing page for guest access.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:dad_app/l10n/app_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/localization/locale_provider.dart';
import 'core/services/notification_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/landing_screen.dart';
import 'features/legal/providers/terms_provider.dart';
import 'features/legal/screens/terms_acceptance_screen.dart';
import 'features/home/screens/home_screen.dart';
import 'features/shell/customer_shell.dart';
import 'features/shell/driver_rider_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the previously selected language and cached brand colors
  // before building the UI, then keep the brand colors in sync with the
  // admin panel (at startup, when the app is reopened, and every 15s while it
  // runs) so an admin color change shows up without reinstalling the app.
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();
  final themeProvider = ThemeProvider();
  await themeProvider.loadCached();
  runApp(DadApp(localeProvider: localeProvider, themeProvider: themeProvider));
  themeProvider.refresh();          // pick up admin changes right away
  themeProvider.startAutoRefresh(); // and keep checking while the app runs
}

class DadApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;
  const DadApp({super.key, required this.localeProvider, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
        // Terms & Conditions published by the admin — shared by the signup
        // step, the customer tab and the Settings entry (one cached fetch).
        ChangeNotifierProvider<TermsProvider>(create: (_) => TermsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
      ],
      child: Consumer3<LocaleProvider, ThemeProvider, AuthProvider>(
        builder: (context, localeProvider, themeProvider, authProvider, _) {

          // Start or stop notification polling based on auth state
          if (authProvider.isLoggedIn) {
            NotificationService.instance.startPolling(authProvider);
          } else {
            NotificationService.instance.stopPolling();
          }

          return MaterialApp(
            title: 'SafeRide',
            debugShowCheckedModeBanner: false,
            scaffoldMessengerKey: notificationKey,
            locale: localeProvider.locale,
            supportedLocales: LocaleProvider.supportedLocales,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: AppTheme.light(seed: themeProvider.seed, secondarySeed: themeProvider.secondarySeed),
            darkTheme: AppTheme.dark(seed: themeProvider.seed, secondarySeed: themeProvider.secondarySeed),
            themeMode: ThemeMode.system,
            home: const StartupScreen(),
          );
        },
      ),
    );
  }
}

// If a session was restored (Keep me logged in), go straight to the Home screen.
// Otherwise show the Landing page where users can access "Let's Hire" or other logins.
class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoggedIn) {
      // Required Terms & Conditions: the backend flags every customer / driver /
      // rider who has not accepted the currently published version (signed in
      // with Google, or an account created before the terms existed). Nothing
      // else is reachable — so a customer cannot request a driver — until the
      // checkbox is accepted.
      if (auth.termsAcceptanceRequired) {
        return const TermsAcceptanceScreen();
      }
      if (auth.role == UserRole.customer) {
        return const CustomerShell();
      }
      if (auth.role == UserRole.driver) {
        return const DriverRiderShell(role: 'driver');
      }
      if (auth.role == UserRole.rider) {
        return const DriverRiderShell(role: 'rider');
      }
      return const HomeScreen();
    }
    return const LandingScreen();
  }
}

