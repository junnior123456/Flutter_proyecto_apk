import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/pet_category.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validation_utils.dart';

class PetFormDialog extends StatefulWidget {
  final String tipo;
  const PetFormDialog({required this.tipo, super.key});

  @override
  State<PetFormDialog> createState() => _PetFormDialogState();
}

class _PetFormDialogState extends State<PetFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final ImageService _imageService = ImageService();
  final PetService _petService = PetService();
  
  // Campos del formulario
  String name = '';
  String description = '';
  String age = '';
  String breed = '';
  String gender = 'Macho';
  String size = 'Mediano';
  bool isVaccinated = false;
  bool isSterilized = false;
  String contactName = '';
  String contactPhone = '';
  String contactEmail = '';
  String address = '';
  
  // Nuevos campos
  PetCategory selectedCategory = PetCategory.dog;
  File? selectedImage;
  bool isUploadingImage = false;
  bool isSubmitting = false;

  /// 📸 Mostrar opciones para seleccionar imagen
  Future<void> _showImageSourceDialog() async {
    try {
      final selectedImageFile = await _imageService.showImageSourceDialog(context);
      
      if (selectedImageFile != null) {
        setState(() {
          selectedImage = selectedImageFile;
        });
      }
    } catch (e) {
      Logger.error('Error selecting image', tag: 'PetFormDialog', error: e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar imagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 📤 Enviar formulario
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    
    setState(() {
      isSubmitting = true;
    });

    try {
      Logger.petOperation('Submitting pet form', data: {
        'name': name,
        'category': selectedCategory.name,
        'tipo': widget.tipo,
      });

      final createdPet = await _petService.createPet(
        name: name,
        description: description,
        categoryId: selectedCategory.id,
        isRisk: widget.tipo == 'riesgo',
        imageFile: selectedImage,
        age: age,
        breed: breed,
        gender: gender,
        size: size,
        isVaccinated: isVaccinated,
        isSterilized: isSterilized,
        contactName: contactName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        address: address,
      );

      if (createdPet != null && mounted) {
        Logger.petOperation('Pet created successfully', petId: createdPet.id.toString());
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${createdPet.name} registrado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.of(context).pop(createdPet);
      }
    } catch (e) {
      Logger.error('Error submitting pet form', tag: 'PetFormDialog', error: e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 420,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header fijo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Formulario para ${widget.tipo}', style: Theme.of(context).textTheme.titleLarge),
                IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 8),
            // Contenido scrolleable
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Datos de la mascota', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      
                      // Selector de categoría
                      DropdownButtonFormField<PetCategory>(
                        value: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Categoría*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: PetCategory.values.where((cat) => cat != PetCategory.all).map((category) {
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
                            setState(() {
                              selectedCategory = value;
                            });
                          }
                        },
                        validator: (value) => value == null ? 'Seleccione una categoría' : null,
                      ),
                      const SizedBox(height: 12),

                      // Nombre
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nombre*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.pets),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                        onSaved: (value) => name = value ?? '',
                      ),
                      const SizedBox(height: 12),

                      // Descripción
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Descripción*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                          hintText: 'Describe a tu mascota...',
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Requerido';
                          if (value!.trim().length < 5) return 'Mínimo 5 caracteres';
                          return null;
                        },
                        onSaved: (value) => description = value ?? '',
                      ),
                      const SizedBox(height: 12),

                      // Imagen
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  selectedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : InkWell(
                                onTap: _showImageSourceDialog,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('Agregar foto', style: TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),

                      // Edad y Raza
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Edad',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.cake),
                              ),
                              onSaved: (value) => age = value ?? '',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Raza',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.pets),
                              ),
                              onSaved: (value) => breed = value ?? '',
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
                              value: gender,
                              decoration: const InputDecoration(
                                labelText: 'Género',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.wc),
                              ),
                              items: ['Macho', 'Hembra'].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
                              onChanged: (value) => setState(() => gender = value ?? 'Macho'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: size,
                              decoration: const InputDecoration(
                                labelText: 'Tamaño',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.straighten),
                              ),
                              items: ['Pequeño', 'Mediano', 'Grande'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                              onChanged: (value) => setState(() => size = value ?? 'Mediano'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Checkboxes
                      CheckboxListTile(
                        title: const Text('Vacunado'),
                        value: isVaccinated,
                        onChanged: (value) => setState(() => isVaccinated = value ?? false),
                      ),
                      CheckboxListTile(
                        title: const Text('Esterilizado'),
                        value: isSterilized,
                        onChanged: (value) => setState(() => isSterilized = value ?? false),
                      ),
                      const SizedBox(height: 12),

                      // Información de contacto
                      const Text('Información de contacto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Nombre de contacto*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Requerido' : null,
                        onSaved: (value) => contactName = value ?? '',
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Teléfono',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.phone),
                          hintText: 'Ej: 987654321 (opcional)',
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          // Solo validar si no está vacío
                          if (value != null && value.isNotEmpty) {
                            final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
                            if (cleanPhone.length < 7 || cleanPhone.length > 11) {
                              return 'Entre 7 y 11 dígitos';
                            }
                          }
                          return null;
                        },
                        onSaved: (value) => contactPhone = value ?? '',
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                          hintText: 'ejemplo@correo.com (opcional)',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          // Solo validar si no está vacío
                          if (value != null && value.isNotEmpty) {
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Email inválido';
                            }
                          }
                          return null;
                        },
                        onSaved: (value) => contactEmail = value ?? '',
                      ),
                      const SizedBox(height: 12),

                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Dirección*',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                          hintText: 'Ej: Lima, Perú',
                        ),
                        validator: (value) {
                          if (value?.isEmpty ?? true) return 'Requerido';
                          if (value!.trim().length < 5) return 'Mínimo 5 caracteres';
                          return null;
                        },
                        onSaved: (value) => address = value ?? '',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Botones de acción
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF9800),
                  ),
                  onPressed: isSubmitting ? null : _submit,
                  child: isSubmitting
                      ? const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Text('Guardando...'),
                          ],
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}