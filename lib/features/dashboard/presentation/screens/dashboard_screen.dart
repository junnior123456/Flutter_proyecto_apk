import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_styles.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/services/user_profile_notifier.dart';
import '../../../../core/services/pet_service.dart';
import '../../../auth/presentation/dialogs/edit_profile_dialog.dart';
import '../../../auth/presentation/screens/my_publications_screen.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../domain/entities/pet_category.dart';
import 'adopt_tab.dart';
import 'risk_tab.dart';

// Widget reutilizable para mostrar una mascota
class PetCard extends StatelessWidget {
  final Pet pet;
  final String buttonText;
  final VoidCallback onPressed;
  const PetCard({super.key, required this.pet, required this.buttonText, required this.onPressed});

  void _showPetDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      pet.name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            pet.imageUrl,
                            height: 200,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(pet.description.isEmpty ? 'Sin descripción' : pet.description),
                        const SizedBox(height: 8),
                        Text('Edad: ${pet.age}'),
                        Text('Raza: ${pet.breed}'),
                        Text('Género: ${pet.gender}'),
                        Text('Tamaño: ${pet.size}'),
                        Text('Vacunado: ${pet.isVaccinated ? "Sí" : "No"}'),
                        Text('Esterilizado: ${pet.isSterilized ? "Sí" : "No"}'),
                        const SizedBox(height: 16),
                        Text('Datos de contacto:', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Nombre: ${pet.contactName}'),
                        Text('Teléfono: ${pet.contactPhone}'),
                        Text('Email: ${pet.contactEmail}'),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cerrar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onPressed();
                        },
                        child: Text(buttonText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 280,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 160,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Image.network(
                  pet.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pet.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF448AFF),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onPressed: () => _showPetDetails(context),
                    child: Text(buttonText, textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialTab;
    _loadPetsFromBackend();
  }

  /// 🔄 Cargar mascotas desde el backend
  Future<void> _loadPetsFromBackend() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cargar mascotas para adopción y en riesgo en paralelo
      final adoptPetsFuture = _petService.getPetsForAdoption();
      final riskPetsFuture = _petService.getPetsInRisk();
      
      final adoptPets = await adoptPetsFuture;
      final riskPets = await riskPetsFuture;

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
      
      // Fallback a datos locales si falla el backend
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
        setState(() {
          _adoptPets.add(createdPet);
        });
        
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
      
      // Fallback: agregar localmente
      setState(() {
        _adoptPets.add(pet);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${pet.name} agregado localmente - Verifica conexión'),
            backgroundColor: Colors.orange,
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
        setState(() {
          _riskPets.add(createdPet);
        });
        
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
      
      // Fallback: agregar localmente
      setState(() {
        _riskPets.add(pet);
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ ${pet.name} reportado localmente - Verifica conexión'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _markSafe(Pet pet) {
    setState(() {
      // remove from risk list and add to adopt list as a safe pet
      _riskPets.removeWhere((p) => p.name == pet.name && p.imageUrl == pet.imageUrl);
      final safePet = Pet(
        id: pet.id,
        name: pet.name,
        imageUrl: pet.imageUrl,
        isRisk: false,
        createdAt: pet.createdAt,
        updatedAt: pet.updatedAt,
        userId: pet.userId,
        categoryId: pet.categoryId,
        description: pet.description,
        address: pet.address,
        age: pet.age,
        breed: pet.breed,
        gender: pet.gender,
        size: pet.size,
        isVaccinated: pet.isVaccinated,
        isSterilized: pet.isSterilized,
        contactName: pet.contactName,
        contactPhone: pet.contactPhone,
        contactEmail: pet.contactEmail,
      );
      _adoptPets.add(safePet);
    });
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
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 35, color: Color(0xFFFF9800)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.isAuthenticated ? 'Ryan Karuna' : 'Invitado',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
              icon: Icons.notifications,
              title: 'Notification',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Notificaciones')),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.message,
              title: 'Message',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mensajes')),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.favorite,
              title: 'Upload your pet',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  _currentIndex = 1; // Ir a la pestaña de Adoptar
                });
              },
            ),
            _buildDrawerItem(
              icon: Icons.shopping_bag,
              title: 'Products',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Productos - Próximamente')),
                );
              },
              hasSubmenu: true,
            ),
            if (_buildDrawerItem(
              icon: Icons.shopping_bag,
              title: 'Products',
              onTap: () {},
              hasSubmenu: true,
            ) != null)
              Padding(
                padding: const EdgeInsets.only(left: 70),
                child: Column(
                  children: [
                    _buildDrawerSubItem('Shopping cart', () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Carrito de compras')),
                      );
                    }),
                    _buildDrawerSubItem('Order history', () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Historial de pedidos')),
                      );
                    }),
                  ],
                ),
              ),
            _buildDrawerItem(
              icon: Icons.volunteer_activism,
              title: 'Donation',
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Donaciones - Próximamente')),
                );
              },
            ),
            _buildDrawerItem(
              icon: Icons.info,
              title: 'About',
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
              title: 'Logout',
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
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
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
        onRequestAdopt: (pet) {
          if (!widget.isAuthenticated) {
            // Mostrar mensaje de que necesita registrarse
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Registro Requerido'),
                content: const Text(
                  'Necesitas registrarte e iniciar sesión para solicitar la adopción de una mascota.'
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
          
          // Usuario autenticado: mostrar diálogo de confirmación
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Solicitar adopción'),
              content: Text('¿Deseas solicitar la adopción de ${pet.name}?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Solicitud enviada para ${pet.name}')));
                }, child: const Text('Enviar')),
              ],
            ),
          );
        }, 
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
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${pet.name} marcado como fuera de peligro')));
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
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
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
                buttonText: 'Fuera de peligro',
                onPressed: () {
                  if (onMarkSafe != null) {
                    onMarkSafe!(pet);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marcado como fuera de peligro')));
                  }
                },
              )).toList(),
            ),
          ),
        ],
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
                    adoptPets: widget.adoptPets.where((pet) => 
                      pet.contactEmail == userEmail
                    ).toList(),
                    riskPets: widget.riskPets.where((pet) => 
                      pet.contactEmail == userEmail
                    ).toList(),
                    onEditPet: (pet) {
                      // Aquí iría la lógica para editar la mascota
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Edición de mascota próximamente')),
                      );
                    },
                    onDeletePet: (pet) {
                      widget.onRemovePet(pet);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Publicación eliminada')),
                      );
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
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
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

