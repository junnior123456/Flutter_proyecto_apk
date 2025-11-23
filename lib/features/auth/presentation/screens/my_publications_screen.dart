import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../core/services/my_pets_service.dart';
import '../../../../core/widgets/cached_pet_image.dart';
import '../bloc/my_pets_bloc.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyPetsBloc(myPetsService: _myPetsService)
        ..add(LoadMyPets()),
      child: BlocConsumer<MyPetsBloc, MyPetsState>(
        listener: (context, state) {
          if (state is MyPetsOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is MyPetsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is MyPetsLoading) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Mis Publicaciones'),
                backgroundColor: Colors.orange,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<MyPetsBloc>().add(RefreshMyPets());
                    },
                  ),
                ],
              ),
              body: const Center(
                child: CircularProgressIndicator(color: Colors.orange),
              ),
            );
          }

          List<Pet> pets = [];
          if (state is MyPetsLoaded) {
            pets = state.pets;
          } else if (state is MyPetsOperationSuccess) {
            pets = state.pets;
          }

          final adoptPets = pets.where((pet) => !pet.isRisk).toList();
          final riskPets = pets.where((pet) => pet.isRisk).toList();

          return DefaultTabController(
            length: 2,
            child: Scaffold(
              appBar: AppBar(
                title: const Text('Mis Publicaciones'),
                backgroundColor: Colors.orange,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () {
                      context.read<MyPetsBloc>().add(RefreshMyPets());
                    },
                    tooltip: 'Actualizar',
                  ),
                ],
                bottom: TabBar(
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('En Adopción'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${adoptPets.length}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('En Riesgo'),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${riskPets.length}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              body: TabBarView(
                children: [
                  _buildPetList(context, adoptPets, false),
                  _buildPetList(context, riskPets, true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(BuildContext blocContext, Pet pet) {
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
            onPressed: () {
              Navigator.pop(context);
              
              final updateData = {
                'name': nameController.text,
                'description': descriptionController.text,
                'age': ageController.text,
                'breed': breedController.text,
              };

              blocContext.read<MyPetsBloc>().add(
                UpdatePet(petId: pet.id, updateData: updateData),
              );
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  Widget _buildPetList(BuildContext blocContext, List<Pet> pets, bool isRisk) {
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
              // Imagen de la mascota con caché
              CachedPetImage(
                imageUrl: pet.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
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
                            onPressed: () => _showEditDialog(blocContext, pet),
                            icon: const Icon(Icons.edit, size: 18),
                            label: const Text('Editar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(vertical: 12),
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
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        blocContext.read<MyPetsBloc>().add(
                                          DeletePet(petId: pet.id),
                                        );
                                        widget.onDeletePet(pet);
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