import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../utils/validators.dart';

class CustomTextFormField extends StatefulWidget {
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final TextCapitalization textCapitalization;
  final String? initialValue;

  const CustomTextFormField({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization = TextCapitalization.none,
    this.initialValue,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  bool _obscureText = false;
  late bool _showPasswordToggle;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _showPasswordToggle = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          initialValue: widget.initialValue,
          validator: widget.validator,
          keyboardType: widget.keyboardType,
          obscureText: _obscureText,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textCapitalization: widget.textCapitalization,
          onTap: widget.onTap,
          onChanged: widget.onChanged,
          onFieldSubmitted: widget.onSubmitted,
          style: TextStyle(
            color: widget.enabled ? AppColors.textPrimary : AppColors.textHint,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            prefixIcon: widget.prefixIcon,
            suffixIcon: _buildSuffixIcon(),
            filled: true,
            fillColor: widget.enabled ? Colors.grey[50] : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
              vertical: AppDimensions.paddingMedium,
            ),
            labelStyle: TextStyle(
              color: widget.enabled ? AppColors.textSecondary : AppColors.textHint,
              fontSize: 14,
            ),
            hintStyle: const TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
            helperStyle: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget? _buildSuffixIcon() {
    if (_showPasswordToggle) {
      return IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          color: AppColors.textSecondary,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      );
    }
    return widget.suffixIcon;
  }
}

// Pre-configured text fields
class EmailFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;

  const EmailFormField({
    super.key,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      labelText: 'Correo electrónico',
      hintText: 'ejemplo@correo.com',
      keyboardType: TextInputType.emailAddress,
      prefixIcon: const Icon(Icons.email_outlined),
      validator: validator ?? Validators.validateEmail,
      onChanged: onChanged,
    );
  }
}

class PasswordFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String? labelText;

  const PasswordFormField({
    super.key,
    this.controller,
    this.validator,
    this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      labelText: labelText ?? 'Contraseña',
      obscureText: true,
      prefixIcon: const Icon(Icons.lock_outline),
      validator: validator ?? Validators.validatePassword,
    );
  }
}

class PhoneFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const PhoneFormField({
    super.key,
    this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      labelText: 'Teléfono',
      hintText: '+51 999 999 999',
      keyboardType: TextInputType.phone,
      prefixIcon: const Icon(Icons.phone_outlined),
      validator: validator ?? Validators.validatePhone,
    );
  }
}