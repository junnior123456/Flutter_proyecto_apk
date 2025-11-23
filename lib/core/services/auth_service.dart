import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'http_service.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpService _httpService = HttpService();
  
  // Keys para SharedPreferences
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _devTokenKey = 'dev_auth_token';
  static const String _devUserKey = 'dev_user_data';
  
  bool _isDevToken = false;

  /// 🛠️ Verificar si está en modo desarrollo
  bool get isDevelopmentMode => kDebugMode;

  /// 🔧 Verificar si es token de desarrollo
  bool get isDevToken => _isDevToken;

  // 🔐 Login con el backend
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      print('🔐 === INICIANDO LOGIN ===');
      print('📧 Email: $email');
      print('🌐 URL base configurada: ${ApiConfig.baseUrl}');
      print('🔄 URLs alternativas: ${ApiConfig.alternativeUrls}');
      
      // Verificar conectividad (no bloquear si falla)
      print('🔍 Verificando conectividad antes del login...');
      try {
        final isConnected = await _httpService.checkConnection();
        print('📡 Estado de conectividad: $isConnected');
      } catch (e) {
        print('⚠️ Error en verificación de conectividad, continuando con login: $e');
      }
      
      final response = await _httpService.post('/auth/login', body: {
        'email': email,
        'password': password,
      });

      print('📡 Respuesta del servidor: ${response.statusCode}');
      print('📥 Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Guardar token y datos del usuario
        await _saveAuthData(data);
        
        // Notificar cambio de usuario autenticado
        await _notifyProfileChange();
        
        print('✅ Login exitoso para: ${data['user']['email']}');
        return data;
      } else {
        final error = jsonDecode(response.body);
        print('❌ Error de login: ${error['message']}');
        throw Exception(error['message'] ?? 'Error de autenticación');
      }
    } catch (e) {
      print('❌ Error completo en login: $e');
      print('❌ Tipo de error: ${e.runtimeType}');
      rethrow;
    }
  }

  // 📝 Registro con el backend
  Future<Map<String, dynamic>?> register({
    required String name,
    required String lastname,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      print('📝 Intentando registro con: $email');
      
      final response = await _httpService.post('/auth/register', body: {
        'name': name,
        'lastname': lastname,
        'email': email,
        'password': password,
        'phone': phone,
      });

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Guardar token y datos del usuario
        await _saveAuthData(data);
        
        // Notificar cambio de usuario autenticado
        await _notifyProfileChange();
        
        print('✅ Registro exitoso para: ${data['user']['email']}');
        return data;
      } else {
        final error = jsonDecode(response.body);
        print('❌ Error de registro: ${error['message']}');
        throw Exception(error['message'] ?? 'Error de registro');
      }
    } catch (e) {
      print('❌ Error en registro: $e');
      rethrow;
    }
  }

  // 💾 Guardar datos de autenticación
  Future<void> _saveAuthData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Guardar token
    final token = data['token'] as String;
    await prefs.setString(_tokenKey, token);
    
    // Guardar datos del usuario
    final userData = jsonEncode(data['user']);
    await prefs.setString(_userKey, userData);
    
    // Configurar token en HttpService
    _httpService.setAuthToken(token.replaceFirst('Bearer ', ''));
  }

  // 🔍 Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // 👤 Obtener datos del usuario actual (con fallback a desarrollo)
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Intentar obtener usuario real primero
      final userData = prefs.getString(_userKey);
      if (userData != null) {
        return jsonDecode(userData);
      }
      
      // Si estamos en modo desarrollo, obtener/crear usuario de desarrollo
      if (isDevelopmentMode) {
        final devUserData = prefs.getString(_devUserKey);
        if (devUserData != null) {
          return jsonDecode(devUserData);
        }
        
        // Crear usuario de desarrollo por defecto
        final devUser = {
          'id': 'dev_user',
          'name': 'Usuario Desarrollo',
          'email': 'dev@pawfinder.com',
          'phone': '123-456-7890'
        };
        
        await prefs.setString(_devUserKey, jsonEncode(devUser));
        return devUser;
      }
      
      return null;
    } catch (e) {
      Logger.authOperation('Error getting current user', success: false, details: e.toString());
      
      // Fallback para desarrollo
      if (isDevelopmentMode) {
        return {
          'id': 'dev_user',
          'name': 'Usuario Desarrollo',
          'email': 'dev@pawfinder.com',
          'phone': '123-456-7890'
        };
      }
      
      return null;
    }
  }

  // 🔑 Obtener token actual (con fallback a desarrollo)
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Intentar obtener token real primero
      String? realToken = prefs.getString(_tokenKey);
      if (realToken != null) {
        _isDevToken = false;
        Logger.authOperation('Using real token', success: true);
        return realToken;
      }
      
      // Si estamos en modo desarrollo, crear/obtener token de desarrollo
      if (isDevelopmentMode) {
        return await getOrCreateDevToken();
      }
      
      Logger.authOperation('No token available', success: false);
      return null;
    } catch (e) {
      Logger.authOperation('Error getting token', success: false, details: e.toString());
      
      // Fallback: si estamos en desarrollo, crear token temporal
      if (isDevelopmentMode) {
        return await getOrCreateDevToken();
      }
      
      return null;
    }
  }

  /// 🔑 Obtener o crear token de desarrollo
  Future<String> getOrCreateDevToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? savedDevToken = prefs.getString(_devTokenKey);
      
      if (savedDevToken != null) {
        _isDevToken = true;
        Logger.authOperation('Using existing dev token', success: true);
        return savedDevToken;
      }

      // Crear nuevo token de desarrollo
      final devToken = 'dev_token_${DateTime.now().millisecondsSinceEpoch}';
      final devUser = {
        'id': 'dev_user',
        'name': 'Usuario Desarrollo',
        'email': 'dev@pawfinder.com',
        'phone': '123-456-7890'
      };
      
      await prefs.setString(_devTokenKey, devToken);
      await prefs.setString(_devUserKey, jsonEncode(devUser));
      
      _isDevToken = true;
      
      // Configurar token en HttpService
      final httpService = HttpService();
      httpService.setAuthToken(devToken);
      
      Logger.authOperation('Created new dev token', success: true);
      return devToken;
    } catch (e) {
      Logger.authOperation('Failed to create dev token', success: false, details: e.toString());
      
      // Fallback: crear token temporal en memoria
      final tempToken = 'temp_dev_token_${DateTime.now().millisecondsSinceEpoch}';
      _isDevToken = true;
      _httpService.setAuthToken(tempToken);
      return tempToken;
    }
  }

  /// 🔍 Verificar si hay token válido
  Future<bool> hasValidToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final realToken = prefs.getString(_tokenKey);
      final devToken = prefs.getString(_devTokenKey);
      
      return realToken != null || (isDevelopmentMode && devToken != null);
    } catch (e) {
      return isDevelopmentMode; // En desarrollo, siempre podemos crear un token
    }
  }

  // 🔄 Refrescar token (simple implementación)
  Future<bool> refreshToken() async {
    try {
      Logger.authOperation('Attempting to refresh token');
      
      // Obtener datos del usuario actual
      final userData = await getCurrentUser();
      if (userData != null && userData['email'] != null) {
        try {
          // Intentar login con las credenciales conocidas
          String? password;
          
          // Mapeo de emails a contraseñas conocidas (solo para desarrollo)
          if (userData['email'] == 'david@gmail.com') {
            password = '123456';
          } else if (userData['email'] == 'junniorchinchay@upeu.edu.pe') {
            password = '123456';
          } else if (userData['email'] == 'demo@pawfinder.com') {
            password = '123456';
          }
          
          if (password != null) {
            final loginResult = await login(userData['email'], password);
            if (loginResult != null) {
              Logger.authOperation('Token refreshed successfully', success: true);
              return true;
            }
          }
        } catch (e) {
          Logger.authOperation('Token refresh failed', success: false, details: e.toString());
        }
      }
      
      // Si no se puede refrescar, limpiar sesión para forzar nuevo login
      Logger.authOperation('Cannot refresh token, clearing session', success: false);
      await logout();
      return false;
    } catch (e) {
      Logger.authOperation('Error refreshing token', success: false, details: e.toString());
      await logout();
      return false;
    }
  }

  // 🚪 Cerrar sesión
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Limpiar datos locales
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      
      // Limpiar token del HttpService
      _httpService.clearAuthToken();
      
      // Limpiar perfil
      await _clearProfile();
      
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
    }
  }

  // 🔄 Inicializar servicio (cargar token si existe)
  Future<void> initialize() async {
    try {
      final token = await getToken();
      if (token != null) {
        _httpService.setAuthToken(token.replaceFirst('Bearer ', ''));
        Logger.authOperation('AuthService initialized', success: true);
      } else if (isDevelopmentMode) {
        // En desarrollo, hacer login automático
        try {
          Logger.authOperation('Attempting automatic login for development');
          final loginResult = await login('demo@pawfinder.com', '123456');
          if (loginResult != null) {
            Logger.authOperation('Automatic login successful', success: true);
          }
        } catch (e) {
          Logger.authOperation('Automatic login failed, using fallback', success: false, details: e.toString());
        }
      }
    } catch (e) {
      Logger.authOperation('Error initializing AuthService', success: false, details: e.toString());
    }
  }

  // 🧪 Validar credenciales (método compatible con el código existente)
  Future<bool> validateCredentials(String email, String password) async {
    try {
      final result = await login(email, password);
      return result != null;
    } catch (e) {
      return false;
    }
  }

  // 🔄 Notificar cambio de perfil (Clean Architecture)
  Future<void> _notifyProfileChange() async {
    // Por ahora, simplemente imprimir. El UserProfileNotifier se sincronizará
    // cuando se cargue la siguiente pantalla
    print('🔄 Usuario autenticado, perfil debe sincronizarse');
  }

  // 🗑️ Limpiar perfil
  Future<void> _clearProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_profile');
      print('🗑️ Perfil limpiado');
    } catch (e) {
      print('⚠️ No se pudo limpiar perfil: $e');
    }
  }

  // 🔍 Verificar si un correo ya existe
  Future<bool> checkEmailExists(String email) async {
    try {
      Logger.authOperation('Checking if email exists', details: email);
      
      final response = await _httpService.post(
        '/auth/check-email',
        body: {'email': email.trim().toLowerCase()},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final exists = data['exists'] == true;
        
        Logger.authOperation(
          'Email check result',
          success: true,
          details: exists ? 'Email exists' : 'Email available',
        );
        
        return exists;
      }
      
      // En caso de error, asumir que no existe para no bloquear el registro
      Logger.authOperation('Email check failed, assuming available', success: false);
      return false;
    } catch (e) {
      Logger.authOperation('Error checking email', success: false, details: e.toString());
      // En caso de error de red, mejor dejar que el usuario intente
      return false;
    }
  }

  // 🔐 Solicitar recuperación de contraseña
  Future<Map<String, dynamic>?> requestPasswordReset(String email) async {
    try {
      Logger.authOperation('Requesting password reset', details: email);
      
      final response = await _httpService.post(
        '/auth/forgot-password',
        body: {'email': email.trim().toLowerCase()},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        Logger.authOperation('Password reset requested', success: true);
        
        return data;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al solicitar recuperación');
      }
    } catch (e) {
      Logger.authOperation('Error requesting password reset', success: false, details: e.toString());
      rethrow;
    }
  }

  // 🔄 Resetear contraseña con token
  Future<bool> resetPassword(String token, String newPassword) async {
    try {
      Logger.authOperation('Resetting password with token');
      
      final response = await _httpService.post(
        '/auth/reset-password',
        body: {
          'token': token,
          'password': newPassword,
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        Logger.authOperation('Password reset successful', success: true);
        
        return data['success'] == true;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Error al resetear contraseña');
      }
    } catch (e) {
      Logger.authOperation('Error resetting password', success: false, details: e.toString());
      rethrow;
    }
  }
}
