// ============================================================
// Glass Surface
// ============================================================
// A frosted / translucent container (backdrop blur + tinted
// fill) used for the floating tab bar and large-title bars to
// get the iOS-26 "liquid glass" look, without adding a package.
// ============================================================

import 'dart:ui';
import 'package:flutter/material.dart';

class GlassSurface extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Color? tint;
  final double tintOpacity;
  final Border? border;

  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.blurSigma = 24,
    this.tint,
    this.tintOpacity = 0.72,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fill = (tint ?? scheme.surface).withValues(alpha: tintOpacity);

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: borderRadius,
            border: border,
          ),
          child: child,
        ),
      ),
    );
  }
}
