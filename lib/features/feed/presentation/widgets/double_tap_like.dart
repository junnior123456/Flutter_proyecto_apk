/// Doble toque sobre la foto para dar "me gusta", con el corazón que crece y
/// se desvanece, como en Instagram y TikTok.
library;

import 'package:flutter/material.dart';

class DobleToqueMeGusta extends StatefulWidget {
  const DobleToqueMeGusta({
    super.key,
    required this.child,
    required this.yaLeGusta,
    required this.onMeGusta,
    this.onToqueSimple,
  });

  final Widget child;

  /// Si la publicación ya tiene el "me gusta" puesto.
  final bool yaLeGusta;

  /// Se llama SOLO cuando el doble toque tiene que poner el me gusta.
  /// Si ya lo tenía, se anima el corazón pero no se quita: quitarlo por
  /// accidente al hacer doble toque sería un fastidio (y así funciona Instagram).
  final VoidCallback onMeGusta;

  /// Toque simple, normalmente para abrir la foto a pantalla completa.
  final VoidCallback? onToqueSimple;

  @override
  State<DobleToqueMeGusta> createState() => _DobleToqueMeGustaState();
}

class _DobleToqueMeGustaState extends State<DobleToqueMeGusta>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controlador = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _escala = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(begin: 0.4, end: 1.15).chain(CurveTween(curve: Curves.easeOut)),
      weight: 30,
    ),
    TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 20),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 30),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 20),
  ]).animate(_controlador);

  late final Animation<double> _opacidad = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 25),
    TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 30),
  ]).animate(_controlador);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  void _dobleToque() {
    if (!widget.yaLeGusta) widget.onMeGusta();
    _controlador.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onToqueSimple,
      onDoubleTap: _dobleToque,
      child: Stack(
        alignment: Alignment.center,
        children: [
          widget.child,
          // IgnorePointer: el corazón es decorativo, no debe robar los toques.
          IgnorePointer(
            child: AnimatedBuilder(
              animation: _controlador,
              builder: (_, __) => Opacity(
                opacity: _opacidad.value,
                child: Transform.scale(
                  scale: _escala.value,
                  child: const Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 96,
                    shadows: [
                      Shadow(color: Colors.black38, blurRadius: 12),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
