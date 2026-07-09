import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';

/// 🔐 Interceptor HTTP profesional
/// Maneja automáticamente errores 401 sin molestar al usuario
class HttpInterceptor {
  static final HttpInterceptor _instance = HttpInterceptor._internal();
  factory HttpInterceptor() => _instance;
  HttpInterceptor._internal();
  
  // Control de logout en progreso
  bool _isLoggingOut = false;

  /// 📤 Hacer petición HTTP con manejo automático de 401
  Future<http.Response> request(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      // Obtener token directamente de SharedPreferences (sin usar AuthService)
      final token = await _getTokenDirect();
      
      // Preparar headers
      final requestHeaders = {
        ...ApiConfig.defaultHeaders,
        if (headers != null) ...headers,
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // Hacer petición
      final response = await _makeRequest(
        method,
        endpoint,
        requestHeaders,
        body,
      );

      // Manejar 401 automáticamente
      if (response.statusCode == 401) {
        await _handleUnauthorized();
        
        // Lanzar excepción para que el servicio sepa que falló
        throw UnauthorizedException('Token expirado o inválido');
      }

      return response;
    } catch (e) {
      if (e is UnauthorizedException) {
        rethrow;
      }
      Logger.error('HTTP request failed', tag: 'HttpInterceptor', error: e);
      rethrow;
    }
  }

  /// 🔨 Hacer petición HTTP real
  Future<http.Response> _makeRequest(
    String method,
    String endpoint,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) async {
    final url = Uri.parse(ApiConfig.baseUrl + endpoint);
    final bodyJson = body != null ? jsonEncode(body) : null;

    Logger.apiRequest(method, endpoint, headers: headers, body: body);

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: headers)
            .timeout(ApiConfig.connectTimeout);
        break;
      case 'POST':
        response = await http.post(url, headers: headers, body: bodyJson)
            .timeout(ApiConfig.connectTimeout);
        break;
      case 'PUT':
        response = await http.put(url, headers: headers, body: bodyJson)
            .timeout(ApiConfig.connectTimeout);
        break;
      case 'PATCH':
        response = await http.patch(url, headers: headers, body: bodyJson)
            .timeout(ApiConfig.connectTimeout);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: headers)
            .timeout(ApiConfig.connectTimeout);
        break;
      default:
        throw UnsupportedError('HTTP method $method not supported');
    }

    Logger.apiResponse(method, endpoint, response.statusCode, body: response.body);

    return response;
  }

  /// 🚪 Manejar 401 Unauthorized de forma profesional
  Future<void> _handleUnauthorized() async {
    // Evitar múltiples logouts simultáneos
    if (_isLoggingOut) {
      return;
    }

    _isLoggingOut = true;

    try {
      Logger.warning('401 Unauthorized detected, logging out silently...', tag: 'HttpInterceptor');
      
      // Logout silencioso directamente (sin usar AuthService para evitar ciclo)
      await _logoutDirect();
      
      Logger.info('User logged out due to expired token', tag: 'HttpInterceptor');
      
      // El interceptor solo limpia la sesión
      // La navegación se maneja automáticamente cuando la app detecta que no hay token
    } finally {
      _isLoggingOut = false;
    }
  }

  /// 🔑 Obtener token directamente de SharedPreferences
  Future<String?> _getTokenDirect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      Logger.error('Error getting token', tag: 'HttpInterceptor', error: e);
      return null;
    }
  }

  /// 🚪 Logout directo sin usar AuthService
  Future<void> _logoutDirect() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      Logger.info('Session cleared', tag: 'HttpInterceptor');
    } catch (e) {
      Logger.error('Error clearing session', tag: 'HttpInterceptor', error: e);
    }
  }
}

/// ❌ Excepción personalizada para 401
class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
