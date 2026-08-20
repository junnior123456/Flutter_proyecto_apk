/// Vídeos cortos de las publicaciones: elegirlos, medirlos y subirlos.
///
/// El tope acordado son 30 s / 50 MB. image_picker ya recorta por duración al
/// elegir, pero se vuelve a comprobar aquí porque en algunos Android el recorte
/// no se aplica y el backend rechazaría la subida con un 400 poco claro.
library;

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';
import 'token_manager.dart';

class VideoService {
  static const int maxSegundos = 30;
  static const int maxBytes = 50 * 1024 * 1024;

  final ImagePicker _picker = ImagePicker();
  final TokenManager _tokenManager = TokenManager();

  /// Elige un vídeo de la galería o lo graba con la cámara.
  Future<File?> pickVideo({bool desdeCamara = false}) async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: desdeCamara ? ImageSource.camera : ImageSource.gallery,
        maxDuration: const Duration(seconds: maxSegundos),
      );
      return video == null ? null : File(video.path);
    } catch (e) {
      Logger.debug('❌ Error eligiendo vídeo: $e');
      return null;
    }
  }

  /// Duración real del archivo: image_picker no la devuelve, así que hay que
  /// abrir el vídeo para leerla.
  Future<int?> duracionSegundos(File video) async {
    final controller = VideoPlayerController.file(video);
    try {
      await controller.initialize();
      return controller.value.duration.inSeconds;
    } catch (e) {
      Logger.debug('❌ No se pudo leer la duración del vídeo: $e');
      return null;
    } finally {
      await controller.dispose();
    }
  }

  /// Comprueba tope de tamaño y duración. Devuelve el motivo del rechazo, o
  /// null si el vídeo vale.
  Future<String?> motivoRechazo(File video) async {
    final bytes = await video.length();
    if (bytes > maxBytes) {
      final mb = (bytes / 1024 / 1024).toStringAsFixed(1);
      return 'El vídeo pesa $mb MB y el máximo son 50 MB';
    }
    final segundos = await duracionSegundos(video);
    if (segundos != null && segundos > maxSegundos) {
      return 'El vídeo dura $segundos s y el máximo son $maxSegundos s';
    }
    return null;
  }

  /// Sube el vídeo a una publicación ya creada.
  /// Devuelve null si fue bien, o el mensaje de error para enseñar al usuario.
  Future<String?> subirVideoDeMascota({
    required int petId,
    required File video,
    int? durationSec,
  }) async {
    final rechazo = await motivoRechazo(video);
    if (rechazo != null) return rechazo;

    try {
      final token = await _tokenManager.getToken();
      final peticion = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/pets/$petId/video'),
      );
      peticion.headers['Authorization'] = 'Bearer $token';
      peticion.files.add(await http.MultipartFile.fromPath('video', video.path));

      final segundos = durationSec ?? await duracionSegundos(video);
      if (segundos != null) {
        peticion.fields['durationSec'] = segundos.toString();
      }

      final respuesta = await http.Response.fromStream(await peticion.send());
      if (respuesta.statusCode == 200 || respuesta.statusCode == 201) {
        Logger.debug('✅ Vídeo subido a la publicación $petId');
        return null;
      }
      if (respuesta.statusCode == 413) {
        return 'El vídeo es demasiado pesado (máximo 50 MB)';
      }
      Logger.debug('❌ Subida de vídeo falló: ${respuesta.statusCode}');
      return 'No se pudo subir el vídeo (${respuesta.statusCode})';
    } catch (e) {
      Logger.debug('❌ Error subiendo vídeo: $e');
      return 'No se pudo subir el vídeo. Revisa tu conexión.';
    }
  }
}
