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
import 'core/localization/locale_provider.dart';
import 'core/services/notification_service.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/auth/screens/landing_screen.dart';
import 'features/home/screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Restore the previously selected language before building the UI.
  final localeProvider = LocaleProvider();
  await localeProvider.loadLocale();
  runApp(DadApp(localeProvider: localeProvider));
}

class DadApp extends StatelessWidget {
  final LocaleProvider localeProvider;
  const DadApp({super.key, required this.localeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
        ChangeNotifierProvider(create: (_) => AuthProvider()..restoreSession()),
      ],
      child: Consumer2<LocaleProvider, AuthProvider>(
        builder: (context, localeProvider, authProvider, _) {
          
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
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
              inputDecorationTheme: const InputDecorationTheme(
                border: OutlineInputBorder(),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
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
      return const HomeScreen();
    }
    return const LandingScreen();
  }
}

