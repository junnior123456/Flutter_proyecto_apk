/// Visor de imagen a pantalla completa, al estilo de Instagram o Facebook:
/// fondo negro, pellizcar para acercar, arrastrar para mover y deslizar hacia
/// abajo para cerrar.
library;

import 'package:flutter/material.dart';

/// Abre la imagen a pantalla completa. El [heroTag] enlaza con la miniatura
/// del feed para que la transición sea continua en vez de un corte seco.
void abrirImagenCompleta(
  BuildContext context, {
  required String imageUrl,
  required Object heroTag,
}) {
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, __, ___) =>
          _VisorImagen(imageUrl: imageUrl, heroTag: heroTag),
      transitionsBuilder: (_, animacion, __, hijo) =>
          FadeTransition(opacity: animacion, child: hijo),
    ),
  );
}

class _VisorImagen extends StatefulWidget {
  const _VisorImagen({required this.imageUrl, required this.heroTag});

  final String imageUrl;
  final Object heroTag;

  @override
  State<_VisorImagen> createState() => _VisorImagenState();
}

class _VisorImagenState extends State<_VisorImagen> {
  final TransformationController _transformacion = TransformationController();

  /// Desplazamiento vertical acumulado al arrastrar para cerrar.
  double _arrastreY = 0;

  bool get _estaAcercada =>
      _transformacion.value.getMaxScaleOnAxis() > 1.01;

  @override
  void dispose() {
    _transformacion.dispose();
    super.dispose();
  }

  void _dobleToque(TapDownDetails detalles) {
    // Doble toque: acerca al punto tocado, o vuelve a la vista normal.
    if (_estaAcercada) {
      _transformacion.value = Matrix4.identity();
      return;
    }
    final posicion = detalles.localPosition;
    _transformacion.value = Matrix4.identity()
      ..translateByDouble(-posicion.dx, -posicion.dy, 0, 1)
      ..scaleByDouble(2.5, 2.5, 1, 1);
  }

  @override
  Widget build(BuildContext context) {
    // Cuanto más se arrastra, más transparente el fondo: da la sensación de
    // que la foto se despega de la pantalla.
    final opacidad = (1 - (_arrastreY.abs() / 400)).clamp(0.3, 1.0);

    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: opacidad),
      body: Stack(
        children: [
          GestureDetector(
            onVerticalDragUpdate: (d) {
              // Con la imagen acercada, el arrastre es para moverla, no para cerrar.
              if (_estaAcercada) return;
              setState(() => _arrastreY += d.delta.dy);
            },
            onVerticalDragEnd: (_) {
              if (_arrastreY.abs() > 120) {
                Navigator.of(context).pop();
              } else {
                setState(() => _arrastreY = 0);
              }
            },
            child: Center(
              child: Transform.translate(
                offset: Offset(0, _arrastreY),
                child: Hero(
                  tag: widget.heroTag,
                  child: GestureDetector(
                    onDoubleTapDown: _dobleToque,
                    onDoubleTap: () {},
                    child: InteractiveViewer(
                      transformationController: _transformacion,
                      minScale: 1,
                      maxScale: 4,
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, hijo, progreso) => progreso == null
                            ? hijo
                            : const SizedBox(
                                height: 200,
                                child: Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              ),
                        errorBuilder: (_, __, ___) => const Padding(
                          padding: EdgeInsets.all(40),
                          child: Icon(Icons.broken_image,
                              color: Colors.white54, size: 64),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 8,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Cerrar',
            ),
          ),
        ],
      ),
    );
  }
}
