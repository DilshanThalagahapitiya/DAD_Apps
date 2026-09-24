// ============================================================
// App Theme
// ============================================================
// Central design system for SafeRide: color scheme, shape/
// spacing tokens, and component themes. Replaces the ad-hoc
// Colors.indigo / Colors.amber usage that used to be scattered
// across every screen.
// ============================================================

import 'package:flutter/material.dart';

/// Semantic status colors, available via `Theme.of(context).extension<StatusColors>()`.
@immutable
class StatusColors extends ThemeExtension<StatusColors> {
  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color danger;
  final Color onDanger;
  final Color dangerContainer;

  const StatusColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.danger,
    required this.onDanger,
    required this.dangerContainer,
  });

  static const light = StatusColors(
    success: Color(0xFF1EA672),
    onSuccess: Colors.white,
    successContainer: Color(0xFFDFF6EB),
    warning: Color(0xFFE08A00),
    onWarning: Colors.white,
    warningContainer: Color(0xFFFFF1D6),
    danger: Color(0xFFE1443B),
    onDanger: Colors.white,
    dangerContainer: Color(0xFFFCE1DF),
  );

  static const dark = StatusColors(
    success: Color(0xFF3DDB96),
    onSuccess: Color(0xFF00391F),
    successContainer: Color(0xFF0E3A28),
    warning: Color(0xFFFFB74D),
    onWarning: Color(0xFF3A2400),
    warningContainer: Color(0xFF40300F),
    danger: Color(0xFFFF8A80),
    onDanger: Color(0xFF3A0A06),
    dangerContainer: Color(0xFF432321),
  );

  @override
  StatusColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? danger,
    Color? onDanger,
    Color? dangerContainer,
  }) {
    return StatusColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      successContainer: successContainer ?? this.successContainer,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      warningContainer: warningContainer ?? this.warningContainer,
      danger: danger ?? this.danger,
      onDanger: onDanger ?? this.onDanger,
      dangerContainer: dangerContainer ?? this.dangerContainer,
    );
  }

  @override
  StatusColors lerp(ThemeExtension<StatusColors>? other, double t) {
    if (other is! StatusColors) return this;
    return StatusColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      successContainer: Color.lerp(successContainer, other.successContainer, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      warningContainer: Color.lerp(warningContainer, other.warningContainer, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      onDanger: Color.lerp(onDanger, other.onDanger, t)!,
      dangerContainer: Color.lerp(dangerContainer, other.dangerContainer, t)!,
    );
  }
}

extension StatusColorsX on BuildContext {
  StatusColors get statusColors =>
      Theme.of(this).extension<StatusColors>() ?? StatusColors.light;
}

/// Shape / spacing tokens shared across the app.
class AppRadius {
  static const double card = 22;
  static const double sheet = 28;
  static const double button = 16;
  static const double field = 16;
  static const double chip = 100;
  static const double pill = 100;
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 28;
}

class AppTheme {
  AppTheme._();

  static const Color _seed = Color(0xFF4C5FE8);

  /// The default brand seed, used until the admin-configured color
  /// (fetched from /api/rates by [ThemeProvider]) is loaded.
  static Color get defaultSeed => _seed;

  static ThemeData light({Color? seed, Color? secondarySeed}) =>
      _build(Brightness.light, seed: seed, secondarySeed: secondarySeed);
  static ThemeData dark({Color? seed, Color? secondarySeed}) =>
      _build(Brightness.dark, seed: seed, secondarySeed: secondarySeed);

