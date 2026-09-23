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
import 'features/home/screens/home_screen.dart';
import 'features/shell/customer_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the previously selected language and cached brand colors
  // before building the UI, then refresh the brand colors from the
  // backend in the background (admin may have changed them since).
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();
  final themeProvider = ThemeProvider();
  await themeProvider.loadCached();
  runApp(DadApp(localeProvider: localeProvider, themeProvider: themeProvider));
  themeProvider.refresh();
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
      if (auth.role == UserRole.customer) {
        return const CustomerShell();
      }
      return const HomeScreen();
    }
    return const LandingScreen();
  }
}

