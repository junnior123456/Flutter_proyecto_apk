import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_manager.dart';

/// Solicitudes de clientes para convertirse en veterinarios.
/// Endpoints backend en /api/vet-requests (ver VetRequestsController).
class VetRequestService {
  static const String baseUrl = 'http://167.99.4.161/api';
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> _headers() async {
    final token = await _tokenManager.getToken();
    final clean = (token ?? '').replaceFirst('Bearer ', '').trim();
    return {
      'Content-Type': 'application/json',
      if (clean.isNotEmpty) 'Authorization': 'Bearer $clean',
    };
  }

  /// El cliente envía su solicitud. Devuelve true si se creó (201).
  Future<bool> create(Map<String, dynamic> body) async {
    final res = await http.post(
      Uri.parse('$baseUrl/vet-requests'),
      headers: await _headers(),
      body: json.encode(body),
    );
    if (res.statusCode == 201 || res.statusCode == 200) return true;
    // 409 = ya es VET o ya tiene una solicitud pendiente
    String msg = 'No se pudo enviar la solicitud';
    try {
      final d = json.decode(res.body);
      if (d is Map && d['message'] != null) msg = d['message'].toString();
    } catch (_) {}
    throw Exception(msg);
  }

  /// Última solicitud del cliente (o null si no tiene). Trae {status, ...}.
  Future<Map<String, dynamic>?> mine() async {
    final res = await http.get(
      Uri.parse('$baseUrl/vet-requests/mine'),
      headers: await _headers(),
    );
    if (res.statusCode == 200 && res.body.isNotEmpty && res.body != 'null') {
      final d = json.decode(res.body);
      if (d is Map<String, dynamic>) return d;
    }
    return null;
  }

  /// (Admin) Lista solicitudes por estado.
  Future<List<dynamic>> list({String status = 'pending'}) async {
    final res = await http.get(
      Uri.parse('$baseUrl/vet-requests?status=$status'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final d = json.decode(res.body);
      return d is List ? d : [];
    }
    return [];
  }

  /// (Admin) Aprobar → la cuenta pasa a VET.
  Future<bool> approve(int id) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/vet-requests/$id/approve'),
      headers: await _headers(),
    );
    return res.statusCode == 200;
  }

  /// (Admin) Rechazar con nota opcional.
  Future<bool> reject(int id, {String? note}) async {
    final res = await http.patch(
      Uri.parse('$baseUrl/vet-requests/$id/reject'),
      headers: await _headers(),
      body: json.encode({'note': note ?? ''}),
    );
    return res.statusCode == 200;
  }
}
