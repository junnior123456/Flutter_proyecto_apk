/// Módulo 3 — Historia clínica de la mascota.
import 'package:flutter/material.dart';
import '../../../../core/services/medical_record_service.dart';

class PetMedicalRecordsScreen extends StatefulWidget {
  final int petId;
  final String petName;
  const PetMedicalRecordsScreen({super.key, required this.petId, required this.petName});

  @override
  State<PetMedicalRecordsScreen> createState() => _PetMedicalRecordsScreenState();
}

class _PetMedicalRecordsScreenState extends State<PetMedicalRecordsScreen> {
  static const Color _brand = Color(0xFF6C63FF);
  final MedicalRecordService _service = MedicalRecordService();

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
      setState(() { _error = 'No se pudo cargar la historia clínica.'; _loading = false; });
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  static const Map<String, String> _typeLabels = {
    'consulta': 'Consulta',
    'cirugia': 'Cirugía',
    'examen': 'Examen',
    'desparasitacion': 'Desparasitación',
    'otro': 'Otro',
  };

  static const Map<String, IconData> _typeIcons = {
    'consulta': Icons.medical_services_outlined,
    'cirugia': Icons.healing,
    'examen': Icons.biotech_outlined,
    'desparasitacion': Icons.bug_report_outlined,
    'otro': Icons.note_alt_outlined,
  };

  static const Map<String, Color> _typeColors = {
    'consulta': Color(0xFF3F51B5),
    'cirugia': Color(0xFFE53935),
    'examen': Color(0xFF00897B),
    'desparasitacion': Color(0xFFF57C00),
    'otro': Color(0xFF757575),
  };

  Future<void> _openAddDialog() async {
    final titleCtrl = TextEditingController();
    final vetCtrl = TextEditingController();
    final diagCtrl = TextEditingController();
    final treatCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String type = 'consulta';
    DateTime occurredAt = DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Registrar en la historia clínica'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: type,
                  decoration: const InputDecoration(labelText: 'Tipo'),
                  items: kMedicalRecordTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(_typeLabels[t] ?? t)))
                      .toList(),
                  onChanged: (v) => setD(() => type = v ?? 'consulta'),
                ),
                TextField(
                  controller: titleCtrl,
                  maxLength: 150,
                  decoration: const InputDecoration(labelText: 'Motivo o procedimiento *'),
                ),
                TextField(
                  controller: vetCtrl,
                  maxLength: 120,
                  decoration: const InputDecoration(labelText: 'Veterinario o clínica'),
                ),
                TextField(
                  controller: diagCtrl,
                  decoration: const InputDecoration(labelText: 'Diagnóstico'),
                  maxLines: 2,
                ),
                TextField(
                  controller: treatCtrl,
                  decoration: const InputDecoration(labelText: 'Tratamiento'),
                  maxLines: 2,
                ),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notas'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Fecha del evento'),
                  subtitle: Text(_fmt(occurredAt)),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: occurredAt,
                      firstDate: DateTime(2010),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setD(() => occurredAt = d);
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
                if (titleCtrl.text.trim().isEmpty) return;
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
        'type': type,
        'title': titleCtrl.text.trim(),
        'occurredAt': _fmt(occurredAt),
        if (vetCtrl.text.trim().isNotEmpty) 'vetName': vetCtrl.text.trim(),
        if (diagCtrl.text.trim().isNotEmpty) 'diagnosis': diagCtrl.text.trim(),
        if (treatCtrl.text.trim().isNotEmpty) 'treatment': treatCtrl.text.trim(),
        if (notesCtrl.text.trim().isNotEmpty) 'notes': notesCtrl.text.trim(),
      });
      await _load();
      _toast('Registro añadido ✅');
    } catch (_) {
      _toast('No se pudo guardar');
    }
  }

  Future<void> _delete(Map<String, dynamic> m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar el registro?'),
        content: Text(
          'Se borrará "${m['title']}" de la historia clínica de ${widget.petName}. Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true) return;
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
        title: Text('📋 Historia clínica · ${widget.petName}'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Registro'),
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
      final muted = Theme.of(context).colorScheme.onSurfaceVariant;
      return ListView(children: [
        const SizedBox(height: 120),
        Icon(Icons.folder_open_outlined, size: 56, color: muted),
        const SizedBox(height: 12),
        Center(
          child: Text(
            'Sin entradas en la historia clínica.\nRegistra consultas, cirugías o exámenes.',
            textAlign: TextAlign.center,
            style: TextStyle(color: muted),
          ),
        ),
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
    final scheme = Theme.of(context).colorScheme;
    final type = m['type']?.toString() ?? 'otro';
    final color = _typeColors[type] ?? _typeColors['otro']!;
    final vet = m['vetName']?.toString() ?? '';

    final details = <Widget>[];
    void addDetail(String label, String? value) {
      if (value == null || value.trim().isEmpty) return;
      details.add(Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: RichText(
          text: TextSpan(
            style: TextStyle(fontSize: 13, color: scheme.onSurface),
            children: [
              TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
              TextSpan(text: value),
            ],
          ),
        ),
      ));
    }

    addDetail('Diagnóstico', m['diagnosis']?.toString());
    addDetail('Tratamiento', m['treatment']?.toString());
    addDetail('Notas', m['notes']?.toString());

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Theme(
        // ExpansionTile pinta su propia línea divisoria; la quitamos.
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.14),
            child: Icon(_typeIcons[type] ?? Icons.note_alt_outlined, color: color, size: 20),
          ),
          title: Text(
            m['title']?.toString() ?? '',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _typeLabels[type] ?? type,
                    style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  m['occurredAt']?.toString() ?? '',
                  style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                ),
              ]),
              if (vet.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('🏥 $vet',
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ),
            ],
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Sin detalles adicionales.',
                    style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
              )
            else
              ...details,
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _delete(m),
                icon: const Icon(Icons.delete_outline, size: 18),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                label: const Text('Eliminar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
