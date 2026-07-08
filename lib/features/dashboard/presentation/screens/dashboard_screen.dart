import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/user_profile_notifier.dart';
import '../../../../core/services/pet_service.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/adoption_service.dart';
import '../../../../core/widgets/pet_card.dart';
import '../../../auth/presentation/dialogs/edit_profile_dialog.dart';
import '../../../auth/presentation/screens/my_publications_screen.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../donations/presentation/screens/donations_screen.dart';
import '../../../adoption/presentation/screens/my_requests_screen.dart';
import '../../../adoption/presentation/screens/received_requests_screen.dart';
import '../../../adoption/presentation/dialogs/send_adoption_request_dialog.dart';
import '../../../adoption/presentation/dialogs/send_risk_adoption_request_dialog.dart';
import '../../../ai/presentation/screens/dog_recommendation_screen.dart'; // 🔍 Recomendación de perros
import '../../../ai/presentation/screens/analyze_photo_screen.dart'; // 🔍 Identificar raza por foto (IA)
import '../../../ai/presentation/screens/pet_match_screen.dart'; // 🐕 Buscar coincidencias (IA)
import 'publish_pet_screen.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/pet_category.dart';
import 'adopt_tab.dart';
import 'risk_tab.dart';
import '../../../pet_details/presentation/screens/pet_detail_screen.dart';

class DashboardScreen extends StatefulWidget {
  final bool isAuthenticated;
  final int initialTab;
  
