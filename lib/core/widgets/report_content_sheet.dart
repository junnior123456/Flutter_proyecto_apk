import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/auth_service.dart';

/// Reportar una publicación.
///
/// Es la vía por la que se ejecuta la Política de Derechos de Autor: sin un
/// botón que permita denunciar, el procedimiento de notificación y retiro se
/// queda en un papel bonito. También cubre el resto de contenido prohibido.
class ReportContentSheet {
  static const List<({String valor, String etiqueta, String detalle})> motivos = [
    (
      valor: 'copyright',
      etiqueta: 'Infringe derechos de autor',
      detalle: 'La foto, el audio o el documento son míos y los usa sin permiso',
    ),
    (
      valor: 'inappropriate_content',
      etiqueta: 'Contenido inapropiado',
      detalle: 'Violencia, maltrato animal o material ofensivo',
    ),
    (
      valor: 'fake_listing',
      etiqueta: 'Publicación falsa',
      detalle: 'La mascota no existe o los datos son inventados',
    ),
    (
      valor: 'scam',
      etiqueta: 'Estafa o venta encubierta',
      detalle: 'Piden dinero por entregar el animal',
    ),
    (valor: 'spam', etiqueta: 'Spam', detalle: 'Publicidad o repetición'),
    (valor: 'other', etiqueta: 'Otro motivo', detalle: ''),
  ];

  static Future<void> mostrar(
    BuildContext context, {
    required int petId,
    required String petName,
  }) async {
    String? seleccionado;
    final descripcion = TextEditingController();

    final enviar = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (ctx, actualizar) => SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reportar "$petName"',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Revisamos todos los reportes. Si el contenido infringe derechos '
                    'de autor, lo retiramos.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  // Selección con ListTile en vez de RadioListTile: el Radio de
                  // Flutter quedó deprecado a favor de RadioGroup (3.32+), y no
                  // merece la pena arrastrar la deprecación por una lista de seis.
                  ...motivos.map(
                    (m) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      leading: Icon(
                        seleccionado == m.valor
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: seleccionado == m.valor ? Colors.red : Colors.grey,
                      ),
                      onTap: () => actualizar(() => seleccionado = m.valor),
                      title: Text(m.etiqueta, style: const TextStyle(fontSize: 14)),
                      subtitle: m.detalle.isEmpty
                          ? null
                          : Text(m.detalle, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: descripcion,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Cuéntanos más (opcional)',
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        onPressed: seleccionado == null
                            ? null
                            : () => Navigator.pop(ctx, true),
                        child: const Text(
                          'Enviar reporte',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (enviar != true || seleccionado == null) return;
    if (!context.mounted) return;

    final mensajero = ScaffoldMessenger.of(context);
    final token = await AuthService().getToken();
    if (token == null || token.isEmpty) {
      mensajero.showSnackBar(
        const SnackBar(content: Text('Inicia sesión para poder reportar')),
      );
      return;
    }

    final etiqueta =
        motivos.firstWhere((m) => m.valor == seleccionado).etiqueta;

    try {
      final respuesta = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/reports'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'type': seleccionado,
              'reportableType': 'pet',
              'reportableId': petId,
              'reason': etiqueta,
              if (descripcion.text.trim().isNotEmpty)
                'description': descripcion.text.trim(),
            }),
          )
          .timeout(const Duration(seconds: 15));

      final ok = respuesta.statusCode == 200 || respuesta.statusCode == 201;
      mensajero.showSnackBar(
        SnackBar(
          content: Text(
            ok
                ? 'Reporte enviado. Gracias por avisar.'
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
