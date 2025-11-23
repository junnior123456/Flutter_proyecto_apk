import 'package:flutter/material.dart';

class AcceptRequestDialog extends StatefulWidget {
  final Map<String, dynamic> request;

  const AcceptRequestDialog({super.key, required this.request});

  @override
  State<AcceptRequestDialog> createState() => _AcceptRequestDialogState();
}

class _AcceptRequestDialogState extends State<AcceptRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'message': _messageController.text.trim(),
      });
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
          Icon(Icons.check_circle, color: Colors.green, size: 28),
          SizedBox(width: 12),
          Text('Aceptar Solicitud'),
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
                'Vas a aceptar la solicitud de $adopterName para adoptar a $petName.',
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 20),
              const Text(
                '💬 Mensaje para el adoptante',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: 'Ej: Puedes venir mañana a las 3pm. Trae documentos de identidad...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Por favor ingresa un mensaje';
                  }
                  if (value.trim().length < 10) {
                    return 'El mensaje debe tener al menos 10 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'El adoptante recibirá tu mensaje y podrá contactarte',
                        style: TextStyle(fontSize: 12, color: Colors.blue),
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
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
          child: const Text('Confirmar Aceptación'),
        ),
      ],
    );
  }
}
