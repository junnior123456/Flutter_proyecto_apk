/// Servicio HTTP para la historia clínica del expediente (Módulo 3).
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_manager.dart';

/// Tipos aceptados por el backend (`MEDICAL_RECORD_TYPES`).
const List<String> kMedicalRecordTypes = [
  'consulta',
  'cirugia',
  'examen',
  'desparasitacion',
  'otro',
];

class MedicalRecordService {
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> _headers() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<Map<String, dynamic>>> list(int petId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/medical-records'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('No se pudo cargar la historia clínica (${res.statusCode})');
  }

  Future<void> add(int petId, Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/medical-records'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('No se pudo guardar (${res.statusCode})');
    }
  }

  Future<void> remove(int petId, int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/medical-records/$id'),
      headers: await _headers(),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('No se pudo eliminar (${res.statusCode})');
    }
  }
}
