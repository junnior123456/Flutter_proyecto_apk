import 'dart:io';
import '../../repositories/image_repository.dart';

/// 🖼️ Caso de uso: Seleccionar imagen de la galería
class PickGalleryImageUseCase {
  final ImageRepository _imageRepository;

  PickGalleryImageUseCase(this._imageRepository);

  /// Ejecutar caso de uso
  Future<File?> execute() async {
    try {
      return await _imageRepository.pickFromGallery();
    } catch (e) {
      throw Exception('Error seleccionando imagen: $e');
    }
  }
}