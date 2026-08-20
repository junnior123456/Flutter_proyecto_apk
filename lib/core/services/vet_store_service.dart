/// La veterinaria como tienda/clínica: su catálogo, su horario y su agenda.
library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_manager.dart';

class VetStoreService {
  final TokenManager _tokenManager = TokenManager();

  String _base(int veterinariaId) =>
      '${ApiConfig.baseUrl}/veterinarias/$veterinariaId';

  Future<Map<String, String>> _headers({bool auth = true}) async {
    final h = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await _tokenManager.getToken();
      h['Authorization'] = 'Bearer $token';
    }
    return h;
  }

  // ---------------- Catálogo ----------------

  /// Catálogo público de la clínica (solo lo que está activo).
  Future<List<Map<String, dynamic>>> getProductos(int veterinariaId) async {
    final res = await http.get(
      Uri.parse('${_base(veterinariaId)}/products'),
      headers: await _headers(auth: false),
    );
    if (res.statusCode != 200) {
      throw Exception('No se pudo cargar el catálogo (${res.statusCode})');
    }
    return (jsonDecode(res.body) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Catálogo del dueño: incluye lo desactivado, para poder reactivarlo.
  Future<List<Map<String, dynamic>>> getProductosDelDueno(
      int veterinariaId) async {
    final res = await http.get(
      Uri.parse('${_base(veterinariaId)}/products/manage'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('No se pudo cargar tu catálogo (${res.statusCode})');
    }
    return (jsonDecode(res.body) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> crearProducto(
      int veterinariaId, Map<String, dynamic> datos) async {
    final res = await http.post(
      Uri.parse('${_base(veterinariaId)}/products'),
      headers: await _headers(),
      body: jsonEncode(datos),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('No se pudo guardar el producto (${res.statusCode})');
    }
  }

  Future<void> editarProducto(
      int veterinariaId, int productoId, Map<String, dynamic> datos) async {
    final res = await http.patch(
      Uri.parse('${_base(veterinariaId)}/products/$productoId'),
      headers: await _headers(),
      body: jsonEncode(datos),
    );
    if (res.statusCode != 200) {
      throw Exception('No se pudo actualizar el producto (${res.statusCode})');
    }
  }

  Future<void> borrarProducto(int veterinariaId, int productoId) async {
    final res = await http.delete(
      Uri.parse('${_base(veterinariaId)}/products/$productoId'),
      headers: await _headers(),
    );
    if (res.statusCode != 200) {
      throw Exception('No se pudo borrar el producto (${res.statusCode})');
    }
  }

  /// Sube una foto del producto y devuelve su URL pública.
  Future<String?> subirFoto(File foto) => _subir(foto, 'image', 'image');

  /// Sube un vídeo corto de publicidad y devuelve su URL pública.
  Future<String?> subirVideo(File video) => _subir(video, 'video', 'video');

  /// Los dos endpoints de subida son gemelos: solo cambia el campo y la ruta.
  Future<String?> _subir(File archivo, String campo, String ruta) async {
    try {
      final token = await _tokenManager.getToken();
      final peticion = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}/upload/$ruta'),
      );
      peticion.headers['Authorization'] = 'Bearer $token';
      peticion.files
          .add(await http.MultipartFile.fromPath(campo, archivo.path));

      final res = await http.Response.fromStream(await peticion.send());
      if (res.statusCode != 200 && res.statusCode != 201) return null;
      final cuerpo = jsonDecode(res.body);
      return (cuerpo['imageUrl'] ?? cuerpo['videoUrl'])?.toString();
    } catch (_) {
      return null;
    }
  }

  // ---------------- Horario ----------------

  Future<List<Map<String, dynamic>>> getHorario(int veterinariaId) async {
    final res = await http.get(
      Uri.parse('${_base(veterinariaId)}/hours'),
      headers: await _headers(auth: false),
    );
    if (res.statusCode != 200) return [];
    return (jsonDecode(res.body) as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  Future<void> guardarHorario(
      int veterinariaId, List<Map<String, dynamic>> tramos) async {
    final res = await http.put(
      Uri.parse('${_base(veterinariaId)}/hours'),
      headers: await _headers(),
      body: jsonEncode({'tramos': tramos}),
    );
    if (res.statusCode != 200) {
      throw Exception('No se pudo guardar el horario (${res.statusCode})');
    }
  }

  // ---------------- Huecos libres ----------------

  /// Turnos libres de un día. Devuelve (horas, cerrado).
  /// Las horas vienen en UTC; se convierten a la hora del teléfono al pintarlas.
  Future<(List<DateTime>, bool)> getHuecosLibres(
      int veterinariaId, DateTime dia) async {
    final fecha = '${dia.year.toString().padLeft(4, '0')}-'
        '${dia.month.toString().padLeft(2, '0')}-'
        '${dia.day.toString().padLeft(2, '0')}';
    final res = await http.get(
      Uri.parse('${_base(veterinariaId)}/availability?date=$fecha'),
      headers: await _headers(auth: false),
    );
    if (res.statusCode != 200) {
      throw Exception('No se pudo cargar la agenda (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    final libres = (data['libres'] as List? ?? [])
        .map((e) => DateTime.parse(e.toString()).toLocal())
        .toList();
    return (libres, data['cerrado'] == true);
  }

  /// Trae al día la agenda desde el sistema propio del veterinario (iCal).
  Future<Map<String, dynamic>> sincronizarAgenda(int veterinariaId) async {
    final res = await http.post(
      Uri.parse('${_base(veterinariaId)}/agenda/sync'),
      headers: await _headers(),
    );
    final cuerpo = jsonDecode(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception(cuerpo['message']?.toString() ??
          'No se pudo sincronizar (${res.statusCode})');
    }
    return Map<String, dynamic>.from(cuerpo);
  }
}
