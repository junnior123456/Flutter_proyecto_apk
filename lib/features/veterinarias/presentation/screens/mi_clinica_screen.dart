/// Panel del veterinario sobre su propia clínica: catálogo, horario de
/// atención y conexión con el sistema de agenda que ya use en su local.
library;

import 'package:flutter/material.dart';
import '../../../../core/services/vet_store_service.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/video_service.dart';

class MiClinicaScreen extends StatefulWidget {
  const MiClinicaScreen({super.key, required this.veterinaria});

  final Map<String, dynamic> veterinaria;

  @override
  State<MiClinicaScreen> createState() => _MiClinicaScreenState();
}

class _MiClinicaScreenState extends State<MiClinicaScreen>
    with SingleTickerProviderStateMixin {
  static const Color _brand = Color(0xFFFF9800);
  static const _dias = [
    'Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado',
  ];

  final VetStoreService _store = VetStoreService();
  final ImageService _imagenes = ImageService();
  final VideoService _videos = VideoService();
  late final TabController _tabs = TabController(length: 3, vsync: this);

  List<Map<String, dynamic>> _catalogo = [];
  List<Map<String, dynamic>> _horario = [];
  bool _cargando = true;
  bool _sincronizando = false;

  int get _vetId => widget.veterinaria['id'] as int;

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
    setState(() => _cargando = true);
    try {
      final catalogo = await _store.getProductosDelDueno(_vetId);
      final horario = await _store.getHorario(_vetId);
      if (!mounted) return;
      setState(() {
        _catalogo = catalogo;
        _horario = horario;
        _cargando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _avisar(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(texto),
        backgroundColor: error ? Colors.orange : Colors.green,
      ),
    );
  }

  // ---------------- Catálogo ----------------

  Future<void> _editarProducto([Map<String, dynamic>? producto]) async {
    final nombre = TextEditingController(text: producto?['name']?.toString());
    final descripcion =
        TextEditingController(text: producto?['description']?.toString());
    final precio =
        TextEditingController(text: '${producto?['price'] ?? ''}');
    final categoria =
        TextEditingController(text: producto?['category']?.toString());
    final stock = TextEditingController(
        text: producto?['stock'] == null ? '' : '${producto!['stock']}');
    String tipo = producto?['kind']?.toString() ?? 'producto';
    // Foto y vídeo de publicidad: se suben al elegirlos y se guarda la URL.
    String? fotoUrl = producto?['imageUrl']?.toString();
    String? videoUrl = producto?['videoUrl']?.toString();
    var subiendo = false;

    final guardar = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text(producto == null ? 'Nuevo en el catálogo' : 'Editar'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'producto', label: Text('Producto')),
                    ButtonSegment(value: 'servicio', label: Text('Servicio')),
                  ],
                  selected: {tipo},
                  onSelectionChanged: (s) => setLocal(() => tipo = s.first),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: nombre,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descripcion,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                ),
                TextField(
                  controller: precio,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Precio (S/)'),
                ),
                TextField(
                  controller: categoria,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    hintText: 'Alimentos, Vacunación, Cirugía...',
                  ),
                ),
                // El stock solo tiene sentido en lo que se vende por unidades.
                if (tipo == 'producto')
                  TextField(
                    controller: stock,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Stock'),
                  ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Publicidad',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                if (subiendo)
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: LinearProgressIndicator(),
                  ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: subiendo
                            ? null
                            : () async {
                                final foto = await _imagenes.pickFromGallery();
                                if (foto == null) return;
                                setLocal(() => subiendo = true);
                                final url = await _store.subirFoto(foto);
                                setLocal(() {
                                  subiendo = false;
                                  if (url != null) fotoUrl = url;
                                });
                              },
                        icon: Icon(fotoUrl != null
                            ? Icons.check_circle
                            : Icons.add_photo_alternate),
                        label: Text(fotoUrl != null ? 'Foto lista' : 'Foto'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: subiendo
                            ? null
                            : () async {
                                final video = await _videos.pickVideo();
                                if (video == null) return;
                                final rechazo =
                                    await _videos.motivoRechazo(video);
                                if (rechazo != null) {
                                  _avisar(rechazo, error: true);
                                  return;
                                }
                                setLocal(() => subiendo = true);
                                final url = await _store.subirVideo(video);
                                setLocal(() {
                                  subiendo = false;
                                  if (url != null) videoUrl = url;
                                });
                              },
                        icon: Icon(videoUrl != null
                            ? Icons.check_circle
                            : Icons.videocam),
                        label: Text(videoUrl != null ? 'Vídeo listo' : 'Vídeo'),
                      ),
                    ),
                  ],
                ),
                if (fotoUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(fotoUrl!, height: 90,
                          fit: BoxFit.cover, errorBuilder: (_, __, ___) =>
                              const SizedBox.shrink()),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (guardar != true) return;
    if (nombre.text.trim().isEmpty) {
      _avisar('Ponle un nombre', error: true);
      return;
    }

    final datos = <String, dynamic>{
      'name': nombre.text.trim(),
      'description': descripcion.text.trim(),
      'price': double.tryParse(precio.text.replaceAll(',', '.')) ?? 0,
      'kind': tipo,
      'category': categoria.text.trim(),
      'stock': tipo == 'producto' ? int.tryParse(stock.text) : null,
      'imageUrl': fotoUrl,
      'videoUrl': videoUrl,
    };

    try {
      if (producto == null) {
        await _store.crearProducto(_vetId, datos);
      } else {
        await _store.editarProducto(_vetId, producto['id'] as int, datos);
      }
      _avisar('Guardado');
      _cargar();
    } catch (e) {
      _avisar('$e', error: true);
    }
  }

  Future<void> _borrarProducto(Map<String, dynamic> producto) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Quitar del catálogo?'),
        content: Text('Se eliminará "${producto['name']}".'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Quitar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;
    try {
      await _store.borrarProducto(_vetId, producto['id'] as int);
      _avisar('Quitado del catálogo');
      _cargar();
    } catch (e) {
      _avisar('$e', error: true);
    }
  }

  // ---------------- Horario ----------------

  Future<void> _anadirTramo(int weekday) async {
    TimeOfDay? abre = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay? cierra = const TimeOfDay(hour: 13, minute: 0);

    abre = await showTimePicker(
      context: context,
      initialTime: abre,
      helpText: 'Hora de apertura',
    );
    if (abre == null || !mounted) return;
    cierra = await showTimePicker(
      context: context,
      initialTime: cierra,
      helpText: 'Hora de cierre',
    );
    if (cierra == null) return;

    String hhmm(TimeOfDay t) =>
        '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

    final nuevos = [
      ..._horario.map((t) => {
            'weekday': t['weekday'],
            'opensAt': t['opensAt'],
            'closesAt': t['closesAt'],
          }),
      {'weekday': weekday, 'opensAt': hhmm(abre), 'closesAt': hhmm(cierra)},
    ];

    try {
      await _store.guardarHorario(_vetId, nuevos);
      _avisar('Horario actualizado');
      _cargar();
    } catch (e) {
      _avisar('$e', error: true);
    }
  }

  Future<void> _quitarTramo(Map<String, dynamic> tramo) async {
    final nuevos = _horario
        .where((t) => t['id'] != tramo['id'])
        .map((t) => {
              'weekday': t['weekday'],
              'opensAt': t['opensAt'],
              'closesAt': t['closesAt'],
            })
        .toList();
    try {
      await _store.guardarHorario(_vetId, nuevos);
      _cargar();
    } catch (e) {
      _avisar('$e', error: true);
    }
  }

  // ---------------- Agenda externa ----------------

  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    try {
      final r = await _store.sincronizarAgenda(_vetId);
      _avisar('Agenda al día: ${r['creados']} nuevas, '
          '${r['actualizados']} actualizadas');
    } catch (e) {
      _avisar('$e'.replaceFirst('Exception: ', ''), error: true);
    } finally {
      if (mounted) setState(() => _sincronizando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi clínica'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.storefront), text: 'Catálogo'),
            Tab(icon: Icon(Icons.schedule), text: 'Horario'),
            Tab(icon: Icon(Icons.sync), text: 'Agenda'),
          ],
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _tabs,
        builder: (_, __) => _tabs.index == 0
            ? FloatingActionButton.extended(
                onPressed: () => _editarProducto(),
                backgroundColor: _brand,
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text('Agregar',
                    style: TextStyle(color: Colors.white)),
              )
            : const SizedBox.shrink(),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [_tabCatalogo(), _tabHorario(), _tabAgenda()],
            ),
    );
  }

  Widget _tabCatalogo() {
    if (_catalogo.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            'Aún no tienes nada publicado.\nUsa el botón Agregar para poner tus '
            'productos y servicios.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _catalogo.length,
      itemBuilder: (_, i) {
        final p = _catalogo[i];
        final precio = double.tryParse('${p['price'] ?? 0}') ?? 0;
        return Card(
          child: ListTile(
            leading: Icon(
              p['kind'] == 'servicio'
                  ? Icons.medical_services
                  : Icons.inventory_2,
              color: p['isActive'] == false ? Colors.grey : _brand,
            ),
            title: Text(
              p['name']?.toString() ?? '',
              style: TextStyle(
                decoration: p['isActive'] == false
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
            subtitle: Text(
              'S/ ${precio.toStringAsFixed(2)}'
              '${p['category'] != null ? ' · ${p['category']}' : ''}'
              '${p['stock'] != null ? ' · stock ${p['stock']}' : ''}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editarProducto(p),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _borrarProducto(p),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabHorario() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      // 1..6 y luego 0: la semana empieza en lunes y el domingo queda al final.
      itemCount: 7,
      itemBuilder: (_, i) {
        final weekday = i == 6 ? 0 : i + 1;
        final tramos =
            _horario.where((t) => t['weekday'] == weekday).toList();
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dias[weekday],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _anadirTramo(weekday),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Tramo'),
                    ),
                  ],
                ),
                if (tramos.isEmpty)
                  const Text('Cerrado',
                      style: TextStyle(color: Colors.grey, fontSize: 12))
                else
                  Wrap(
                    spacing: 8,
                    children: tramos
                        .map((t) => Chip(
                              label: Text(
                                '${t['opensAt'].toString().substring(0, 5)} - '
                                '${t['closesAt'].toString().substring(0, 5)}',
                              ),
                              onDeleted: () => _quitarTramo(t),
                            ))
                        .toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _tabAgenda() {
    final url = widget.veterinaria['externalAgendaUrl']?.toString() ?? '';
    final clave = widget.veterinaria['externalAgendaKey']?.toString() ?? '';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          '¿Ya usas un sistema para tus citas?',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Conéctalo y las horas que ya tengas ocupadas en tu local dejarán de '
          'aparecer libres en la app, para que nadie te reserve encima.',
          style: TextStyle(fontSize: 13),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Opción 1 · Calendario (iCal)',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                  'Si tu sistema o tu Google Calendar pueden dar un enlace .ics, '
                  'pégalo en tu ficha y pulsa Sincronizar.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                if (url.isEmpty)
                  const Text('Sin calendario configurado',
                      style: TextStyle(color: Colors.grey, fontSize: 12))
                else
                  Text(url, style: const TextStyle(fontSize: 11)),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: (url.isEmpty || _sincronizando) ? null : _sincronizar,
                  icon: _sincronizando
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.sync),
                  label: const Text('Sincronizar ahora'),
                  style: FilledButton.styleFrom(backgroundColor: _brand),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Opción 2 · Que tu sistema nos avise',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                const Text(
                  'Si tu sistema no publica calendario, puede enviarnos las horas '
                  'ocupadas. Dale estos datos a quien lo programó:',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 10),
                SelectableText(
                  'POST /api/veterinarias/$_vetId/agenda/busy\n'
                  'Cabecera: X-Agenda-Key: ${clave.isEmpty ? '(pídela al admin)' : clave}\n'
                  'Cuerpo: {"bloques":[{"startsAt":"...","endsAt":"...",'
                  '"title":"...","externalId":"..."}]}',
                  style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
                ),
                const SizedBox(height: 6),
                const Text(
                  'El externalId evita duplicados: si lo reenvías, se actualiza.',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
