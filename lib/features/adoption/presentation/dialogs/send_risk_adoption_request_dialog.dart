import 'package:flutter/material.dart';
import '../../../../domain/entities/pet.dart';

/// Diálogo especializado para solicitudes de adopción de animales en riesgo
class SendRiskAdoptionRequestDialog extends StatefulWidget {
  final Pet pet;

  const SendRiskAdoptionRequestDialog({super.key, required this.pet});

  @override
  State<SendRiskAdoptionRequestDialog> createState() => _SendRiskAdoptionRequestDialogState();
}

class _SendRiskAdoptionRequestDialogState extends State<SendRiskAdoptionRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  // Campos separados para información personal
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _occupationController = TextEditingController();
  // Campos de vivienda
  final _housingTypeController = TextEditingController();
  final _housingConditionsController = TextEditingController();
  // Otros campos
  final _adoptionReasonController = TextEditingController();
  final _rescuePlanController = TextEditingController();
  final _medicalCareController = TextEditingController();
  final _previousExperienceController = TextEditingController();
  
  bool _hasYard = false;
  bool _hasOtherPets = false;
  bool _canProvideMedicalCare = false;
  bool _hasTransportation = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _occupationController.dispose();
    _housingTypeController.dispose();
    _housingConditionsController.dispose();
    _adoptionReasonController.dispose();
    _rescuePlanController.dispose();
    _medicalCareController.dispose();
    _previousExperienceController.dispose();
    super.dispose();
  }

  void _handleSend() {
    if (_formKey.currentState!.validate()) {
      // Combinar información personal en un solo string para el backend
      final personalInfo = '${_fullNameController.text.trim()}, ${_ageController.text.trim()} años, ${_occupationController.text.trim()}';
      final livingSituation = '${_housingTypeController.text.trim()} - ${_housingConditionsController.text.trim()}';
      
      Navigator.pop(context, {
        'personalInfo': personalInfo,
        'livingSituation': livingSituation,
        'adoptionReason': _adoptionReasonController.text.trim(),
        'rescuePlan': _rescuePlanController.text.trim(),
        'medicalCare': _medicalCareController.text.trim(),
        'previousExperience': _previousExperienceController.text.trim(),
        'hasYard': _hasYard,
        'hasOtherPets': _hasOtherPets,
        'canProvideMedicalCare': _canProvideMedicalCare,
        'hasTransportation': _hasTransportation,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border(
                  bottom: BorderSide(color: Colors.orange[200]!),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.volunteer_activism, color: Colors.orange[700], size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Solicitud de Adopción',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange[900],
                          ),
                        ),
                        Text(
                          'Para: ${widget.pet.name}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mensaje informativo
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Este animal necesita ayuda urgente. Describe cómo planeas rescatarlo y cuidarlo.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Información personal
                      _buildSectionTitle('Información Personal'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          labelText: 'Nombre completo *',
                          hintText: 'Ej: Juan Pérez García',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.person),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El nombre es obligatorio';
                          }
                          if (value.trim().length < 3) {
                            return 'Ingresa tu nombre completo';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Edad *',
                                hintText: '28',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.cake),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Requerido';
                                }
                                final age = int.tryParse(value);
                                if (age == null || age < 18 || age > 100) {
                                  return 'Edad inválida';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _occupationController,
                              decoration: InputDecoration(
                                labelText: 'Ocupación *',
                                hintText: 'Ingeniero',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                prefixIcon: const Icon(Icons.work),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'La ocupación es obligatoria';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Situación de vivienda
                      _buildSectionTitle('Situación de Vivienda'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _housingTypeController,
                        decoration: InputDecoration(
                          labelText: 'Tipo de vivienda *',
                          hintText: 'Ej: Casa propia, Departamento, Casa alquilada',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.home),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      TextFormField(
                        controller: _housingConditionsController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Condiciones de la vivienda *',
                          hintText: 'Ej: Amplia, con jardín, 3 habitaciones, zona tranquila',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.home_work),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Describe las condiciones de tu vivienda';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Motivo de adopción
                      _buildSectionTitle('¿Por qué quieres adoptar?'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _adoptionReasonController,
                        maxLines: 3,
                        maxLength: 300,
                        decoration: InputDecoration(
                          labelText: 'Cuéntanos tu motivación *',
                          hintText: 'Cuéntanos por qué quieres adoptar a ${widget.pet.name}...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.chat_bubble_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.trim().length < 20) {
                            return 'Por favor, escribe al menos 20 caracteres';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Plan de rescate (ESPECÍFICO PARA RIESGO)
                      _buildSectionTitle('Plan de Rescate y Cuidado'),
                      const SizedBox(height: 8),
                      Text(
                        'Describe cómo sacarás al animal de su situación de riesgo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _rescuePlanController,
                        maxLines: 4,
                        maxLength: 400,
                        decoration: InputDecoration(
                          labelText: 'Plan de rescate *',
                          hintText: 'Ej: Iré al lugar indicado con transporte, lo llevaré al veterinario inmediatamente, tengo espacio preparado en casa...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.medical_services),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio para animales en riesgo';
                          }
                          if (value.trim().length < 30) {
                            return 'Describe tu plan con más detalle (mínimo 30 caracteres)';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Atención médica (ESPECÍFICO PARA RIESGO)
                      _buildSectionTitle('Atención Médica'),
                      const SizedBox(height: 8),
                      Text(
                        '¿Cómo atenderás las necesidades médicas del animal?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _medicalCareController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Plan de atención médica *',
                          hintText: 'Ej: Tengo veterinario de confianza, puedo costear tratamientos, tengo experiencia con animales heridos...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.local_hospital),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Este campo es obligatorio';
                          }
                          if (value.trim().length < 20) {
                            return 'Describe tu plan médico con más detalle';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Experiencia previa
                      _buildSectionTitle('Experiencia con Mascotas'),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _previousExperienceController,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: '¿Has tenido mascotas antes? (opcional)',
                          hintText: 'Ej: He tenido 2 perros rescatados, experiencia con animales heridos',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          prefixIcon: const Icon(Icons.pets),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Checkboxes
                      _buildSectionTitle('Condiciones Adicionales'),
                      const SizedBox(height: 12),
                      
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            CheckboxListTile(
                              title: const Text('Tengo patio o jardín'),
                              value: _hasYard,
                              onChanged: (value) => setState(() => _hasYard = value ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            CheckboxListTile(
                              title: const Text('Tengo otras mascotas'),
                              value: _hasOtherPets,
                              onChanged: (value) => setState(() => _hasOtherPets = value ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            CheckboxListTile(
                              title: const Text('Puedo costear atención veterinaria'),
                              value: _canProvideMedicalCare,
                              onChanged: (value) => setState(() => _canProvideMedicalCare = value ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            Divider(height: 1, color: Colors.grey[300]),
                            CheckboxListTile(
                              title: const Text('Tengo transporte disponible'),
                              value: _hasTransportation,
                              onChanged: (value) => setState(() => _hasTransportation = value ?? false),
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Nota final
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'El publicador revisará tu solicitud y te contactará para coordinar el rescate',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Botones de acción
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
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
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _handleSend,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.send),
                      label: const Text('Enviar Solicitud'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: Colors.orange[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
