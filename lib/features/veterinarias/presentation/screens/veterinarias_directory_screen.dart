/// Directorio de veterinarias (visible para todos los usuarios).
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/veterinaria_service.dart';

class VeterinariasDirectoryScreen extends StatefulWidget {
  const VeterinariasDirectoryScreen({super.key});

  @override
  State<VeterinariasDirectoryScreen> createState() =>
      _VeterinariasDirectoryScreenState();
}

class _VeterinariasDirectoryScreenState
    extends State<VeterinariasDirectoryScreen> {
  static const Color _brand = Color(0xFFFF9800);
  final VeterinariaService _service = VeterinariaService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final data = await _service.listPublic();
      if (!mounted) return;
      setState(() { _items = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'No se pudo cargar el directorio.'; _loading = false; });
    }
  }

  Future<void> _launch(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('No se pudo abrir')));
      }
    }
  }

  void _call(String phone) => _launch(Uri.parse('tel:${phone.replaceAll(' ', '')}'));

  void _whatsapp(String number) {
    final clean = number.replaceAll(RegExp(r'[^0-9]'), '');
    _launch(Uri.parse('https://wa.me/$clean'));
  }

  void _map(double lat, double lng, String name) {
    _launch(Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏥 Veterinarias'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(onRefresh: _load, child: _body()),
    );
  }

  Widget _body() {
    final scheme = Theme.of(context).colorScheme;
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return ListView(children: [
        const SizedBox(height: 120),
        Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
        const SizedBox(height: 12),
        Center(child: OutlinedButton(onPressed: _load, child: const Text('Reintentar'))),
      ]);
    }
    if (_items.isEmpty) {
      return ListView(children: [
        const SizedBox(height: 120),
        Icon(Icons.local_hospital_outlined, size: 56, color: scheme.onSurfaceVariant),
        const SizedBox(height: 12),
        Center(
          child: Text('Aún no hay veterinarias registradas.',
              style: TextStyle(color: scheme.onSurfaceVariant)),
        ),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, i) => _card(_items[i]),
    );
  }

  Widget _card(Map<String, dynamic> v) {
    final scheme = Theme.of(context).colorScheme;
    final phone = v['phone']?.toString() ?? '';
    final wa = v['whatsapp']?.toString() ?? '';
    final addr = v['address']?.toString() ?? '';
    final hours = v['openingHours']?.toString() ?? '';
    final lat = v['latitude'], lng = v['longitude'];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: _brand.withValues(alpha: 0.15),
                child: const Icon(Icons.local_hospital, color: _brand),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(v['name']?.toString() ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ]),
            if (addr.isNotEmpty) ...[
              const SizedBox(height: 8),
              _row(Icons.location_on_outlined, addr, scheme),
            ],
            if (hours.isNotEmpty) _row(Icons.schedule, hours, scheme),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (phone.isNotEmpty)
                  _action(Icons.call, 'Llamar', Colors.blue, () => _call(phone)),
                if (wa.isNotEmpty)
                  _action(Icons.chat, 'WhatsApp', const Color(0xFF25D366),
                      () => _whatsapp(wa)),
                if (lat != null && lng != null)
                  _action(Icons.map, 'Mapa', Colors.red,
                      () => _map((lat as num).toDouble(), (lng as num).toDouble(),
                          v['name']?.toString() ?? '')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String text, ColorScheme scheme) => Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 16, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
          ),
        ]),
      );

  Widget _action(IconData icon, String label, Color color, VoidCallback onTap) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: color),
      label: Text(label, style: TextStyle(color: color)),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: color.withValues(alpha: 0.5)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
    );
  }
}
