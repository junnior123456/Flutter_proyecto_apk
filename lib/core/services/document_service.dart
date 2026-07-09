/// Servicio HTTP para documentos y galería del expediente (Módulo 3).
///
/// Los archivos son PRIVADOS: no viven en /uploads (que nginx sirve al público),
/// sino detrás de `GET /pets/:petId/documents/:id/file`, que exige el JWT.
/// Por eso las imágenes se pintan pasando `authHeaders()` a la petición.
library;

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../config/api_config.dart';
import 'token_manager.dart';

/// Categorías aceptadas por el backend (`DOCUMENT_CATEGORIES`).
const List<String> kDocumentCategories = [
  'radiografia',
  'analisis',
  'receta',
  'foto',
  'otro',
];

/// Extensiones aceptadas (el backend además verifica los magic bytes).
const List<String> kDocumentExtensions = ['jpg', 'jpeg', 'png', 'webp', 'pdf'];

const int kMaxDocumentBytes = 10 * 1024 * 1024;

class DocumentService {
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> authHeaders() async {
    final token = await _tokenManager.getToken();
    return {'Authorization': 'Bearer $token'};
  }

  String fileUrl(int petId, int id) =>
      '${ApiConfig.baseUrl}/pets/$petId/documents/$id/file';

  Future<List<Map<String, dynamic>>> list(int petId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/documents'),
      headers: await authHeaders(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('No se pudieron cargar los documentos (${res.statusCode})');
  }

  /// Sube un archivo. `path` debe apuntar a una imagen o PDF de menos de 10 MB.
  Future<void> upload(
    int petId, {
    required String path,
    required String title,
    required String category,
  }) async {
    final req = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/documents'),
    );
    req.headers.addAll(await authHeaders());
    req.fields['title'] = title;
    req.fields['category'] = category;
    req.files.add(await http.MultipartFile.fromPath('file', path));

    final res = await http.Response.fromStream(await req.send());
    if (res.statusCode == 200 || res.statusCode == 201) return;
    if (res.statusCode == 415) {
      throw Exception('Formato no permitido. Solo JPG, PNG, WEBP o PDF.');
    }
    if (res.statusCode == 413) {
      throw Exception('El archivo supera los 10 MB.');
    }
    throw Exception('No se pudo subir (${res.statusCode})');
  }

  Future<void> remove(int petId, int id) async {
    final res = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/documents/$id'),
      headers: await authHeaders(),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('No se pudo eliminar (${res.statusCode})');
    }
  }

  /// Descarga el documento a un archivo temporal y devuelve su ruta local.
  /// Necesario para los PDF: el visor del sistema no puede mandar el JWT.
  Future<String> downloadToTemp(int petId, Map<String, dynamic> doc) async {
    final res = await http.get(
      Uri.parse(fileUrl(petId, doc['id'] as int)),
      headers: await authHeaders(),
    );
    if (res.statusCode != 200) {
      throw Exception('No se pudo descargar (${res.statusCode})');
    }
    final dir = await getTemporaryDirectory();
    final ext = (doc['mimeType']?.toString() ?? '') == 'application/pdf' ? 'pdf' : 'img';
    final file = File('${dir.path}/pawfinder_doc_${doc['id']}.$ext');
    await file.writeAsBytes(res.bodyBytes);
    return file.path;
  }
}
