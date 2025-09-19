import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Medical/Healthcare Theme
  static const Color primary = Color(0xFF2E7D61); // Medical green
  static const Color primaryLight = Color(0xFF4CAF73);
  static const Color primaryDark = Color(0xFF1B5940);
  
  // Secondary Colors
  static const Color secondary = Color(0xFF3B82F6); // Medical blue
  static const Color secondaryLight = Color(0xFF60A5FA);
  static const Color secondaryDark = Color(0xFF2563EB);
  
  // Accent Colors
  static const Color accent = Color(0xFFEF4444); // Medical red for alerts
  static const Color accentLight = Color(0xFFF87171);
  static const Color accentDark = Color(0xFFDC2626);
  
  // Warning & Status Colors
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFF34D399);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);
  
  // Background Colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Text Colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF4A4A4A);
  static const Color textLight = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Border & Divider Colors
  static const Color border = Color(0xFFE5E5E5);
  static const Color borderLight = Color(0xFFF0F0F0);
  static const Color divider = Color(0xFFEAEAEA);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [secondary, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Role-specific Colors
  static const Color patientRole = Color(0xFF8B5CF6); // Purple for patients
  static const Color doctorRole = Color(0xFF2E7D61); // Green for doctors
  static const Color adminRole = Color(0xFF3B82F6); // Blue for admin/insurance
  
  // Medical Document Type Colors
  static const Color labReport = Color(0xFFEF4444);
  static const Color prescription = Color(0xFF10B981);
  static const Color discharge = Color(0xFF3B82F6);
  static const Color xray = Color(0xFF8B5CF6);
  static const Color general = Color(0xFF6B7280);
}

// Material 3 Color Extensions
extension AppColorsExtension on AppColors {
  static ColorScheme get lightColorScheme => ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.light,
  );
  
  static ColorScheme get darkColorScheme => ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    brightness: Brightness.dark,
  );
}
