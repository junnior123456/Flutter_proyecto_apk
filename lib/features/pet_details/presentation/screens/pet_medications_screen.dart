/// Módulo 3 — Medicación de la mascota.
import 'package:flutter/material.dart';
import '../../../../core/services/medication_service.dart';

class PetMedicationsScreen extends StatefulWidget {
  final int petId;
  final String petName;
  const PetMedicationsScreen({super.key, required this.petId, required this.petName});

  @override
  State<PetMedicationsScreen> createState() => _PetMedicationsScreenState();
}

class _PetMedicationsScreenState extends State<PetMedicationsScreen> {
  static const Color _brand = Color(0xFF6C63FF);
  final MedicationService _service = MedicationService();

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
      final data = await _service.list(widget.petId);
      if (!mounted) return;
      setState(() { _items = data; _loading = false; });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'No se pudo cargar la medicación.'; _loading = false; });
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isActive(Map<String, dynamic> m) {
    final end = m['endAt']?.toString();
    if (end == null || end.isEmpty) return true;
    final d = DateTime.tryParse(end);
    if (d == null) return true;
    return !d.isBefore(DateTime.now());
  }

  Future<void> _openAddDialog() async {
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    DateTime start = DateTime.now();
    DateTime? end;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Registrar medicación'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Medicamento *')),
                TextField(controller: doseCtrl, decoration: const InputDecoration(labelText: 'Dosis (ej: 1 tableta)')),
                TextField(controller: freqCtrl, decoration: const InputDecoration(labelText: 'Frecuencia (ej: cada 12h)')),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Inicio'),
                  subtitle: Text(_fmt(start)),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final d = await showDatePicker(context: ctx, initialDate: start, firstDate: DateTime(2010), lastDate: DateTime(2100));
                    if (d != null) setD(() => start = d);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fin (opcional)'),
                  subtitle: Text(end == null ? 'Sin definir' : _fmt(end!)),
                  trailing: const Icon(Icons.event, size: 18),
                  onTap: () async {
                    final d = await showDatePicker(context: ctx, initialDate: start, firstDate: DateTime(2010), lastDate: DateTime(2100));
                    if (d != null) setD(() => end = d);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _brand, foregroundColor: Colors.white),
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
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
        'name': nameCtrl.text.trim(),
        if (doseCtrl.text.trim().isNotEmpty) 'dose': doseCtrl.text.trim(),
        if (freqCtrl.text.trim().isNotEmpty) 'frequency': freqCtrl.text.trim(),
        'startAt': _fmt(start),
        if (end != null) 'endAt': _fmt(end!),
      });
      await _load();
      _toast('Medicación registrada ✅');
    } catch (_) {
      _toast('No se pudo guardar');
    }
  }

  Future<void> _delete(Map<String, dynamic> m) async {
    try {
      await _service.remove(widget.petId, m['id'] as int);
      await _load();
      _toast('Registro eliminado');
    } catch (_) {
      _toast('No se pudo eliminar');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('💊 Medicación · ${widget.petName}'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Medicación'),
      ),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
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
      return ListView(children: const [
        SizedBox(height: 120),
        Icon(Icons.medication_outlined, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Center(child: Text('Sin medicación registrada.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _card(_items[i]),
    );
  }

  Widget _card(Map<String, dynamic> m) {
    final active = _isActive(m);
    final parts = <String>[];
    if ((m['dose']?.toString() ?? '').isNotEmpty) parts.add(m['dose'].toString());
    if ((m['frequency']?.toString() ?? '').isNotEmpty) parts.add(m['frequency'].toString());
    final range = m['endAt'] != null && m['endAt'].toString().isNotEmpty
        ? '${m['startAt']} → ${m['endAt']}'
        : 'Desde ${m['startAt']}';
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.medication, color: active ? _brand : Colors.grey),
        title: Row(children: [
          Expanded(child: Text(m['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: (active ? Colors.teal : Colors.grey).withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(active ? 'activo' : 'finalizado',
                style: TextStyle(color: active ? Colors.teal : Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (parts.isNotEmpty) Text(parts.join(' · ')),
            Text(range, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
        trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.grey), onPressed: () => _delete(m)),
      ),
    );
  }
}
