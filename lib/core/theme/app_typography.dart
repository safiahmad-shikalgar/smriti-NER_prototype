import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  // Heading Fonts (Fraunces - warm, human, serif)
  static TextStyle displayLarge({Color color = AppColors.textPrimary}) {
    return GoogleFonts.fraunces(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.5,
    );
  }

  static TextStyle headingLarge({Color color = AppColors.textPrimary}) {
    return GoogleFonts.fraunces(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: color,
      letterSpacing: -0.3,
    );
  }

  static TextStyle headingMedium({Color color = AppColors.textPrimary}) {
    return GoogleFonts.fraunces(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  static TextStyle headingSmall({Color color = AppColors.textPrimary}) {
    return GoogleFonts.fraunces(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: color,
    );
  }

  // Body & UI Fonts (Figtree - clean, highly legible, modern sans-serif)
  static TextStyle bodyLarge({
    Color color = AppColors.textPrimary,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.figtree(
      fontSize: 18,
      fontWeight: weight,
      color: color,
      height: 1.4,
    );
  }

  static TextStyle bodyMedium({
    Color color = AppColors.textSecondary,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.figtree(
      fontSize: 15,
      fontWeight: weight,
      color: color,
      height: 1.35,
    );
  }

  static TextStyle bodySmall({
    Color color = AppColors.textSecondary,
    FontWeight weight = FontWeight.w400,
  }) {
    return GoogleFonts.figtree(fontSize: 13, fontWeight: weight, color: color);
  }

  static TextStyle button({
    Color color = Colors.white,
    FontWeight weight = FontWeight.w700,
  }) {
    return GoogleFonts.figtree(
      fontSize: 17,
      fontWeight: weight,
      color: color,
      letterSpacing: 0.3,
    );
  }

  static TextStyle navLabel({
    Color color = AppColors.textMuted,
    FontWeight weight = FontWeight.w500,
  }) {
    return GoogleFonts.figtree(fontSize: 13, fontWeight: weight, color: color);
  }
}
