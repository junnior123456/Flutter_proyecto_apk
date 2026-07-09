import 'package:flutter/material.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/pet_category.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/responsive_grid.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/services/auth_service.dart'; // ✅ NUEVO
import '../../../../core/services/adoption_service.dart'; // ✅ NUEVO
import '../../../../core/widgets/pet_card.dart';
import '../widgets/category_filter.dart';
import 'risk_pet_form_dialog.dart';
import '../../../pet_details/presentation/screens/pet_detail_screen.dart';
import '../../../adoption/presentation/dialogs/send_risk_adoption_request_dialog.dart'; // ✅ Diálogo especializado para riesgo

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
                          // Rejilla responsiva: 2 columnas en móvil, más en tablet.
                          // Antes no tenía espaciado ni padding: las tarjetas se
                          // pegaban entre sí y al borde de la pantalla.
                          child: GridView.count(
                            crossAxisCount: responsiveColumns(context),
                            childAspectRatio: 0.72,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            padding: const EdgeInsets.all(12),
                            children: _filteredPets.map((pet) => PetCard(
                              pet: pet,
                              buttonText: 'Ayudar Adoptando', // ✅ NUEVO TEXTO
                              onPressed: () => _handleMarkSafe(context, pet),
                              onImageTap: () => _navigateToPetDetails(context, pet), // ✅ Clean Architecture
                              buttonColor: Colors.orange, // ✅ Color más cálido
                              buttonIcon: Icons.favorite_border, // ✅ Icono de corazón
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

  /// 📱 Navegar a detalles de mascota - Clean Architecture
  void _navigateToPetDetails(BuildContext context, Pet pet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailScreen(
          pet: pet,
          onAdoptPressed: () {
            Navigator.pop(context); // Cerrar detalles
            _handleMarkSafe(context, pet); // Ejecutar marcar como segura
          },
          actionButtonText: 'Ayudar Adoptando', // ✅ NUEVO TEXTO
          actionButtonColor: Colors.orange, // ✅ Color más cálido
        ),
      ),
    );
  }

  /// 💙 Manejar ayuda por adopción (NUEVA LÓGICA)
  Future<void> _handleMarkSafe(BuildContext context, Pet pet) async {
    if (!widget.isAuthenticated) {
      // Usuario no autenticado: mostrar diálogo para registrarse
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registro Requerido'),
          content: Text(
            'Para ayudar a ${pet.name}, necesitas registrarte e iniciar sesión primero.'
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

    // Verificar si es su propia mascota
    final authService = AuthService();
    final userData = await authService.getCurrentUser();
    final currentUserId = userData?['id'];

    if (currentUserId != null && pet.userId == currentUserId) {
      // Es su propia mascota
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange),
                SizedBox(width: 12),
                Text('No Disponible'),
              ],
            ),
            content: const Text(
              'No puedes ayudar a tu propia mascota. Esta es una publicación que tú creaste.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Entendido'),
              ),
            ],
          ),
        );
      }
      return;
    }

    // Verificar si ya tiene una solicitud pendiente
    final adoptionService = AdoptionService();
    final hasExisting = await adoptionService.hasExistingRequest(pet.id);

    if (hasExisting && mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange),
              SizedBox(width: 12),
              Text('Solicitud Existente'),
            ],
          ),
          content: Text(
            'Ya tienes una solicitud pendiente para ayudar a ${pet.name}. Espera la respuesta del publicador.'
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }

    // Usuario autenticado y puede ayudar: mostrar formulario especializado para riesgo
    if (mounted) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => SendRiskAdoptionRequestDialog(pet: pet), // ✅ Diálogo especializado
      );

      if (result != null && mounted) {
        // Enviar solicitud con campos adicionales de rescate
        try {
          await adoptionService.sendAdoptionRequest(
            petId: pet.id,
            personalInfo: result['personalInfo'],
            livingSituation: result['livingSituation'],
            adoptionReason: result['adoptionReason'],
            previousExperience: result['previousExperience'],
            hasYard: result['hasYard'],
            hasOtherPets: result['hasOtherPets'],
            // Campos adicionales específicos para animales en riesgo
            rescuePlan: result['rescuePlan'],
            medicalCare: result['medicalCare'],
            canProvideMedicalCare: result['canProvideMedicalCare'],
            hasTransportation: result['hasTransportation'],
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Solicitud de rescate enviada para ${pet.name}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al enviar solicitud: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    }
  }
}
