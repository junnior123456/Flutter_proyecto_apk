/// Módulo 3 — Control de peso de la mascota.
/// Muestra el peso actual, la variación y el historial; permite registrar / eliminar.
import 'package:flutter/material.dart';
import '../../../../core/services/weight_service.dart';

class PetWeightsScreen extends StatefulWidget {
  final int petId;
  final String petName;
  const PetWeightsScreen({
    super.key,
    required this.petId,
    required this.petName,
  });

  @override
  State<PetWeightsScreen> createState() => _PetWeightsScreenState();
}

class _PetWeightsScreenState extends State<PetWeightsScreen> {
  static const Color _brand = Color(0xFF6C63FF);
  final WeightService _service = WeightService();

  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _items = []; // orden ascendente por fecha

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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'No se pudo cargar el peso.';
        _loading = false;
      });
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  double _kg(Map<String, dynamic> m) =>
      (m['weightKg'] is num) ? (m['weightKg'] as num).toDouble() : 0;

  Future<void> _openAddDialog() async {
    final weightCtrl = TextEditingController();
    DateTime measured = DateTime.now();

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          title: const Text('Registrar peso'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Peso (kg) *',
                  hintText: 'Ej: 12.5',
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de medición'),
                subtitle: Text(_fmt(measured)),
                trailing: const Icon(Icons.calendar_today, size: 18),
                onTap: () async {
                  final d = await showDatePicker(
                    context: ctx,
                    initialDate: measured,
                    firstDate: DateTime(2010),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) setD(() => measured = d);
                },
              ),
            ],
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
                final v = double.tryParse(weightCtrl.text.replaceAll(',', '.'));
                if (v == null || v <= 0) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (saved != true) return;
    final v = double.tryParse(weightCtrl.text.replaceAll(',', '.'));
    if (v == null) return;
    try {
      await _service.add(widget.petId, {
        'weightKg': v,
        'measuredAt': _fmt(measured),
      });
      await _load();
      _toast('Peso registrado ✅');
    } catch (_) {
      _toast('No se pudo guardar el peso');
    }
  }

  Future<void> _delete(Map<String, dynamic> w) async {
    try {
      await _service.remove(widget.petId, w['id'] as int);
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
        title: Text('⚖️ Peso · ${widget.petName}'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDialog,
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Peso'),
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
        Icon(Icons.monitor_weight_outlined, size: 56, color: Colors.grey),
        SizedBox(height: 12),
        Center(
          child: Text('Aún no hay registros de peso.\nToca "Peso" para agregar el primero.',
              textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
        ),
      ]);
    }

    final last = _items.last;
    final prev = _items.length >= 2 ? _items[_items.length - 2] : null;
    final delta = prev != null ? _kg(last) - _kg(prev) : 0.0;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _currentCard(_kg(last), last['measuredAt']?.toString() ?? '', delta),
        const SizedBox(height: 18),
        const Text('Historial', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Historial más reciente primero
        ..._items.reversed.map(_historyRow),
      ],
    );
  }

  Widget _currentCard(double kg, String date, double delta) {
    final up = delta > 0.05, down = delta < -0.05;
    final color = up ? Colors.orange : (down ? Colors.teal : Colors.grey);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Peso actual', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text('${kg.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        fontSize: 34, fontWeight: FontWeight.bold, color: _brand)),
                const SizedBox(width: 12),
                if (delta != 0)
                  Row(children: [
                    Icon(up ? Icons.trending_up : (down ? Icons.trending_down : Icons.trending_flat),
                        color: color, size: 20),
                    const SizedBox(width: 3),
                    Text('${delta > 0 ? '+' : ''}${delta.toStringAsFixed(1)} kg',
                        style: TextStyle(color: color, fontWeight: FontWeight.w600)),
                  ]),
              ],
            ),
            const SizedBox(height: 4),
            Text('Última medición: $date',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _historyRow(Map<String, dynamic> w) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.monitor_weight_outlined, color: _brand),
      title: Text('${_kg(w).toStringAsFixed(1)} kg',
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(w['measuredAt']?.toString() ?? ''),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.grey),
        onPressed: () => _delete(w),
      ),
    );
  }
}
