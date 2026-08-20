/// La clínica del veterinario vista desde dentro de la app: su catálogo de
/// productos y servicios, y la reserva de cita eligiendo entre los turnos que
/// de verdad están libres.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/vet_store_service.dart';
import '../../../../core/services/appointment_service.dart';

class ClinicaScreen extends StatefulWidget {
  const ClinicaScreen({super.key, required this.veterinaria});

  /// Ficha de la veterinaria tal cual llega del directorio.
  final Map<String, dynamic> veterinaria;

  @override
  State<ClinicaScreen> createState() => _ClinicaScreenState();
}

class _ClinicaScreenState extends State<ClinicaScreen>
    with SingleTickerProviderStateMixin {
  static const Color _brand = Color(0xFFFF9800);

  final VetStoreService _store = VetStoreService();
  late final TabController _tabs = TabController(length: 2, vsync: this);

  List<Map<String, dynamic>> _catalogo = [];
  bool _cargando = true;
  String? _error;

  int get _vetId => widget.veterinaria['id'] as int;
  String get _nombre => widget.veterinaria['name']?.toString() ?? 'Clínica';

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _cargar() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final catalogo = await _store.getProductos(_vetId);
      if (!mounted) return;
      setState(() {
        _catalogo = catalogo;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar la clínica.';
        _cargando = false;
      });
    }
  }

  Future<void> _abrir(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir')),
        );
      }
    }
  }

  void _contactar() {
    final wa = widget.veterinaria['whatsapp']?.toString() ?? '';
    final tel = widget.veterinaria['phone']?.toString() ?? '';
    if (wa.isNotEmpty) {
      final limpio = wa.replaceAll(RegExp(r'[^0-9]'), '');
      _abrir(Uri.parse('https://wa.me/$limpio'));
    } else if (tel.isNotEmpty) {
      _abrir(Uri.parse('tel:${tel.replaceAll(' ', '')}'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_nombre, overflow: TextOverflow.ellipsis),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            tooltip: 'Contactar',
            onPressed: _contactar,
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: 'Catálogo'),
            Tab(icon: Icon(Icons.event_available), text: 'Pedir cita'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _pestanaCatalogo(),
          ReservaCitaTab(veterinariaId: _vetId, nombre: _nombre),
        ],
      ),
    );
  }

  Widget _pestanaCatalogo() {
    if (_cargando) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _cargar, child: const Text('Reintentar')),
          ],
        ),
      );
    }
    if (_catalogo.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Esta clínica todavía no ha publicado productos ni servicios.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Agrupar por categoría: un catálogo plano de 14 líneas se lee fatal.
    final porCategoria = <String, List<Map<String, dynamic>>>{};
    for (final p in _catalogo) {
      final cat = (p['category']?.toString().isNotEmpty ?? false)
          ? p['category'].toString()
          : 'Otros';
      porCategoria.putIfAbsent(cat, () => []).add(p);
    }
    final categorias = porCategoria.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: categorias.length,
        itemBuilder: (_, i) {
          final cat = categorias[i];
          final items = porCategoria[cat]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                child: Text(
                  cat,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ...items.map(_tarjetaProducto),
            ],
          );
        },
      ),
    );
  }

  Widget _tarjetaProducto(Map<String, dynamic> p) {
    final scheme = Theme.of(context).colorScheme;
    final esServicio = p['kind'] == 'servicio';
    // El precio llega como texto: la columna es numeric en Postgres.
    final precio = double.tryParse('${p['price'] ?? 0}') ?? 0;
    final stock = p['stock'];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: (esServicio ? Colors.teal : _brand)
              .withValues(alpha: 0.15),
          child: Icon(
            esServicio ? Icons.medical_services : Icons.inventory_2,
            color: esServicio ? Colors.teal : _brand,
          ),
        ),
        title: Text(p['name']?.toString() ?? ''),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((p['description']?.toString() ?? '').isNotEmpty)
              Text(
                p['description'].toString(),
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            if (!esServicio && stock != null)
              Text(
                stock == 0 ? 'Sin stock' : 'Stock: $stock',
                style: TextStyle(
                  fontSize: 11,
                  color: stock == 0 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        trailing: Text(
          'S/ ${precio.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        isThreeLine: true,
        onTap: _contactar,
      ),
    );
  }
}

