import 'package:flutter/material.dart';

/// SMES (Shri Markandeshwara English Medium School) dummy theme constants.
/// Central colour and typography tokens for the Forest Green + Saffron brand.
abstract class SmesTheme {
  // Primary palette — Forest Green
  static const Color primary     = Color(0xFF065F46); // emerald-800
  static const Color primaryDark = Color(0xFF022C22); // emerald-950
  static const Color primaryBg   = Color(0xFFF0FDF4); // green-50

  // Accent — Saffron / Gold
  static const Color accent      = Color(0xFFD97706); // amber-600
  static const Color accentLight = Color(0xFFFEF3C7); // amber-100

  // Semantic colours
  static const Color success = Color(0xFF16A34A); // green-600
  static const Color error   = Color(0xFFDC2626); // red-600
  static const Color warning = Color(0xFFF59E0B); // amber-500
  static const Color info    = Color(0xFF0284C7); // sky-600

  // Neutral
  static const Color navy    = Color(0xFF0F172A); // slate-900
  static const Color surface = Colors.white;

  // Gradient used in all dashboard headers
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryDark, primary],
  );

  // Typography scale
  static const TextStyle headingLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    color: navy,
    letterSpacing: -0.5,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: navy,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: navy,
    height: 1.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: Color(0xFF6B7280),
    letterSpacing: 0.3,
  );

  /// Returns a consistent border radius used across SMES cards.
  static BorderRadius get cardRadius => BorderRadius.circular(16);
}
