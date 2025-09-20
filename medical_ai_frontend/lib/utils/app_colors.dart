import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Medical/Healthcare Theme (Forest-inspired)
  static const Color primary = Color(0xFF2E7D61); // Forest green
  static const Color primaryLight = Color(0xFF4CAF73); // Bright forest green
  static const Color primaryDark = Color(0xFF1B5940); // Dark forest green
  
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
  
  // Light Mode - Forest Nature Background Colors
  static const Color backgroundLight = Color(0xFFF0F8F0); // Very light forest green
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceVariantLight = Color(0xFFF5FBF5); // Light forest tint
  
  // Dark Mode - Dark Forest Background Colors
  static const Color backgroundDark = Color(0xFF0F1B0F); // Deep dark forest
  static const Color surfaceDark = Color(0xFF1A2B1A); // Dark forest surface
  static const Color surfaceVariantDark = Color(0xFF142014); // Darker forest variant
  
  // Forest-themed accent colors
  static const Color forestGreen = Color(0xFF228B22); // Forest green
  static const Color mossGreen = Color(0xFF8FBC8F); // Moss green
  static const Color leafGreen = Color(0xFF32CD32); // Leaf green
  static const Color pineGreen = Color(0xFF01796F); // Pine green
  static const Color earthBrown = Color(0xFF8B4513); // Earth brown
  static const Color barkBrown = Color(0xFF654321); // Bark brown
  static const Color skyBlue = Color(0xFF87CEEB); // Sky blue
  
  // Dark forest colors
  static const Color darkForestGreen = Color(0xFF0D4F0D);
  static const Color shadowGreen = Color(0xFF1A3A1A);
  static const Color moonbeam = Color(0xFFF0F8FF);
  static const Color starlight = Color(0xFFE6F3FF);
  
  // Text Colors - Light Mode
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textMedium = Color(0xFF2D4A2D); // Forest dark green
  static const Color textLight = Color(0xFF6B8E6B); // Forest light green
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Text Colors - Dark Mode
  static const Color textDarkMode = Color(0xFFE0F0E0); // Light forest green
  static const Color textMediumDarkMode = Color(0xFFB8D4B8); // Medium forest green
  static const Color textLightDarkMode = Color(0xFF8FB08F); // Light forest green
  
  // Border & Divider Colors - Light Mode
  static const Color borderLight = Color(0xFFD4E6D4); // Light forest border
  static const Color borderLightVariant = Color(0xFFE0F0E0);
  static const Color dividerLight = Color(0xFFD4E6D4);
  
  // Border & Divider Colors - Dark Mode
  static const Color borderDark = Color(0xFF2D4A2D); // Dark forest border
  static const Color borderDarkVariant = Color(0xFF1A3A1A);
  static const Color dividerDark = Color(0xFF2D4A2D);
  
  // Legacy colors for backward compatibility
  static const Color background = backgroundLight;
  static const Color surface = surfaceLight;
  static const Color surfaceVariant = surfaceVariantLight;
  static const Color border = borderLight;
  static const Color divider = dividerLight;
  
  // Forest Nature Gradients - Light Mode
  static const LinearGradient forestLightGradient = LinearGradient(
    colors: [
      Color(0xFFF0F8F0), // Light forest background
      Color(0xFFE8F5E8), // Slightly darker forest
      Color(0xFFE0F2E0), // Forest tint
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient forestCardGradient = LinearGradient(
    colors: [
      Color(0xFFFFFFFF), // Pure white
      Color(0xFFF8FDF8), // Very light forest tint
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Forest Nature Gradients - Dark Mode
  static const LinearGradient forestDarkGradient = LinearGradient(
    colors: [
      Color(0xFF0F1B0F), // Deep dark forest
      Color(0xFF142014), // Dark forest
      Color(0xFF1A2B1A), // Dark forest surface
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient forestCardDarkGradient = LinearGradient(
    colors: [
      Color(0xFF1A2B1A), // Dark forest surface
      Color(0xFF142014), // Darker forest
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
