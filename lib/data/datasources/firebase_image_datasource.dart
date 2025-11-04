import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'image_datasource.dart';

/// 📸 Implementación de fuente de datos de imágenes con Firebase
class FirebaseImageDataSource implements ImageDataSource {
  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<File?> takePhoto() async {
    try {
      // En web, los permisos se manejan automáticamente por el navegador
      if (!kIsWeb) {
        // Solo verificar permisos en móvil
        final cameraPermission = await Permission.camera.request();
        if (cameraPermission.isDenied) {
          throw Exception('Permiso de cámara denegado. Ve a Configuración para habilitarlo.');
        }
      }

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
      throw Exception('Error tomando foto: $e');
    }
  }

  @override
  Future<File?> pickFromGallery() async {
    try {
      // En web, los permisos se manejan automáticamente por el navegador
      if (!kIsWeb) {
        // Solo verificar permisos en móvil
        final storagePermission = await Permission.photos.request();
        if (storagePermission.isDenied) {
          throw Exception('Permiso de galería denegado. Ve a Configuración para habilitarlo.');
        }
      }

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
      throw Exception('Error seleccionando imagen: $e');
    }
  }

  @override
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

  @override
  Future<String?> uploadImage(File imageFile, String userId, {String? folder}) async {
    int retryCount = 0;
    const maxRetries = 3;
    final folderName = folder ?? 'images';
    
    while (retryCount < maxRetries) {
      try {
        // Crear referencia en Firebase Storage
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final ref = _storage.ref().child(folderName).child('${userId}_$timestamp.jpg');
        
        // Subir archivo con metadata
        final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {
            'uploadedBy': userId,
            'uploadedAt': DateTime.now().toIso8601String(),
          },
        );
        
        UploadTask uploadTask;
        
        if (kIsWeb) {
          // En web, usar putData con bytes
          final bytes = await imageFile.readAsBytes();
          uploadTask = ref.putData(bytes, metadata);
        } else {
          // En móvil, usar putFile
          uploadTask = ref.putFile(imageFile, metadata);
        }
        
        final snapshot = await uploadTask;
        
        // Obtener URL de descarga
        final downloadUrl = await snapshot.ref.getDownloadURL();
        
        print('✅ Imagen subida exitosamente: $downloadUrl');
        return downloadUrl;
      } catch (e) {
        retryCount++;
        print('❌ Error subiendo imagen (intento $retryCount/$maxRetries): $e');
        
        if (retryCount >= maxRetries) {
          throw Exception('Error subiendo imagen después de $maxRetries intentos: $e');
        }
        
        // Esperar antes del siguiente intento
        await Future.delayed(Duration(seconds: retryCount * 2));
      }
    }
    
    return null;
  }

  @override
  Future<bool> deleteImage(String imageUrl) async {
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
}