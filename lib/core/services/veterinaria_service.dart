/// Servicio HTTP del directorio de veterinarias (P3).
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_manager.dart';

/// Valida un RUC peruano (mismo algoritmo que el backend: 11 dígitos,
/// prefijo válido y dígito verificador módulo 11). Evita un viaje al servidor.
bool isValidRuc(String value) {
  final ruc = value.trim();
  if (!RegExp(r'^\d{11}$').hasMatch(ruc)) return false;
  if (!['10', '15', '16', '17', '20'].contains(ruc.substring(0, 2))) return false;
  const weights = [5, 4, 3, 2, 7, 6, 5, 4, 3, 2];
  var sum = 0;
  for (var i = 0; i < 10; i++) {
    sum += int.parse(ruc[i]) * weights[i];
  }
  var check = 11 - (sum % 11);
  if (check == 10) check = 0;
  if (check == 11) check = 1;
  return check == int.parse(ruc[10]);
}

class VeterinariaService {
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _tokenManager.getToken();
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  String get _base => '${ApiConfig.baseUrl}/veterinarias';

  Future<List<Map<String, dynamic>>> _getList(String url, {bool auth = false}) async {
    final res = await http.get(Uri.parse(url), headers: await _headers(auth: auth));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('No se pudo cargar (${res.statusCode})');
  }

  /// Directorio público (verificadas y activas).
  Future<List<Map<String, dynamic>>> listPublic() => _getList(_base);

  /// Fichas del veterinario logueado.
  Future<List<Map<String, dynamic>>> listMine() => _getList('$_base/mine', auth: true);

  /// Todas, para el panel de administración.
  Future<List<Map<String, dynamic>>> listAll() => _getList('$_base/admin/all', auth: true);

  Future<Map<String, dynamic>> create(Map<String, dynamic> data) async {
    final res = await http.post(
      Uri.parse(_base),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    }
    throw Exception(_errorMsg(res));
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> data) async {
    final res = await http.patch(
      Uri.parse('$_base/$id'),
      headers: await _headers(),
      body: jsonEncode(data),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Map<String, dynamic>.from(jsonDecode(res.body));
    }
    throw Exception(_errorMsg(res));
  }

  Future<void> remove(int id) async {
    final res = await http.delete(Uri.parse('$_base/$id'), headers: await _headers());
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('No se pudo eliminar (${res.statusCode})');
    }
  }

  /// Extrae el mensaje de error del backend (class-validator devuelve una lista).
  String _errorMsg(http.Response res) {
    try {
      final body = jsonDecode(res.body);
      final m = body['message'];
      if (m is List) return m.join('\n');
      if (m is String) return m;
    } catch (_) {}
    return 'Error ${res.statusCode}';
  }
}
