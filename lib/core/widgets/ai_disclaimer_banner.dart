import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/auth_service.dart';

/// Aviso de IA que se muestra en las pantallas del asistente.
///
/// Dos obligaciones distintas en un mismo sitio:
///  - **Transparencia y salud:** el usuario tiene que saber que habla con una
///    máquina y que sus respuestas no son consejo veterinario.
///  - **Google Play (política de IA generativa):** la app debe permitir
///    reportar contenido generado por IA que sea ofensivo o peligroso.
class AiDisclaimerBanner extends StatelessWidget {
  /// Última respuesta del asistente, para adjuntarla al reporte.
  final String? ultimaRespuesta;

  const AiDisclaimerBanner({super.key, this.ultimaRespuesta});

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      color: oscuro ? const Color(0xFF2D2410) : const Color(0xFFFFF8E6),
      child: Row(
        children: [
          const Icon(Icons.smart_toy_outlined, size: 16, color: Color(0xFFB26A00)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Respuestas generadas por IA: pueden equivocarse. No sustituyen a un veterinario.',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.3,
                color: oscuro ? const Color(0xFFE8D9B0) : const Color(0xFF6B4E00),
              ),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () => _reportar(context),
            child: const Text('Reportar', style: TextStyle(fontSize: 11.5)),
          ),
        ],
      ),
    );
  }

  Future<void> _reportar(BuildContext context) async {
    final motivo = TextEditingController();

    final enviar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reportar respuesta de la IA'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '¿Qué tuvo de malo la respuesta? (ofensiva, peligrosa, falsa...)',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: motivo,
              autofocus: true,
              maxLines: 3,
              maxLength: 500,
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    if (enviar != true) return;
    if (motivo.text.trim().isEmpty) return;
    // El diálogo fue un await: la pantalla pudo desaparecer mientras tanto.
    if (!context.mounted) return;

    final mensajero = ScaffoldMessenger.of(context);
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      mensajero.showSnackBar(
        const SnackBar(content: Text('Inicia sesión para poder reportar')),
      );
      return;
    }

    try {
      final respuesta = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/reports'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'type': 'inappropriate_content',
              'reportableType': 'ai_response',
              // La respuesta de la IA no es una fila de la base de datos: no
              // tiene id. Se manda 0 y el texto viaja en la descripción.
              'reportableId': 0,
              'reason': motivo.text.trim(),
              'description': (ultimaRespuesta ?? '').isEmpty
                  ? 'Sin respuesta capturada'
                  : ultimaRespuesta!.substring(
                      0,
                      ultimaRespuesta!.length > 900 ? 900 : ultimaRespuesta!.length,
                    ),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final ok = respuesta.statusCode == 200 || respuesta.statusCode == 201;
      mensajero.showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Gracias. Revisaremos esta respuesta.'
                : 'No se pudo enviar el reporte (${respuesta.statusCode})',
          ),
          backgroundColor: ok ? Colors.green : Colors.red,
        ),
      );
    } catch (_) {
      mensajero.showSnackBar(
        const SnackBar(
          content: Text('No se pudo enviar el reporte. Revisa tu conexión.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
