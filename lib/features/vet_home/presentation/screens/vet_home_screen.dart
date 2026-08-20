/// La app vista por un veterinario: su panel de clínica, no el muro de un
/// usuario normal. Aquí lleva el control de sus citas, habla con sus clientes
/// y gestiona su tienda.
library;

import 'package:flutter/material.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/veterinaria_service.dart';
import '../../../../core/services/vet_store_service.dart';
import '../../../../core/services/appointment_service.dart';
import '../../../appointments/presentation/screens/appointments_screen.dart';
import '../../../chat/presentation/screens/conversations_screen.dart';
import '../../../veterinarias/presentation/screens/mi_clinica_screen.dart';
import '../../../veterinarias/presentation/screens/clinica_screen.dart';
import '../../../veterinarias/presentation/screens/my_veterinaria_screen.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  State<VetHomeScreen> createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> {
  static const Color _brand = Color(0xFFFF9800);

  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pantallas = [
      const _InicioVet(),
      const AppointmentsScreen(),
      const ConversationsScreen(),
      const _TiendaVet(),
    ];

    return Scaffold(
      body: IndexedStack(index: _tab, children: pantallas),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        indicatorColor: _brand.withValues(alpha: 0.2),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: _brand),
            label: 'Inicio',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note, color: _brand),
            label: 'Citas',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble, color: _brand),
            label: 'Mensajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront, color: _brand),
            label: 'Mi tienda',
          ),
        ],
      ),
    );
  }
}

/// Portada del veterinario: cómo va su día de un vistazo y accesos directos.
class _InicioVet extends StatefulWidget {
  const _InicioVet();

  @override
  State<_InicioVet> createState() => _InicioVetState();
}

class _InicioVetState extends State<_InicioVet> {
  static const Color _brand = Color(0xFFFF9800);

  final VeterinariaService _vets = VeterinariaService();
  final VetStoreService _store = VetStoreService();
  final AppointmentService _citas = AppointmentService();

  Map<String, dynamic>? _clinica;
  int _pendientes = 0;
  int _productos = 0;
  int _libresHoy = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final mias = await _vets.listMine();
      final clinica = mias.isNotEmpty ? mias.first : null;

      var pendientes = 0;
      var productos = 0;
      var libres = 0;

      final recibidas = await _citas.forVet();
      pendientes = recibidas.where((c) => c['status'] == 'pending').length;

      if (clinica != null) {
        final id = clinica['id'] as int;
        productos = (await _store.getProductosDelDueno(id)).length;
        final (huecos, _) = await _store.getHuecosLibres(id, DateTime.now());
        libres = huecos.length;
      }

      if (!mounted) return;
      setState(() {
        _clinica = clinica;
        _pendientes = pendientes;
        _productos = productos;
        _libresHoy = libres;
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
    // Al volver puede haber cambiado el catálogo o una cita: refrescar.
    _cargar();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final nombre = _clinica?['name']?.toString() ?? 'Tu clínica';
    final verificada = _clinica?['isVerified'] == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel del veterinario'),
        backgroundColor: _brand,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Ver la app como usuario',
            icon: const Icon(Icons.pets),
            onPressed: () => _abrir(
              const DashboardScreen(isAuthenticated: true),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Se guarda el navegador ANTES del await: después, usar el
              // context del State para navegar es justo lo que avisa el linter.
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
                  // Cabecera de la clínica
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_brand, _brand.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.local_hospital,
                                color: Colors.white, size: 30),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                nombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              verificada ? Icons.verified : Icons.pending,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              verificada
                                  ? 'Clínica verificada · visible para todos'
                                  : 'Pendiente de que el admin la verifique',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                        if (_clinica != null) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _abrir(
                                ClinicaScreen(veterinaria: _clinica!),
                              ),
                              icon: const Icon(Icons.visibility,
                                  color: Colors.white),
                              label: const Text(
                                'Ver mi tienda como la ven los clientes',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.white70),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (_clinica == null) ...[
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.orange.shade50,
                      child: ListTile(
                        leading: const Icon(Icons.warning_amber,
                            color: Colors.orange),
                        title: const Text('Todavía no tienes ficha de clínica'),
                        subtitle: const Text(
                            'Créala para poder publicar tu catálogo y recibir citas.'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _abrir(const MyVeterinariaScreen()),
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),
                  // Cómo va el día
                  Row(
                    children: [
                      _metrica('Citas por\nconfirmar', '$_pendientes',
                          Icons.pending_actions, Colors.deepPurple, scheme),
                      const SizedBox(width: 10),
                      _metrica('Turnos libres\nhoy', '$_libresHoy',
                          Icons.event_available, Colors.teal, scheme),
                      const SizedBox(width: 10),
                      _metrica('En el\ncatálogo', '$_productos',
                          Icons.inventory_2, _brand, scheme),
                    ],
                  ),

                  const SizedBox(height: 22),
                  const Text('Gestiona tu clínica',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),

                  _accion(
                    Icons.storefront,
                    'Mi catálogo',
                    'Sube tus productos y servicios con foto o vídeo',
                    _brand,
                    () => _clinica == null
                        ? _abrir(const MyVeterinariaScreen())
                        : _abrir(MiClinicaScreen(veterinaria: _clinica!)),
                  ),
                  _accion(
                    Icons.event_note,
                    'Citas recibidas',
                    _pendientes > 0
                        ? '$_pendientes esperando tu respuesta'
                        : 'Confirma o rechaza las solicitudes',
                    Colors.deepPurple,
                    () => _abrir(const AppointmentsScreen()),
                  ),
                  _accion(
                    Icons.chat,
                    'Mensajes de clientes',
                    'Conversa con quienes te escriben',
                    Colors.green,
                    () => _abrir(const ConversationsScreen()),
                  ),
                  _accion(
                    Icons.schedule,
                    'Horario y agenda',
                    'Tus horas de atención y tu propio sistema de citas',
                    Colors.blueGrey,
                    () => _clinica == null
                        ? _abrir(const MyVeterinariaScreen())
                        : _abrir(MiClinicaScreen(veterinaria: _clinica!)),
                  ),
                  _accion(
                    Icons.badge,
                    'Datos de la clínica',
                    'Dirección, teléfono, RUC y descripción',
                    Colors.indigo,
                    () => _abrir(const MyVeterinariaScreen()),
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
        title: Text(titulo,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(detalle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Pestaña "Mi tienda": abre directamente el panel de la clínica.
class _TiendaVet extends StatefulWidget {
  const _TiendaVet();

  @override
  State<_TiendaVet> createState() => _TiendaVetState();
}

class _TiendaVetState extends State<_TiendaVet> {
  final VeterinariaService _vets = VeterinariaService();
  Map<String, dynamic>? _clinica;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final mias = await _vets.listMine();
      if (!mounted) return;
      setState(() {
        _clinica = mias.isNotEmpty ? mias.first : null;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_clinica == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mi tienda')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: Text(
              'Primero crea la ficha de tu clínica desde Inicio.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }
    return MiClinicaScreen(veterinaria: _clinica!);
  }
}
