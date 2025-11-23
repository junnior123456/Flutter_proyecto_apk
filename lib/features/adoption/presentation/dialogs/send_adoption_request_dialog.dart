import 'package:flutter/material.dart';
import '../../../../domain/entities/pet.dart';

class SendAdoptionRequestDialog extends StatefulWidget {
  final Pet pet;

  const SendAdoptionRequestDialog({super.key, required this.pet});

  @override
  State<SendAdoptionRequestDialog> createState() => _SendAdoptionRequestDialogState();
}

class _SendAdoptionRequestDialogState extends State<SendAdoptionRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _personalInfoController = TextEditingController();
  final _livingSituationController = TextEditingController();
  final _adoptionReasonController = TextEditingController();
  final _previousExperienceController = TextEditingController();
  
  bool _hasYard = false;
  bool _hasOtherPets = false;

  @override
  void dispose() {
    _personalInfoController.dispose();
    _livingSituationController.dispose();
    _adoptionReasonController.dispose();
    _previousExperienceController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(context, {
        'personalInfo': _personalInfoController.text.trim(),
        'livingSituation': _livingSituationController.text.trim(),
        'adoptionReason': _adoptionReasonController.text.trim(),
        'previousExperience': _previousExperienceController.text.trim(),
        'hasYard': _hasYard,
        'hasOtherPets': _hasOtherPets,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título
                Row(
                  children: [
                    const Icon(Icons.pets, color: Colors.orange, size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Solicitud de Adopción',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Para: ${widget.pet.name}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Información personal
                const Text(
                  '👤 Información Personal *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _personalInfoController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Nombre completo, edad, ocupación...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obligatorio';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Situación de vivienda
                const Text(
                  '🏠 Situación de Vivienda *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _livingSituationController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Casa propia, departamento, con familia...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obligatorio';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Motivo de adopción
                const Text(
                  '💭 ¿Por qué quieres adoptar? *',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _adoptionReasonController,
                  maxLines: 3,
                  maxLength: 300,
                  decoration: InputDecoration(
                    hintText: 'Cuéntanos por qué quieres adoptar a ${widget.pet.name}...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Campo obligatorio';
                    }
                    if (value.trim().length < 20) {
                      return 'Por favor, escribe al menos 20 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Experiencia previa (opcional)
                const Text(
                  '🐾 Experiencia con Mascotas (opcional)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _previousExperienceController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: '¿Has tenido mascotas antes?',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Checkboxes
                CheckboxListTile(
                  title: const Text('Tengo patio o jardín'),
                  value: _hasYard,
                  onChanged: (value) => setState(() => _hasYard = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                
                CheckboxListTile(
                  title: const Text('Tengo otras mascotas'),
                  value: _hasOtherPets,
                  onChanged: (value) => setState(() => _hasOtherPets = value ?? false),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
                
                const SizedBox(height: 16),
                
                // Nota informativa
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
                          'El dueño revisará tu solicitud y te contactará',
                          style: TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Botones
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSend,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Enviar Solicitud'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