/// Pestaña de reserva: elige día, mira los turnos libres de verdad y reserva.
class ReservaCitaTab extends StatefulWidget {
  const ReservaCitaTab({
    super.key,
    required this.veterinariaId,
    required this.nombre,
  });

  final int veterinariaId;
  final String nombre;

  @override
  State<ReservaCitaTab> createState() => _ReservaCitaTabState();
}

class _ReservaCitaTabState extends State<ReservaCitaTab> {
  static const Color _brand = Color(0xFFFF9800);

  final VetStoreService _store = VetStoreService();
  final AppointmentService _citas = AppointmentService();
  final TextEditingController _motivo = TextEditingController();

  DateTime _dia = DateTime.now();
  List<DateTime> _libres = [];
  DateTime? _elegido;
  bool _cargando = true;
  bool _reservando = false;
  bool _cerrado = false;

  @override
  void initState() {
    super.initState();
    _cargarDia(_dia);
  }

  @override
  void dispose() {
    _motivo.dispose();
    super.dispose();
  }

  Future<void> _cargarDia(DateTime dia) async {
    setState(() {
      _cargando = true;
      _dia = dia;
      _elegido = null;
    });
    try {
      final (libres, cerrado) =
          await _store.getHuecosLibres(widget.veterinariaId, dia);
      if (!mounted) return;
      setState(() {
        _libres = libres;
        _cerrado = cerrado;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _libres = [];
        _cargando = false;
      });
    }
  }

  Future<void> _reservar() async {
    if (_elegido == null) return;
    if (_motivo.text.trim().length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cuéntale al veterinario el motivo')),
      );
      return;
    }

    setState(() => _reservando = true);
    final error = await _citas.reservar(
      veterinariaId: widget.veterinariaId,
      cuando: _elegido!,
      motivo: _motivo.text.trim(),
    );
    if (!mounted) return;
    setState(() => _reservando = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ $error'), backgroundColor: Colors.orange),
      );
      // Puede que alguien haya cogido el turno mientras rellenaba el motivo.
      _cargarDia(_dia);
      return;
    }

    _motivo.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Cita solicitada. El veterinario la confirmará.'),
        backgroundColor: Colors.green,
      ),
    );
    _cargarDia(_dia);
  }

  String _dosDigitos(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hoy = DateTime.now();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Elige el día',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: 14,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final d = DateTime(hoy.year, hoy.month, hoy.day + i);
              final activo = d.day == _dia.day && d.month == _dia.month;
              const nombres = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
              return InkWell(
                onTap: () => _cargarDia(d),
                child: Container(
                  width: 56,
                  decoration: BoxDecoration(
                    color: activo ? _brand : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        nombres[d.weekday - 1],
                        style: TextStyle(
                          fontSize: 12,
                          color: activo ? Colors.white70 : scheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        '${d.day}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: activo ? Colors.white : scheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        const Text('Turnos libres',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          'Solo se muestran las horas realmente disponibles: se descuentan las '
          'citas de la app y lo que la clínica ya tiene agendado en su sistema.',
          style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        if (_cargando)
          const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ))
        else if (_cerrado)
          _aviso('La clínica no atiende ese día.', scheme)
        else if (_libres.isEmpty)
          _aviso('No quedan turnos libres ese día. Prueba con otro.', scheme)
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _libres.map((h) {
              final elegido = _elegido == h;
              return ChoiceChip(
                label: Text('${_dosDigitos(h.hour)}:${_dosDigitos(h.minute)}'),
                selected: elegido,
                selectedColor: _brand,
                labelStyle: TextStyle(
                  color: elegido ? Colors.white : scheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) => setState(() => _elegido = h),
              );
            }).toList(),
          ),
        const SizedBox(height: 20),
        TextField(
          controller: _motivo,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo de la consulta',
            hintText: 'Ej.: mi perro se rasca mucho desde hace 3 días',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: (_elegido == null || _reservando) ? null : _reservar,
          icon: _reservando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.event_available),
          label: Text(_elegido == null
              ? 'Elige un turno'
              : 'Pedir cita a las '
                  '${_dosDigitos(_elegido!.hour)}:${_dosDigitos(_elegido!.minute)}'),
          style: FilledButton.styleFrom(
            backgroundColor: _brand,
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      ],
    );
  }

  Widget _aviso(String texto, ColorScheme scheme) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: scheme.onSurfaceVariant),
            const SizedBox(width: 10),
            Expanded(child: Text(texto)),
          ],
        ),
      );
}
