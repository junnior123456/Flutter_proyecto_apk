import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../domain/entities/pet_category.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/logger.dart';

/// 🚨 Formulario específico para reportar animales en riesgo
/// Incluye requisitos de responsabilidad y validaciones estrictas
class RiskPetFormDialog extends StatefulWidget {
  const RiskPetFormDialog({super.key});

  @override
  State<RiskPetFormDialog> createState() => _RiskPetFormDialogState();
}

class _RiskPetFormDialogState extends State<RiskPetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();
  final _petService = PetService();
  final _authService = AuthService();
  
  // Controladores
  final _descriptionController = TextEditingController();
  final _conditionController = TextEditingController();
  final _addressController = TextEditingController();
  final _referenceController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  
  // Datos del formulario
  PetCategory _selectedCategory = PetCategory.dog;
  File? _selectedImage;
  bool _isSubmitting = false;
  
  // ✅ Requisitos de responsabilidad (TODOS OBLIGATORIOS)
  bool _acceptRealCase = false;
  bool _acceptVerifiableInfo = false;
  bool _acceptContactAvailable = false;
  bool _acceptClearLocation = false;
  bool _acceptAvailableToRespond = false;
  bool _acceptResponsibleUse = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _conditionController.dispose();
    _addressController.dispose();
    _referenceController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    super.dispose();
  }

  /// 👤 Cargar datos del usuario autenticado
  Future<void> _loadUserData() async {
    try {
      final userData = await _authService.getCurrentUser();
      
      if (userData != null && mounted) {
        setState(() {
          _contactNameController.text = '${userData['name'] ?? ''} ${userData['lastname'] ?? ''}'.trim();
          _contactPhoneController.text = userData['phone'] ?? '';
          _contactEmailController.text = userData['email'] ?? '';
          _addressController.text = userData['address'] ?? '';
        });
      }
    } catch (e) {
      Logger.error('Error loading user data', tag: 'RiskPetForm', error: e);
    }
  }

  /// 📸 Seleccionar imagen
  Future<void> _selectImage() async {
    try {
      final image = await _imageService.showImageSourceDialog(context);
      if (image != null && mounted) {
        setState(() {
          _selectedImage = image;
        });
      }
    } catch (e) {
      Logger.error('Error selecting image', tag: 'RiskPetForm', error: e);
    }
  }

  /// ✅ Validar que todos los requisitos estén aceptados
  bool _validateRequirements() {
    return _acceptRealCase &&
           _acceptVerifiableInfo &&
           _acceptContactAvailable &&
           _acceptClearLocation &&
           _acceptAvailableToRespond &&
           _acceptResponsibleUse;
  }

  /// 📤 Enviar formulario
  Future<void> _submit() async {
    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor completa todos los campos obligatorios'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validar requisitos
    if (!_validateRequirements()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar todos los requisitos para continuar'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final createdPet = await _petService.createPet(
        name: 'Animal en riesgo - ${_selectedCategory.displayName}',
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory.id,
        isRisk: true,
        imageFile: _selectedImage,
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        address: _addressController.text.trim(),
        // Campos adicionales específicos de riesgo
        breed: _conditionController.text.trim(), // Usamos breed para guardar condición
        age: _referenceController.text.trim(), // Usamos age para guardar referencia
      );

      if (createdPet != null && mounted) {
        Navigator.pop(context, createdPet);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Caso reportado exitosamente. Gracias por ayudar.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      Logger.error('Error submitting risk pet', tag: 'RiskPetForm', error: e);
      if (mounted) {
        final errorMessage = e.toString();
        
        // Si es error de token, el interceptor ya lo manejó
        // Solo cerrar el formulario silenciosamente
        if (errorMessage.contains('Token expirado') || errorMessage.contains('401') || errorMessage.contains('UnauthorizedException')) {
          Navigator.pop(context); // Cerrar formulario
          return; // No mostrar más errores
        }
        
        // Otros errores sí los mostramos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al reportar el caso'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally{
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
                color: Colors.red[50],
                border: Border(
                  bottom: BorderSide(color: Colors.red[200]!),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reportar Animal en Riesgo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                        ),
                        Text(
                          'Ayúdanos a usar la app de forma responsable',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
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
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mensaje de responsabilidad
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.orange[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Solo publica casos reales de animales que estén en peligro o en malas condiciones.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.orange[900],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // SECCIÓN 1: Datos del animal en riesgo
                      _buildSectionTitle('Datos del animal en riesgo'),
                      const SizedBox(height: 12),
                      
                      // Categoría
                      DropdownButtonFormField<PetCategory>(
                        initialValue: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Tipo de animal*',
                          prefixIcon: Icon(Icons.category),
                          border: OutlineInputBorder(),
                        ),
                        items: PetCategory.values.where((c) => c != PetCategory.all).map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Text(category.emoji),
                                const SizedBox(width: 8),
                                Text(category.displayName),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedCategory = value);
                          }
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Descripción del caso
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Descripción del caso*',
                          prefixIcon: Icon(Icons.description),
                          border: OutlineInputBorder(),
                          hintText: 'Describe con detalle la situación del animal: ¿Qué le pasó? ¿Dónde está? ¿Qué ayuda necesita?',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La descripción es obligatoria';
                          }
                          if (value.trim().length < 20) {
                            return 'Describe el caso con más detalle (mínimo 20 caracteres)';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Condición actual
                      TextFormField(
                        controller: _conditionController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Condición actual del animal*',
                          prefixIcon: Icon(Icons.medical_services),
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Herido, desnutrido, abandonado, maltratado, etc.',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Describe la condición del animal';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Foto del caso
                      Container(
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _selectedImage != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      icon: const Icon(Icons.close, color: Colors.white),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () => setState(() => _selectedImage = null),
                                    ),
                                  ),
                                ],
                              )
                            : InkWell(
                                onTap: _selectImage,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 48, color: Colors.grey[400]),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Agregar foto del caso',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '(Opcional pero recomendado)',
                                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // SECCIÓN 2: Ubicación del caso
                      _buildSectionTitle('Ubicación del caso'),
                      const SizedBox(height: 12),
                      
                      // Dirección
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: 'Dirección exacta*',
                          prefixIcon: Icon(Icons.location_on),
                          border: OutlineInputBorder(),
                          hintText: 'Calle, número, distrito, ciudad',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La dirección es obligatoria';
                          }
                          if (value.trim().length < 10) {
                            return 'Proporciona una dirección más específica';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Referencia
                      TextFormField(
                        controller: _referenceController,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Referencia del lugar*',
                          prefixIcon: Icon(Icons.place),
                          border: OutlineInputBorder(),
                          hintText: 'Ej: Frente al parque, al lado de la tienda, cerca del mercado',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'La referencia es obligatoria';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // SECCIÓN 3: Información de contacto
                      _buildSectionTitle('Información de contacto'),
                      const SizedBox(height: 12),
                      
                      // Nombre de contacto
                      TextFormField(
                        controller: _contactNameController,
                        decoration: const InputDecoration(
                          labelText: 'Tu nombre completo*',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Tu nombre es obligatorio';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // WhatsApp/Teléfono
                      TextFormField(
                        controller: _contactPhoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'WhatsApp / Teléfono*',
                          prefixIcon: Icon(Icons.phone),
                          border: OutlineInputBorder(),
                          hintText: 'Para coordinar el rescate',
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'El teléfono es obligatorio';
                          }
                          final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                          if (cleanPhone.length < 7) {
                            return 'Teléfono inválido';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Email (opcional)
                      TextFormField(
                        controller: _contactEmailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email (opcional)',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Email inválido';
                            }
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // SECCIÓN 4: Requisitos para registrar el caso
                      _buildSectionTitle('Requisitos para registrar un animal en riesgo'),
                      const SizedBox(height: 8),
                      
                      Text(
                        'Completa los datos con la mayor precisión posible y acepta los requisitos mínimos para que los rescatistas puedan ayudarte.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Checkboxes de requisitos
                      _buildRequirementCheckbox(
                        value: _acceptRealCase,
                        onChanged: (value) => setState(() => _acceptRealCase = value ?? false),
                        title: 'Caso real y reciente',
                        subtitle: 'Confirmo que la situación del animal es real y ha ocurrido hace poco tiempo.',
                      ),
                      
                      _buildRequirementCheckbox(
                        value: _acceptVerifiableInfo,
                        onChanged: (value) => setState(() => _acceptVerifiableInfo = value ?? false),
                        title: 'Información verificable',
                        subtitle: 'Me comprometo a describir con la verdad lo que vi (sin exagerar ni inventar).',
                      ),
                      
                      _buildRequirementCheckbox(
                        value: _acceptContactAvailable,
                        onChanged: (value) => setState(() => _acceptContactAvailable = value ?? false),
                        title: 'Contacto disponible',
                        subtitle: 'Acepto que se use mi número de WhatsApp/teléfono como contacto para coordinar el rescate.',
                      ),
                      
                      _buildRequirementCheckbox(
                        value: _acceptClearLocation,
                        onChanged: (value) => setState(() => _acceptClearLocation = value ?? false),
                        title: 'Ubicación clara',
                        subtitle: 'Puedo proporcionar dirección y referencia exacta del lugar donde está el animal.',
                      ),
                      
                      _buildRequirementCheckbox(
                        value: _acceptAvailableToRespond,
                        onChanged: (value) => setState(() => _acceptAvailableToRespond = value ?? false),
                        title: 'Disponibilidad para responder',
                        subtitle: 'Estoy dispuesto(a) a responder mensajes o llamadas de las personas que quieran ayudar.',
                      ),
                      
                      _buildRequirementCheckbox(
                        value: _acceptResponsibleUse,
                        onChanged: (value) => setState(() => _acceptResponsibleUse = value ?? false),
                        title: 'Uso responsable de la app',
                        subtitle: 'Entiendo que subir información falsa, bromas o casos duplicados puede causar bloqueos en mi cuenta.',
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Advertencia final
                      if (!_validateRequirements())
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[700], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Debes aceptar todos los requisitos para poder reportar el caso',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red[900],
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(_isSubmitting ? 'Reportando...' : 'Reportar Caso'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📋 Widget para título de sección
  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.red[600],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  /// ✅ Widget para checkbox de requisito
  Widget _buildRequirementCheckbox({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border.all(
          color: value ? Colors.green[300]! : Colors.grey[300]!,
          width: value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: value ? Colors.green[50] : Colors.white,
      ),
      child: CheckboxListTile(
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.green[700],
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: value ? Colors.green[900] : Colors.grey[800],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: value ? Colors.green[800] : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }
}
