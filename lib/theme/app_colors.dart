import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Tech Blue
  static const Color primary = Color(0xFF2563EB); // Tech Blue
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primaryDark = Color(0xFF1D4ED8);

  // Secondary Colors - Vibrant Purple
  static const Color secondary = Color(0xFF7C3AED); // Vibrant Purple
  static const Color secondaryLight = Color(0xFF8B5CF6);
  static const Color secondaryDark = Color(0xFF6D28D9);

  // Accent Colors - Gradient Neon
  static const Color accentStart = Color(0xFF22D3EE); // Cyan
  static const Color accentEnd = Color(0xFF34D399); // Emerald

  // Dark Theme Colors (VS Code inspired)
  static const Color darkBackground = Color(0xFF111827); // Dark background
  static const Color darkSurface = Color(0xFF1F2937);
  static const Color darkSurfaceVariant = Color(0xFF374151);
  static const Color darkOnBackground = Color(0xFFE5E7EB); // Light text
  static const Color darkOnSurface = Color(0xFFE5E7EB);
  static const Color darkOnSurfaceVariant = Color(0xFF9CA3AF);

  // Light Theme Colors (Clean, professional)
  static const Color lightBackground = Color(0xFFF9FAFB); // Light background
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF3F4F6);
  static const Color lightOnBackground = Color(0xFF1F2937); // Dark text
  static const Color lightOnSurface = Color(0xFF1F2937);
  static const Color lightOnSurfaceVariant = Color(0xFF6B7280);

  // Status Colors (Developer-friendly)
  static const Color success = Color(0xFF10B981); // Green for completed
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B); // Orange for in-progress
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFF60A5FA);

  // Progress Colors (Gradient-based)
  static const Color progressCompleted = success; // Green for completed
  static const Color progressInProgress = secondary; // Purple for in-progress
  static const Color progressNotStarted = Color(0xFF6B7280);

  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accentStart, accentEnd],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x1A2563EB), // 10% opacity primary
      Color(0x1A7C3AED), // 10% opacity secondary
    ],
  );

  // Glassmorphism Colors
  static const Color glassBackground = Color(0x1AFFFFFF); // 10% white
  static const Color glassBorder = Color(0x33FFFFFF); // 20% white
  static const Color glassShadow = Color(0x1A000000); // 10% black

  // Text Colors
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Border Colors
  static const Color borderLight = Color(0xFFE5E7EB);
  static const Color borderMedium = Color(0xFFD1D5DB);
  static const Color borderDark = Color(0xFF9CA3AF);

  // Shadow Colors
  static const Color shadowLight = Color(0x0A000000); // 4% black
  static const Color shadowMedium = Color(0x14000000); // 8% black
  static const Color shadowDark = Color(0x1F000000); // 12% black
}
