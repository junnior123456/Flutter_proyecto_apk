import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';
import 'http_service.dart';
import 'image_service.dart';
import 'auth_service.dart';
import '../utils/logger.dart';
import '../config/api_config.dart';

class ProfileService {
  static final ProfileService _instance = ProfileService._internal();
  factory ProfileService() => _instance;
  ProfileService._internal();

  final HttpService _httpService = HttpService();
  final ImageService _imageService = ImageService();

  /// 📝 Actualizar perfil del usuario sin imagen
  Future<Map<String, dynamic>?> updateProfile({
    required int userId,
    required String name,
    required String email,
    String? phone,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      Logger.userOperation('Updating profile without image', userId: userId.toString());

      // Configurar token en HttpService
      _httpService.setAuthToken(token);

      final response = await _httpService.put(
        '/users/$userId',
        body: {
          'name': name,
          'email': email,
          if (phone != null) 'phone': phone,
        },
      );

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        Logger.userOperation('Profile updated successfully', userId: userId.toString(), data: updatedData);
        
        // Guardar datos actualizados localmente
        await saveUserDataLocally(updatedData);
        
        return updatedData;
      } else {
        throw Exception('Error al actualizar perfil: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error updating profile', tag: 'ProfileService', error: e, stackTrace: StackTrace.current);
      rethrow; // Re-lanzar para manejo en UI
    }
  }

  /// 🖼️ Actualizar perfil del usuario con imagen (implementación del profesor)
  Future<Map<String, dynamic>?> updateProfileWithImage({
    required int userId,
    required String name,
    required String email,
    String? phone,
    required File imageFile,
  }) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      Logger.userOperation('Starting profile update with image using MultipartRequest', userId: userId.toString());

      // Implementación exacta del profesor
      final url = Uri.parse('${ApiConfig.baseUrl}/users/upload/$userId');
      final request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = token;

      // Añadir el archivo (como el profesor)
      request.files.add(http.MultipartFile(
        'file',
        http.ByteStream(imageFile.openRead().cast()),
        await imageFile.length(),
        filename: path.basename(imageFile.path),
        contentType: MediaType('image', 'jpg'),
      ));

      // Añadir campos (como el profesor)
      request.fields['name'] = name;
      request.fields['email'] = email;
      if (phone != null) {
        request.fields['phone'] = phone;
      }

      final response = await request.send();
      Logger.userOperation('MultipartRequest response', userId: userId.toString(), data: {'statusCode': response.statusCode});

      final responseBody = await response.stream.transform(utf8.decoder).first;
      final data = json.decode(responseBody);

