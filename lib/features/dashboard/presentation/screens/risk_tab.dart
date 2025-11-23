import 'package:flutter/material.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/pet_category.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/widgets/pet_card.dart';
import '../widgets/category_filter.dart';
import 'risk_pet_form_dialog.dart';

class RiskTab extends StatefulWidget {
  final List<Pet> riskPets;
  final Future<void> Function(Pet) onAdd;
  final void Function(Pet)? onMarkSafe;
  final bool isAuthenticated;
  final VoidCallback? onRefresh;
  
  const RiskTab({
    super.key, 
    required this.riskPets, 
    required this.onAdd, 
    this.onMarkSafe,
    required this.isAuthenticated,
    this.onRefresh,
  });

  @override
  State<RiskTab> createState() => _RiskTabState();
}

class _RiskTabState extends State<RiskTab> {
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
      return widget.riskPets;
    }
    return widget.riskPets.where((pet) => pet.category == _selectedCategory).toList();
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
      final pets = await _petService.getPetsInRisk(categoryId: category.id);
      setState(() {
        _filteredBackendPets = pets;
        _isLoadingFiltered = false;
      });
    } catch (e) {
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
              'Mascotas en riesgo',
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
              '${_filteredPets.length} ${_filteredPets.length == 1 ? 'mascota en riesgo' : 'mascotas en riesgo'}',
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
                              buttonText: 'Fuera de peligro',
                              onPressed: () => _handleMarkSafe(context, pet),
                              buttonColor: Colors.red,
                              buttonIcon: Icons.check_circle,
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
                  'Necesitas registrarte e iniciar sesión para reportar una mascota en riesgo.'
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
          
          // Usuario autenticado: mostrar formulario específico de riesgo
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => const RiskPetFormDialog(),
          );
          if (result == true) {
            // Refrescar la lista desde el backend
            if (widget.onRefresh != null) {
              widget.onRefresh!();
            }
            // También refrescar el filtro actual
            await _filterByCategory(_selectedCategory);
          }
        },
        tooltip: 'Reportar en riesgo',
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
            Icons.warning_amber_rounded,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay ${_selectedCategory.displayName.toLowerCase()} en riesgo',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            '¡Excelente! Esto significa que están seguros',
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

  /// 🚨 Manejar marcar mascota como fuera de peligro
  void _handleMarkSafe(BuildContext context, Pet pet) {
    if (!widget.isAuthenticated) {
      // Usuario no autenticado: mostrar diálogo para registrarse
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registro Requerido'),
          content: Text(
            'Para marcar a ${pet.name} como fuera de peligro, necesitas registrarte e iniciar sesión primero.'
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

    // Usuario autenticado: mostrar confirmación
    if (widget.onMarkSafe != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Marcar fuera de peligro'),
          content: Text('¿Confirmas que ${pet.name} ya está fuera de peligro?'),
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
                widget.onMarkSafe!(pet);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${pet.name} marcado como fuera de peligro'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('Confirmar'),
            ),
          ],
        ),
      );
    }
  }
}
