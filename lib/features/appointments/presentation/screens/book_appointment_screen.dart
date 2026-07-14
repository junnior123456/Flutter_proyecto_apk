import 'package:flutter/material.dart';
import '../../../../core/services/appointment_service.dart';

/// Reserva de cita con una veterinaria: fecha, hora y motivo.
class BookAppointmentScreen extends StatefulWidget {
  final int veterinariaId;
  final String veterinariaName;
  const BookAppointmentScreen({
    super.key,
    required this.veterinariaId,
    required this.veterinariaName,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final _service = AppointmentService();
  final _reason = TextEditingController();
  DateTime? _fecha;
  TimeOfDay? _hora;
  bool _enviando = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _pickFecha() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 120)),
    );
    if (d != null) setState(() => _fecha = d);
  }

  Future<void> _pickHora() async {
    final t = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (t != null) setState(() => _hora = t);
  }

  Future<void> _reservar() async {
    if (_fecha == null || _hora == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Elige fecha y hora')),
      );
      return;
    }
    if (_reason.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escribe el motivo de la cita')),
      );
      return;
    }
    final cuando = DateTime(
      _fecha!.year, _fecha!.month, _fecha!.day, _hora!.hour, _hora!.minute,
    );
    setState(() => _enviando = true);
    final r = await _service.book(
      veterinariaId: widget.veterinariaId,
      scheduledAt: cuando,
      reason: _reason.text.trim(),
    );
    if (!mounted) return;
    setState(() => _enviando = false);
    if (r != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Cita solicitada! La veterinaria la confirmará.')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo reservar. Revisa la fecha (debe ser futura).')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    two(int n) => n.toString().padLeft(2, '0');
    return Scaffold(
      appBar: AppBar(title: const Text('Reservar cita')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(widget.veterinariaName,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(_fecha == null
                ? 'Elegir fecha'
                : '${two(_fecha!.day)}/${two(_fecha!.month)}/${_fecha!.year}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickFecha,
          ),
          ListTile(
            leading: const Icon(Icons.access_time),
            title: Text(_hora == null
                ? 'Elegir hora'
                : '${two(_hora!.hour)}:${two(_hora!.minute)}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: _pickHora,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Motivo de la cita',
              hintText: 'Ej: vacuna anual, control, síntomas…',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _enviando ? null : _reservar,
            icon: _enviando
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.event_available),
            label: Text(_enviando ? 'Enviando…' : 'Solicitar cita'),
          ),
        ],
      ),
    );
  }
}
