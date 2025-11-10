import 'package:flutter/material.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../core/services/my_pets_service.dart';

class MyPublicationsScreen extends StatefulWidget {
  final List<Pet> adoptPets;
  final List<Pet> riskPets;
  final Function(Pet) onEditPet;
  final Function(Pet) onDeletePet;

  const MyPublicationsScreen({
    super.key,
    required this.adoptPets,
    required this.riskPets,
    required this.onEditPet,
    required this.onDeletePet,
  });

  @override
  State<MyPublicationsScreen> createState() => _MyPublicationsScreenState();
}

class _MyPublicationsScreenState extends State<MyPublicationsScreen> {
  final MyPetsService _myPetsService = MyPetsService();
  List<Pet> _myPets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMyPets();
  }

  Future<void> _loadMyPets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final pets = await _myPetsService.getMyPets();
      setState(() {
        _myPets = pets;
        _isLoading = false;
      });
      print('✅ Cargadas ${pets.length} mascotas del usuario');
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      print('❌ Error cargando mis mascotas: $e');
    }
  }

  Future<void> _handleDelete(Pet pet) async {
    try {
      await _myPetsService.deletePet(pet.id);
      
      setState(() {
        _myPets.removeWhere((p) => p.id == pet.id);
      });
      
      widget.onDeletePet(pet);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${pet.name} eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mis Publicaciones'),
          backgroundColor: Colors.orange,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.orange),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Mis Publicaciones'),
          backgroundColor: Colors.orange,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadMyPets,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final adoptPets = _myPets.where((pet) => !pet.isRisk).toList();
    final riskPets = _myPets.where((pet) => pet.isRisk).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mis Publicaciones'),
          backgroundColor: Colors.orange,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'En Adopción'),
              Tab(text: 'En Riesgo'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildPetList(adoptPets, false),
            _buildPetList(riskPets, true),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(Pet pet) {
    final nameController = TextEditingController(text: pet.name);
    final descriptionController = TextEditingController(text: pet.description);
    final ageController = TextEditingController(text: pet.age);
    final breedController = TextEditingController(text: pet.breed);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar ${pet.name}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(
                  labelText: 'Edad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: breedController,
                decoration: const InputDecoration(
                  labelText: 'Raza',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final updateData = {
                  'name': nameController.text,
                  'description': descriptionController.text,
                  'age': ageController.text,
                  'breed': breedController.text,
                };

                await _myPetsService.updatePet(pet.id, updateData);
                
                // Recargar la lista
                await _loadMyPets();
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mascota actualizada correctamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al actualizar: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetList(List<Pet> pets, bool isRisk) {
    if (pets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isRisk ? Icons.warning_amber_rounded : Icons.pets,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              isRisk 
                ? 'No has publicado mascotas en riesgo' 
                : 'No has publicado mascotas en adopción',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pets.length,
      itemBuilder: (context, index) {
        final pet = pets[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen de la mascota
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  pet.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      color: Colors.grey[300],
                      child: const Icon(Icons.pets, size: 64, color: Colors.grey),
                    );
                  },
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y estado
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isRisk ? Colors.red : Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isRisk ? 'En Riesgo' : 'En Adopción',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Descripción
                    if (pet.description.isNotEmpty)
                      Text(
                        pet.description,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Detalles
                    Row(
                      children: [
                        if (pet.breed.isNotEmpty) ...[
                          Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(pet.breed, style: TextStyle(color: Colors.grey[600])),
                          const SizedBox(width: 16),
                        ],
                        if (pet.age.isNotEmpty) ...[
                          Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(pet.age, style: TextStyle(color: Colors.grey[600])),
                        ],
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Botones de acción
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showEditDialog(pet),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Eliminar publicación'),
                                  content: Text(
                                    '¿Estás seguro de eliminar la publicación de ${pet.name}?'
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _handleDelete(pet);
                                      },
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.delete, size: 18),
                            label: const Text('Eliminar'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}