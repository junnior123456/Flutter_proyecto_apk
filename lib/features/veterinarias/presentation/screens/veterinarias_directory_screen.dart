/// Directorio de veterinarias (visible para todos los usuarios).
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/veterinaria_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../appointments/presentation/screens/book_appointment_screen.dart';

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
  final LocationService _location = LocationService();

  /// Dos modos: el directorio completo (por defecto) y las de cerca, que
  /// necesitan permiso de ubicación. Se guarda el radio para poder ampliarlo
  /// sin volver a pedir la posición.
  bool _soloCercanas = false;
  double _radioKm = 10;

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
      final data = _soloCercanas
          ? await _cargarCercanas()
          : await _service.listPublic();
      if (!mounted) return;
      if (data == null) return; // el error ya se mostró
      setState(() { _items = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'No se pudo cargar el directorio.'; _loading = false; });
    }
  }

  /// Pide la ubicación y trae las veterinarias del radio actual.
  /// Devuelve null si no se pudo (y deja el error puesto).
  Future<List<Map<String, dynamic>>?> _cargarCercanas() async {
    final (posicion, errorUbicacion) = await _location.posicionActual();
    if (!mounted) return null;
    if (posicion == null) {
      setState(() {
        _error = errorUbicacion;
        _loading = false;
        // Volver al directorio: sin ubicación el modo cercanas no da nada.
        _soloCercanas = false;
      });
      return null;
    }
    return _service.getNearby(
      lat: posicion.latitude,
      lng: posicion.longitude,
      radiusKm: _radioKm,
    );
  }

  void _alternarCercanas() {
    setState(() => _soloCercanas = !_soloCercanas);
    _load();
  }

  void _ampliarRadio() {
    setState(() => _radioKm = _radioKm >= 50 ? 50 : _radioKm * 2);
    _load();
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
        title: Text(_soloCercanas ? '📍 Cerca de mí' : '🏥 Veterinarias'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: _soloCercanas
                ? 'Ver todo el directorio'
                : 'Ver las más cercanas a mí',
            icon: Icon(_soloCercanas ? Icons.list : Icons.my_location),
            onPressed: _alternarCercanas,
          ),
        ],
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
          child: Text(
            _soloCercanas
                ? 'No hay veterinarias a menos de ${_radioKm.toInt()} km.'
                : 'Aún no hay veterinarias registradas.',
            style: TextStyle(color: scheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ),
        if (_soloCercanas && _radioKm < 50) ...[
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton.icon(
              onPressed: _ampliarRadio,
              icon: const Icon(Icons.zoom_out_map),
              label: Text('Buscar hasta ${(_radioKm * 2).toInt()} km'),
            ),
          ),
        ],
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
              // Solo llega en el modo "cerca de mí".
              if (v['distanceKm'] != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _brand.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${v['distanceKm']} km',
                    style: const TextStyle(
                        color: _brand, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
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
                _action(Icons.event_available, 'Reservar cita',
                    const Color(0xFF6A1B9A), () {
                  final id = int.tryParse('${v['id']}');
                  if (id == null) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BookAppointmentScreen(
                        veterinariaId: id,
                        veterinariaName: v['name']?.toString() ?? 'Veterinaria',
                      ),
                    ),
                  );
                }),
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