  const DashboardScreen({
    super.key, 
    this.isAuthenticated = false,
    this.initialTab = 0,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;
  final PetService _petService = PetService();
  
  List<Pet> _adoptPets = [];
  List<Pet> _riskPets = [];
  bool _isLoading = true;
  
  // Datos del usuario
  String? _userName;
  String? _userEmail;
  String? _userImage;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _loadUserProfile();
    _loadPetsFromBackend();
  }
  
  /// 👤 Cargar perfil del usuario
  Future<void> _loadUserProfile() async {
    try {
      final authService = AuthService();
      final userData = await authService.getCurrentUser();
      
      if (userData != null && mounted) {
        setState(() {
          _userName = '${userData['name'] ?? ''} ${userData['lastname'] ?? ''}'.trim();
          _userEmail = userData['email'] ?? '';
          _userImage = userData['image'];
        });
      }
    } catch (e) {
      print('❌ Error cargando perfil: $e');
    }
  }

  /// 🔄 Cargar mascotas desde el backend
  Future<void> _loadPetsFromBackend() async {
    print('🔄 Iniciando carga de mascotas desde backend...');
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar mascotas para adopción y en riesgo en paralelo
      print('📡 Solicitando mascotas para adopción...');
      final adoptPetsFuture = _petService.getPetsForAdoption();
      print('📡 Solicitando mascotas en riesgo...');
      final riskPetsFuture = _petService.getPetsInRisk();
      
      print('⏳ Esperando respuestas...');
      final adoptPets = await adoptPetsFuture;
      print('✅ Mascotas para adopción recibidas: ${adoptPets.length}');
      final riskPets = await riskPetsFuture;
      print('✅ Mascotas en riesgo recibidas: ${riskPets.length}');

      setState(() {
        _adoptPets = adoptPets;
        _riskPets = riskPets;
        _isLoading = false;
      });

      print('✅ Mascotas cargadas desde backend:');
      print('   - Adopción: ${_adoptPets.length}');
      print('   - Riesgo: ${_riskPets.length}');
    } catch (e) {
      print('❌ Error cargando mascotas del backend: $e');
      
      // Si es error de token, redirigir a login
      final errorMessage = e.toString();
      if (errorMessage.contains('Token expirado') || errorMessage.contains('401')) {
        if (mounted) {
          // Mostrar mensaje y redirigir
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tu sesión ha expirado. Por favor, inicia sesión de nuevo.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 2),
            ),
          );
          
          // Esperar un momento y redirigir
          await Future.delayed(const Duration(seconds: 2));
          
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.welcome,
              (route) => false,
            );
          }
        }
        return;
      }
      
      // Fallback a datos locales si falla el backend por otra razón
      _loadFallbackData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usando datos locales - Verifica tu conexión'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  /// 📱 Cargar datos de fallback (locales)
  void _loadFallbackData() {
    setState(() {
      _adoptPets = [
        Pet(
          id: 1,
          name: 'Bella',
          imageUrl: 'https://images.pexels.com/photos/1108099/pexels-photo-1108099.jpeg',
          isRisk: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 1,
          categoryId: 1,
          category: PetCategory.dog,
          description: 'Perrita muy cariñosa y juguetona',
          age: '2 años',
          breed: 'Mestiza',
          gender: 'Hembra',
        ),
        Pet(
          id: 2,
          name: 'Max',
          imageUrl: 'https://images.pexels.com/photos/1108098/pexels-photo-1108098.jpeg',
          isRisk: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 1,
          categoryId: 1,
          category: PetCategory.dog,
          description: 'Perro tranquilo y obediente',
          age: '3 años',
          breed: 'Golden Retriever',
          gender: 'Macho',
        ),
        Pet(
          id: 5,
          name: 'Mimi',
          imageUrl: 'https://images.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg',
          isRisk: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 1,
          categoryId: 2,
          category: PetCategory.cat,
          description: 'Gatita muy independiente y cariñosa',
          age: '1 año',
          breed: 'Siamés',
          gender: 'Hembra',
        ),
      ];
      
      _riskPets = [
        Pet(
          id: 3,
          name: 'Rocky',
          imageUrl: 'https://images.pexels.com/photos/4587997/pexels-photo-4587997.jpeg',
          isRisk: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 1,
          categoryId: 1,
          category: PetCategory.dog,
          description: 'Perro perdido en el centro de la ciudad',
          age: '4 años',
          breed: 'Pastor Alemán',
          gender: 'Macho',
        ),
        Pet(
          id: 4,
          name: 'Luna',
          imageUrl: 'https://images.pexels.com/photos/4588000/pexels-photo-4588000.jpeg',
          isRisk: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 1,
          categoryId: 2,
          category: PetCategory.cat,
          description: 'Gata herida encontrada en la calle',
          age: '2 años',
          breed: 'Mestiza',
          gender: 'Hembra',
        ),
      ];
      
      _isLoading = false;
    });
  }



  /// ➕ Agregar mascota para adopción (usando backend)
  Future<void> _addAdoptPet(Pet pet) async {
    try {
      final createdPet = await _petService.createPet(
        name: pet.name,
        description: pet.description,
        categoryId: pet.category.id,
        isRisk: false,
        age: pet.age,
        breed: pet.breed,
        gender: pet.gender,
        size: pet.size,
        isVaccinated: pet.isVaccinated,
        isSterilized: pet.isSterilized,
        contactName: pet.contactName,
        contactPhone: pet.contactPhone,
        contactEmail: pet.contactEmail,
        address: pet.address,
      );

      if (createdPet != null) {
        // Recargar la lista completa desde el backend en lugar de agregar localmente
        await _loadPetsFromBackend();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ ${pet.name} publicado para adopción'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Error creando mascota');
      }
    } catch (e) {
      print('❌ Error agregando mascota para adopción: $e');
      
      String errorMessage;
      Color backgroundColor;
      
      if (e.toString().contains('Token expirado')) {
        errorMessage = '🔐 Sesión expirada. Por favor, inicia sesión nuevamente.';
        backgroundColor = Colors.red;
      } else if (e.toString().contains('401')) {
        errorMessage = '🔐 Error de autenticación. Verifica tu sesión.';
        backgroundColor = Colors.red;
      } else if (e.toString().contains('Error al crear mascota en backend')) {
        errorMessage = '❌ Error del servidor. Inténtalo más tarde.';
        backgroundColor = Colors.red;
      } else {
        errorMessage = '❌ Error: ${e.toString()}';
        backgroundColor = Colors.red;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () => _addAdoptPet(pet),
            ),
          ),
        );
      }
    }
  }

  /// 🚨 Agregar mascota en riesgo (usando backend)
  Future<void> _addRiskPet(Pet pet) async {
    try {
      final createdPet = await _petService.createPet(
        name: pet.name,
        description: pet.description,
        categoryId: pet.category.id,
        isRisk: true,
        age: pet.age,
        breed: pet.breed,
        gender: pet.gender,
        size: pet.size,
        isVaccinated: pet.isVaccinated,
        isSterilized: pet.isSterilized,
        contactName: pet.contactName,
        contactPhone: pet.contactPhone,
        contactEmail: pet.contactEmail,
        address: pet.address,
      );

      if (createdPet != null) {
        // Recargar la lista completa desde el backend en lugar de agregar localmente
        await _loadPetsFromBackend();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🚨 ${pet.name} reportado en riesgo'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Error creando mascota');
      }
    } catch (e) {
      print('❌ Error agregando mascota en riesgo: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error al reportar mascota: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  /// 💙 Manejar ayuda por adopción de animal en riesgo
  Future<void> _markSafe(Pet pet) async {
    // Usar la misma lógica que en risk_tab.dart
    if (!widget.isAuthenticated) {
      // Usuario no autenticado: mostrar diálogo para registrarse
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Registro Requerido'),
          content: Text(
            'Para ayudar a ${pet.name}, necesitas registrarse e iniciar sesión primero.'
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
        builder: (context) => SendRiskAdoptionRequestDialog(pet: pet),
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

  /// 🐕 Manejar solicitud de adopción (igual que en adopt_tab.dart)
  Future<void> _handleAdoptRequest(BuildContext context, Pet pet) async {
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
                Navigator.pushNamed(context, AppRoutes.register);
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
              'No puedes adoptar tu propia mascota. Esta es una publicación que tú creaste.'
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
            'Ya tienes una solicitud pendiente para ${pet.name}. Espera la respuesta del dueño.'
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

    // Usuario autenticado y puede adoptar: mostrar formulario completo
    if (mounted) {
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        builder: (context) => SendAdoptionRequestDialog(pet: pet),
      );

      if (result != null && mounted) {
        // Enviar solicitud
        try {
          await adoptionService.sendAdoptionRequest(
            petId: pet.id,
            personalInfo: result['personalInfo'],
            livingSituation: result['livingSituation'],
            adoptionReason: result['adoptionReason'],
            previousExperience: result['previousExperience'],
            hasYard: result['hasYard'],
            hasOtherPets: result['hasOtherPets'],
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('✅ Solicitud enviada para ${pet.name}'),
                backgroundColor: Colors.green,
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

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFFF9800), // Naranja
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color(0xFFFF9800),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Foto de perfil
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    backgroundImage: (_userImage != null && _userImage!.isNotEmpty)
                        ? CachedNetworkImageProvider(_userImage!)
                        : null,
                    child: (_userImage == null || _userImage!.isEmpty)
                        ? const Icon(Icons.person, size: 35, color: Color(0xFFFF9800))
                        : null,
                  ),
                  const SizedBox(height: 10),
                  // Nombre del usuario
                  Text(
                    widget.isAuthenticated 
                        ? (_userName ?? 'Usuario') 
                        : 'Invitado',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Email del usuario
                  if (_userEmail != null && _userEmail!.isNotEmpty)
                    Text(
                      _userEmail!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.image_search,
              title: 'Identificar raza (IA)',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyzePhotoScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.find_in_page,
              title: 'Buscar coincidencias (IA)',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PetMatchScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.notifications,
              title: 'Notificaciones',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.favorite,
              title: 'Publicar mascota',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PublishPetScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.volunteer_activism,
              title: 'Donaciones',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DonationsScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.assignment,
              title: 'Mis Solicitudes',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MyRequestsScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.inbox,
              title: 'Solicitudes Recibidas',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReceivedRequestsScreen(),
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.info,
              title: 'Acerca de',
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Acerca de PawFinder'),
                    content: const Text(
                      'PawFinder es una plataforma para ayudar a mascotas en adopción y en riesgo.\n\nVersión 1.0.0',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cerrar'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.logout,
              title: 'Cerrar sesión',
              onTap: () {
                Navigator.pop(context);
                if (widget.isAuthenticated) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                          ),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.welcome,
                              (route) => false,
                            );
                          },
                          child: const Text('Cerrar Sesión'),
                        ),
                      ],
                    ),
                  );
                } else {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.welcome,
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool hasSubmenu = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.white, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: hasSubmenu
          ? const Icon(Icons.arrow_drop_down, color: Colors.white)
          : null,
      onTap: hasSubmenu ? null : onTap,
    );
  }

  Widget _buildDrawerSubItem(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
        ),
      ),
      onTap: onTap,
      dense: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar loading mientras cargan los datos
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'PawFinder',
            style: AppStyles.headingSmall.copyWith(color: Colors.white),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Cargando mascotas...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Lista de pantallas - incluye Perfil solo si está autenticado
    final List<Widget> screens = [
      HomeTab(
        adoptPets: _adoptPets, 
        riskPets: _riskPets,
        isAuthenticated: widget.isAuthenticated,
        onRequestAdopt: (pet) => _handleAdoptRequest(context, pet), 
        onMarkSafe: (pet) {
          if (!widget.isAuthenticated) {
            // Mostrar mensaje de que necesita registrarse
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Registro Requerido'),
                content: const Text(
                  'Necesitas registrarte e iniciar sesión para marcar una mascota como fuera de peligro.'
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
          
          // Usuario autenticado: ejecutar acción
          _markSafe(pet);
        },
      ),
      AdoptTab(
        adoptPets: _adoptPets, 
        onAdd: _addAdoptPet,
        isAuthenticated: widget.isAuthenticated,
        onRefresh: _loadPetsFromBackend,
      ),
      RiskTab(
        riskPets: _riskPets, 
        onAdd: _addRiskPet, 
        onMarkSafe: _markSafe,
        isAuthenticated: widget.isAuthenticated,
        onRefresh: _loadPetsFromBackend,
      ),
      if (widget.isAuthenticated)
        ProfileTab(
          adoptPets: _adoptPets,
          riskPets: _riskPets,
          onRemovePet: (pet) {
            setState(() {
              if (pet.isRisk) {
                _riskPets.removeWhere((p) => p.name == pet.name && p.imageUrl == pet.imageUrl);
              } else {
                _adoptPets.removeWhere((p) => p.name == pet.name && p.imageUrl == pet.imageUrl);
              }
            });
          },
        ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'PawFinder',
          style: AppStyles.headingSmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: widget.isAuthenticated 
          ? [
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cerrar Sesión'),
                      content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[700],
                          ),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.pop(context); // Cierra el diálogo
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.welcome,
                              (route) => false,
                            );
                          },
                          child: const Text('Cerrar Sesión'),
                        ),
                      ],
                    ),
                  );
                },
                tooltip: 'Cerrar Sesión',
              ),
            ]
          : [
              TextButton.icon(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.welcome,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.login, color: Colors.white, size: 20),
                label: const Text(
                  'Sign In / Register',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
      ),
      drawer: _buildDrawer(context),
      body: screens[_currentIndex],
      // (El acceso a la IA está en la burbuja flotante global 🐶 PawBot;
      //  se quitó el FAB para no duplicar la burbuja.)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: widget.isAuthenticated 
          ? const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pets),
                label: 'Adoptar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.warning_amber_rounded),
                label: 'Riesgo',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ]
          : const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.pets),
                label: 'Adoptar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.warning_amber_rounded),
                label: 'Riesgo',
              ),
            ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final List<Pet> adoptPets;
  final List<Pet> riskPets;
  final void Function(Pet)? onRequestAdopt;
  final void Function(Pet)? onMarkSafe;
  final bool isAuthenticated;
  
  const HomeTab({
    super.key, 
    required this.adoptPets, 
    required this.riskPets, 
    this.onRequestAdopt, 
    this.onMarkSafe,
    required this.isAuthenticated,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          const Text(
            'Mascotas disponibles',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: adoptPets.map((pet) => PetCard(
                pet: pet,
                buttonText: 'Adoptar',
                buttonColor: Colors.blue,
                buttonIcon: Icons.favorite,
                onPressed: () {
                  if (onRequestAdopt != null) {
                    onRequestAdopt!(pet);
                  } else {
                    // default: show a simple request dialog
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Solicitar adopción'),
                        content: const Text('Solicitud enviada'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                        ],
                      ),
                    );
                  }
                },
                onImageTap: () => _navigateToAdoptPetDetails(context, pet, onRequestAdopt), // ✅ Clean Architecture
              )).toList(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mascotas en riesgo',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: riskPets.map((pet) => PetCard(
                pet: pet,
                buttonText: 'Ayudar Adoptando', // ✅ NUEVO TEXTO
                buttonColor: Colors.orange, // ✅ Color más cálido
                buttonIcon: Icons.favorite_border, // ✅ Icono de corazón
                onPressed: () {
                  if (onMarkSafe != null) {
                    onMarkSafe!(pet);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ayudando a esta mascota')));
                  }
                },
                onImageTap: () => _navigateToRiskPetDetails(context, pet, onMarkSafe), // ✅ Clean Architecture
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 📱 Navegar a detalles de mascota para adopción - Clean Architecture
  static void _navigateToAdoptPetDetails(BuildContext context, Pet pet, void Function(Pet)? onRequestAdopt) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailScreen(
          pet: pet,
          onAdoptPressed: onRequestAdopt != null ? () {
            Navigator.pop(context); // Cerrar detalles
            onRequestAdopt(pet); // Ejecutar adopción
          } : null,
          actionButtonText: 'Adoptar',
          actionButtonColor: Colors.blue,
        ),
      ),
    );
  }

  /// 📱 Navegar a detalles de mascota en riesgo - Clean Architecture
  static void _navigateToRiskPetDetails(BuildContext context, Pet pet, void Function(Pet)? onMarkSafe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PetDetailScreen(
          pet: pet,
          onAdoptPressed: onMarkSafe != null ? () {
            Navigator.pop(context); // Cerrar detalles
            onMarkSafe(pet); // Ejecutar marcar como segura
          } : null,
          actionButtonText: 'Ayudar Adoptando', // ✅ NUEVO TEXTO
          actionButtonColor: Colors.orange, // ✅ Color más cálido
        ),
      ),
    );
  }
}

