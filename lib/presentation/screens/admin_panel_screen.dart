import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../core/services/token_manager.dart';
import '../../core/services/vet_request_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  /// Los endpoints /users exigen JWT (y rol ADMIN). Antes se llamaban sin token.
  Future<Map<String, String>> _authHeaders() async {
    final token = await TokenManager().getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  late TabController _tabController;
  
  // Data
  List<dynamic> users = [];
  List<dynamic> pets = [];
  List<dynamic> adoptionRequests = [];
  List<dynamic> comments = [];
  List<dynamic> notifications = [];
  List<dynamic> reports = [];
  List<dynamic> veterinarias = [];
  List<dynamic> vetRequests = [];
  final VetRequestService _vetReqService = VetRequestService();

  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 8, vsync: this);
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
        loadVeterinarias(),
        loadVetRequests(),
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
        Uri.parse('http://167.99.4.161/api/users'),
        headers: await _authHeaders(),
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
        Uri.parse('http://167.99.4.161/api/pets'),
        headers: await _authHeaders(),
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
    try {
      final response = await http.get(
        Uri.parse('http://167.99.4.161/api/notifications'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          notifications =
              (data['data']?['notifications'] as List?) ?? [];
        });
      }
    } catch (e) {
      print('Error loading notifications: $e');
    }
  }

  Future<void> loadReports() async {
    try {
      final response = await http.get(
        Uri.parse('http://167.99.4.161/api/reports/admin/all'),
        headers: await _authHeaders(),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          reports = (data['data']?['reports'] as List?) ?? [];
        });
      }
    } catch (e) {
      print('Error loading reports: $e');
    }
  }

  Future<void> updateUser(int userId, Map<String, dynamic> body) async {
    try {
      final response = await http.put(
        Uri.parse('http://167.99.4.161/api/users/$userId'),
        headers: await _authHeaders(),
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        await loadUsers();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario actualizado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar usuario: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updatePet(int petId, Map<String, dynamic> body) async {
    try {
      final response = await http.patch(
        Uri.parse('http://167.99.4.161/api/pets/$petId'),
        headers: await _authHeaders(),
        body: json.encode(body),
      );
      if (response.statusCode == 200) {
        await loadPets();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mascota actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar mascota: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> loadVeterinarias() async {
    try {
      final response = await http.get(
        Uri.parse('http://167.99.4.161/api/veterinarias/admin/all'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          veterinarias = data is List ? data : (data['data'] ?? []);
        });
      }
    } catch (e) {
      print('Error loading veterinarias: $e');
    }
  }

  Future<void> loadVetRequests() async {
    try {
      final data = await _vetReqService.list(status: 'pending');
      setState(() {
        vetRequests = data;
      });
    } catch (e) {
      print('Error loading vet requests: $e');
    }
  }

  Future<void> approveVetRequest(int id, String name) async {
    final ok = await _vetReqService.approve(id);
    await loadVetRequests();
    await loadUsers();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok
            ? '$name ahora es veterinario'
            : 'No se pudo aprobar la solicitud'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  Future<void> rejectVetRequest(int id, String name) async {
    final ok = await _vetReqService.reject(id);
    await loadVetRequests();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Solicitud de $name rechazada' : 'No se pudo rechazar'),
        backgroundColor: ok ? Colors.orange : Colors.red,
      ),
    );
  }

  Future<void> updateVeterinaria(int vetId, Map<String, dynamic> body) async {
    try {
      final response = await http.patch(
        Uri.parse('http://167.99.4.161/api/veterinarias/$vetId'),
        headers: await _authHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        await loadVeterinarias();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veterinaria actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar veterinaria: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteVeterinaria(int vetId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://167.99.4.161/api/veterinarias/$vetId'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        await loadVeterinarias();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Veterinaria eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar veterinaria: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://167.99.4.161/api/users/$userId'),
        headers: await _authHeaders(),
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

  /// Cambia el rol de un usuario. roleId: '2'=CLIENTE, '3'=VETERINARIO.
  /// El backend REEMPLAZA los roles (PATCH /api/users/:id/role, solo ADMIN).
  Future<void> setUserRole(int userId, String roleId) async {
    try {
      final response = await http.patch(
        Uri.parse('http://167.99.4.161/api/users/$userId/role'),
        headers: await _authHeaders(),
        body: json.encode({'roleId': roleId}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await loadUsers();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(roleId == '3'
                ? 'Usuario ascendido a veterinario'
                : 'Usuario ahora es cliente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar rol (${response.statusCode})'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar rol: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> deletePet(int petId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://167.99.4.161/api/pets/$petId'),
        headers: await _authHeaders(),
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
            Tab(icon: Icon(Icons.local_hospital), text: 'Veterinarias'),
            Tab(icon: Icon(Icons.assignment_ind), text: 'Solicitudes'),
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
                    _buildVeterinariasTab(),
                    _buildVetRequestsTab(),
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
          // Los roles llegan como lista de {id, name}. El JWT usa IDs:
          // '1'=ADMIN, '2'=CLIENT, '3'=VET. Detectamos por nombre o por id.
          final rolesList = (user['roles'] as List?) ?? [];
          bool hasRole(String name, String id) => rolesList
              .any((r) => r['name'] == name || '${r['id']}' == id);
          final isAdmin = hasRole('ADMIN', '1');
          final isVet = hasRole('VET', '3');
          final roleLabel = isAdmin
              ? 'ADMINISTRADOR'
              : (isVet ? 'VETERINARIO' : 'CLIENTE');
          final roleColor = isAdmin
              ? Colors.red
              : (isVet ? Colors.blue : Colors.green);
          final roleIcon = isAdmin
              ? Icons.admin_panel_settings
              : (isVet ? Icons.local_hospital : Icons.person);

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isAdmin
                    ? Colors.red
                    : (isVet ? Colors.blue : const Color(0xFFFF9800)),
                child: Icon(roleIcon, color: Colors.white),
              ),
              title: Text('${user['name'] ?? ''} ${user['lastname'] ?? ''}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user['email'] ?? ''),
                  Text(
                    roleLabel,
                    style: TextStyle(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isAdmin) // Ascender/quitar VET (no aplica a admins)
                    IconButton(
                      tooltip: isVet
                          ? 'Quitar veterinario'
                          : 'Hacer veterinario',
                      icon: Icon(
                        isVet
                            ? Icons.medical_services
                            : Icons.medical_services_outlined,
                        color: isVet ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () => _confirmRoleChange(user, isVet),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => _showEditUserDialog(user),
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

  Widget _emptyState(IconData icon, String text, Future<void> Function() onRefresh) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        children: [
          const SizedBox(height: 120),
          Center(
            child: Column(
              children: [
                Icon(icon, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                Text(text, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    if (notifications.isEmpty) {
      return _emptyState(
          Icons.notifications_off, 'No hay notificaciones', loadNotifications);
    }
    return RefreshIndicator(
      onRefresh: loadNotifications,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          final isRead = n['isRead'] == true;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isRead ? Colors.grey : const Color(0xFFFF9800),
                child: const Icon(Icons.notifications, color: Colors.white),
              ),
              title: Text(
                n['title'] ?? 'Notificación',
                style: TextStyle(
                  fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Text(n['message'] ?? ''),
              trailing: Text(
                '${n['type'] ?? ''}',
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReportsTab() {
    if (reports.isEmpty) {
      return _emptyState(
          Icons.verified, 'No hay reportes pendientes', loadReports);
    }
    return RefreshIndicator(
      onRefresh: loadReports,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final r = reports[index];
          final status = '${r['status'] ?? 'pendiente'}';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.red,
                child: Icon(Icons.report, color: Colors.white),
              ),
              title: Text(r['reason'] ?? r['type'] ?? 'Reporte'),
              subtitle: Text(r['description'] ?? ''),
              trailing: Text(
                status,
                style: TextStyle(
                  color: status == 'pending' || status == 'pendiente'
                      ? Colors.orange
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVeterinariasTab() {
    final colorScheme = Theme.of(context).colorScheme;

    if (veterinarias.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_hospital, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No hay veterinarias registradas'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: loadVeterinarias,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: veterinarias.length,
        itemBuilder: (context, index) {
          final vet = veterinarias[index];
          final bool isVerified = vet['isVerified'] == true;
          final bool isActive = vet['isActive'] == true;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFFFF9800),
                        child: const Icon(Icons.local_hospital, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              vet['name'] ?? 'Sin nombre',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'RUC: ${vet['ruc'] ?? 'No especificado'}',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                            if (vet['address'] != null && '${vet['address']}'.isNotEmpty)
                              Text(
                                vet['address'],
                                style: TextStyle(
                                  color: colorScheme.onSurfaceVariant,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _statusChip(
                        isVerified ? 'Verificada' : 'Pendiente',
                        isVerified ? Colors.green : Colors.orange,
                        isVerified ? Icons.verified : Icons.hourglass_empty,
                      ),
                      _statusChip(
                        isActive ? 'Activa' : 'Inactiva',
                        isActive ? Colors.green : Colors.grey,
                        isActive ? Icons.check_circle : Icons.block,
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => updateVeterinaria(
                          vet['id'],
                          {'isVerified': !isVerified},
                        ),
                        icon: Icon(
                          isVerified ? Icons.gpp_bad : Icons.verified,
                          color: isVerified ? Colors.orange : Colors.green,
                          size: 20,
                        ),
                        label: Text(
                          isVerified ? 'Desverificar' : 'Verificar',
                          style: TextStyle(
                            color: isVerified ? Colors.orange : Colors.green,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => updateVeterinaria(
                          vet['id'],
                          {'isActive': !isActive},
                        ),
                        icon: Icon(
                          isActive ? Icons.toggle_off : Icons.toggle_on,
                          color: isActive ? Colors.grey : Colors.green,
                          size: 20,
                        ),
                        label: Text(
                          isActive ? 'Desactivar' : 'Activar',
                          style: TextStyle(
                            color: isActive ? Colors.grey : Colors.green,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(
                          'veterinaria',
                          vet['name'] ?? 'Veterinaria',
                          () => deleteVeterinaria(vet['id']),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVetRequestsTab() {
    if (vetRequests.isEmpty) {
      return RefreshIndicator(
        onRefresh: loadVetRequests,
        child: ListView(
          children: const [
            SizedBox(height: 120),
            Center(
              child: Column(
                children: [
                  Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No hay solicitudes pendientes'),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: loadVetRequests,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: vetRequests.length,
        itemBuilder: (context, index) {
          final r = vetRequests[index];
          final user = r['user'] as Map<String, dynamic>?;
          final email = user?['email'] ?? '';
          final name = r['fullName'] ?? user?['name'] ?? 'Solicitante';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.blue,
                        child: Icon(Icons.medical_services, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if ('$email'.isNotEmpty)
                              Text(
                                email,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if ('${r['clinicName'] ?? ''}'.isNotEmpty)
                    Text('🏥 ${r['clinicName']}'),
                  if ('${r['phone'] ?? ''}'.isNotEmpty) Text('📞 ${r['phone']}'),
                  if (r['ruc'] != null && '${r['ruc']}'.isNotEmpty)
                    Text('RUC: ${r['ruc']}'),
                  if ('${r['message'] ?? ''}'.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '"${r['message']}"',
                        style: const TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => rejectVetRequest(r['id'], name),
                        icon: const Icon(Icons.close, color: Colors.red, size: 20),
                        label: const Text('Rechazar',
                            style: TextStyle(color: Colors.red)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => approveVetRequest(r['id'], name),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check, size: 20),
                        label: const Text('Aprobar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _statusChip(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
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
        Uri.parse('http://167.99.4.161/api/users'),
        headers: await _authHeaders(),
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
        Uri.parse('http://167.99.4.161/api/pets'),
        headers: await _authHeaders(),
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
    final name = TextEditingController(text: user['name'] ?? '');
    final lastname = TextEditingController(text: user['lastname'] ?? '');
    final email = TextEditingController(text: user['email'] ?? '');
    final phone = TextEditingController(text: user['phone'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Usuario'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: lastname,
                decoration: const InputDecoration(labelText: 'Apellido'),
              ),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(labelText: 'Teléfono'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              updateUser(user['id'], {
                'name': name.text.trim(),
                'lastname': lastname.text.trim(),
                'email': email.text.trim(),
                'phone': phone.text.trim(),
              });
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showEditPetDialog(Map<String, dynamic> pet) {
    final name = TextEditingController(text: pet['name'] ?? '');
    final breed = TextEditingController(text: pet['breed'] ?? '');
    final age = TextEditingController(text: pet['age'] ?? '');
    final description = TextEditingController(text: pet['description'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Editar ${pet['name'] ?? 'Mascota'}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: breed,
                decoration: const InputDecoration(labelText: 'Raza'),
              ),
              TextField(
                controller: age,
                decoration: const InputDecoration(labelText: 'Edad'),
              ),
              TextField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Descripción'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              updatePet(pet['id'], {
                'name': name.text.trim(),
                'breed': breed.text.trim(),
                'age': age.text.trim(),
                'description': description.text.trim(),
              });
            },
            child: const Text('Guardar'),
          ),
        ],
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

  void _confirmRoleChange(Map<String, dynamic> user, bool isVet) {
    final name = '${user['name'] ?? ''} ${user['lastname'] ?? ''}'.trim();
    final toVet = !isVet; // si NO es vet, lo ascendemos; si lo es, lo quitamos
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(toVet ? 'Hacer veterinario' : 'Quitar veterinario'),
        content: Text(toVet
            ? '¿Ascender a "$name" a VETERINARIO? Podrá crear y gestionar la ficha de su veterinaria.'
            : '¿Quitar el rol de veterinario a "$name"? Volverá a ser CLIENTE.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setUserRole(user['id'], toVet ? '3' : '2');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: toVet ? Colors.blue : Colors.orange,
              foregroundColor: Colors.white,
            ),
            child: Text(toVet ? 'Ascender' : 'Quitar'),
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