import 'dart:io';
import '../../repositories/image_repository.dart';

/// ☁️ Caso de uso: Subir imagen al almacenamiento remoto
class UploadImageUseCase {
  final ImageRepository _imageRepository;

  UploadImageUseCase(this._imageRepository);

  /// Ejecutar caso de uso para imagen de perfil
  Future<String?> executeProfileImage(File imageFile, String userId) async {
    try {
      // Procesar imagen antes de subir
      final processedImage = await _imageRepository.processImage(imageFile);
      if (processedImage == null) {
        throw Exception('Error procesando imagen');
      }

      return await _imageRepository.uploadImage(
        processedImage, 
        userId, 
        folder: 'profile_images'
      );
    } catch (e) {
      throw Exception('Error subiendo imagen de perfil: $e');
    }
  }

  /// Ejecutar caso de uso para imagen de mascota
  Future<String?> executePetImage(File imageFile, String petId) async {
    try {
      // Procesar imagen antes de subir
      final processedImage = await _imageRepository.processImage(imageFile);
      if (processedImage == null) {
        throw Exception('Error procesando imagen');
      }

      return await _imageRepository.uploadImage(
        processedImage, 
        petId, 
        folder: 'pet_images'
      );
    } catch (e) {
      throw Exception('Error subiendo imagen de mascota: $e');
    }
  }
}