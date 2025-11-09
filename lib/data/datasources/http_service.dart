import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class HttpService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/api'; // Para emulador Android
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  String? _authToken;
  
  void setAuthToken(String token) {
    _authToken = token;
  }
  
  void clearAuthToken() {
    _authToken = null;
  }
  
  Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    
    if (_authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }
    
    return headers;
  }
  
  Future<Map<String, dynamic>> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final uriWithParams = queryParams != null 
          ? uri.replace(queryParameters: queryParams)
          : uri;
      
      final response = await http.get(
        uriWithParams,
        headers: _headers,
      ).timeout(timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      ).timeout(timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      ).timeout(timeoutDuration);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, 
    Map<String, String> fields, 
    List<http.MultipartFile> files
  ) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$endpoint'));
      
      // Add headers
      if (_authToken != null) {
        request.headers['Authorization'] = 'Bearer $_authToken';
      }
      
      // Add fields
      request.fields.addAll(fields);
      
      // Add files
      request.files.addAll(files);
      
      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }
  
  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data;
    
    try {
      data = json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      throw HttpException('Invalid JSON response: ${response.body}');
    }
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      final errorMessage = data['message'] ?? data['error'] ?? 'Unknown error occurred';
      throw HttpException('HTTP ${response.statusCode}: $errorMessage');
    }
  }
  
  Exception _handleError(dynamic error) {
    if (error is SocketException) {
      return const HttpException('No internet connection');
    } else if (error is HttpException) {
      return error;
    } else if (error.toString().contains('TimeoutException')) {
      return const HttpException('Request timeout');
    } else {
      return HttpException('Unexpected error: ${error.toString()}');
    }
  }
}

class HttpException implements Exception {
  final String message;
  
  const HttpException(this.message);
  
  @override
  String toString() => 'HttpException: $message';
}