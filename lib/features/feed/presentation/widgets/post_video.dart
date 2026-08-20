/// Reproductor de los vídeos cortos del feed.
///
/// Arranca mostrando la portada (una imagen ligera) con un botón de play, y
/// solo crea el VideoPlayerController cuando el usuario toca: si se inicializara
/// un controlador por cada tarjeta, bajando por el muro se abrirían decenas de
/// vídeos a la vez y la app se arrastraría.
library;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostVideo extends StatefulWidget {
  const PostVideo({
    super.key,
    required this.videoUrl,
    this.thumbnailUrl,
    this.durationSec,
  });

  final String videoUrl;
  final String? thumbnailUrl;
  final int? durationSec;

  @override
  State<PostVideo> createState() => _PostVideoState();
}

class _PostVideoState extends State<PostVideo> {
  VideoPlayerController? _controller;
  bool _cargando = false;
  String? _error;

  @override
  void dispose() {
    // Sin esto el vídeo se sigue oyendo al salir de la pantalla.
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _iniciar() async {
    if (_cargando || _controller != null) return;
    setState(() {
      _cargando = true;
      _error = null;
    });

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    );

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.play();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _cargando = false;
      });
    } catch (e) {
      await controller.dispose();
      if (!mounted) return;
      setState(() {
        _cargando = false;
        _error = 'No se pudo reproducir el vídeo';
      });
    }
  }

  void _alternarPausa() {
    final c = _controller;
    if (c == null) return;
    setState(() => c.value.isPlaying ? c.pause() : c.play());
  }

  String get _duracionTexto {
    final s = widget.durationSec;
    if (s == null || s <= 0) return '';
    final m = s ~/ 60;
    final r = s % 60;
    return '$m:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final c = _controller;

    // Ya reproduciendo: el vídeo manda su propia relación de aspecto.
    if (c != null && c.value.isInitialized) {
      return GestureDetector(
        onTap: _alternarPausa,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: c.value.aspectRatio,
              child: VideoPlayer(c),
            ),
            if (!c.value.isPlaying)
              const _BotonPlay(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(c, allowScrubbing: true),
            ),
          ],
        ),
      );
    }

    // Aún no ha tocado: portada + play.
    return GestureDetector(
      onTap: _iniciar,
      child: AspectRatio(
        aspectRatio: 1,
        child: Stack(
          fit: StackFit.expand,
          alignment: Alignment.center,
          children: [
            if (widget.thumbnailUrl != null && widget.thumbnailUrl!.isNotEmpty)
              Image.network(
                widget.thumbnailUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: scheme.surfaceContainerHighest),
              )
            else
              Container(color: scheme.surfaceContainerHighest),
            Container(color: Colors.black26),
            if (_cargando)
              const CircularProgressIndicator(color: Colors.white)
            else if (_error != null)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white, size: 40),
                  const SizedBox(height: 6),
                  Text(_error!,
                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              )
            else
              const _BotonPlay(),
            if (_duracionTexto.isNotEmpty)
              Positioned(
                right: 8,
                bottom: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _duracionTexto,
                    style: const TextStyle(color: Colors.white, fontSize: 11),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BotonPlay extends StatelessWidget {
  const _BotonPlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 62,
      height: 62,
      decoration: const BoxDecoration(
        color: Colors.black54,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.play_arrow, color: Colors.white, size: 38),
    );
  }
}
