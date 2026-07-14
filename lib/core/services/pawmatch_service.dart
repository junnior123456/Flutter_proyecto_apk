import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

/// Cliente del modelo PawMatch (árbol de decisión adoptante ↔ perro).
/// Llama a POST /api/ai/pawmatch y devuelve el bloque `data` del backend.
class PawmatchService {
  final AuthService _authService = AuthService();

  Future<Map<String, dynamic>?> predecir(Map<String, dynamic> features) async {
    final token = await _authService.getToken();
    if (token == null) return null;

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ai/pawmatch'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(features),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final body = json.decode(response.body);
      // El backend responde { ok, data: {...} }.
      final data = body is Map ? body['data'] : null;
      return data is Map ? Map<String, dynamic>.from(data) : null;
    }
    return null;
  }
}
