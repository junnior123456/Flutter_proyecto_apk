import 'package:flutter/widgets.dart';

/// Número de columnas de las rejillas de publicaciones según el ancho.
/// Móvil 2, tablet 3, tablet grande / escritorio 4.
int responsiveColumns(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width >= 1100) return 4;
  if (width >= 700) return 3;
  return 2;
}
