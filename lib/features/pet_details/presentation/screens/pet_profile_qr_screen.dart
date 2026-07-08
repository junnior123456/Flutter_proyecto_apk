/// Módulo 3 — Datos del expediente + Código QR de la mascota.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/services/profile_qr_service.dart';

class PetProfileQrScreen extends StatefulWidget {
  final int petId;
  final String petName;
  const PetProfileQrScreen({super.key, required this.petId, required this.petName});

  @override
  State<PetProfileQrScreen> createState() => _PetProfileQrScreenState();
}

class _PetProfileQrScreenState extends State<PetProfileQrScreen> {
  static const Color _brand = Color(0xFF6C63FF);
  final ProfileQrService _service = ProfileQrService();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _publicUid;

  final _speciesCtrl = TextEditingController();
  final _microchipCtrl = TextEditingController();
  DateTime? _birthDate;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _speciesCtrl.dispose();
    _microchipCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final pet = await _service.getPet(widget.petId);
      final uid = await _service.getPublicUid(widget.petId);
      if (!mounted) return;
      setState(() {
        _speciesCtrl.text = (pet['species'] ?? '').toString();
        _microchipCtrl.text = (pet['microchip'] ?? '').toString();
        final bd = pet['birthDate']?.toString();
        _birthDate = (bd != null && bd.isNotEmpty) ? DateTime.tryParse(bd) : null;
        _publicUid = uid;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() { _error = 'No se pudo cargar el expediente.'; _loading = false; });
    }
  }

  static String _fmt(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await _service.updateProfile(widget.petId, {
        'species': _speciesCtrl.text.trim(),
        'microchip': _microchipCtrl.text.trim(),
        if (_birthDate != null) 'birthDate': _fmt(_birthDate!),
      });
      _toast('Datos guardados ✅');
    } catch (_) {
      _toast('No se pudo guardar');
    } finally {
      if (mounted) setState(() => _saving = false);
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
        title: Text('🪪 Datos & QR · ${widget.petName}'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : (_error != null
              ? _errorView()
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _profileCard(),
                    const SizedBox(height: 18),
                    _qrCard(),
                  ],
                )),
    );
  }

  Widget _errorView() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('Reintentar')),
          ],
        ),
      );

  Widget _profileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Datos del expediente',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _speciesCtrl,
              decoration: const InputDecoration(labelText: 'Especie', hintText: 'Perro, Gato...'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _microchipCtrl,
              decoration: const InputDecoration(labelText: 'Microchip'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Fecha de nacimiento'),
              subtitle: Text(_birthDate == null ? 'Sin definir' : _fmt(_birthDate!)),
              trailing: const Icon(Icons.calendar_today, size: 18),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _birthDate ?? DateTime(2022),
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _birthDate = d);
              },
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _brand,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                icon: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.save),
                label: Text(_saving ? 'Guardando...' : 'Guardar datos'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _qrCard() {
    final url = _publicUid == null ? '' : _service.publicUrl(_publicUid!);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text('Código QR de la mascota',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 6),
            const Text(
              'Imprímelo o ponlo en el collar. Quien lo escanee verá una ficha pública para contactarte si tu mascota se pierde (sin datos médicos).',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: url.isEmpty
                  ? const SizedBox(height: 200, child: Center(child: Text('QR no disponible')))
                  : QrImageView(
                      data: url,
                      version: QrVersions.auto,
                      size: 210,
                      backgroundColor: Colors.white,
                    ),
            ),
            const SizedBox(height: 14),
            SelectableText(url, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: url));
                      _toast('Enlace copiado');
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copiar'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final uri = Uri.parse(url);
                      try {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      } catch (_) {
                        _toast('No se pudo abrir');
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Ver ficha'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
