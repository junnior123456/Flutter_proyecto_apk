import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.elevated,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget button;
    
    switch (type) {
      case ButtonType.elevated:
        button = _buildElevatedButton();
        break;
      case ButtonType.outlined:
        button = _buildOutlinedButton();
        break;
      case ButtonType.text:
        button = _buildTextButton();
        break;
    }

    return SizedBox(
      width: width,
      height: height ?? AppDimensions.buttonHeight,
      child: button,
    );
  }

  Widget _buildElevatedButton() {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primary,
        foregroundColor: textColor ?? Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        elevation: AppDimensions.elevationMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      child: _buildButtonChild(),
    );
  }

  Widget _buildOutlinedButton() {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: backgroundColor ?? AppColors.primary,
        side: BorderSide(
          color: backgroundColor ?? AppColors.primary,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
        ),
      ),
      child: _buildButtonChild(),
    );
  }

  Widget _buildTextButton() {
    return TextButton(
      onPressed: isLoading ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: backgroundColor ?? AppColors.primary,
      ),
      child: _buildButtonChild(),
    );
  }

  Widget _buildButtonChild() {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppDimensions.iconMedium),
          const SizedBox(width: AppDimensions.paddingSmall),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}

enum ButtonType { elevated, outlined, text }