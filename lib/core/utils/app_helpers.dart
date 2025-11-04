import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppHelpers {
  // Show success snackbar
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  // Show error snackbar
  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  // Show info snackbar
  static void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  // Show warning snackbar
  static void showWarningSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.warning,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
  
  // Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirmar',
    String cancelText = 'Cancelar',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
  
  // Show loading dialog
  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message),
            ],
          ],
        ),
      ),
    );
  }
  
  // Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }
  
  // Format phone number
  static String formatPhoneNumber(String phone) {
    // Remove any non-digit characters
    final digitsOnly = phone.replaceAll(RegExp(r'[^\d+]'), '');
    
    if (digitsOnly.startsWith('51') && digitsOnly.length == 11) {
      // Peruvian number format: +51 999 999 999
      return '+${digitsOnly.substring(0, 2)} ${digitsOnly.substring(2, 5)} ${digitsOnly.substring(5, 8)} ${digitsOnly.substring(8)}';
    } else if (digitsOnly.length == 9) {
      // Local format: 999 999 999
      return '${digitsOnly.substring(0, 3)} ${digitsOnly.substring(3, 6)} ${digitsOnly.substring(6)}';
    }
    
    return phone; // Return original if no format matches
  }
  
  // Get pet status color
  static Color getPetStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'perdido':
        return AppColors.statusLost;
      case 'adopcion':
        return AppColors.statusAdoption;
      case 'encontrado':
        return AppColors.statusFound;
      default:
        return AppColors.textSecondary;
    }
  }
  
  // Get pet status icon
  static IconData getPetStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'perdido':
        return Icons.warning;
      case 'adopcion':
        return Icons.volunteer_activism;
      case 'encontrado':
        return Icons.check_circle;
      default:
        return Icons.pets;
    }
  }
  
  // Capitalize first letter
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
  
  // Check if email is valid
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
  
  // Get initials from name
  static String getInitials(String name) {
    if (name.isEmpty) return '';
    
    final words = name.trim().split(' ');
    if (words.length == 1) {
      return words[0][0].toUpperCase();
    }
    
    return (words[0][0] + words[words.length - 1][0]).toUpperCase();
  }
  
  // Format date to readable string
  static String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días atrás';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
  
  // Dismiss keyboard
  static void dismissKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }
}