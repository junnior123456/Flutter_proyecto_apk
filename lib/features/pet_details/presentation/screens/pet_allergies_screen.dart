/// Módulo 3 — Alergias de la mascota.
import 'package:flutter/material.dart';
import '../../../../core/services/allergy_service.dart';

class PetAllergiesScreen extends StatefulWidget {
  final int petId;
  final String petName;
  const PetAllergiesScreen({super.key, required this.petId, required this.petName});

  @override
  State<PetAllergiesScreen> createState() => _PetAllergiesScreenState();
}

class _PetAllergiesScreenState extends State<PetAllergiesScreen> {
  static const Color _brand = Color(0xFF6C63FF);
  final AllergyService _service = AllergyService();

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
      setState(() { _error = 'No se pudieron cargar las alergias.'; _loading = false; });
    }
  }

  Color _sevColor(String s) {
    switch (s) {
      case 'grave': return Colors.red;
      case 'moderada': return Colors.orange;
      default: return Colors.teal;
    }
  }

  Future<void> _openAddDialog() async {
    final substanceCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String severity = 'leve';

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Registrar alergia'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: substanceCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Sustancia / alérgeno *',
                    hintText: 'Pollo, polen, penicilina...',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: severity,
                  decoration: const InputDecoration(labelText: 'Severidad'),
                  items: const [
                    DropdownMenuItem(value: 'leve', child: Text('Leve')),
                    DropdownMenuItem(value: 'moderada', child: Text('Moderada')),
                    DropdownMenuItem(value: 'grave', child: Text('Grave')),
                  ],
                  onChanged: (v) => setD(() => severity = v ?? 'leve'),
                ),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notas (opcional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _brand, foregroundColor: Colors.white),
              onPressed: () {
                if (substanceCtrl.text.trim().isEmpty) return;
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
        'substance': substanceCtrl.text.trim(),
        'severity': severity,
        if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
      });
      await _load();
      _toast('Alergia registrada ✅');
    } catch (_) {
      _toast('No se pudo guardar');
    }
  }

  Future<void> _delete(Map<String, dynamic> a) async {
    try {
      await _service.remove(widget.petId, a['id'] as int);
      await _load();
      _toast('Registro eliminado');
    } catch (_) {
      _toast('No se pudo eliminar');
    }
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('⚠️ Alergias · ${widget.petName}'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Alergia'),
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
        Icon(Icons.warning_amber_rounded, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Center(child: Text('Sin alergias registradas.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey))),
      ]);
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _card(_items[i]),
    );
  }

  Widget _card(Map<String, dynamic> a) {
    final sev = (a['severity'] ?? 'leve').toString();
    final color = _sevColor(sev);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: color),
        title: Text(a['substance']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: (a['notes']?.toString() ?? '').isEmpty ? null : Text(a['notes'].toString()),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
              child: Text(sev, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            IconButton(icon: const Icon(Icons.delete_outline, color: Colors.grey), onPressed: () => _delete(a)),
          ],
        ),
      ),
    );
  }
}
