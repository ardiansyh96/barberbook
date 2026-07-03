import 'package:flutter/material.dart';

/// Centralized color palette for BarberBook.
///
/// The app uses a Black / White / Gold theme inspired by premium barbershop
/// aesthetics. Gold serves as the primary accent, with a warm dark-orange
/// fallback for contexts where gold may not render well (e.g. status bars).
class AppColors {
  AppColors._();

  // ─── Primary Palette ────────────────────────────────────────────────
  /// Deep black used for primary surfaces and text
  static const Color primaryBlack = Color(0xFF1A1A2E);

  /// Rich gold accent – the signature BarberBook color
  static const Color gold = Color(0xFFD4AF37);

  /// Light gold for backgrounds and subtle highlights
  static const Color goldLight = Color(0xFFF5E6A3);

  /// Dark gold for pressed states and contrast
  static const Color goldDark = Color(0xFFB8960C);

  // ─── Secondary / Accent ─────────────────────────────────────────────
  /// Warm orange used as a secondary accent (matches UI reference)
  static const Color accentOrange = Color(0xFFFF8C00);

  /// Soft red for destructive / error actions
  static const Color errorRed = Color(0xFFE53935);

  /// Green for success states and confirmed bookings
  static const Color successGreen = Color(0xFF43A047);

  /// Blue for informational messages
  static const Color infoBlue = Color(0xFF1E88E5);

  /// Amber for warnings and pending states
  static const Color warningAmber = Color(0xFFFFB300);

  // ─── Neutral Palette ────────────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F8F8);
  static const Color lightGrey = Color(0xFFEEEEEE);
  static const Color mediumGrey = Color(0xFFBDBDBD);
  static const Color darkGrey = Color(0xFF616161);
  static const Color charcoal = Color(0xFF424242);
  static const Color nearBlack = Color(0xFF212121);

  // ─── Background Colors ──────────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // ─── Glassmorphism ──────────────────────────────────────────────────
  static const Color glassWhite = Color(0x40FFFFFF);
  static const Color glassBorder = Color(0x30FFFFFF);

  // ─── Gradient Definitions ───────────────────────────────────────────
  /// Primary gold gradient used for CTA buttons and headers
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFD4AF37), Color(0xFFF5E6A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Dark gradient for splash screen and premium cards
  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Orange-gold gradient for promotional cards (matches UI reference)
  static const LinearGradient promoGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFD4AF37)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // ─── Status Colors by Booking State ─────────────────────────────────
  static Color bookingStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return warningAmber;
      case 'confirmed':
        return infoBlue;
      case 'processing':
        return accentOrange;
      case 'completed':
        return successGreen;
      case 'rejected':
      case 'cancelled':
        return errorRed;
      default:
        return mediumGrey;
    }
  }

  // ─── Rating Star Colors ─────────────────────────────────────────────
  static const Color starFilled = Color(0xFFFFC107);
  static const Color starEmpty = Color(0xFFE0E0E0);
}
