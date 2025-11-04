import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';

/// Estilos centralizados para toda la aplicación
class AppStyles {
  AppStyles._();

  // ===================
  // TEXT STYLES
  // ===================

  // Títulos principales
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle headingMedium = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle headingSmall = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // Subtítulos
  static const TextStyle subtitleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle subtitleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle subtitleSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // Texto del cuerpo
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
  );

  // Texto para botones
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Texto para descripciones y subtextos
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  static const TextStyle captionLight = TextStyle(
    fontSize: 12,
    color: Colors.white70,
  );

  // Texto para links
  static const TextStyle link = TextStyle(
    fontSize: 14,
    color: AppColors.primary,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );

  static const TextStyle linkWhite = TextStyle(
    fontSize: 14,
    color: Colors.white,
    fontWeight: FontWeight.w500,
    decoration: TextDecoration.underline,
  );

  // ===================
  // DECORATIONS
  // ===================

  // Gradient Decorations
  static const BoxDecoration primaryGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [AppColors.primary, AppColors.primaryDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const BoxDecoration welcomeGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
  );

  static const BoxDecoration authGradient = BoxDecoration(
    gradient: LinearGradient(
      colors: [Color(0xFFFF9800), Color(0xFFFF5722)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ),
  );

  // Card Decorations
  static BoxDecoration cardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.1),
        spreadRadius: 1,
        blurRadius: 5,
        offset: const Offset(0, 2),
      ),
    ],
  );

  static BoxDecoration elevatedCardDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(AppDimensions.radiusLarge),
    boxShadow: [
      BoxShadow(
        color: Colors.grey.withValues(alpha: 0.2),
        spreadRadius: 2,
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ],
  );

  // Container Decorations
  static BoxDecoration primaryContainer = BoxDecoration(
    color: AppColors.primary.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
  );

  static BoxDecoration secondaryContainer = BoxDecoration(
    color: AppColors.secondary.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
  );

  // Status Containers
  static BoxDecoration successContainer = BoxDecoration(
    color: AppColors.success.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
  );

  static BoxDecoration warningContainer = BoxDecoration(
    color: AppColors.warning.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
  );

  static BoxDecoration errorContainer = BoxDecoration(
    color: AppColors.error.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
  );

  // Form Field Decoration
  static BoxDecoration textFieldDecoration = BoxDecoration(
    color: Colors.white.withValues(alpha: 0.9),
    borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
  );

  // ===================
  // BUTTON STYLES
  // ===================

  // Primary Button Style
  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: AppColors.primary.withValues(alpha: 0.3),
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingLarge,
      vertical: AppDimensions.paddingMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    textStyle: buttonLarge,
  );

  // Secondary Button Style
  static ButtonStyle secondaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.secondary,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: AppColors.secondary.withValues(alpha: 0.3),
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingLarge,
      vertical: AppDimensions.paddingMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    textStyle: buttonLarge,
  );

  // Outline Button Style
  static ButtonStyle outlineButtonStyle = OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary, width: 2),
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingLarge,
      vertical: AppDimensions.paddingMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.primary,
    ),
  );

  // Text Button Style
  static ButtonStyle textButtonStyle = TextButton.styleFrom(
    foregroundColor: AppColors.primary,
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingMedium,
      vertical: AppDimensions.paddingSmall,
    ),
    textStyle: link,
  );

  // Danger Button Style
  static ButtonStyle dangerButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.error,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: AppColors.error.withValues(alpha: 0.3),
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingLarge,
      vertical: AppDimensions.paddingMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    textStyle: buttonLarge,
  );

  // Success Button Style
  static ButtonStyle successButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: AppColors.success,
    foregroundColor: Colors.white,
    elevation: 2,
    shadowColor: AppColors.success.withValues(alpha: 0.3),
    padding: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingLarge,
      vertical: AppDimensions.paddingMedium,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    textStyle: buttonLarge,
  );

  // ===================
  // INPUT DECORATIONS
  // ===================

  static InputDecoration textFieldInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool isError = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: BorderSide(
          color: isError ? AppColors.error : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: BorderSide(
          color: Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
    );
  }

  // Auth-specific input decoration with transparent background
  static InputDecoration authInputDecoration({
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    bool isError = false,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.white70) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(color: Colors.white70),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(color: Colors.white70),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(color: Colors.white, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.1),
      labelStyle: const TextStyle(color: Colors.white70),
      hintStyle: const TextStyle(color: Colors.white60),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingMedium,
      ),
    );
  }

  // ===================
  // SHADOW STYLES
  // ===================

  static List<BoxShadow> get lightShadow => [
    BoxShadow(
      color: Colors.grey.withValues(alpha: 0.1),
      spreadRadius: 1,
      blurRadius: 5,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get mediumShadow => [
    BoxShadow(
      color: Colors.grey.withValues(alpha: 0.2),
      spreadRadius: 2,
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: Colors.grey.withValues(alpha: 0.3),
      spreadRadius: 3,
      blurRadius: 15,
      offset: const Offset(0, 6),
    ),
  ];

  // ===================
  // SPECIFIC COMPONENT STYLES
  // ===================

  // AppBar Style
  static AppBarTheme get appBarTheme => AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
    ),
  );

  // Bottom Navigation Bar Style
  static BottomNavigationBarThemeData get bottomNavTheme => BottomNavigationBarThemeData(
    selectedItemColor: AppColors.primary,
    unselectedItemColor: Colors.grey,
    backgroundColor: Colors.white,
    elevation: 8,
    type: BottomNavigationBarType.fixed,
    selectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 12,
    ),
    unselectedLabelStyle: const TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 12,
    ),
  );

  // Card Theme
  static CardTheme get cardTheme => CardTheme(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    margin: const EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingSmall,
      vertical: 4.0,
    ),
  );

  // List Tile Theme
  static ListTileThemeData get listTileTheme => const ListTileThemeData(
    contentPadding: EdgeInsets.symmetric(
      horizontal: AppDimensions.paddingMedium,
      vertical: AppDimensions.paddingSmall,
    ),
    iconColor: AppColors.primary,
  );

  // Dialog Theme
  static DialogTheme get dialogTheme => DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    ),
    titleTextStyle: headingSmall,
    contentTextStyle: bodyMedium,
  );

  // ===================
  // UTILITY METHODS
  // ===================

  /// Crea una decoración con color personalizado y opacidad
  static BoxDecoration containerWithColor(Color color, {double opacity = 0.1}) {
    return BoxDecoration(
      color: color.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
    );
  }

  /// Crea una sombra personalizada
  static List<BoxShadow> customShadow({
    Color? color,
    double opacity = 0.1,
    double blurRadius = 5,
    Offset offset = const Offset(0, 2),
  }) {
    return [
      BoxShadow(
        color: (color ?? Colors.grey).withValues(alpha: opacity),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  /// Estilo de texto personalizado con color
  static TextStyle textWithColor(Color color, {
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
  }) {
    return TextStyle(
      color: color,
      fontSize: fontSize,
      fontWeight: fontWeight,
    );
  }
}