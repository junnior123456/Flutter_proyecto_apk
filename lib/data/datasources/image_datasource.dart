import 'dart:io';

/// 📸 Fuente de datos de imágenes - Define contratos para acceso a datos
abstract class ImageDataSource {
  /// Tomar foto con la cámara
  Future<File?> takePhoto();
  
  /// Seleccionar imagen de la galería
  Future<File?> pickFromGallery();
  
  /// Procesar y optimizar imagen
  Future<File?> processImage(File imageFile);
  
  /// Subir imagen a Firebase Storage
  Future<String?> uploadImage(File imageFile, String userId, {String? folder});
  
  /// Eliminar imagen de Firebase Storage
  Future<bool> deleteImage(String imageUrl);
}