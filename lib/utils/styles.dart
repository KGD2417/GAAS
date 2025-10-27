import 'package:flutter/material.dart';

class AppColors {
  static const background = Color(0xFF0A0E27);
  static const cardBackground = Color(0xFF141937);
  static const cardBackgroundLight = Color(0xFF1A2142);

  static const cyan = Color(0xFF00D9FF);
  static const cyanLight = Color(0xFF4DFFFF);
  static const cyanDark = Color(0xFF00A3CC);

  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB0B8D4);
  static const textTertiary = Color(0xFF6B7494);

  static const success = Color(0xFF00FF88);
  static const warning = Color(0xFFFFAA00);
  static const error = Color(0xFFFF4444);
}

class AppStyles {
  static BoxDecoration glowingCardDecoration({Color? glowColor}) {
    return BoxDecoration(
      color: AppColors.cardBackground,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: (glowColor ?? AppColors.cyan).withOpacity(0.3),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: (glowColor ?? AppColors.cyan).withOpacity(0.2),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration selectedCardDecoration() {
    return BoxDecoration(
      color: AppColors.cardBackgroundLight,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.cyan, width: 2),
      boxShadow: [
        BoxShadow(
          color: AppColors.cyan.withOpacity(0.4),
          blurRadius: 25,
          spreadRadius: 3,
        ),
      ],
    );
  }

  static const heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const heading2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );
}
