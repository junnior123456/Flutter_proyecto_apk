import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Data
  List<dynamic> users = [];
  List<dynamic> pets = [];
  List<dynamic> adoptionRequests = [];
  List<dynamic> comments = [];
  List<dynamic> notifications = [];
  List<dynamic> reports = [];
  
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> loadAllData() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      await Future.wait([
        loadUsers(),
        loadPets(),
        loadAdoptionRequests(),
        loadComments(),
        loadNotifications(),
        loadReports(),
      ]);
      
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> loadUsers() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.18.97:3000/api/users'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data is List ? data : [];
        });
      }
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> loadPets() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.18.97:3000/api/api/pets'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['ok'] == true && data['data'] != null) {
          setState(() {
            pets = data['data']['pets'] ?? [];
          });
        }
      }
    } catch (e) {
      print('Error loading pets: $e');
    }
  }

  Future<void> loadAdoptionRequests() async {
    // Simulado por ahora
    setState(() {
      adoptionRequests = [];
    });
  }

  Future<void> loadComments() async {
    // Simulado por ahora
    setState(() {
      comments = [];
    });
  }

  Future<void> loadNotifications() async {
    // Simulado por ahora
    setState(() {
      notifications = [];
    });
  }

  Future<void> loadReports() async {
    // Simulado por ahora
    setState(() {
      reports = [];
    });
  }

  Future<void> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.18.97:3000/api/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario eliminado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar usuario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deletePet(int petId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://192.168.18.97:3000/api/api/pets/$petId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        await loadPets();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mascota eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar mascota: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: 'Usuarios'),
            Tab(icon: Icon(Icons.pets), text: 'Mascotas'),
            Tab(icon: Icon(Icons.assignment), text: 'Adopciones'),
            Tab(icon: Icon(Icons.comment), text: 'Comentarios'),
            Tab(icon: Icon(Icons.notifications), text: 'Notificaciones'),
            Tab(icon: Icon(Icons.report), text: 'Reportes'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAllData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFFF9800),
              ),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text('Error: $error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: loadAllData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUsersTab(),
                    _buildPetsTab(),
                    _buildAdoptionsTab(),
                    _buildCommentsTab(),
                    _buildNotificationsTab(),
                    _buildReportsTab(),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFFF9800),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUsersTab() {
    return RefreshIndicator(
      onRefresh: loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          final isAdmin = user['roles'] != null && 
                         (user['roles'] as List).any((role) => role['name'] == 'ADMIN');
          
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isAdmin ? Colors.red : const Color(0xFFFF9800),
                child: Icon(
                  isAdmin ? Icons.admin_panel_settings : Icons.person,
                  color: Colors.white,
                ),
              ),
              title: Text('${user['name'] ?? ''} ${user['lastname'] ?? ''}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'] ?? ''),
                  Text(
                    isAdmin ? 'ADMINISTRADOR' : 'CLIENTE',
                    style: TextStyle(
                      color: isAdmin ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditUserDialog(user),
                  ),
                  if (!isAdmin) // No permitir eliminar admins
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _confirmDelete(
                        'usuario',
                        user['name'] ?? 'Usuario',
                        () => deleteUser(user['id']),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetsTab() {
    return RefreshIndicator(
      onRefresh: loadPets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          final images = pet['images'] as List<dynamic>? ?? [];
          String? imageUrl;
          
          if (images.isNotEmpty) {
            final primaryImage = images.firstWhere(
              (img) => img['isPrimary'] == true,
              orElse: () => images.first,
            );
            imageUrl = primaryImage['url'] ?? primaryImage['imageUrl'];
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: imageUrl != null && imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                backgroundColor: Colors.grey[300],
                child: (imageUrl == null || imageUrl.isEmpty) ? const Icon(Icons.pets) : null,
              ),
              title: Text(pet['name'] ?? 'Sin nombre'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${pet['breed'] ?? ''} - ${pet['age'] ?? ''}'),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: pet['isRisk'] == true ? Colors.red : Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      pet['isRisk'] == true ? 'EN RIESGO' : 'ADOPCIÓN',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.visibility, color: Colors.blue),
                    onPressed: () => _showPetDetails(pet),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditPetDialog(pet),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(
                      'mascota',
                      pet['name'] ?? 'Mascota',
                      () => deletePet(pet['id']),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdoptionsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Solicitudes de Adopción'),
          Text('Próximamente...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildCommentsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.comment, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Comentarios'),
          Text('Próximamente...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Notificaciones'),
          Text('Próximamente...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildReportsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.report, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Reportes'),
          Text('Próximamente...', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  void _showAddDialog() {
    final currentTab = _tabController.index;
    switch (currentTab) {
      case 0: // Usuarios
        _showAddUserDialog();
        break;
      case 1: // Mascotas
        _showAddPetDialog();
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Función próximamente disponible'),
            backgroundColor: Colors.orange,
          ),
        );
    }
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final lastnameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final passwordController = TextEditingController();
    bool isAdmin = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: lastnameController,
                  decoration: const InputDecoration(labelText: 'Apellido'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                TextField(
                  controller: passwordController,
                  decoration: const InputDecoration(labelText: 'Contraseña'),
                  obscureText: true,
                ),
                CheckboxListTile(
                  title: const Text('Es Administrador'),
                  value: isAdmin,
                  onChanged: (value) => setState(() => isAdmin = value ?? false),
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
              onPressed: () async {
                if (nameController.text.isNotEmpty && 
                    emailController.text.isNotEmpty &&
                    passwordController.text.isNotEmpty) {
                  Navigator.pop(context);
                  await _createUser({
                    'name': nameController.text,
                    'lastname': lastnameController.text,
                    'email': emailController.text,
                    'phone': phoneController.text,
                    'password': passwordController.text,
                    'isAdmin': isAdmin,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPetDialog() {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final breedController = TextEditingController();
    final ageController = TextEditingController();
    bool isRisk = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Mascota'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Descripción'),
                  maxLines: 3,
                ),
                TextField(
                  controller: breedController,
                  decoration: const InputDecoration(labelText: 'Raza'),
                ),
                TextField(
                  controller: ageController,
                  decoration: const InputDecoration(labelText: 'Edad'),
                ),
                CheckboxListTile(
                  title: const Text('En Riesgo'),
                  value: isRisk,
                  onChanged: (value) => setState(() => isRisk = value ?? false),
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
              onPressed: () async {
                if (nameController.text.isNotEmpty) {
                  Navigator.pop(context);
                  await _createPet({
                    'name': nameController.text,
                    'description': descriptionController.text,
                    'breed': breedController.text,
                    'age': ageController.text,
                    'isRisk': isRisk,
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9800),
                foregroundColor: Colors.white,
              ),
              child: const Text('Crear'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createUser(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.18.97:3000/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201) {
        await loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario creado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear usuario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _createPet(Map<String, dynamic> petData) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.18.97:3000/api/api/pets'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(petData),
      );

      if (response.statusCode == 201) {
        await loadPets();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mascota creada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear mascota: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edición de usuarios próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showEditPetDialog(Map<String, dynamic> pet) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Edición de mascotas próximamente'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  void _showPetDetails(Map<String, dynamic> pet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(pet['name'] ?? 'Mascota'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pet['description'] != null && pet['description'].isNotEmpty)
                Text('Descripción: ${pet['description']}'),
              Text('Raza: ${pet['breed'] ?? 'No especificada'}'),
              Text('Edad: ${pet['age'] ?? 'No especificada'}'),
              Text('Género: ${pet['gender'] ?? 'No especificado'}'),
              Text('Estado: ${pet['isRisk'] == true ? 'En Riesgo' : 'Para Adopción'}'),
              Text('Vacunado: ${pet['isVaccinated'] == true ? 'Sí' : 'No'}'),
              Text('Esterilizado: ${pet['isSterilized'] == true ? 'Sí' : 'No'}'),
              if (pet['contactName'] != null)
                Text('Contacto: ${pet['contactName']}'),
              if (pet['contactPhone'] != null)
                Text('Teléfono: ${pet['contactPhone']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String type, String name, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar $type'),
        content: Text('¿Estás seguro de que quieres eliminar $type "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}