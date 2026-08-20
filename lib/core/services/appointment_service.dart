import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

/// Cliente REST de citas/reservas con veterinarios.
class AppointmentService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>?> book({
    required int veterinariaId,
    required DateTime scheduledAt,
    required String reason,
    int? petId,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/appointments'),
      headers: await _headers(),
      body: json.encode({
        'veterinariaId': veterinariaId,
        'scheduledAt': scheduledAt.toUtc().toIso8601String(),
        'reason': reason,
        if (petId != null) 'petId': petId,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(res.body));
    }
    return null;
  }

  /// Reserva y devuelve NULL si fue bien, o el mensaje de error del servidor.
  ///
  /// book() se queda con un null pelado cuando falla, y aquí el motivo importa:
  /// el backend responde "Ese horario ya no está disponible" cuando alguien se
  /// adelantó, y el usuario tiene que poder leerlo.
  Future<String?> reservar({
    required int veterinariaId,
    required DateTime cuando,
    required String motivo,
    int? petId,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/appointments'),
        headers: await _headers(),
        body: json.encode({
          'veterinariaId': veterinariaId,
          'scheduledAt': cuando.toUtc().toIso8601String(),
          'reason': motivo,
          if (petId != null) 'petId': petId,
        }),
      );
      if (res.statusCode == 200 || res.statusCode == 201) return null;

      final cuerpo = json.decode(res.body);
      final mensaje = cuerpo is Map ? cuerpo['message'] : null;
      if (mensaje is List && mensaje.isNotEmpty) return mensaje.first.toString();
      return mensaje?.toString() ?? 'No se pudo reservar (${res.statusCode})';
    } catch (_) {
      return 'No se pudo reservar. Revisa tu conexión.';
    }
  }

  Future<List<Map<String, dynamic>>> mine() => _list('/appointments/mine');
  Future<List<Map<String, dynamic>>> forVet() => _list('/appointments/vet');

  Future<List<Map<String, dynamic>>> _list(String path) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}$path'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    return [];
  }

  Future<bool> updateStatus(int id, String status, {String? vetNote}) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/appointments/$id/status'),
      headers: await _headers(),
      body: json.encode({'status': status, if (vetNote != null) 'vetNote': vetNote}),
    );
    return res.statusCode == 200 || res.statusCode == 201;
  }
}
