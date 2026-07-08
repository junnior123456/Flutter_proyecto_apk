/// Servicio de IA para PawFinder
/// Conecta con el backend que usa Google Gemini
/// Funcionalidades: recomendación de perros, cuidado, veterinarias en Tarapoto
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/token_manager.dart';

class AiService {
  final TokenManager _tokenManager = TokenManager();

  /// Obtiene los headers con autenticación JWT
  Future<Map<String, String>> _getHeaders() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Verifica si el servicio de IA está disponible
  Future<Map<String, dynamic>> getStatus() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/ai/status'),
      headers: headers,
    );
    return jsonDecode(response.body);
  }

  /// Recomienda qué tipo de perro adoptar según el perfil del usuario
  /// [profile] contiene datos como vivienda, niños, actividad, etc.
  Future<String> recommendDog(Map<String, dynamic> profile) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ai/recommend-dog'),
      headers: headers,
      body: jsonEncode(profile),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['response'] ?? 'No se pudo obtener recomendación';
    }
    throw Exception('Error al obtener recomendación: ${response.statusCode}');
  }

  /// Seguimiento del cuidado del perro adoptado
  /// [message] pregunta del dueño sobre el cuidado
  /// [dogInfo] información opcional del perro (nombre, raza, edad, peso)
  Future<String> trackDogCare(String message, {Map<String, dynamic>? dogInfo}) async {
    final headers = await _getHeaders();
    final body = {
      'message': message,
      'chatType': 'care_tracking',
      if (dogInfo != null) ...dogInfo,
    };

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ai/care-tracking'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['response'] ?? 'No se pudo obtener respuesta';
    }
    throw Exception('Error en seguimiento: ${response.statusCode}');
  }

  /// Refiere a veterinarias en Tarapoto según la preocupación del dueño
  /// [concern] descripción del problema o síntoma del perro
  Future<String> referToVet(String concern) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ai/vet-referral'),
      headers: headers,
      body: jsonEncode({'concern': concern}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['response'] ?? 'No se pudo obtener información';
    }
    throw Exception('Error en referencia veterinaria: ${response.statusCode}');
  }

  /// Chat general sobre perros
  /// [message] cualquier pregunta sobre perros
  Future<String> generalChat(String message) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ai/chat'),
      headers: headers,
      body: jsonEncode({'message': message, 'chatType': 'general'}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['response'] ?? 'No se pudo obtener respuesta';
    }
    throw Exception('Error en chat: ${response.statusCode}');
  }
}
