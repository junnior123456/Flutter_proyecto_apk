import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFFF9800);
  static const Color primaryDark = Color(0xFFFF5722);
  static const Color secondary = Color(0xFF4CAF50);
  static const Color accent = Color(0xFF2196F3);
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color success = Color(0xFF4CAF50);
  static const Color info = Color(0xFF2196F3);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textWhite = Color(0xFFFFFFFF);
  
  // Status colors for pets
  static const Color statusLost = Color(0xFFE53935);
  static const Color statusAdoption = Color(0xFF1E88E5);
  static const Color statusFound = Color(0xFF43A047);
  
  // Gradient colors
  static const Gradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryDark],
  );
}