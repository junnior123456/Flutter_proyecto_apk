/// Solicitudes de empresas veterinarias: el administrador revisa los datos,
/// y al aprobar le concede a esa cuenta el acceso de veterinario.
library;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/vet_request_service.dart';

class SolicitudesVetScreen extends StatefulWidget {
  const SolicitudesVetScreen({super.key});

  @override
  State<SolicitudesVetScreen> createState() => _SolicitudesVetScreenState();
}

class _SolicitudesVetScreenState extends State<SolicitudesVetScreen>
    with SingleTickerProviderStateMixin {
  static const Color _admin = Color(0xFF3949AB);
  static const _estados = ['pending', 'approved', 'rejected'];
  static const _titulos = ['Pendientes', 'Aprobadas', 'Rechazadas'];

  final VetRequestService _service = VetRequestService();
  late final TabController _tabs = TabController(length: 3, vsync: this);

  final Map<String, List<dynamic>> _porEstado = {};
  bool _cargando = true;
  int? _procesando;

  @override
  void initState() {
    super.initState();
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) setState(() {});
    });
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
      for (final estado in _estados) {
        _porEstado[estado] = await _service.list(status: estado);
      }
    } catch (_) {
      // Se deja lo que haya cargado; el aviso sale al pintar la lista vacía.
    }
    if (!mounted) return;
    setState(() => _cargando = false);
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

  Future<void> _aprobar(Map<String, dynamic> solicitud) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Dar acceso de veterinario?'),
        content: Text(
          '${solicitud['clinicName'] ?? solicitud['name'] ?? 'Esta cuenta'} '
          'podrá publicar su catálogo, recibir citas y atender a los clientes '
          'desde la app.\n\nSu cuenta pasará de cliente a veterinario.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.verified_user),
            label: const Text('Dar acceso'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _procesando = solicitud['id'] as int);
    final ok = await _service.approve(solicitud['id'] as int);
    if (!mounted) return;
    setState(() => _procesando = null);

    if (ok) {
      _avisar('Acceso concedido. La cuenta ya es veterinaria.');
      _cargar();
    } else {
      _avisar('No se pudo aprobar la solicitud', error: true);
    }
  }

  Future<void> _rechazar(Map<String, dynamic> solicitud) async {
    final motivo = TextEditingController();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rechazar solicitud'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Explica por qué. El solicitante lo verá y podrá corregirlo.',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: motivo,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Ej.: el RUC no corresponde a la razón social',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Rechazar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    setState(() => _procesando = solicitud['id'] as int);
    final ok = await _service.reject(
      solicitud['id'] as int,
      note: motivo.text.trim().isEmpty ? null : motivo.text.trim(),
    );
    if (!mounted) return;
    setState(() => _procesando = null);

    if (ok) {
      _avisar('Solicitud rechazada');
      _cargar();
    } else {
      _avisar('No se pudo rechazar', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes de veterinarias'),
        backgroundColor: _admin,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: List.generate(3, (i) {
            final n = _porEstado[_estados[i]]?.length ?? 0;
            return Tab(text: n > 0 ? '${_titulos[i]} ($n)' : _titulos[i]);
          }),
        ),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: _estados.map(_lista).toList(),
            ),
    );
  }

  Widget _lista(String estado) {
    final items = _porEstado[estado] ?? [];
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _cargar,
        child: ListView(
          children: const [
            SizedBox(height: 140),
            Icon(Icons.inbox, size: 56, color: Colors.grey),
            SizedBox(height: 12),
            Center(child: Text('No hay solicitudes aquí.')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _cargar,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: items.length,
        itemBuilder: (_, i) =>
            _tarjeta(Map<String, dynamic>.from(items[i]), estado),
      ),
    );
  }

  Widget _tarjeta(Map<String, dynamic> s, String estado) {
    final scheme = Theme.of(context).colorScheme;
    final ocupado = _procesando == s['id'];
    final telefono = s['phone']?.toString() ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _admin.withValues(alpha: 0.15),
                  child: const Icon(Icons.business, color: _admin),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['clinicName']?.toString() ??
                            s['fullName']?.toString() ??
                            'Clínica sin nombre',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      if ((s['ruc']?.toString() ?? '').isNotEmpty)
                        Text('RUC ${s['ruc']}',
                            style: TextStyle(
                                fontSize: 12,
                                color: scheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if ((s['fullName']?.toString() ?? '').isNotEmpty)
              _dato(Icons.person, 'Solicitante', s['fullName'].toString(), scheme),
            if (telefono.isNotEmpty)
              _dato(Icons.phone, 'Teléfono', telefono, scheme),
            if ((s['message']?.toString() ?? '').isNotEmpty)
              _dato(Icons.notes, 'Mensaje', s['message'].toString(), scheme),
            if ((s['reviewNote']?.toString() ?? '').isNotEmpty)
              _dato(Icons.gavel, 'Motivo del rechazo',
                  s['reviewNote'].toString(), scheme),

            const SizedBox(height: 12),
            if (estado == 'pending')
              Row(
                children: [
                  if (telefono.isNotEmpty)
                    IconButton(
                      tooltip: 'Llamar para verificar',
                      icon: const Icon(Icons.call, color: Colors.blue),
                      onPressed: () => launchUrl(
                        Uri.parse('tel:${telefono.replaceAll(' ', '')}'),
                        mode: LaunchMode.externalApplication,
                      ),
                    ),
                  const Spacer(),
                  if (ocupado)
                    const Padding(
                      padding: EdgeInsets.all(8),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else ...[
                    TextButton.icon(
                      onPressed: () => _rechazar(s),
                      icon: const Icon(Icons.close, color: Colors.red),
                      label: const Text('Rechazar',
                          style: TextStyle(color: Colors.red)),
                    ),
                    const SizedBox(width: 6),
                    FilledButton.icon(
                      onPressed: () => _aprobar(s),
                      icon: const Icon(Icons.verified_user),
                      label: const Text('Dar acceso'),
                      style: FilledButton.styleFrom(backgroundColor: _admin),
                    ),
                  ],
                ],
              )
            else
              Chip(
                avatar: Icon(
                  estado == 'approved' ? Icons.check_circle : Icons.cancel,
                  size: 18,
                  color: estado == 'approved' ? Colors.green : Colors.red,
                ),
                label: Text(
                  estado == 'approved'
                      ? 'Acceso concedido'
                      : 'Rechazada',
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _dato(
      IconData icono, String etiqueta, String valor, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icono, size: 15, color: scheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 12, color: scheme.onSurface),
                children: [
                  TextSpan(
                    text: '$etiqueta: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: valor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
