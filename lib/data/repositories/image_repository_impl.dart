import 'dart:io';
import '../../domain/repositories/image_repository.dart';
import '../datasources/image_datasource.dart';

/// 📸 Implementación del repositorio de imágenes
class ImageRepositoryImpl implements ImageRepository {
  final ImageDataSource _imageDataSource;

  ImageRepositoryImpl(this._imageDataSource);

  @override
  Future<File?> takePhoto() async {
    return await _imageDataSource.takePhoto();
  }

  @override
  Future<File?> pickFromGallery() async {
    return await _imageDataSource.pickFromGallery();
  }

  @override
  Future<File?> processImage(File imageFile) async {
    return await _imageDataSource.processImage(imageFile);
  }

  @override
  Future<String?> uploadImage(File imageFile, String userId, {String? folder}) async {
    return await _imageDataSource.uploadImage(imageFile, userId, folder: folder);
  }

  @override
  Future<bool> deleteImage(String imageUrl) async {
    return await _imageDataSource.deleteImage(imageUrl);
  }
}