/// La app vista por el super administrador: control de la plataforma, no el
/// muro de un usuario. Desde aquí evalúa las solicitudes de las veterinarias,
/// les da el acceso y vigila qué está pasando.
library;

import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/veterinaria_service.dart';
import '../../../../core/services/vet_request_service.dart';
import '../../../../presentation/screens/admin_panel_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import 'solicitudes_vet_screen.dart';
import 'veterinarias_admin_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  static const Color _admin = Color(0xFF3949AB);

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      const _InicioAdmin(),
      const SolicitudesVetScreen(),
      const VeterinariasAdminScreen(),
      const AdminPanelScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: _admin.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.shield_outlined),
            selectedIcon: Icon(Icons.shield, color: _admin),
            label: 'Control',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_ind_outlined),
            selectedIcon: Icon(Icons.assignment_ind, color: _admin),
            label: 'Solicitudes',
          ),
          NavigationDestination(
            icon: Icon(Icons.local_hospital_outlined),
            selectedIcon: Icon(Icons.local_hospital, color: _admin),
            label: 'Clínicas',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            selectedIcon: Icon(Icons.tune, color: _admin),
            label: 'Panel',
          ),
        ],
      ),
    );
  }
}

/// Portada del administrador: qué necesita su atención AHORA.
class _InicioAdmin extends StatefulWidget {
  const _InicioAdmin();

  @override
  State<_InicioAdmin> createState() => _InicioAdminState();
}

class _InicioAdminState extends State<_InicioAdmin> {
  static const Color _admin = Color(0xFF3949AB);

  final VetRequestService _solicitudes = VetRequestService();
  final VeterinariaService _vets = VeterinariaService();

  int _pendientes = 0;
  int _sinVerificar = 0;
  int _clinicas = 0;
  int _activas = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final pendientes = await _solicitudes.list(status: 'pending');
      final todas = await _vets.listAll();
      if (!mounted) return;
      setState(() {
        _pendientes = pendientes.length;
        _clinicas = todas.length;
        _sinVerificar = todas.where((v) => v['isVerified'] != true).length;
        _activas = todas.where((v) => v['isActive'] == true).length;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => pantalla),
    );
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración'),
        backgroundColor: _admin,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Ver la app como usuario',
            icon: const Icon(Icons.pets),
            onPressed: () =>
                _abrir(const DashboardScreen(isAuthenticated: true)),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final navegador = Navigator.of(context);
              await AuthService().logout();
              if (!mounted) return;
              navegador.pushNamedAndRemoveUntil('/welcome', (_) => false);
            },
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_admin, _admin.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.shield, color: Colors.white, size: 32),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Super administrador',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Control de la plataforma y de las clínicas',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lo que necesita atención va PRIMERO y en color: si hay
                  // solicitudes esperando, es lo único que importa al entrar.
                  if (_pendientes > 0) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.orange.shade50,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.orange,
                          child: Icon(Icons.assignment_late,
                              color: Colors.white),
                        ),
                        title: Text(
                          _pendientes == 1
                              ? '1 veterinaria espera tu evaluación'
                              : '$_pendientes veterinarias esperan tu evaluación',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                            'Revisa sus datos y dales acceso, o recházalas.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _abrir(const SolicitudesVetScreen()),
                      ),
                    ),
                  ],
                  if (_sinVerificar > 0) ...[
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.blue.shade50,
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.verified_user, color: Colors.white),
                        ),
                        title: Text(
                          _sinVerificar == 1
                              ? '1 clínica sin verificar'
                              : '$_sinVerificar clínicas sin verificar',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                            'Hasta que las verifiques no salen en el directorio.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _abrir(const VeterinariasAdminScreen()),
                      ),
                    ),
                  ],

                  const SizedBox(height: 18),
                  Row(
                    children: [
                      _metrica('Solicitudes\npendientes', '$_pendientes',
                          Icons.assignment_ind, Colors.orange, scheme),
                      const SizedBox(width: 10),
                      _metrica('Clínicas\nregistradas', '$_clinicas',
                          Icons.local_hospital, _admin, scheme),
                      const SizedBox(width: 10),
                      _metrica('Clínicas\nactivas', '$_activas',
                          Icons.check_circle, Colors.green, scheme),
                    ],
                  ),

                  const SizedBox(height: 22),
                  const Text('Gestión',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  _accion(
                    Icons.assignment_ind,
                    'Solicitudes de veterinarias',
                    'Evalúa y da acceso de veterinario',
                    Colors.orange,
                    () => _abrir(const SolicitudesVetScreen()),
                  ),
                  _accion(
                    Icons.local_hospital,
                    'Clínicas',
                    'Verificar, activar o dar de baja',
                    _admin,
                    () => _abrir(const VeterinariasAdminScreen()),
                  ),
                  _accion(
                    Icons.tune,
                    'Panel completo',
                    'Usuarios, mascotas, adopciones, reportes y más',
                    Colors.teal,
                    () => _abrir(const AdminPanelScreen()),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _metrica(String titulo, String valor, IconData icono, Color color,
      ColorScheme scheme) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icono, color: color),
            const SizedBox(height: 6),
            Text(valor,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _accion(IconData icono, String titulo, String detalle, Color color,
      VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icono, color: color),
        ),
        title:
            Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(detalle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
