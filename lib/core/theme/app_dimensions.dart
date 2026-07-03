import 'package:flutter/material.dart';

/// Dimensional constants for consistent spacing, sizing, and layout
/// throughout the BarberBook application.
///
/// Following the 4-point grid system (multiples of 4) as recommended
/// by Material Design guidelines.
class AppDimensions {
  AppDimensions._();

  // ─── Spacing (Padding & Margin) ─────────────────────────────────────
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 12.0;
  static const double spacingLG = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacingXXXL = 32.0;
  static const double spacingGiant = 48.0;

  // ─── Border Radius ──────────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double radiusFull = 100.0;
  static const double radiusCircle = 999.0;

  // ─── Icon Sizes ─────────────────────────────────────────────────────
  static const double iconSM = 16.0;
  static const double iconMD = 20.0;
  static const double iconLG = 24.0;
  static const double iconXL = 32.0;
  static const double iconXXL = 48.0;

  // ─── Button Heights ─────────────────────────────────────────────────
  static const double buttonHeightSM = 36.0;
  static const double buttonHeightMD = 44.0;
  static const double buttonHeightLG = 52.0;
  static const double buttonHeightXL = 60.0;

  // ─── Input Field ────────────────────────────────────────────────────
  static const double inputHeight = 52.0;
  static const double inputBorderWidth = 1.5;

  // ─── Card ───────────────────────────────────────────────────────────
  static const double cardElevation = 2.0;
  static const double cardPadding = 16.0;

  // ─── Avatar ─────────────────────────────────────────────────────────
  static const double avatarSM = 32.0;
  static const double avatarMD = 48.0;
  static const double avatarLG = 64.0;
  static const double avatarXL = 96.0;
  static const double avatarXXL = 120.0;

  // ─── Bottom Navigation ──────────────────────────────────────────────
  static const double bottomNavHeight = 64.0;
  static const double bottomNavIconSize = 24.0;

  // ─── App Bar ────────────────────────────────────────────────────────
  static const double appBarHeight = 56.0;

  // ─── Banner ─────────────────────────────────────────────────────────
  static const double bannerHeight = 180.0;
  static const double bannerBorderRadius = 20.0;

  // ─── Responsive Breakpoints ─────────────────────────────────────────
  /// Below this width: phone layout
  static const double phoneBreakpoint = 600.0;

  /// Below this width: tablet layout, above: desktop
  static const double tabletBreakpoint = 900.0;

  // ─── Shadow ─────────────────────────────────────────────────────────
  static const List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      offset: Offset(0, 8),
    ),
  ];
}

/// Shorthand box decoration helper for commonly used card styles.
class AppDecoration {
  AppDecoration._();

  /// Standard card decoration with white background, rounded corners, subtle shadow
  static const BoxDecoration card = BoxDecoration(
    color: Color(0xFFFFFFFF),
    borderRadius: BorderRadius.all(Radius.circular(16)),
    boxShadow: [
      BoxShadow(
        color: Color(0x0D000000),
        blurRadius: 8,
        offset: Offset(0, 4),
      ),
    ],
  );

  /// Glassmorphism card decoration
  static const BoxDecoration glass = BoxDecoration(
    color: Color(0x40FFFFFF),
    borderRadius: BorderRadius.all(Radius.circular(16)),
    border: Border.fromBorderSide(
      BorderSide(color: Color(0x30FFFFFF), width: 1),
    ),
  );
}
