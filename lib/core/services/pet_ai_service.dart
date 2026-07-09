/// Servicio HTTP del chat contextual del expediente (Módulo 3 — IA contextual).
/// El backend sólo entrega datos médicos al modelo si `aiConsent` está activo.
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_manager.dart';

/// Respuesta de PawBot sobre una mascota concreta.
class PetChatReply {
  final String response;
  final bool usedRecord; // true = la IA leyó el expediente
  final bool consentRequired; // true = falta activar el consentimiento

  PetChatReply({
    required this.response,
    required this.usedRecord,
    required this.consentRequired,
  });
}

class PetAiService {
  final TokenManager _tokenManager = TokenManager();

  Future<Map<String, String>> _headers() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Estado del consentimiento de IA de una mascota.
  Future<bool> getConsent(int petId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/ai-consent'),
      headers: await _headers(),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['aiConsent'] == true;
    }
    throw Exception('No se pudo leer el consentimiento (${res.statusCode})');
  }

  /// Otorga o revoca el permiso de la IA para leer el expediente.
  Future<bool> setConsent(int petId, bool enabled) async {
    final res = await http.patch(
      Uri.parse('${ApiConfig.baseUrl}/pets/$petId/ai-consent'),
      headers: await _headers(),
      body: jsonEncode({'enabled': enabled}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return data['aiConsent'] == true;
    }
    throw Exception('No se pudo cambiar el consentimiento (${res.statusCode})');
  }

  /// Pregunta a PawBot sobre una mascota. Si no hay consentimiento, la respuesta
  /// llega igual pero genérica, con `consentRequired = true`.
  /// [history] son los turnos previos, para que recuerde la conversación.
  Future<PetChatReply> petChat(
    int petId,
    String message, {
    List<Map<String, String>> history = const [],
  }) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.baseUrl}/ai/pet-chat'),
      headers: await _headers(),
      body: jsonEncode({
        'petId': petId,
        'message': message,
        if (history.isNotEmpty) 'history': history,
      }),
    );
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return PetChatReply(
        response: data['response'] as String? ?? '',
        usedRecord: data['usedRecord'] == true,
        consentRequired: data['consentRequired'] == true,
      );
    }
    if (res.statusCode == 403) {
      throw Exception('No tienes permiso sobre esta mascota');
    }
    throw Exception('PawBot no pudo responder (${res.statusCode})');
  }
}
