import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/legal_links.dart';
import '../../../../core/services/account_service.dart';

/// Centro legal y de privacidad.
///
/// Reúne lo que la ley (y Google Play) exigen que el usuario pueda encontrar:
/// qué hacemos con sus datos, qué puede publicar, qué hace la IA con lo que le
/// cuenta, y cómo borrar su cuenta.
class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  bool _borrando = false;

  Future<void> _abrir(String url) async {
    final uri = Uri.parse(url);
    final abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!abierto && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el documento')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Legal y privacidad'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _seccion('Documentos'),
          _documento(
            icono: Icons.privacy_tip_outlined,
            titulo: 'Política de Privacidad',
            subtitulo: 'Qué datos recogemos y con quién se comparten',
            url: LegalLinks.privacidad,
          ),
          _documento(
            icono: Icons.gavel_outlined,
            titulo: 'Términos y Condiciones',
            subtitulo: 'Las reglas de uso y tu responsabilidad al publicar',
            url: LegalLinks.terminos,
          ),
          _documento(
            icono: Icons.copyright_outlined,
            titulo: 'Derechos de autor y retiro',
            subtitulo: 'Cómo denunciar contenido que infringe tus derechos',
            url: LegalLinks.copyright,
          ),
          _documento(
            icono: Icons.smart_toy_outlined,
            titulo: 'Aviso de Inteligencia Artificial',
            subtitulo: 'Qué hace la IA con lo que le escribes',
            url: LegalLinks.avisoIa,
          ),

          const SizedBox(height: 8),
          _seccion('Inteligencia artificial'),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: oscuro ? const Color(0xFF2D2410) : const Color(0xFFFFF8E6),
                border: Border.all(color: const Color(0xFFF0A500)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFB26A00), size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'PawBot no es un veterinario',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Las respuestas del asistente las genera una inteligencia artificial '
                    'y pueden ser incorrectas. No son un diagnóstico ni un tratamiento, y '
                    'no sustituyen a un veterinario colegiado.\n\n'
                    'Lo que le escribes al asistente se envía a un proveedor de IA fuera '
                    'del Perú (GitHub Models, de Microsoft, con modelos de OpenAI). Nunca '
                    'le enviamos tu contraseña, tu correo ni tu teléfono.\n\n'
                    'Ante una emergencia, acude a un veterinario.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 8),
          _seccion('Tu cuenta'),
          ListTile(
            leading: const Icon(Icons.delete_forever, color: Colors.red),
            title: const Text(
              'Eliminar mi cuenta',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
            subtitle: const Text(
              'Borra tu cuenta, tus publicaciones y el expediente de tus mascotas. '
              'Es definitivo.',
            ),
            onTap: _borrando ? null : _confirmarBorrado,
          ),
          if (_borrando)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _seccion(String titulo) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Text(
          titulo.toUpperCase(),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );

  Widget _documento({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required String url,
  }) =>
      ListTile(
        leading: Icon(icono, color: const Color(0xFFFF9800)),
        title: Text(titulo),
        subtitle: Text(subtitulo),
        trailing: const Icon(Icons.open_in_new, size: 18),
        onTap: () => _abrir(url),
      );

  /// Doble confirmación: el usuario tiene que escribir ELIMINAR. Es irreversible
  /// y no queremos que se cargue su cuenta de un toque accidental.
  Future<void> _confirmarBorrado() async {
    final controlador = TextEditingController();
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (contexto) => StatefulBuilder(
        builder: (contexto, actualizar) => AlertDialog(
          title: const Text('Eliminar mi cuenta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Se borrarán tu cuenta, tus publicaciones, las fotos y el expediente '
                'de salud de tus mascotas, tus comentarios y tus solicitudes de adopción.\n\n'
                'Esto NO se puede deshacer.\n',
                style: TextStyle(height: 1.4),
              ),
              const Text('Escribe ELIMINAR para confirmar:'),
              const SizedBox(height: 8),
              TextField(
                controller: controlador,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'ELIMINAR',
                ),
                onChanged: (_) => actualizar(() {}),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(contexto, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: controlador.text.trim().toUpperCase() == 'ELIMINAR'
                  ? () => Navigator.pop(contexto, true)
                  : null,
              child: const Text(
                'Eliminar definitivamente',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmado != true) return;

    setState(() => _borrando = true);
    final error = await AccountService().deleteMyAccount();
    if (!mounted) return;
    setState(() => _borrando = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tu cuenta y tus datos han sido eliminados'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
  }
}
