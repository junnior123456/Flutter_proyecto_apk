import 'package:flutter/material.dart';

/// Widget que previene overflow visual de forma segura
/// Sigue Clean Architecture: Core/Widgets (capa de presentación compartida)
/// 
/// Este widget envuelve contenido que puede causar overflow y lo maneja
/// de forma elegante sin mostrar las rayas amarillas/negras de debug
class OverflowSafeContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final BoxConstraints? constraints;

  const OverflowSafeContainer({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.constraints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      color: backgroundColor,
      constraints: constraints,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: child,
      ),
    );
  }
}

/// Widget para botones que previene overflow
class OverflowSafeButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double? elevation;
  final BorderSide? side;

  const OverflowSafeButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.elevation,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 56,
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
            side: side ?? BorderSide.none,
          ),
          elevation: elevation ?? 2,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: child,
        ),
      ),
    );
  }
}

/// Widget para botones outlined que previene overflow
class OverflowSafeOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final BorderSide? side;

  const OverflowSafeOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.foregroundColor,
    this.padding,
    this.borderRadius,
    this.side,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 56,
      ),
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: foregroundColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
          side: side ?? BorderSide(color: foregroundColor ?? Colors.orange),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: child,
        ),
      ),
    );
  }
}
