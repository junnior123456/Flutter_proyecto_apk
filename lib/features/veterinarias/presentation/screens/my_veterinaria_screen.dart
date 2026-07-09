/// "Mi veterinaria": la cuenta VET crea/edita su ficha del directorio.
library;

import 'package:flutter/material.dart';
import '../../../../core/services/veterinaria_service.dart';

class MyVeterinariaScreen extends StatefulWidget {
  const MyVeterinariaScreen({super.key});

  @override
  State<MyVeterinariaScreen> createState() => _MyVeterinariaScreenState();
}

class _MyVeterinariaScreenState extends State<MyVeterinariaScreen> {
  static const Color _brand = Color(0xFFFF9800);
  final VeterinariaService _service = VeterinariaService();
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _ruc = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  final _whatsapp = TextEditingController();
  final _email = TextEditingController();
  final _hours = TextEditingController();
  final _description = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  int? _id; // null = todavía no tiene ficha
  bool _isVerified = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _ruc, _address, _phone, _whatsapp, _email, _hours, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final mine = await _service.listMine();
      if (!mounted) return;
      if (mine.isNotEmpty) _fill(mine.first);
      setState(() => _loading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _fill(Map<String, dynamic> v) {
    _id = v['id'] as int?;
    _isVerified = v['isVerified'] == true;
    _name.text = v['name']?.toString() ?? '';
    _ruc.text = v['ruc']?.toString() ?? '';
    _address.text = v['address']?.toString() ?? '';
    _phone.text = v['phone']?.toString() ?? '';
    _whatsapp.text = v['whatsapp']?.toString() ?? '';
    _email.text = v['email']?.toString() ?? '';
    _hours.text = v['openingHours']?.toString() ?? '';
    _description.text = v['description']?.toString() ?? '';
  }

  Map<String, dynamic> _payload() {
    String? nn(TextEditingController c) =>
        c.text.trim().isEmpty ? null : c.text.trim();
    return {
      'name': _name.text.trim(),
      'ruc': _ruc.text.trim(),
      if (nn(_address) != null) 'address': nn(_address),
      if (nn(_phone) != null) 'phone': nn(_phone),
      if (nn(_whatsapp) != null) 'whatsapp': nn(_whatsapp),
      if (nn(_email) != null) 'email': nn(_email),
      if (nn(_hours) != null) 'openingHours': nn(_hours),
      if (nn(_description) != null) 'description': nn(_description),
    };
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final saved = _id == null
          ? await _service.create(_payload())
          : await _service.update(_id!, _payload());
      if (!mounted) return;
      _fill(saved);
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ficha guardada ✅')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏥 Mi veterinaria'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Estado de verificación
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_isVerified ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(children: [
                      Icon(_isVerified ? Icons.verified : Icons.hourglass_bottom,
                          color: _isVerified ? Colors.green : Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _id == null
                              ? 'Aún no has registrado tu veterinaria. Complétala y guárdala.'
                              : _isVerified
                                  ? 'Tu veterinaria está verificada y visible en el directorio.'
                                  : 'Pendiente de verificación por el administrador. Aún no es pública.',
                          style: TextStyle(fontSize: 12, color: scheme.onSurface),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  _field(_name, 'Nombre de la veterinaria *',
                      validator: (v) =>
                          (v == null || v.trim().length < 3) ? 'Nombre muy corto' : null),
                  _field(_ruc, 'RUC *',
                      keyboard: TextInputType.number,
                      validator: (v) => (v == null || !isValidRuc(v))
                          ? 'RUC inválido (11 dígitos, dígito verificador correcto)'
                          : null),
                  _field(_address, 'Dirección'),
                  _field(_phone, 'Teléfono', keyboard: TextInputType.phone),
                  _field(_whatsapp, 'WhatsApp (con código país)', keyboard: TextInputType.phone),
                  _field(_email, 'Correo', keyboard: TextInputType.emailAddress,
                      validator: (v) => (v != null && v.trim().isNotEmpty && !v.contains('@'))
                          ? 'Correo inválido'
                          : null),
                  _field(_hours, 'Horario (ej: Lun-Sáb 9:00-19:00)'),
                  _field(_description, 'Descripción', maxLines: 3),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brand,
                        foregroundColor: Colors.white,
                      ),
                      icon: _saving
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.save),
                      label: Text(_id == null ? 'Registrar veterinaria' : 'Guardar cambios'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _field(
    TextEditingController c,
    String label, {
    TextInputType? keyboard,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }
}
