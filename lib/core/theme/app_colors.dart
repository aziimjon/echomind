import 'package:flutter/material.dart';

/// EchoMind color system — calming, therapeutic, premium palette
class AppColors {
  AppColors._();

  // ─── Primary Colors ─────────────────────────────────────────────────
  static const Color primaryIndigo = Color(0xFF4F46E5);
  static const Color primaryIndigoLight = Color(0xFF818CF8);
  static const Color primaryIndigoDark = Color(0xFF3730A3);

  // ─── Secondary / Accent ─────────────────────────────────────────────
  static const Color accentTeal = Color(0xFF14B8A6);
  static const Color accentTealLight = Color(0xFF5EEAD4);
  static const Color accentTealDark = Color(0xFF0D9488);

  // ─── Light Theme Surfaces ──────────────────────────────────────────
  static const Color lightBackground = Color(0xFFFAF9F6);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF1F0EB);
  static const Color lightCard = Color(0xFFFFFEFC);

  // ─── Dark Theme Surfaces ──────────────────────────────────────────
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkSurfaceVariant = Color(0xFF334155);
  static const Color darkCard = Color(0xFF1E293B);

  // ─── Text Colors ──────────────────────────────────────────────────
  static const Color textDark = Color(0xFF1E1B4B);
  static const Color textDarkSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFFF8FAFC);
  static const Color textLightSecondary = Color(0xFF94A3B8);

  // ─── Mood Colors ──────────────────────────────────────────────────
  static const Color moodTerrible = Color(0xFF6366F1);
  static const Color moodBad = Color(0xFF8B5CF6);
  static const Color moodOkay = Color(0xFFA78BFA);
  static const Color moodGood = Color(0xFF14B8A6);
  static const Color moodAmazing = Color(0xFF10B981);

  static const List<Color> moodColors = [
    moodTerrible,
    moodBad,
    moodOkay,
    moodGood,
    moodAmazing,
  ];

  // ─── Gradients ────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryIndigo, accentTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient calmGradient = LinearGradient(
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunriseGradient = LinearGradient(
    colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient oceanGradient = LinearGradient(
    colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Color(0x00000000), Color(0x80000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Glass Effect Colors ──────────────────────────────────────────
  static Color glassWhite = Colors.white.withValues(alpha: 0.15);
  static Color glassBorder = Colors.white.withValues(alpha: 0.2);
  static Color glassDark = Colors.black.withValues(alpha: 0.1);
  static Color glassDarkBorder = Colors.white.withValues(alpha: 0.08);
}
