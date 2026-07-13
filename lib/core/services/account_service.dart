import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

/// Borrado de la propia cuenta.
///
/// Google Play lo exige a toda app con registro, y la Ley 29733 lo llama
/// derecho de cancelación. El backend borra en una sola transacción al usuario,
/// sus mascotas, su expediente clínico, comentarios, "me gusta", solicitudes y
/// notificaciones.
class AccountService {
  final AuthService _authService = AuthService();

  /// Devuelve null si todo fue bien, o el mensaje de error si falló.
  Future<String?> deleteMyAccount() async {
    try {
      final token = await _authService.getToken();
      if (token == null || token.isEmpty) {
        return 'Tu sesión expiró. Vuelve a entrar e inténtalo de nuevo.';
      }

      final respuesta = await http
          .delete(
            Uri.parse('${ApiConfig.baseUrl}/users/me'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 20));

      if (respuesta.statusCode == 200 || respuesta.statusCode == 204) {
        // La cuenta ya no existe: la sesión local tiene que irse con ella.
        await _authService.logout();
        return null;
      }

      String detalle = 'Error ${respuesta.statusCode}';
      try {
        final cuerpo = jsonDecode(respuesta.body);
        if (cuerpo is Map && cuerpo['message'] != null) {
          detalle = cuerpo['message'].toString();
        }
      } catch (_) {}
      return 'No se pudo eliminar la cuenta: $detalle';
    } catch (e) {
      return 'No se pudo eliminar la cuenta. Revisa tu conexión.';
    }
  }
}
