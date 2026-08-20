/// Evita que el botón "atrás" del teléfono saque al usuario de la app cuando
/// ya está dentro. Sin esto, un atrás en la pantalla principal cerraba la
/// sesión a efectos prácticos: volvías a la bienvenida y tocaba entrar otra vez.
///
/// Se sale solo con el botón "Salir", o pulsando atrás dos veces seguidas,
/// que es lo que hace cualquier app de Android y no sorprende a nadie.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SalidaConDobleAtras extends StatefulWidget {
  const SalidaConDobleAtras({super.key, required this.child});

  final Widget child;

  @override
  State<SalidaConDobleAtras> createState() => _SalidaConDobleAtrasState();
}

class _SalidaConDobleAtrasState extends State<SalidaConDobleAtras> {
  DateTime? _primerAtras;

  bool get _dentroDeLaVentana {
    final anterior = _primerAtras;
    if (anterior == null) return false;
    return DateTime.now().difference(anterior) < const Duration(seconds: 2);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // canPop en false: el atrás NO cierra esta pantalla por su cuenta.
      canPop: false,
      onPopInvokedWithResult: (salio, _) {
        if (salio) return;

        if (_dentroDeLaVentana) {
          // Segundo atrás seguido: sí quiere irse. Se cierra la app, pero la
          // sesión SIGUE guardada: al volver a abrir entra directo.
          SystemNavigator.pop();
          return;
        }

        _primerAtras = DateTime.now();
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('Pulsa atrás otra vez para salir de la app'),
              duration: Duration(seconds: 2),
            ),
          );
      },
      child: widget.child,
    );
  }
}
