/// Servicio HTTP para perfil extendido + QR del expediente (Módulo 3).
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_manager.dart';

class ProfileQrService {
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> _headers() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Devuelve los datos actuales de la mascota (incluye species/birthDate/microchip).
  Future<Map<String, dynamic>> getPet(int petId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    }
    throw Exception('No se pudo cargar la mascota (${res.statusCode})');
  }

  /// Garantiza y devuelve el identificador público (para el QR).
  Future<String> getPublicUid(int petId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/qr'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      return jsonDecode(res.body)['publicUid'] as String;
    }
    throw Exception('No se pudo generar el QR (${res.statusCode})');
  }

  /// Actualiza especie / fecha de nacimiento / microchip.
  Future<void> updateProfile(int petId, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/profile'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('No se pudo guardar (${res.statusCode})');
    }
  }

  /// URL pública de la ficha (lo que codifica el QR).
  String publicUrl(String publicUid) => '${ApiConfig.baseUrl}/p/$publicUid';
}
