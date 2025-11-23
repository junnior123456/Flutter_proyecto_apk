import 'package:flutter/material.dart';

class RejectRequestDialog extends StatefulWidget {
  final Map<String, dynamic> request;

  const RejectRequestDialog({super.key, required this.request});

  @override
  State<RejectRequestDialog> createState() => _RejectRequestDialogState();
}

class _RejectRequestDialogState extends State<RejectRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, _reasonController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final adopter = widget.request['adopter'] as Map<String, dynamic>?;
    final pet = widget.request['pet'] as Map<String, dynamic>?;
    final adopterName = '${adopter?['name'] ?? ''} ${adopter?['lastname'] ?? ''}'.trim();
    final petName = pet?['name'] ?? 'la mascota';

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.cancel, color: Colors.red, size: 28),
          SizedBox(width: 12),
          Text('Rechazar Solicitud'),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Vas a rechazar la solicitud de $adopterName para adoptar a $petName.',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
              const Text(
                '📝 Razón del rechazo *',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                maxLength: 300,
                decoration: InputDecoration(
                  hintText: 'Ej: La mascota ya fue adoptada por otra persona. Gracias por tu interés.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa una razón';
                  }
                  if (value.trim().length < 10) {
                    return 'La razón debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 4),
              const Text(
                '* Campo obligatorio',
                style: TextStyle(fontSize: 12, color: Colors.grey, fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El adoptante verá la razón del rechazo',
                        style: TextStyle(fontSize: 12, color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _handleConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Confirmar Rechazo'),
        ),
      ],
    );
  }
}
