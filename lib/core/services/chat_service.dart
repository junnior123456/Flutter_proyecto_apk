import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

/// Cliente REST del chat (conversaciones y mensajes). Sondeo desde la pantalla.
class ChatService {
  final AuthService _auth = AuthService();

  Future<Map<String, String>> _headers() async {
    final token = await _auth.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Abre (o recupera) la conversación con [withUserId].
  Future<Map<String, dynamic>?> openConversation({
    required int withUserId,
    String type = 'direct',
    int? petId,
    int? veterinariaId,
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/conversations'),
      headers: await _headers(),
      body: json.encode({
        'withUserId': withUserId,
        'type': type,
        if (petId != null) 'petId': petId,
        if (veterinariaId != null) 'veterinariaId': veterinariaId,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(res.body));
    }
    return null;
  }

  Future<List<Map<String, dynamic>>> listConversations() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/chat/conversations'),
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

  /// Mensajes de una conversación. [afterId] trae solo lo nuevo (sondeo).
  Future<List<Map<String, dynamic>>> getMessages(int conversationId, {int? afterId}) async {
    final url = '${ApiConfig.baseUrl}/chat/conversations/$conversationId/messages'
        '${afterId != null ? '?after=$afterId' : ''}';
    final res = await http.get(Uri.parse(url), headers: await _headers());
    if (res.statusCode == 200) {
      final data = json.decode(res.body);
      if (data is List) {
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    }
    return [];
  }

  Future<Map<String, dynamic>?> sendMessage(int conversationId, String body) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$conversationId/messages'),
      headers: await _headers(),
      body: json.encode({'body': body}),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      return Map<String, dynamic>.from(json.decode(res.body));
    }
    return null;
  }

  Future<void> markRead(int conversationId) async {
    await http.post(
      Uri.parse('${ApiConfig.baseUrl}/chat/conversations/$conversationId/read'),
      headers: await _headers(),
    );
  }
}
