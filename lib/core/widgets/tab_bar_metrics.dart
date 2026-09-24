// ============================================================
// Floating tab bar metrics
// ============================================================
// The shells draw their tab bar ON TOP of the body
// (Scaffold.extendBody = true) so the glass pill floats over the content.
// The body must therefore reserve room for it, otherwise the last rows of
// every tab (ride cards, profile rows, form buttons, ...) are hidden behind
// the bar no matter how far the user scrolls.
//
// Usage inside a shell:
//
//   body: SafeArea(
//     bottom: false,
//     child: Padding(
//       key: const Key('tabBarInset'),
//       padding: EdgeInsets.only(bottom: floatingTabBarInset(context)),
//       child: IndexedStack(index: _index, children: tabs),
//     ),
//   ),
// ============================================================

import 'package:flutter/material.dart';

/// Height of the NavigationBar inside the floating pill.
const double kFloatingTabBarHeight = 64;

/// Gap between the pill and the bottom of the screen (the `bottom` value the
/// shells pass to `bottomNavigationBar` when the device has no home indicator).
const double kFloatingTabBarBottomGap = 16;

/// Breathing room between the last row of a tab and the pill (the pill also
/// draws a 1px border, so content must not sit flush against it).
const double kFloatingTabBarClearance = 8;

/// Space every tab must leave free at the bottom so its content can be
/// scrolled completely clear of the floating tab bar.
///
/// [NavigationBar] already adds the device's bottom safe-area inset to its own
/// height, so that inset is included here as well.
double floatingTabBarInset(BuildContext context) =>
    kFloatingTabBarHeight +
    kFloatingTabBarBottomGap +
    kFloatingTabBarClearance +
    MediaQuery.of(context).padding.bottom;
