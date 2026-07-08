/// Módulo 3 — Cartilla de vacunas de la mascota.
/// Lista las vacunas del expediente y permite registrar / eliminar.
import 'package:flutter/material.dart';
import '../../../../core/services/vaccination_service.dart';

class PetVaccinationsScreen extends StatefulWidget {
  final int petId;
  final String petName;
  const PetVaccinationsScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetVaccinationsScreen> createState() => _PetVaccinationsScreenState();
}

class _PetVaccinationsScreenState extends State<PetVaccinationsScreen> {
  static const Color _brand = Color(0xFF6C63FF);
  final VaccinationService _service = VaccinationService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.list(widget.petId);
      if (!mounted) return;
      setState(() {
        _items = data;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudieron cargar las vacunas.';
        _loading = false;
      });
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isOverdue(String? nextDue) {
    if (nextDue == null || nextDue.isEmpty) return false;
    final due = DateTime.tryParse(nextDue);
    if (due == null) return false;
    return due.isBefore(DateTime.now());
  }

  Future<void> _openAddDialog() async {
    final typeCtrl = TextEditingController();
    final batchCtrl = TextEditingController();
    DateTime applied = DateTime.now();
    DateTime? nextDue;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Registrar vacuna'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: typeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de vacuna *',
                    hintText: 'Antirrábica, Parvovirus...',
                  ),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha de aplicación'),
                  subtitle: Text(_fmt(applied)),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: applied,
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setD(() => applied = d);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Próxima dosis (opcional)'),
                  subtitle: Text(nextDue == null ? 'Sin definir' : _fmt(nextDue!)),
                  trailing: const Icon(Icons.event_repeat, size: 18),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 365)),
                      firstDate: DateTime(2010),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setD(() => nextDue = d);
                  },
                ),
                TextField(
                  controller: batchCtrl,
                  decoration: const InputDecoration(labelText: 'Lote (opcional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _brand,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (typeCtrl.text.trim().isEmpty) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    try {
      await _service.add(widget.petId, {
        'type': typeCtrl.text.trim(),
        'appliedAt': _fmt(applied),
        if (nextDue != null) 'nextDueAt': _fmt(nextDue!),
        if (batchCtrl.text.trim().isNotEmpty) 'batch': batchCtrl.text.trim(),
      });
      await _load();
      _toast('Vacuna registrada ✅');
    } catch (_) {
      _toast('No se pudo guardar la vacuna');
    }
  }

  Future<void> _delete(Map<String, dynamic> v) async {
    try {
      await _service.remove(widget.petId, v['id'] as int);
      await _load();
      _toast('Registro eliminado');
    } catch (_) {
      _toast('No se pudo eliminar');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('💉 Vacunas · ${widget.petName}'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Vacuna'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return ListView(
        children: [
          const SizedBox(height: 120),
          Center(child: Text(_error!, style: const TextStyle(color: Colors.red))),
          const SizedBox(height: 12),
          Center(
            child: OutlinedButton(onPressed: _load, child: const Text('Reintentar')),
          ),
        ],
      );
    }
    if (_items.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 120),
          Icon(Icons.vaccines, size: 56, color: Colors.grey),
          SizedBox(height: 12),
          Center(
            child: Text('Aún no hay vacunas registradas.\nToca "Vacuna" para agregar la primera.',
                textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
          ),
        ],
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _card(_items[i]),
    );
  }

  Widget _card(Map<String, dynamic> v) {
    final nextDue = v['nextDueAt'] as String?;
    final overdue = _isOverdue(nextDue);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: _brand.withOpacity(0.12),
              child: const Icon(Icons.vaccines, color: _brand),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(v['type']?.toString() ?? 'Vacuna',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 3),
                  Text('Aplicada: ${v['appliedAt'] ?? '—'}',
                      style: const TextStyle(fontSize: 13, color: Colors.grey)),
                  if (nextDue != null && nextDue.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 3),
                      child: Text(
                        overdue ? '⚠️ Vencida: $nextDue' : 'Próxima: $nextDue',
                        style: TextStyle(
                          fontSize: 13,
                          color: overdue ? Colors.red : Colors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  if ((v['batch']?.toString() ?? '').isNotEmpty)
                    Text('Lote: ${v['batch']}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey),
              onPressed: () => _delete(v),
            ),
          ],
        ),
      ),
    );
  }
}
