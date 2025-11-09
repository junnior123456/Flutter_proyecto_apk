import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../domain/entities/pet.dart';
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
  String imageUrl = '';
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
  String addressStreet = '';
  String addressCity = '';
  String addressState = ''; 
  bool submitted = false;
  
  // Nuevos campos
  PetCategory selectedCategory = PetCategory.dog;
  File? selectedImage;
  bool isUploadingImage = false;
  bool isSubmitting = false;

  /// 📸 Mostrar opciones para seleccionar imagen y subirla inmediatamente
  Future<void> _showImageSourceDialog() async {
    try {
      final selectedImageFile = await _imageService.showImageSourceDialog(context);

      if (selectedImageFile != null) {
        setState(() {
          selectedImage = selectedImageFile;
          isUploadingImage = true;
        });

        // Mostrar mensaje de subida
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 16),
                Text('Subiendo imagen a Firebase...'),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        // Subir imagen al backend que la subirá a Firebase
        Logger.imageOperation('Uploading image to Firebase via backend');
        final uploadedUrl = await _imageService.uploadToFirebase(
          selectedImageFile, 
          'pet_${DateTime.now().millisecondsSinceEpoch}',
          folder: 'pets'
        );

        if (uploadedUrl != null) {
          setState(() {
            imageUrl = uploadedUrl;
            isUploadingImage = false;
          });

          Logger.imageOperation('Image uploaded successfully', details: uploadedUrl, success: true);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 16),
                    Text('✅ Imagen subida exitosamente'),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() {
            imageUrl = selectedImageFile.path; // Fallback a path local
            isUploadingImage = false;
          });

          Logger.imageOperation('Image upload failed, using local path', success: false);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    SizedBox(width: 16),
                    Text('⚠️ Error subiendo imagen, usando archivo local'),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        isUploadingImage = false;
      });

      Logger.imageOperation('Error in image selection/upload process', success: false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Método removido - ahora se usa el widget ImagePickerDialog

  // Métodos removidos - ahora se usa el ImageService con Clean Architecture

  Future<void> _submit() async {
    // Validar formulario primero
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    _formKey.currentState?.save();

    // Validar datos usando ValidationUtils
    final validationErrors = ValidationUtils.validatePetData(
      name: name,
      description: description,
      categoryId: selectedCategory.id,
      age: age,
      breed: breed,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      address: '${addressStreet.trim()}, ${addressCity.trim()}, ${addressState.trim()}',
    );

    if (validationErrors.isNotEmpty) {
      final errorMessage = validationErrors.values.join('\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errores de validación:\n$errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Validar que se haya seleccionado una imagen
    if (selectedImage == null && imageUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona una foto de la mascota'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Seleccionar',
            textColor: Colors.white,
            onPressed: _showImageSourceDialog,
          ),
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      Logger.petOperation('Submitting pet form', data: {
        'name': name,
        'category': selectedCategory.name,
        'isRisk': widget.tipo == 'riesgo',
        'hasImage': selectedImage != null,
      });

      // Crear mascota usando la URL de Firebase ya subida
      final createdPet = await _petService.createPetWithImageUrl(
        name: ValidationUtils.cleanText(name),
        description: ValidationUtils.cleanText(description),
        categoryId: selectedCategory.id,
        isRisk: widget.tipo == 'riesgo',
        imageUrl: imageUrl.isNotEmpty ? imageUrl : null, // Usar la URL de Firebase
        age: age?.isNotEmpty == true ? ValidationUtils.cleanText(age!) : null,
        breed: breed?.isNotEmpty == true ? ValidationUtils.cleanText(breed!) : null,
        gender: gender,
        size: size,
        isVaccinated: isVaccinated,
        isSterilized: isSterilized,
        contactName: contactName?.isNotEmpty == true ? ValidationUtils.cleanText(contactName!) : null,
        contactPhone: contactPhone?.isNotEmpty == true ? ValidationUtils.formatPhone(contactPhone!) : null,
        contactEmail: contactEmail?.isNotEmpty == true ? ValidationUtils.normalizeEmail(contactEmail!) : null,
        address: '${addressStreet.trim()}, ${addressCity.trim()}, ${addressState.trim()}',
      );

      if (createdPet != null) {
        Logger.petOperation('Pet created successfully', petId: createdPet.id.toString());
        
        if (mounted) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(createdPet.id.toString().startsWith('local_') 
                  ? '⚠️ Mascota guardada localmente - Verifica tu conexión'
                  : '✅ Mascota creada exitosamente'),
              backgroundColor: createdPet.id.toString().startsWith('local_') 
                  ? Colors.orange 
                  : Theme.of(context).primaryColor,
              duration: const Duration(seconds: 2),
            ),
          );
          
          Navigator.of(context).pop(createdPet);
        }
      } else {
        throw Exception('Error creando mascota');
      }
    } catch (e) {
      Logger.error('Error submitting pet form', tag: 'PetFormDialog', error: e, stackTrace: StackTrace.current);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: _submit,
            ),
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
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 420, maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Formulario para ${widget.tipo}', style: Theme.of(context).textTheme.titleLarge),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 8),
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
                          items: PetCategory.selectableCategories.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category.fullName),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                selectedCategory = value;
                              });
                            }
                          },
                          validator: (value) => value == null ? 'Selecciona una categoría' : null,
                        ),
                        const SizedBox(height: 8),
                        
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Nombre de la mascota*', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          onSaved: (v) => name = v ?? '',
                        ),
                        const SizedBox(height: 8),
                        
                        // Selector de imagen mejorado con tema naranja
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: selectedImage != null 
                                  ? Theme.of(context).primaryColor 
                                  : Colors.grey.shade400,
                              width: selectedImage != null ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            gradient: selectedImage != null 
                                ? LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Theme.of(context).primaryColor.withOpacity(0.05),
                                      Colors.white,
                                    ],
                                  )
                                : null,
                          ),
                          child: Column(
                            children: [
                              if (selectedImage != null)
                                Container(
                                  height: 200,
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                    image: DecorationImage(
                                      image: FileImage(selectedImage!),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                            onPressed: () {
                                              setState(() {
                                                selectedImage = null;
                                                imageUrl = '';
                                              });
                                              Logger.imageOperation('Pet image removed by user');
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: selectedImage != null 
                                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                                        : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: isUploadingImage 
                                      ? SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                        )
                                      : Icon(
                                          selectedImage != null ? Icons.photo : Icons.add_photo_alternate,
                                          color: selectedImage != null 
                                              ? Theme.of(context).primaryColor 
                                              : Colors.grey.shade600,
                                        ),
                                ),
                                title: Text(
                                  selectedImage != null 
                                      ? 'Imagen seleccionada' 
                                      : 'Agregar foto de la mascota*',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: selectedImage != null 
                                        ? Theme.of(context).primaryColor 
                                        : Colors.grey.shade700,
                                  ),
                                ),
                                subtitle: Text(
                                  selectedImage != null 
                                      ? 'Toca para cambiar la imagen' 
                                      : 'Toca para seleccionar desde cámara o galería',
                                  style: TextStyle(
                                    color: selectedImage != null 
                                        ? Theme.of(context).primaryColor.withOpacity(0.7)
                                        : Colors.grey.shade600,
                                  ),
                                ),
                                trailing: Icon(
                                  selectedImage != null ? Icons.edit : Icons.arrow_forward_ios,
                                  color: selectedImage != null 
                                      ? Theme.of(context).primaryColor 
                                      : Colors.grey.shade600,
                                  size: selectedImage != null ? 20 : 16,
                                ),
                                onTap: isUploadingImage ? null : _showImageSourceDialog,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Edad*', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                onSaved: (v) => age = v ?? '',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Raza*', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                onSaved: (v) => breed = v ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: gender,
                                decoration: const InputDecoration(labelText: 'Género', border: OutlineInputBorder()),
                                items: ['Macho', 'Hembra'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
                                onChanged: (value) => setState(() { gender = value!; }),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: size,
                                decoration: const InputDecoration(labelText: 'Tamaño', border: OutlineInputBorder()),
                                items: ['Pequeño', 'Mediano', 'Grande'].map((label) => DropdownMenuItem(value: label, child: Text(label))).toList(),
                                onChanged: (value) => setState(() { size = value!; }),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: CheckboxListTile(title: const Text('Vacunado'), value: isVaccinated, onChanged: (v) => setState(() { isVaccinated = v!; }))),
                            Expanded(child: CheckboxListTile(title: const Text('Esterilizado'), value: isSterilized, onChanged: (v) => setState(() { isSterilized = v!; }))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Descripción*', border: OutlineInputBorder()),
                          maxLines: 3,
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          onSaved: (v) => description = v ?? '',
                        ),
                        const SizedBox(height: 12),
                        const Text('Dirección', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Calle/numero*', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          onSaved: (v) => addressStreet = v ?? '',
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Ciudad*', border: OutlineInputBorder()),
                                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                                onSaved: (v) => addressCity = v ?? '',
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                decoration: const InputDecoration(labelText: 'Estado', border: OutlineInputBorder()),
                                onSaved: (v) => addressState = v ?? '',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text('Datos de contacto', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Nombre de contacto*', border: OutlineInputBorder()),
                          validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          onSaved: (v) => contactName = v ?? '',
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          maxLength: 9,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono de contacto* (9 dígitos)', 
                            hintText: '987654321',
                            border: OutlineInputBorder(),
                            counterText: '', // Ocultar el contador de caracteres
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly, // Solo números
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Requerido';
                            }
                            if (value.length != 9) {
                              return 'El teléfono debe tener exactamente 9 dígitos';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Solo se permiten números';
                            }
                            return null;
                          },
                          onSaved: (v) => contactPhone = v ?? '',
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Email de contacto*', border: OutlineInputBorder()),
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Requerido';
                            if (!value.contains('@')) return 'Ingrese un email válido';
                            return null;
                          },
                          onSaved: (v) => contactEmail = v ?? '',
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSubmitting ? null : () => Navigator.of(context).pop(), 
                    child: const Text('Cancelar')
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF9800)), 
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
                              Text('Enviando...'),
                            ],
                          )
                        : const Text('Enviar')
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
