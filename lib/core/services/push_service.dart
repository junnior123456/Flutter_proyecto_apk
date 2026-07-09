/// Registro del dispositivo en FCM para recibir notificaciones push
/// (recordatorios de vacunas, adopciones, comentarios).
///
/// Sin esto `users.notification_token` queda vacío y el backend no tiene
/// a dónde enviar: la notificación sólo se ve al abrir la app.
library;

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_manager.dart';

class PushService {
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;
  PushService._internal();

  final TokenManager _tokenManager = TokenManager();
  bool _listening = false;

  Future<Map<String, String>> _headers() async {
    final token = await _tokenManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Pide permiso, obtiene el token de FCM y lo registra en el backend.
  /// Llamar sólo con sesión iniciada: el endpoint exige JWT.
  Future<void> syncToken() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Android 13+ e iOS exigen permiso explícito.
      final settings = await messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        print('🔕 El usuario denegó las notificaciones');
        return;
      }

      final fcmToken = await messaging.getToken();
      if (fcmToken == null) {
        print('⚠️ FCM no devolvió token');
        return;
      }
      await _register(fcmToken);

      // El token puede rotar; hay que re-registrarlo cuando pase.
      if (!_listening) {
        _listening = true;
        messaging.onTokenRefresh.listen(_register);
      }
    } catch (e) {
      // Que no llegue el push nunca debe impedir usar la app.
      print('⚠️ No se pudo registrar el token de push: $e');
    }
  }

  Future<void> _register(String fcmToken) async {
    try {
      final res = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/notifications/push-token'),
        headers: await _headers(),
        body: jsonEncode({'token': fcmToken}),
      );
      if (res.statusCode == 200 || res.statusCode == 201) {
        print('✅ Token de push registrado');
      } else {
        print('⚠️ El backend rechazó el token de push (${res.statusCode})');
      }
    } catch (e) {
      print('⚠️ Error registrando el token de push: $e');
    }
  }

  /// Al cerrar sesión. Debe llamarse ANTES de borrar el JWT.
  Future<void> unregister() async {
    try {
      await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/notifications/push-token'),
        headers: await _headers(),
      );
      await FirebaseMessaging.instance.deleteToken();
      print('✅ Token de push dado de baja');
    } catch (e) {
      print('⚠️ Error dando de baja el token de push: $e');
    }
  }
}
