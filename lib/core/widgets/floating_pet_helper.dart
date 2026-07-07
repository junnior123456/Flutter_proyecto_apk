import 'package:flutter/material.dart';

/// Guarda el nombre de la ruta actual para poder ocultar el ayudante
/// en pantallas donde no corresponde (bienvenida, login, etc.).
final ValueNotifier<String?> currentRouteNotifier = ValueNotifier<String?>(null);

/// Observa la navegación y actualiza [currentRouteNotifier].
class AppRouteTracker extends NavigatorObserver {
  void _set(Route<dynamic>? route) {
    currentRouteNotifier.value = route?.settings.name;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _set(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _set(newRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _set(previousRoute);
}

/// Rutas donde NO se muestra el perrito ayudante.
const Set<String?> _hiddenRoutes = {
  '/welcome',
  '/login',
  '/register',
  '/forgot-password',
  '/reset-password',
  '/terms',
  '/primeros-auxilios',
  '/asistente',
};

/// 🐶 Perrito flotante y arrastrable que acompaña toda la navegación
/// y da acceso rápido a la guía de primeros auxilios / cuidados.
///
/// (Preparado para, en el futuro, abrir un asistente con IA.)
class FloatingPetHelper extends StatefulWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final String helpRoute;

  const FloatingPetHelper({
    super.key,
    required this.navigatorKey,
    required this.helpRoute,
  });

  @override
  State<FloatingPetHelper> createState() => _FloatingPetHelperState();
}

class _FloatingPetHelperState extends State<FloatingPetHelper> {
  Offset? _pos; // esquina superior-izquierda del botón
  static const double _size = 60;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: currentRouteNotifier,
      builder: (context, route, _) {
        if (_hiddenRoutes.contains(route)) {
          return const SizedBox.shrink();
        }

        final media = MediaQuery.of(context);
        final size = media.size;

        // Posición por defecto: derecha, algo arriba de la parte inferior.
        final pos = _pos ??
            Offset(
              size.width - _size - 16,
              size.height - _size - media.padding.bottom - 120,
            );

        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: GestureDetector(
            onPanUpdate: (d) {
              setState(() {
                final nx = (pos.dx + d.delta.dx)
                    .clamp(8.0, size.width - _size - 8);
                final ny = (pos.dy + d.delta.dy).clamp(
                  media.padding.top + 8,
                  size.height - _size - media.padding.bottom - 8,
                );
                _pos = Offset(nx, ny);
              });
            },
            onTap: () {
              widget.navigatorKey.currentState?.pushNamed(widget.helpRoute);
            },
            child: _dogButton(),
          ),
        );
      },
    );
  }

  Widget _dogButton() {
    return Container(
      width: _size,
      height: _size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB74D), Color(0xFFFF9800)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text('🐶', style: TextStyle(fontSize: 30)),
    );
  }
}
