// ============================================================
// AppTheme tests — the admin brand colors must drive the whole UI
// ============================================================
// Guards the requirement: "use updated colors to app buttons and card
// backgrounds and tab bar selected color".
//
// AppTheme.light()/dark() are rebuilt from ThemeProvider.seed (the color the
// admin panel saved), so these tests assert that the resulting ThemeData
// really carries those colors on buttons, cards, text fields and the tab bar.
// ============================================================

import 'package:dad_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const brandPrimary = Color(0xFF1D2FBF);
  const brandSecondary = Color(0xFF22C55E);

  test('buttons use the admin primary color', () {
    final theme = AppTheme.light(seed: brandPrimary, secondarySeed: brandSecondary);

    expect(theme.elevatedButtonTheme.style!.backgroundColor!.resolve({}), brandPrimary);
    expect(theme.filledButtonTheme.style!.backgroundColor!.resolve({}), brandPrimary);
    expect(theme.outlinedButtonTheme.style!.foregroundColor!.resolve({}), brandPrimary);
    expect(theme.textButtonTheme.style!.foregroundColor!.resolve({}), brandPrimary);
  });

  test('the tab bar selected color uses the admin primary color', () {
    final theme = AppTheme.light(seed: brandPrimary, secondarySeed: brandSecondary);

    final selectedIcon = theme.navigationBarTheme.iconTheme!.resolve({WidgetState.selected});
    final selectedLabel =
        theme.navigationBarTheme.labelTextStyle!.resolve({WidgetState.selected});

    expect(selectedIcon!.color, brandPrimary);
    expect(selectedLabel!.color, brandPrimary);
  });

  test('card backgrounds follow the brand color', () {
    final blue = AppTheme.light(seed: const Color(0xFF0000FF));
    final red = AppTheme.light(seed: const Color(0xFFFF0000));

    // Cards are brand-tinted, not plain white ...
    expect(blue.cardTheme.color, isNot(Colors.white));
    // ... and change when the admin picks another color
    expect(blue.cardTheme.color, isNot(red.cardTheme.color));
    // ... and are bordered with the brand color
    final shape = blue.cardTheme.shape as RoundedRectangleBorder;
    expect(shape.side.color.a, greaterThan(0));
  });

  test('text field fill and tab bar glass follow the brand color', () {
    final blue = AppTheme.light(seed: const Color(0xFF0000FF));
    final red = AppTheme.light(seed: const Color(0xFFFF0000));

    expect(blue.inputDecorationTheme.fillColor, isNot(red.inputDecorationTheme.fillColor));
    expect(blue.inputDecorationTheme.focusedBorder!.borderSide.color, const Color(0xFF0000FF));

    expect(
      AppTheme.brandBarFill(blue.colorScheme),
      isNot(AppTheme.brandBarFill(red.colorScheme)),
    );
  });

  test('dark theme follows the brand color too', () {
    final theme = AppTheme.dark(seed: brandPrimary, secondarySeed: brandSecondary);

    expect(theme.brightness, Brightness.dark);
    expect(theme.filledButtonTheme.style!.backgroundColor!.resolve({}), brandPrimary);
    expect(
      theme.navigationBarTheme.iconTheme!.resolve({WidgetState.selected})!.color,
      brandPrimary,
    );
  });
}