class PetsTab extends StatelessWidget {
  const PetsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cuadro de Adopción
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Adopción',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.orange),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.reportPet,
                        arguments: {'tipo': 'adopcion'},
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Da en adopción o encuentra una mascota para adoptar',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Cuadro de En Riesgo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'En Riesgo',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.orange),
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.reportPet,
                        arguments: {'tipo': 'riesgo'},
                      ),
                    ),
                  ],
                ),
                const Text(
                  'Ayuda a mascotas perdidas, maltratadas o enfermas',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileTab extends StatefulWidget {
  final List<Pet> adoptPets;
  final List<Pet> riskPets;
  final Function(Pet) onRemovePet;

  const ProfileTab({
    super.key,
    required this.adoptPets,
    required this.riskPets,
    required this.onRemovePet,
  });

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final UserProfileNotifier _profileNotifier = UserProfileNotifier();
  String userName = 'Usuario Demo';
  String userEmail = 'usuario@ejemplo.com';
  String? userImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _profileNotifier.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    _profileNotifier.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onProfileChanged() {
    final profile = _profileNotifier.currentProfile;
    if (profile != null && mounted) {
      print('🖼️ DEBUG: Profile image URL: ${profile.image}');
      setState(() {
        userName = profile.name;
        userEmail = profile.email;
        userImageUrl = profile.image; // Usar image en lugar de imageUrl
      });
    }
  }

  Future<void> _loadUserProfile() async {
    await _profileNotifier.loadProfile();
    _onProfileChanged();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Stack(
            children: [
              (userImageUrl != null && userImageUrl!.isNotEmpty)
                  ? CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange,
                      backgroundImage: NetworkImage(userImageUrl!),
                      onBackgroundImageError: (exception, stackTrace) {
                        print('❌ Error cargando imagen: $exception');
                        print('🔗 URL problemática: $userImageUrl');
                      },
                    )
                  : CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.orange,
                      child: const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
              // Indicador de que hay URL pero imagen no visible
              if (userImageUrl != null && userImageUrl!.isNotEmpty)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.check, size: 12, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text(
            userEmail,
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.orange),
            title: const Text('Editar Perfil'),
            subtitle: const Text('Actualiza tu información personal'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final result = await Navigator.pushNamed(context, '/edit-profile');
              
              if (result != null && result is Map<String, dynamic>) {
                final updated = result['updated'] as bool? ?? false;
                if (updated) {
                  // Forzar refresh del perfil
                  print('✅ Perfil actualizado, refrescando desde backend...');
                  await _profileNotifier.refreshFromBackend();
                }
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.pets, color: Colors.orange),
            title: const Text('Mis Publicaciones'),
            subtitle: const Text('Ver mascotas que has publicado'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MyPublicationsScreen(
                    adoptPets: widget.adoptPets,
                    riskPets: widget.riskPets,
                    onEditPet: (pet) {
                      Navigator.pop(context);
                      // Mostrar diálogo de edición
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Editar ${pet.name}'),
                          content: const Text(
                            'La funcionalidad de edición estará disponible próximamente.\n\n'
                            'Podrás modificar:\n'
                            '• Nombre\n'
                            '• Descripción\n'
                            '• Edad\n'
                            '• Raza\n'
                            '• Foto'
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Entendido'),
                            ),
                          ],
                        ),
                      );
                    },
                    onDeletePet: (pet) {
                      Navigator.pop(context);
                      widget.onRemovePet(pet);
                    },
                  ),
                ),
              );
            },
          ),
          // DEBUG: Botón temporal para refrescar perfil
          ListTile(
            leading: const Icon(Icons.refresh, color: Colors.blue),
            title: const Text('🔄 DEBUG: Refrescar Perfil'),
            subtitle: const Text('Actualizar imagen desde Firebase'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              print('🔄 DEBUG: Refrescando perfil manualmente...');
              await _profileNotifier.refreshFromBackend();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Perfil refrescado desde Firebase'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Cerrar Sesión'),
                  content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.grey[700],
                      ),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Cierra el diálogo
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRoutes.welcome,
                          (route) => false,
                        );
                      },
                      child: const Text('Cerrar Sesión'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

