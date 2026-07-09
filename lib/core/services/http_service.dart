import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../utils/logger.dart';
import 'http_interceptor.dart';

/// Servicio HTTP para comunicación con el backend NestJS
/// Ahora apuntando al backend deployado en Railway
class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;

  HttpService._internal() {
    _initializeConnection();
  }

  /// 🌐 URL fija de tu backend en Railway
  static const String _railwayBaseUrl =
      'http://167.99.4.161';

  // URL que funciona (se actualiza automáticamente al detectar conexión)
  String? _workingBaseUrl;

  // Interceptor para manejo automático de 401
  final HttpInterceptor _interceptor = HttpInterceptor();

  /// Getter central para la URL base
  /// 1) Si ya detectamos una URL que funciona → _workingBaseUrl
  /// 2) Si ApiConfig.baseUrl está configurada → esa
  /// 3) Si no, usa directamente la URL de Railway
  String get _baseUrl {
    if (_workingBaseUrl != null) return _workingBaseUrl!;
    final configured = ApiConfig.baseUrl;
    if (configured.isNotEmpty) return configured;
    return _railwayBaseUrl;
  }

  // Inicialización automática de la conexión
  void _initializeConnection() {
    Future.delayed(const Duration(milliseconds: 500), () {
      checkConnection().catchError((e) {
        Logger.warning(
          'Initial connection check failed',
          tag: 'HttpService',
          error: e,
        );
        // checkConnection() devuelve Future<bool>: el handler DEBE devolver bool.
        // Sin este return, un fallo de conexión lanzaba un TypeError.
        return false;
      });
    });
  }

  // 🔐 Token de autenticación (se puede guardar en SharedPreferences)
  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void clearAuthToken() {
    _authToken = null;
  }

  // 📋 Headers con autenticación
  Map<String, String> get _authHeaders {
    final headers = Map<String, String>.from(ApiConfig.defaultHeaders);
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    return headers;
  }

  // 🔍 GET Request (con manejo automático de 401)
  Future<http.Response> get(String endpoint) async {
    try {
      // El interceptor internamente usará ApiConfig.baseUrl.
      // Asegúrate de que ahí también tengas la URL de Railway
      return await _interceptor.request('GET', endpoint);
    } catch (e) {
      if (e is UnauthorizedException) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      }
      rethrow;
    }
  }

  // 📤 POST Request (con manejo automático de 401)
  Future<http.Response> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      return await _interceptor.request('POST', endpoint, body: body);
    } catch (e) {
      if (e is UnauthorizedException) {
        throw Exception('Token expirado. Por favor, inicia sesión nuevamente.');
      }
      rethrow;
    }
  }

  // 🔄 PUT Request
  Future<http.Response> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    final stopwatch = Stopwatch()..start();
    final baseUrl = _baseUrl;

    try {
      final url = Uri.parse(baseUrl + endpoint);
      Logger.apiRequest('PUT', endpoint, body: body, headers: _authHeaders);

      final response = await http
          .put(
            url,
            headers: _authHeaders,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(ApiConfig.connectTimeout);

      stopwatch.stop();
      Logger.apiResponse(
        'PUT',
        endpoint,
        response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return response;
    } catch (e) {
      stopwatch.stop();
      Logger.error(
        'PUT request failed',
        tag: 'HttpService',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  // 🗑️ DELETE Request
  Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse(_baseUrl + endpoint);
      final response = await http
          .delete(url, headers: _authHeaders)
          .timeout(ApiConfig.connectTimeout);

      _logRequest('DELETE', url.toString(), response.statusCode);
      return response;
    } catch (e) {
      _logError('DELETE', endpoint, e);
      rethrow;
    }
  }

  // 📸 Multipart Request (para subir archivos)
  Future<http.Response> uploadFile(
    String endpoint,
    File file, {
    Map<String, String>? fields,
    String fieldName = 'image',
  }) async {
    final stopwatch = Stopwatch()..start();
    final baseUrl = _baseUrl;

    try {
      final url = Uri.parse(baseUrl + endpoint);
      Logger.apiRequest('UPLOAD', endpoint, body: fields);
      Logger.info(
        'Uploading file: ${file.path} (${await file.length()} bytes)',
        tag: 'HttpService',
      );

      final request = http.MultipartRequest('POST', url);

      // Agregar headers de autenticación
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Agregar archivo
      request.files.add(
        await http.MultipartFile.fromPath(fieldName, file.path),
      );

      // Agregar campos adicionales
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final streamedResponse = await request.send().timeout(
        ApiConfig.receiveTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);

      stopwatch.stop();
      Logger.apiResponse(
        'UPLOAD',
        endpoint,
        response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return response;
    } catch (e) {
      stopwatch.stop();
      Logger.error(
        'File upload failed',
        tag: 'HttpService',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  // 🔄 PUT Multipart Request (para actualizar con archivos)
  Future<http.Response> putMultipart(
    String endpoint, {
    Map<String, String>? fields,
    Map<String, File>? files,
    String? token,
  }) async {
    final stopwatch = Stopwatch()..start();
    final baseUrl = _baseUrl;

    try {
      final url = Uri.parse(baseUrl + endpoint);
      Logger.apiRequest('PUT_MULTIPART', endpoint, body: fields);

      final request = http.MultipartRequest('PUT', url);

      // Agregar headers de autenticación
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      } else if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }

      // Agregar campos de texto
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Agregar archivos
      if (files != null) {
        for (final entry in files.entries) {
          final fieldName = entry.key;
          final file = entry.value;
          Logger.info(
            'Adding file: $fieldName -> ${file.path} (${await file.length()} bytes)',
            tag: 'HttpService',
          );
          request.files.add(
            await http.MultipartFile.fromPath(fieldName, file.path),
          );
        }
      }

      final streamedResponse = await request.send().timeout(
        ApiConfig.receiveTimeout,
      );
      final response = await http.Response.fromStream(streamedResponse);

      stopwatch.stop();
      Logger.apiResponse(
        'PUT_MULTIPART',
        endpoint,
        response.statusCode,
        body: response.body,
        duration: stopwatch.elapsed,
      );

      return response;
    } catch (e) {
      stopwatch.stop();
      Logger.error(
        'PUT multipart request failed',
        tag: 'HttpService',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow;
    }
  }

  // 📊 Logging (deprecated - using Logger class now)
  void _logRequest(String method, String url, int statusCode) {
    // Deprecated - using Logger.apiResponse instead
  }

  void _logError(String method, String endpoint, dynamic error) {
    // Deprecated - using Logger.error instead
  }

  // 🔍 Verificar conexión con el backend
  Future<bool> checkConnection() async {
    // Lista completa de URLs para probar
    final urlsToTest = [
      ApiConfig.baseUrl,
      ...ApiConfig.alternativeUrls,
      _railwayBaseUrl, // siempre probamos también la URL de Railway
    ];

    Logger.info('Starting connectivity check', tag: 'HttpService');

    for (String baseUrl in urlsToTest) {
      if (baseUrl.isEmpty) continue;

      try {
        Logger.debug('Testing URL: $baseUrl', tag: 'HttpService');
        final url = Uri.parse('$baseUrl/health');
        final response = await http
            .get(url, headers: _authHeaders)
            .timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          Logger.info(
            'Connection successful! URL: $baseUrl',
            tag: 'HttpService',
          );
          // Actualizar la URL base para futuras peticiones
          _workingBaseUrl = baseUrl;
          return true;
        } else {
          Logger.warning(
            'Response ${response.statusCode} from: $baseUrl',
            tag: 'HttpService',
          );
        }
      } catch (e) {
        Logger.warning('Error with $baseUrl', tag: 'HttpService', error: e);
      }
    }

    Logger.error('Could not connect to any URL', tag: 'HttpService');
    return false;
  }

  // 🧪 Método de prueba directo
  Future<Map<String, dynamic>> testDirectConnection() async {
    // Probar todas las URLs posibles
    final urlsToTest = [
      ApiConfig.baseUrl,
      ...ApiConfig.alternativeUrls,
      _railwayBaseUrl,
    ];

    for (String baseUrl in urlsToTest) {
      if (baseUrl.isEmpty) continue;

      try {
        final url = Uri.parse('$baseUrl/health');
        Logger.debug('Testing direct connection: $url', tag: 'HttpService');

        final response = await http
            .get(
              url,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )
            .timeout(const Duration(seconds: 10));

        if (response.statusCode == 200) {
          return {
            'success': true,
            'url': url.toString(),
            'statusCode': response.statusCode,
            'body': response.body,
          };
        }
      } catch (e) {
        Logger.warning(
          'Direct connection error with $baseUrl',
          tag: 'HttpService',
          error: e,
        );
      }
    }

    return {
      'success': false,
      'error': 'No se pudo conectar con ninguna URL',
      'testedUrls': urlsToTest,
    };
  }
}
