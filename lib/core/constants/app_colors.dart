import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Light)
  static const Color primary = Color(0xFF5B15FC);
  static const Color primaryHover = Color(0xFF4A0FD4);
  static const Color primaryLight = Color(0xFFF3EEFE);
  static const Color primaryContainer = Color(0xFFEADBFE);

  // Primary Brand Colors (AMOLED Dark)
  static const Color primaryDark = Color(0xFF8B5CF6); // Electric Violet
  static const Color primaryDarkLight = Color(0xFF1E1035); // Obsidian-Violet Tint

  // Secondary & Accents
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color secondaryLight = Color(0xFFECFDF5);
  static const Color secondaryDark = Color(0xFF34D399); // Electric Emerald
  static const Color secondaryDarkLight = Color(0xFF062E20);
  static const Color accent = Color(0xFF0284C7); // Sky

  // Status & Feedback
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFF87171);
  static const Color errorDarkLight = Color(0xFF3B1215);
  static const Color info = Color(0xFF3B82F6);

  // Light Background & Neutral Surfaces
  static const Color background = Color(0xFFFAF8F5); // Warm modern off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Pure AMOLED True Black & Obsidian Neutral Surfaces
  static const Color darkBackground = Color(0xFF000000); // 100% OLED Pitch Black
  static const Color darkSurface = Color(0xFF0D0D11); // Deep OLED Obsidian
  static const Color darkSurfaceElevated = Color(0xFF16161C); // Elevated surface
  static const Color darkCardBackground = Color(0xFF0D0D11);

  // Light Borders & Dividers
  static const Color border = Color(0xFFE7E5E4); // Stone 200
  static const Color borderSubtle = Color(0xFFF5F5F4); // Stone 100
  static const Color divider = Color(0xFFE7E5E4);

  // AMOLED Dark Borders & Dividers
  static const Color darkBorder = Color(0xFF22222A); // Crisp Zinc/Dark Border
  static const Color darkBorderSubtle = Color(0xFF181820);
  static const Color darkDivider = Color(0xFF1E1E26);

  // Typography - Light Mode
  static const Color textPrimary = Color(0xFF1C1917); // Stone 900
  static const Color textSecondary = Color(0xFF57534E); // Stone 600
  static const Color textMuted = Color(0xFFA8A29E); // Stone 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Typography - AMOLED Dark Mode
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Pure White
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Zinc 400
  static const Color darkTextMuted = Color(0xFF71717A); // Zinc 500
}
