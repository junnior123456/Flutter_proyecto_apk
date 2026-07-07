import 'dart:io';
import '../../repositories/image_repository.dart';

/// 📸 Caso de uso: Tomar foto con la cámara
class TakePhotoUseCase {
  final ImageRepository _imageRepository;

  TakePhotoUseCase(this._imageRepository);

  /// Ejecutar caso de uso
  Future<File?> execute() async {
    try {
      return await _imageRepository.takePhoto();
    } catch (e) {
      throw Exception('Error tomando foto: $e');
    }
  }
}