  static ThemeData _build(Brightness brightness, {Color? seed, Color? secondarySeed}) {
    final brand = seed ?? _seed;
    var scheme = ColorScheme.fromSeed(seedColor: brand, brightness: brightness);

    // Use the admin's EXACT colors rather than Material's tonal approximation:
    // ColorScheme.fromSeed() replaces the seed with a derived tonal variant, so
    // buttons, card tints and the tab-bar selection would show a slightly
    // different shade than the one picked in the admin panel.
    scheme = scheme.copyWith(
      primary: brand,
      onPrimary: _onColor(brand),
      surfaceTint: brand,
    );

    if (secondarySeed != null) {
      // Admin-picked "secondary" brand color overrides the auto-derived
      // secondary so the app reflects the exact two-color combination
      // chosen in the admin Appearance settings, not just a seed-derived one.
      final secondaryScheme = ColorScheme.fromSeed(seedColor: secondarySeed, brightness: brightness);
      scheme = scheme.copyWith(
        secondary: secondarySeed,
        onSecondary: _onColor(secondarySeed),
        secondaryContainer: secondaryScheme.primaryContainer,
        onSecondaryContainer: secondaryScheme.onPrimaryContainer,
      );
    }
    final isDark = brightness == Brightness.dark;
    final surface = isDark ? const Color(0xFF121316) : const Color(0xFFF5F6FB);

    // ---- Brand tints -------------------------------------------------------
    // The admin-configured colors must be visible everywhere — not only on
    // primary buttons — so cards, text fields and the floating tab bar each
    // get a tint of the primary/secondary brand color. Everything below is
    // derived from `scheme`, which ThemeProvider rebuilds whenever the admin
    // changes the colors, so these follow automatically.
    final cardColor = _tint(
      scheme.primary,
      isDark ? const Color(0xFF1C1D22) : Colors.white,
      isDark ? 0.16 : 0.07,
    );
    final fieldColor = _tint(
      scheme.primary,
      isDark ? const Color(0xFF1C1D22) : const Color(0xFFF0F1F8),
      isDark ? 0.14 : 0.05,
    );
    final accentColor = _tint(
      scheme.secondary,
      isDark ? const Color(0xFF1C1D22) : Colors.white,
      isDark ? 0.20 : 0.12,
    );
    final cardBorder = scheme.primary.withValues(alpha: isDark ? 0.28 : 0.12);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: surface,
      extensions: [isDark ? StatusColors.dark : StatusColors.light],
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        // Brand-tinted card background + hairline brand border
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
          side: BorderSide(color: cardBorder),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: fieldColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: scheme.primary, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: scheme.error, width: 1.2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary.withValues(alpha: 0.55)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.chip)),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        side: BorderSide.none,
        backgroundColor: scheme.surfaceContainerHighest,
        // Selected chips use the admin's secondary brand color
        selectedColor: accentColor,
        checkmarkColor: scheme.secondary,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
        height: 64,
        // Selected tab: pill + icon + label all use the brand primary color
        indicatorColor: scheme.primary.withValues(alpha: 0.18),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? scheme.primary : scheme.onSurfaceVariant,
            size: 24,
          );
        }),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withValues(alpha: 0.5),
        space: 1,
        thickness: 1,
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        iconColor: scheme.onSurfaceVariant,
        // Brand-tinted row highlight when a list row is tapped
        tileColor: Colors.transparent,
        selectedColor: scheme.primary,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.button)),
        backgroundColor: isDark ? const Color(0xFF2A2B31) : const Color(0xFF1F2126),
      ),
    );
  }

  /// Brand-tinted fill for the floating tab bar / glass bars, so the bar itself
  /// carries the admin-configured color instead of plain white.
  static Color brandBarFill(ColorScheme scheme, {bool isDark = false}) => _tint(
        scheme.primary,
        isDark ? const Color(0xFF191A1F) : Colors.white,
        isDark ? 0.22 : 0.10,
      );

  /// Blend a dose of [brand] into [base] — used for card / field / bar fills.
  static Color _tint(Color brand, Color base, double opacity) =>
      Color.alphaBlend(brand.withValues(alpha: opacity), base);

  /// Black or white — whichever stays readable on [color]. Keeps button labels
  /// legible even when the admin picks a very light or very dark brand color.
  static Color _onColor(Color color) =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? Colors.white
          : Colors.black;
}