      if (response.statusCode == 200 || response.statusCode == 201) {
        Logger.userOperation('Profile updated successfully with image', userId: userId.toString(), data: data);
        
        // Guardar datos actualizados localmente
        await saveUserDataLocally(data);
        
        return data;
      } else {
        Logger.error('Backend update failed', tag: 'ProfileService', error: 'Status: ${response.statusCode}, Body: $responseBody');
        throw Exception('Error al actualizar perfil en backend: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error updating profile with image', tag: 'ProfileService', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  /// 👤 Obtener perfil del usuario actual con mecanismos de fallback
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    try {
      Logger.userOperation('Getting current user profile');
      
      // 1. Intentar obtener datos locales primero
      final localData = await getUserDataLocally();
      if (localData == null) {
        throw Exception('No hay datos de usuario guardados localmente');
      }

      final userId = localData['id'];
      if (userId == null) {
        throw Exception('ID de usuario no encontrado en datos locales');
      }

      // 2. Intentar sincronizar con backend si hay token
      final token = await _getToken();
      if (token != null) {
        try {
          Logger.userOperation('Syncing with backend', userId: userId.toString());
          
          // Configurar token en HttpService
          _httpService.setAuthToken(token.replaceFirst('Bearer ', ''));

          final response = await _httpService.get('/users/$userId');

          if (response.statusCode == 200) {
            final backendData = json.decode(response.body);
            Logger.userOperation('Profile obtained from backend', userId: userId.toString(), data: {'name': backendData['name']});
            
            // DEBUG: Log de la URL de imagen
            print('🖼️ DEBUG ProfileService: Image URL from backend: ${backendData['image']}');
            
            // Actualizar datos locales con los del backend
            await saveUserDataLocally(backendData);
            
            return backendData;
          } else if (response.statusCode == 401) {
            // Token expirado, limpiar y usar datos locales
            Logger.warning('Token expired, using local data', tag: 'ProfileService');
            await _clearExpiredToken();
            return localData;
          } else {
            Logger.warning('Backend error (${response.statusCode}), using local data', tag: 'ProfileService');
            return localData;
          }
        } catch (networkError) {
          Logger.warning('Network error, using local data', tag: 'ProfileService', error: networkError);
          return localData;
        }
      } else {
        Logger.warning('No token available, using local data', tag: 'ProfileService');
        return localData;
      }
    } catch (e) {
      Logger.error('Error getting current user profile', tag: 'ProfileService', error: e, stackTrace: StackTrace.current);
      
      // Último intento: retornar datos locales si existen
      try {
        final fallbackData = await getUserDataLocally();
        if (fallbackData != null) {
          Logger.info('Using local data as last resort', tag: 'ProfileService');
          return fallbackData;
        }
      } catch (fallbackError) {
        Logger.error('Error getting local fallback data', tag: 'ProfileService', error: fallbackError);
      }
      
      return null;
    }
  }

  /// 🧹 Limpiar token expirado
  Future<void> _clearExpiredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      Logger.authOperation('Expired token cleared', success: true);
    } catch (e) {
      Logger.error('Error clearing expired token', tag: 'ProfileService', error: e);
    }
  }

  /// 🔄 Refrescar perfil desde backend (FORZADO)
  Future<Map<String, dynamic>?> refreshProfileFromBackend() async {
    try {
      final localData = await getUserDataLocally();
      if (localData == null) {
        throw Exception('No hay datos locales para refrescar');
      }

      final userId = localData['id'];
      final token = await _getToken();
      
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      Logger.userOperation('FORCE Refreshing profile from backend', userId: userId.toString());
      print('🔄 FORCE REFRESH: Obteniendo perfil actualizado del backend...');
      
      _httpService.setAuthToken(token.replaceFirst('Bearer ', ''));
      final response = await _httpService.get('/users/$userId');

      if (response.statusCode == 200) {
        final backendData = json.decode(response.body);
        print('🖼️ FORCE REFRESH: Nueva imagen URL: ${backendData['image']}');
        await saveUserDataLocally(backendData);
        Logger.userOperation('Profile FORCE refreshed from backend', userId: userId.toString(), data: backendData);
        return backendData;
      } else {
        throw Exception('Error refrescando perfil: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error refreshing profile', tag: 'ProfileService', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }

  final AuthService _authService = AuthService();

  /// 🔑 Obtener token de autenticación (con fallback automático)
  Future<String?> _getToken() async {
    try {
      final token = await _authService.getToken();
      if (token != null) {
        Logger.storageOperation('Get auth token', success: true);
        return token;
      }
      Logger.storageOperation('Get auth token', success: false);
      return null;
    } catch (e) {
      Logger.error('Error getting auth token', tag: 'ProfileService', error: e);
      return null;
    }
  }

  /// 💾 Guardar datos del usuario en preferencias locales
  Future<void> saveUserDataLocally(Map<String, dynamic> userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_data', json.encode(userData));
    } catch (e) {
      Logger.error('Error saving user data locally', tag: 'ProfileService', error: e);
    }
  }

  /// 📖 Obtener datos del usuario desde preferencias locales
  Future<Map<String, dynamic>?> getUserDataLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString('user_data');
      if (userData != null) {
        return json.decode(userData);
      }
      return null;
    } catch (e) {
      Logger.error('Error getting local user data', tag: 'ProfileService', error: e);
      return null;
    }
  }

  /// 🔄 Sincronizar datos con el backend
  Future<Map<String, dynamic>?> syncWithBackend() async {
    try {
      final localData = await getUserDataLocally();
      if (localData == null) {
        throw Exception('No hay datos locales para sincronizar');
      }

      final userId = localData['id'];
      if (userId == null) {
        throw Exception('ID de usuario no encontrado en datos locales');
      }

      final token = await _getToken();
      if (token == null) {
        print('⚠️ No hay token, manteniendo datos locales');
        return localData;
      }

      // Configurar token en HttpService
      _httpService.setAuthToken(token.replaceFirst('Bearer ', ''));

      final response = await _httpService.get('/users/$userId');

      if (response.statusCode == 200) {
        final backendData = json.decode(response.body);
        Logger.userOperation('Data synced with backend successfully', userId: userId.toString());
        
        // Actualizar datos locales con los del backend
        await saveUserDataLocally(backendData);
        
        return backendData;
      } else {
        Logger.warning('Error syncing with backend (${response.statusCode}), keeping local data', tag: 'ProfileService');
        return localData;
      }
    } catch (e) {
      Logger.error('Error syncing with backend', tag: 'ProfileService', error: e);
      // Retornar datos locales como fallback
      return await getUserDataLocally();
    }
  }

  /// 🔄 Sincronizar con datos específicos del backend
  Future<void> syncWithBackendData(Map<String, dynamic> backendData) async {
    try {
      await saveUserDataLocally(backendData);
      Logger.storageOperation('Backend data saved locally', success: true);
    } catch (e) {
      Logger.error('Error saving backend data', tag: 'ProfileService', error: e);
    }
  }

  /// 🗑️ Eliminar imagen de perfil
  Future<Map<String, dynamic>?> removeProfileImage(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No hay token de autenticación');

      Logger.userOperation('Removing profile image', userId: userId.toString());

      // Configurar token en HttpService
      _httpService.setAuthToken(token);

      // Actualizar perfil en backend removiendo la imagen
      final response = await _httpService.put(
        '/users/$userId',
        body: {
          'imageUrl': null, // Remover imagen
        },
      );

      if (response.statusCode == 200) {
        final updatedData = json.decode(response.body);
        Logger.userOperation('Profile image removed successfully', userId: userId.toString());
        
        // Guardar datos actualizados localmente
        await saveUserDataLocally(updatedData);
        
        return updatedData;
      } else {
        throw Exception('Error eliminando imagen de perfil: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error removing profile image', tag: 'ProfileService', error: e, stackTrace: StackTrace.current);
      rethrow;
    }
  }
}