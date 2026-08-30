import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Brand Colors (Light)
  static const Color primary = Color(0xFF5B15FC);
  static const Color primaryHover = Color(0xFF4A0FD4);
  static const Color primaryLight = Color(0xFFF3EEFE);
  static const Color primaryContainer = Color(0xFFEADBFE);

  // Primary Brand Colors (iOS Dark Accent)
  static const Color primaryDark = Color(0xFFBF5AF2); // Apple System Purple Dark
  static const Color primaryDarkLight = Color(0xFF2C2C2E); // Neutral Apple System Gray 5 (No Tint)

  // Secondary & Accents
  static const Color secondary = Color(0xFF10B981); // Emerald
  static const Color secondaryLight = Color(0xFFECFDF5);
  static const Color secondaryDark = Color(0xFF30D158); // Apple System Green Dark
  static const Color secondaryDarkLight = Color(0xFF2C2C2E); // Neutral Apple Gray
  static const Color accent = Color(0xFF0284C7); // Sky

  // Status & Feedback
  static const Color success = Color(0xFF30D158); // Apple Green
  static const Color warning = Color(0xFFFF9F0A); // Apple Orange
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFFF453A); // Apple Red
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFFFF453A); // Apple System Red Dark
  static const Color errorDarkLight = Color(0xFF2C2C2E);
  static const Color info = Color(0xFF0A84FF); // Apple Blue

  // Light Background & Neutral Surfaces
  static const Color background = Color(0xFFFAF8F5); // Warm modern off-white
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Pure Apple iOS Dark Neutral Surfaces (No Tint)
  static const Color darkBackground = Color(0xFF000000); // Apple systemBackground (Pure Black)
  static const Color darkSurface = Color(0xFF1C1C1E); // Apple secondarySystemGroupedBackground (System Gray 6)
  static const Color darkSurfaceElevated = Color(0xFF2C2C2E); // Apple tertiarySystemBackground (System Gray 5)
  static const Color darkCardBackground = Color(0xFF1C1C1E); // Apple secondarySystemGroupedBackground

  // Light Borders & Dividers
  static const Color border = Color(0xFFE7E5E4); // Stone 200
  static const Color borderSubtle = Color(0xFFF5F5F4); // Stone 100
  static const Color divider = Color(0xFFE7E5E4);

  // Apple iOS Dark Borders & Separators (Zero Tint)
  static const Color darkBorder = Color(0xFF38383A); // Apple opaqueSeparator
  static const Color darkBorderSubtle = Color(0xFF2C2C2E); // Apple separator
  static const Color darkDivider = Color(0xFF38383A);

  // Typography - Light Mode
  static const Color textPrimary = Color(0xFF1C1917); // Stone 900
  static const Color textSecondary = Color(0xFF57534E); // Stone 600
  static const Color textMuted = Color(0xFFA8A29E); // Stone 400
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Typography - Apple iOS Dark Mode (Zero Tint)
  static const Color darkTextPrimary = Color(0xFFFFFFFF); // Apple System Label (White)
  static const Color darkTextSecondary = Color(0xFF8E8E93); // Apple System Gray 1 (secondaryLabel)
  static const Color darkTextMuted = Color(0xFF636366); // Apple System Gray 3 (tertiaryLabel)
}
