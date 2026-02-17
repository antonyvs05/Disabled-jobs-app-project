import 'package:flutter/material.dart';

/// Centralized color palette for the entire app
class AppColors {
  // Primary Colors - Soft, Professional Palette
  static const Color primary = Color(0xFF4A5568);        // Soft Charcoal
  static const Color primaryDark = Color(0xFF2D3748);    // Deep Charcoal
  static const Color secondary = Color(0xFF5B8DEE);      // Soft Blue
  static const Color accent = Color(0xFF48A868);         // Soft Green

  // Neutral Colors
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color greyLight = Color(0xFFF7F9FC);
  static const Color greyMedium = Color(0xFF8892A6);
  static const Color greyDark = Color(0xFF5A6B7D);

  // Semantic Colors
  static const Color success = Color(0xFF48A868);        // Soft Green
  static const Color error = Color(0xFFD97B6B);          // Soft Red
  static const Color warning = Color(0xFFD4956F);        // Soft Orange
  static const Color info = Color(0xFF5B8DEE);           // Soft Blue

  // Background Colors
  static const Color backgroundLight = Color(0xFFF7F9FC);
  static const Color backgroundCard = Color(0xFFEBF4FF);
}

/// Centralized spacing values (8px base unit)
class AppSpacing {
  static const double xs = 4.0;      // Extra small
  static const double sm = 8.0;      // Small
  static const double md = 16.0;     // Medium
  static const double lg = 24.0;     // Large
  static const double xl = 32.0;     // Extra large
  static const double xxl = 48.0;    // Double extra large
}

/// Border radius values
class AppBorderRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double circle = 50.0;
}

/// Elevation/Shadow values
class AppElevation {
  static const double low = 2.0;
  static const double medium = 4.0;
  static const double high = 8.0;
}
