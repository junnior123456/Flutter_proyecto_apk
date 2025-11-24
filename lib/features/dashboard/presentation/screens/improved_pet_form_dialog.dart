import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../domain/entities/pet_category.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/utils/logger.dart';

/// Formulario mejorado para publicar mascotas en adopción
/// Sigue Clean Architecture: Features/Dashboard/Presentation
class ImprovedPetFormDialog extends StatefulWidget {
  final String tipo; // 'adopción' o 'riesgo'
  
  const ImprovedPetFormDialog({
    required this.tipo,
    super.key,
  });

  @override
  State<ImprovedPetFormDialog> createState() => _ImprovedPetFormDialogState();
}

class _ImprovedPetFormDialogState extends State<ImprovedPetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ImageService();
  final _petService = PetService();
  final _authService = AuthService();
  
  // Controladores
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _contactNameController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactEmailController = TextEditingController();
  final _addressController = TextEditingController();
  final _additionalRequirementsController = TextEditingController();
  
  // Datos del formulario
  PetCategory _selectedCategory = PetCategory.dog;
  String _gender = 'Macho';
  String _size = 'Mediano';
  bool _isVaccinated = false;
  bool _isSterilized = false;
  
  // Requisitos de adopción
  bool _requiresOwnHome = false;
  bool _requiresSufficientSpace = false;
  bool _requiresStableEconomy = false;
  
  // Imágenes (máximo 5, mínimo 2)
  List<File> _selectedImages = [];
  bool _isSubmitting = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _contactNameController.dispose();
    _contactPhoneController.dispose();
    _contactEmailController.dispose();
    _addressController.dispose();
    _additionalRequirementsController.dispose();
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
      Logger.error('Error loading user data', tag: 'PetForm', error: e);
    }
  }

  /// 📸 Agregar imagen
  Future<void> _addImage() async {
    if (_selectedImages.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo 5 imágenes permitidas'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      final image = await _imageService.showImageSourceDialog(context);
      if (image != null && mounted) {
        setState(() {
          _selectedImages.add(image);
        });
      }
    } catch (e) {
      Logger.error('Error adding image', tag: 'PetForm', error: e);
    }
  }

  /// 🗑️ Eliminar imagen
  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  /// ✅ Validar y enviar formulario
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Prevenir doble envío
    if (_isSubmitting) {
      print('⚠️ Ya se está enviando el formulario, ignorando clic adicional');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Mostrar indicador de progreso
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 16),
                Text('Subiendo imagen y publicando...'),
              ],
            ),
            duration: Duration(seconds: 30),
            backgroundColor: Colors.orange,
          ),
        );
      }

      // Usar la primera imagen si existe, sino null
      final createdPet = await _petService.createPet(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        categoryId: _selectedCategory.id,
        isRisk: widget.tipo == 'riesgo',
        imageFile: _selectedImages.isNotEmpty ? _selectedImages.first : null,
        age: _ageController.text.trim(),
        breed: _breedController.text.trim(),
        gender: _gender,
        size: _size,
        isVaccinated: _isVaccinated,
        isSterilized: _isSterilized,
        contactName: _contactNameController.text.trim(),
        contactPhone: _contactPhoneController.text.trim(),
        contactEmail: _contactEmailController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (createdPet != null && mounted) {
        // Ocultar indicador de progreso
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        Navigator.pop(context, createdPet);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${createdPet.name} publicado exitosamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      Logger.error('Error submitting pet', tag: 'PetForm', error: e);
      if (mounted) {
        // Ocultar indicador de progreso
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        
        final errorMessage = e.toString();
        
        // Si es error de token, el interceptor ya lo manejó
        // Solo cerrar el formulario silenciosamente
        if (errorMessage.contains('Token expirado') || errorMessage.contains('401') || errorMessage.contains('UnauthorizedException')) {
          Navigator.pop(context); // Cerrar formulario
          return; // No mostrar más errores
        }
        
        // Detectar error de duplicado
        if (errorMessage.contains('Ya existe una mascota') || errorMessage.contains('CONFLICT') || errorMessage.contains('409')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('⚠️ Ya publicaste una mascota con este nombre recientemente. Espera unos minutos.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          return;
        }
        
        // Otros errores sí los mostramos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Error al publicar mascota. Intenta de nuevo.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } finally {
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
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 2) {
              setState(() => _currentStep++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.pop(context);
            }
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                    ),
                    child: Text(_currentStep == 2 ? 'Publicar' : 'Siguiente'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: Text(_currentStep == 0 ? 'Cancelar' : 'Atrás'),
                  ),
                ],
              ),
            );
          },
          steps: [
            // Paso 1: Datos de la mascota
            Step(
              title: const Text('Datos de la mascota'),
              isActive: _currentStep >= 0,
              state: _currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _buildPetDataStep(),
            ),
            
            // Paso 2: Imágenes
            Step(
              title: const Text('Fotos (opcional)'),
              isActive: _currentStep >= 1,
              state: _currentStep > 1 ? StepState.complete : StepState.indexed,
              content: _buildImagesStep(),
            ),
            
            // Paso 3: Contacto y requisitos
            Step(
              title: const Text('Contacto y requisitos'),
              isActive: _currentStep >= 2,
              content: _buildContactAndRequirementsStep(),
            ),
          ],
        ),
      ),
    );
  }

  /// 📝 Paso 1: Datos de la mascota
  Widget _buildPetDataStep() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Categoría
          DropdownButtonFormField<PetCategory>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Categoría*',
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
          
          // Nombre
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre*',
              prefixIcon: Icon(Icons.pets),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'El nombre es obligatorio';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          
          // Descripción
          TextFormField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Descripción*',
              prefixIcon: Icon(Icons.description),
              border: OutlineInputBorder(),
              hintText: 'Describe a la mascota...',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'La descripción es obligatoria';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          
          // Edad y Raza
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _ageController,
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                    prefixIcon: Icon(Icons.cake),
                    border: OutlineInputBorder(),
                    hintText: '2 años',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _breedController,
                  decoration: const InputDecoration(
                    labelText: 'Raza',
                    prefixIcon: Icon(Icons.pets),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Género y Tamaño
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Género',
                    prefixIcon: Icon(Icons.wc),
                    border: OutlineInputBorder(),
                  ),
                  items: ['Macho', 'Hembra'].map((g) {
                    return DropdownMenuItem(value: g, child: Text(g));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _gender = value);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _size,
                  decoration: const InputDecoration(
                    labelText: 'Tamaño',
                    prefixIcon: Icon(Icons.straighten),
                    border: OutlineInputBorder(),
                  ),
                  items: ['Pequeño', 'Mediano', 'Grande'].map((s) {
                    return DropdownMenuItem(value: s, child: Text(s));
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _size = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Vacunado y Esterilizado
          CheckboxListTile(
            title: const Text('Vacunado'),
            value: _isVaccinated,
            onChanged: (value) => setState(() => _isVaccinated = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          CheckboxListTile(
            title: const Text('Esterilizado'),
            value: _isSterilized,
            onChanged: (value) => setState(() => _isSterilized = value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ],
      ),
    );
  }

  /// 📸 Paso 2: Imágenes
  Widget _buildImagesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Agrega fotos de la mascota (opcional)',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        
        // Grid de imágenes
        if (_selectedImages.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: _selectedImages.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(24, 24),
                      ),
                      onPressed: () => _removeImage(index),
                    ),
                  ),
                  if (index == 0)
                    const Positioned(
                      bottom: 4,
                      left: 4,
                      child: Chip(
                        label: Text('Principal', style: TextStyle(fontSize: 10)),
                        backgroundColor: Colors.orange,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              );
            },
          ),
        
        const SizedBox(height: 16),
        
        // Botón agregar imagen
        if (_selectedImages.length < 5)
          OutlinedButton.icon(
            onPressed: _addImage,
            icon: const Icon(Icons.add_photo_alternate),
            label: Text('Agregar foto (${_selectedImages.length}/5)'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        
        // Mensaje informativo
        if (_selectedImages.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'ℹ️ Las fotos son opcionales pero recomendadas',
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
      ],
    );
  }

  /// 📞 Paso 3: Contacto y requisitos
  Widget _buildContactAndRequirementsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Información de contacto',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        // Nombre de contacto
        TextFormField(
          controller: _contactNameController,
          decoration: const InputDecoration(
            labelText: 'Nombre de contacto*',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'El nombre es obligatorio';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        
        // Teléfono
        TextFormField(
          controller: _contactPhoneController,
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        
        // Email
        TextFormField(
          controller: _contactEmailController,
          decoration: const InputDecoration(
            labelText: 'Email',
            prefixIcon: Icon(Icons.email),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        
        // Dirección
        TextFormField(
          controller: _addressController,
          decoration: const InputDecoration(
            labelText: 'Dirección*',
            prefixIcon: Icon(Icons.location_on),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'La dirección es obligatoria';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 24),
        const Text(
          'Requisitos para adoptar',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        
        // Requisitos
        CheckboxListTile(
          title: const Text('Casa propia'),
          subtitle: const Text('El adoptante debe tener casa propia'),
          value: _requiresOwnHome,
          onChanged: (value) => setState(() => _requiresOwnHome = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: const Text('Espacio suficiente'),
          subtitle: const Text('Espacio adecuado para la mascota'),
          value: _requiresSufficientSpace,
          onChanged: (value) => setState(() => _requiresSufficientSpace = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        CheckboxListTile(
          title: const Text('Economía estable'),
          subtitle: const Text('Capacidad económica para cuidar la mascota'),
          value: _requiresStableEconomy,
          onChanged: (value) => setState(() => _requiresStableEconomy = value ?? false),
          controlAffinity: ListTileControlAffinity.leading,
        ),
        
        const SizedBox(height: 12),
        
        // Requisitos adicionales
        TextFormField(
          controller: _additionalRequirementsController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Requisitos adicionales (opcional)',
            border: OutlineInputBorder(),
            hintText: 'Otros requisitos específicos...',
          ),
        ),
      ],
    );
  }
}
