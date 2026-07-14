import 'package:flutter/material.dart';
import '../../../../core/services/appointment_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../chat/presentation/screens/chat_screen.dart';

/// Citas del usuario. Pestaña "Mis citas" (como cliente) y, si es veterinario,
/// "Recibidas" (las de su veterinaria, que puede confirmar/rechazar/atender).
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _service = AppointmentService();
  bool _isVet = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    AuthService().isVet().then((v) {
      if (mounted) setState(() {
        _isVet = v;
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return DefaultTabController(
      length: _isVet ? 2 : 1,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Citas'),
          bottom: TabBar(
            tabs: [
              const Tab(text: 'Mis citas'),
              if (_isVet) const Tab(text: 'Recibidas'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Lista(cargar: _service.mine, esVet: false, onCambio: () => setState(() {})),
            if (_isVet)
              _Lista(cargar: _service.forVet, esVet: true, onCambio: () => setState(() {})),
          ],
        ),
      ),
    );
  }
}

class _Lista extends StatefulWidget {
  final Future<List<Map<String, dynamic>>> Function() cargar;
  final bool esVet;
  final VoidCallback onCambio;
  const _Lista({required this.cargar, required this.esVet, required this.onCambio});

  @override
  State<_Lista> createState() => _ListaState();
}

class _ListaState extends State<_Lista> {
  final _service = AppointmentService();
  List<Map<String, dynamic>> _citas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final c = await widget.cargar();
    if (!mounted) return;
    setState(() {
      _citas = c;
      _loading = false;
    });
  }

  Color _color(String estado) {
    switch (estado) {
      case 'confirmed':
        return const Color(0xFF2ECC71);
      case 'rejected':
      case 'cancelled':
        return const Color(0xFFE74C3C);
      case 'completed':
        return Colors.blueGrey;
      default:
        return const Color(0xFFF39C12);
    }
  }

  Future<void> _cambiar(int id, String estado) async {
    final ok = await _service.updateStatus(id, estado);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'Cita actualizada' : 'No se pudo actualizar')),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_citas.isEmpty) {
      return const Center(child: Text('No hay citas'));
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _citas.length,
        itemBuilder: (context, i) {
          final a = _citas[i];
          final estado = '${a['status']}';
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('${a['reason']}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      Chip(
                        label: Text(estado, style: const TextStyle(fontSize: 12, color: Colors.white)),
                        backgroundColor: _color(estado),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('📅 ${_fecha(a['scheduledAt'])}'),
                  if (a['vetNote'] != null && '${a['vetNote']}'.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Nota: ${a['vetNote']}',
                          style: const TextStyle(fontStyle: FontStyle.italic)),
                    ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (a['conversationId'] != null)
                        OutlinedButton.icon(
                          icon: const Icon(Icons.chat_bubble_outline, size: 18),
                          label: const Text('Chat'),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversationId: a['conversationId'] as int,
                                title: widget.esVet ? 'Cliente' : 'Veterinaria',
                              ),
                            ),
                          ),
                        ),
                      // Acciones del veterinario
                      if (widget.esVet && estado == 'pending') ...[
                        FilledButton(
                          onPressed: () => _cambiar(a['id'] as int, 'confirmed'),
                          child: const Text('Confirmar'),
                        ),
                        OutlinedButton(
                          onPressed: () => _cambiar(a['id'] as int, 'rejected'),
                          child: const Text('Rechazar'),
                        ),
                      ],
                      if (widget.esVet && estado == 'confirmed')
                        FilledButton(
                          onPressed: () => _cambiar(a['id'] as int, 'completed'),
                          child: const Text('Marcar atendida'),
                        ),
                      // Acción del cliente
                      if (!widget.esVet && (estado == 'pending' || estado == 'confirmed'))
                        OutlinedButton(
                          onPressed: () => _cambiar(a['id'] as int, 'cancelled'),
                          child: const Text('Cancelar'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _fecha(dynamic iso) {
    final d = DateTime.tryParse('$iso')?.toLocal();
    if (d == null) return '$iso';
    two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
  }
}
