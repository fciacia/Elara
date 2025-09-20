import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Medical/Healthcare Theme (Purple-inspired)
  static const Color primary = Color(0xFF7C3AED); // Medical purple
  static const Color primaryLight = Color(0xFF8B5CF6); // Bright purple
  static const Color primaryDark = Color(0xFF5B21B6); // Dark purple
  
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
  
  // Light Mode - Purple Medical Background Colors
  static const Color backgroundLight = Color(0xFFFAF7FF); // Very light purple tint
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5F3FF); // Light purple tint
  
  // Dark Mode - Dark Purple Medical Background Colors
  static const Color backgroundDark = Color(0xFF0F0A1B); // Deep dark purple
  static const Color surfaceDark = Color(0xFF1A0F2B); // Dark purple surface
  static const Color surfaceVariantDark = Color(0xFF140A20); // Darker purple variant
  
  // Purple Medical-themed accent colors
  static const Color medicalPurple = Color(0xFF8B5CF6); // Medical purple
  static const Color lavenderPurple = Color(0xFFB794F6); // Lavender purple
  static const Color deepPurple = Color(0xFF6D28D9); // Deep purple
  static const Color violetPurple = Color(0xFF7C2D92); // Violet purple
  static const Color medicalBlue = Color(0xFF3B82F6); // Medical blue
  static const Color softBlue = Color(0xFF60A5FA); // Soft blue
  static const Color skyBlue = Color(0xFF87CEEB); // Sky blue
  
  // Dark purple medical colors
  static const Color darkMedicalPurple = Color(0xFF4C1D95);
  static const Color shadowPurple = Color(0xFF312E81);
  static const Color moonbeam = Color(0xFFF0F8FF);
  static const Color starlight = Color(0xFFE6F3FF);
  
  // Text Colors - Light Mode
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF4A2D5A); // Purple dark
  static const Color textLight = Color(0xFF8E6BA8); // Purple light
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Text Colors - Dark Mode
  static const Color textDarkMode = Color(0xFFE0E7FF); // Light purple tint
  static const Color textMediumDarkMode = Color(0xFFB8C5FF); // Medium purple tint
  static const Color textLightDarkMode = Color(0xFF8FA3FF); // Light purple tint
  
  // Border & Divider Colors - Light Mode
  static const Color borderLight = Color(0xFFD4C2F0); // Light purple border
  static const Color borderLightVariant = Color(0xFFE0D1F7);
  static const Color dividerLight = Color(0xFFD4C2F0);
  
  // Border & Divider Colors - Dark Mode
  static const Color borderDark = Color(0xFF4A2D5A); // Dark purple border
  static const Color borderDarkVariant = Color(0xFF3A1A4A);
  static const Color dividerDark = Color(0xFF4A2D5A);
  
  // Legacy colors for backward compatibility
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color surfaceVariant = surfaceVariantLight;
  static const Color border = borderLight;
  static const Color divider = dividerLight;
  
  // Purple Medical Gradients - Light Mode
  static const LinearGradient purpleLightGradient = LinearGradient(
    colors: [
      Color(0xFFFAF7FF), // Light purple background
      Color(0xFFF3EDFF), // Slightly darker purple
      Color(0xFFEDE4FF), // Purple tint
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient purpleCardGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF), // Pure white
      Color(0xFFFDFAFF), // Very light purple tint
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Purple Medical Gradients - Dark Mode
  static const LinearGradient purpleDarkGradient = LinearGradient(
    colors: [
      Color(0xFF0F0A1B), // Deep dark purple
      Color(0xFF140A20), // Dark purple
      Color(0xFF1A0F2B), // Dark purple surface
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient purpleCardDarkGradient = LinearGradient(
    colors: [
      Color(0xFF1A0F2B), // Dark purple surface
      Color(0xFF140A20), // Darker purple
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Legacy gradients for backward compatibility
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

  // Alias names for new gradients
  static const LinearGradient forestLightGradient = purpleLightGradient;
  static const LinearGradient forestCardGradient = purpleCardGradient;
  static const LinearGradient forestDarkGradient = purpleDarkGradient;
  static const LinearGradient forestCardDarkGradient = purpleCardDarkGradient;
  
  // Role-specific Colors
  static const Color patientRole = Color(0xFF8B5CF6); // Purple for patients
  static const Color doctorRole = Color(0xFF7C3AED); // Purple for doctors
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
