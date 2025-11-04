import 'package:flutter/material.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/pet_category.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/pet_service.dart';
import '../widgets/category_filter.dart';
import 'pet_form_dialog.dart';
import 'dashboard_screen.dart';

class AdoptTab extends StatefulWidget {
  final List<Pet> adoptPets;
  final Future<void> Function(Pet) onAdd;
  final bool isAuthenticated;
  final VoidCallback? onRefresh;
  
  const AdoptTab({
    super.key, 
    required this.adoptPets, 
    required this.onAdd,
    required this.isAuthenticated,
    this.onRefresh,
  });

  @override
  State<AdoptTab> createState() => _AdoptTabState();
}

class _AdoptTabState extends State<AdoptTab> {
  PetCategory _selectedCategory = PetCategory.all;
  final PetService _petService = PetService();
  List<Pet> _filteredBackendPets = [];
  bool _isLoadingFiltered = false;

  List<Pet> get _filteredPets {
    // Si hay datos filtrados del backend, usarlos
    if (_filteredBackendPets.isNotEmpty && _selectedCategory != PetCategory.all) {
      return _filteredBackendPets;
    }
    
    // Fallback a filtrado local
    if (_selectedCategory == PetCategory.all) {
      return widget.adoptPets;
    }
    return widget.adoptPets.where((pet) => pet.category == _selectedCategory).toList();
  }

  /// 🔄 Filtrar mascotas por categoría usando backend
  Future<void> _filterByCategory(PetCategory category) async {
    setState(() {
      _selectedCategory = category;
      _isLoadingFiltered = true;
    });

    if (category == PetCategory.all) {
      // Mostrar todas las mascotas
      setState(() {
        _filteredBackendPets = [];
        _isLoadingFiltered = false;
      });
      return;
    }

    try {
      final pets = await _petService.getPetsForAdoption(categoryId: category.id);
      setState(() {
        _filteredBackendPets = pets;
        _isLoadingFiltered = false;
      });
      
      print('✅ Filtrado por ${category.displayName}: ${pets.length} mascotas');
    } catch (e) {
      print('❌ Error filtrando por categoría: $e');
      setState(() {
        _filteredBackendPets = [];
        _isLoadingFiltered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mascotas disponibles para adoptar',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            // Filtro de categorías
            CategoryFilter(
              selectedCategory: _selectedCategory,
              onCategoryChanged: _filterByCategory,
            ),
            
            const SizedBox(height: 8),
            
            // Contador de resultados
            Text(
              '${_filteredPets.length} ${_filteredPets.length == 1 ? 'mascota encontrada' : 'mascotas encontradas'}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: _isLoadingFiltered
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: Colors.orange),
                          SizedBox(height: 16),
                          Text('Filtrando mascotas...'),
                        ],
                      ),
                    )
                  : _filteredPets.isEmpty
                      ? _buildEmptyState()
                      : RefreshIndicator(
                          onRefresh: () async {
                            if (widget.onRefresh != null) {
                              widget.onRefresh!();
                            }
                            await _filterByCategory(_selectedCategory);
                          },
                          child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            children: _filteredPets.map((pet) => PetCard(
                              pet: pet,
                              buttonText: 'Adoptar',
                              onPressed: () => _handleAdoptRequest(context, pet),
                            )).toList(),
                          ),
                        ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFFFF9800),
        shape: const CircleBorder(),
        onPressed: () async {
          if (!widget.isAuthenticated) {
            // Mostrar diálogo de que necesita registrarse
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Registro Requerido'),
                content: const Text(
                  'Necesitas registrarte e iniciar sesión para publicar una mascota en adopción.'
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
                      Navigator.pop(context); // Cerrar diálogo
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.welcome,
                        (route) => false,
                      );
                    },
                    child: const Text('Ir a Registro'),
                  ),
                ],
              ),
            );
            return;
          }
          
          // Usuario autenticado: mostrar formulario
          final result = await showDialog<Pet>(
            context: context,
            builder: (context) => PetFormDialog(tipo: 'adopción'),
          );
          if (result != null) {
            await widget.onAdd(result);
            // Refrescar la lista después de agregar
            await _filterByCategory(_selectedCategory);
          }
        },
        tooltip: 'Dar en adopción',
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay ${_selectedCategory.displayName.toLowerCase()} disponibles para adoptar',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Prueba con otra categoría o vuelve más tarde',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// 🐕 Manejar solicitud de adopción
  void _handleAdoptRequest(BuildContext context, Pet pet) {
    if (!widget.isAuthenticated) {
      // Usuario no autenticado: mostrar diálogo para registrarse
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registro Requerido'),
          content: Text(
            'Para adoptar a ${pet.name}, necesitas registrarte e iniciar sesión primero.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, AppRoutes.login);
              },
              child: const Text('Iniciar Sesión'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/register');
              },
              child: const Text('Registrarse'),
            ),
          ],
        ),
      );
      return;
    }

    // Usuario autenticado: mostrar confirmación de adopción
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Solicitar adopción'),
        content: Text('¿Deseas solicitar la adopción de ${pet.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('✅ Solicitud enviada para ${pet.name}'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Enviar Solicitud'),
          ),
        ],
      ),
    );
  }
}
