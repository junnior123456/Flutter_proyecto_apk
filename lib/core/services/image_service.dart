import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import '../utils/logger.dart';
import '../config/api_config.dart';

class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// 📸 Tomar foto con la cámara
  Future<File?> takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (photo != null) {
        return File(photo.path);
      }
      return null;
    } catch (e) {
      print('❌ Error tomando foto: $e');
      return null;
    }
  }

  /// 🖼️ Seleccionar imagen de la galería
  Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      print('❌ Error seleccionando imagen: $e');
      return null;
    }
  }

  /// 🔄 Procesar y optimizar imagen
  Future<File?> processImage(File imageFile) async {
    try {
      // Leer la imagen
      final bytes = await imageFile.readAsBytes();
      img.Image? image = img.decodeImage(bytes);
      
      if (image == null) return null;

      // Redimensionar si es muy grande
      if (image.width > 512 || image.height > 512) {
        image = img.copyResize(image, width: 512, height: 512);
      }

      // Convertir a JPEG con calidad optimizada
      final processedBytes = img.encodeJpg(image, quality: 85);

      if (kIsWeb) {
        // En web, crear un archivo temporal en memoria
        return File.fromRawPath(processedBytes);
      } else {
        // En móvil, guardar en directorio temporal
        final tempDir = await getTemporaryDirectory();
        final processedFile = File('${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.jpg');
        await processedFile.writeAsBytes(processedBytes);
        return processedFile;
      }
    } catch (e) {
      print('❌ Error procesando imagen: $e');
      return imageFile; // Retornar original si falla el procesamiento
    }
  }

  /// ☁️ Subir imagen a través del backend
  Future<String?> uploadToFirebase(File imageFile, String userId, {String folder = 'profile_images'}) async {
    try {
      Logger.info('📤 Uploading image through backend', tag: 'IMAGE');
      Logger.debug('File path: ${imageFile.path}', tag: 'IMAGE');
      Logger.debug('Folder: $folder', tag: 'IMAGE');

      // Procesar imagen antes de subir
      final processedImage = await processImage(imageFile);
      if (processedImage == null) return null;

      // Crear FormData para multipart/form-data
      final bytes = await processedImage.readAsBytes();
      final fileName = path.basename(processedImage.path);
      
      // Crear el request multipart
      final uri = Uri.parse('${ApiConfig.baseUrl}/upload/image?folder=$folder');
      final request = http.MultipartRequest('POST', uri);
      
      // Agregar el archivo
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: fileName,
        ),
      );
      
      // Agregar headers
      request.headers.addAll({
        'Accept': 'application/json',
      });
      
      Logger.debug('Sending request to: $uri', tag: 'IMAGE');
      
      // Enviar request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      Logger.debug('Response status: ${response.statusCode}', tag: 'IMAGE');
      Logger.debug('Response body: ${response.body}', tag: 'IMAGE');
      
      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        final imageUrl = responseData['imageUrl'] as String;
        
        Logger.info('✅ Image uploaded successfully through backend', tag: 'IMAGE');
        Logger.debug('Image URL: $imageUrl', tag: 'IMAGE');
        
        return imageUrl;
      } else {
        Logger.error('❌ Backend upload failed: ${response.statusCode} - ${response.body}', tag: 'IMAGE');
        return null;
      }
    } catch (e) {
      Logger.error('❌ Error uploading image through backend: $e', tag: 'IMAGE');
      return null;
    }
  }

  /// 🗑️ Eliminar imagen de Firebase Storage
  Future<bool> deleteFromFirebase(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Imagen eliminada de Firebase');
      return true;
    } catch (e) {
      print('❌ Error eliminando imagen: $e');
      return false;
    }
  }

  /// 📱 Mostrar opciones de selección de imagen
  Future<File?> showImageSourceDialog(BuildContext context) async {
    return showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Seleccionar imagen',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageOption(
                    context: context,
                    icon: Icons.photo_camera,
                    label: 'Cámara',
                    onTap: () async {
                      final image = await takePhoto();
                      Navigator.pop(context, image);
                    },
                  ),
                  _buildImageOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Galería',
                    onTap: () async {
                      final image = await pickFromGallery();
                      Navigator.pop(context, image);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: (color ?? Theme.of(context).primaryColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color ?? Theme.of(context).primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? Theme.of(context).textTheme.bodyMedium?.color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
  /// 🔄 Subir imagen para mascotas
  Future<String?> uploadPetImage(File imageFile, String petId) async {
    return await uploadToFirebase(imageFile, petId, folder: 'pet_images');
  }

  /// 🔄 Subir imagen de perfil
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    return await uploadToFirebase(imageFile, userId, folder: 'profile_images');
  }
}