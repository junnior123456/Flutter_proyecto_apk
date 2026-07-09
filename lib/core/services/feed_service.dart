/// Servicio HTTP del feed social (P4): publicaciones con like/comentar.
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_manager.dart';

class FeedService {
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> _headers() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Página del muro. Devuelve (posts, hayMás).
  Future<(List<Map<String, dynamic>>, bool)> getFeed({int page = 1, int limit = 10}) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pets/feed?page=$page&limit=$limit'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      final data = body['data'] ?? {};
      final list = (data['data'] as List? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
      final total = data['total'] as int? ?? list.length;
      final hasMore = page * limit < total;
      return (list, hasMore);
    }
    throw Exception('No se pudo cargar el feed (${res.statusCode})');
  }

  /// Da o quita el "me gusta". Devuelve (isLiked, likesCount).
  Future<(bool, int)> toggleLike(int petId) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/favorite'),
      headers: await _headers(),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body)['data'] ?? {};
      return (data['isFavorite'] == true, data['likesCount'] as int? ?? 0);
    }
    throw Exception('No se pudo actualizar el me gusta (${res.statusCode})');
  }

  Future<List<Map<String, dynamic>>> getComments(int petId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/comments/pet/$petId'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      // El endpoint puede devolver {data:[...]} o una lista directa.
      final list = body is Map ? (body['data'] ?? []) : body;
      return (list as List).map((e) => Map<String, dynamic>.from(e)).toList();
    }
    throw Exception('No se pudieron cargar los comentarios (${res.statusCode})');
  }

  Future<Map<String, dynamic>> addComment(int petId, String content) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/comments'),
      headers: await _headers(),
      body: jsonEncode({'petId': petId, 'content': content}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final body = jsonDecode(res.body);
      return Map<String, dynamic>.from(body['data'] ?? body);
    }
    throw Exception('No se pudo publicar el comentario (${res.statusCode})');
  }
}
