import 'dart:io';

/// 📸 Repositorio de imágenes - Define contratos para manejo de imágenes
abstract class ImageRepository {
  /// Tomar foto con la cámara
  Future<File?> takePhoto();
  
  /// Seleccionar imagen de la galería
  Future<File?> pickFromGallery();
  
  /// Procesar y optimizar imagen
  Future<File?> processImage(File imageFile);
  
  /// Subir imagen a almacenamiento remoto
  Future<String?> uploadImage(File imageFile, String userId, {String? folder});
  
  /// Eliminar imagen del almacenamiento remoto
  Future<bool> deleteImage(String imageUrl);
}