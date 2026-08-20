/// Clínicas registradas, desde el lado del administrador: verificarlas para
/// que salgan al directorio, o darlas de baja.
library;

import 'package:flutter/material.dart';
import '../../../../core/services/veterinaria_service.dart';
import '../../../veterinarias/presentation/screens/clinica_screen.dart';

class VeterinariasAdminScreen extends StatefulWidget {
  const VeterinariasAdminScreen({super.key});

  @override
  State<VeterinariasAdminScreen> createState() =>
      _VeterinariasAdminScreenState();
}

class _VeterinariasAdminScreenState extends State<VeterinariasAdminScreen> {
  static const Color _admin = Color(0xFF3949AB);

  final VeterinariaService _service = VeterinariaService();
  List<Map<String, dynamic>> _clinicas = [];
  bool _cargando = true;
  int? _procesando;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _cargando = true);
    try {
      final todas = await _service.listAll();
      if (!mounted) return;
      setState(() {
        // Las que faltan por verificar arriba: son las que piden acción.
        todas.sort((a, b) {
          final av = a['isVerified'] == true ? 1 : 0;
          final bv = b['isVerified'] == true ? 1 : 0;
          return av.compareTo(bv);
        });
        _clinicas = todas;
        _cargando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cargando = false);
    }
  }

  Future<void> _cambiar(
      Map<String, dynamic> v, String campo, bool valor) async {
    setState(() => _procesando = v['id'] as int);
    try {
      await _service.update(v['id'] as int, {campo: valor});
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(campo == 'isVerified'
              ? (valor
                  ? 'Clínica verificada: ya sale en el directorio'
                  : 'Verificación retirada')
              : (valor ? 'Clínica activada' : 'Clínica dada de baja')),
          backgroundColor: valor ? Colors.green : Colors.orange,
        ),
      );
      _cargar();
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = null);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('No se pudo actualizar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Clínicas registradas'),
        backgroundColor: _admin,
        foregroundColor: Colors.white,
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargar,
              child: _clinicas.isEmpty
                  ? ListView(children: const [
                      SizedBox(height: 140),
                      Icon(Icons.local_hospital_outlined,
                          size: 56, color: Colors.grey),
                      SizedBox(height: 12),
                      Center(child: Text('Todavía no hay clínicas.')),
                    ])
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _clinicas.length,
                      itemBuilder: (_, i) {
                        final v = _clinicas[i];
                        final verificada = v['isVerified'] == true;
                        final activa = v['isActive'] == true;
                        final ocupado = _procesando == v['id'];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: (verificada
                                              ? Colors.green
                                              : Colors.orange)
                                          .withValues(alpha: 0.15),
                                      child: Icon(
                                        verificada
                                            ? Icons.verified
                                            : Icons.pending,
                                        color: verificada
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            v['name']?.toString() ?? '',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'RUC ${v['ruc'] ?? '—'} · '
                                            '${v['address'] ?? 'sin dirección'}',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: scheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (ocupado)
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                  ],
                                ),
                                const Divider(height: 20),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: const Text('Verificada'),
                                  subtitle: const Text(
                                    'Solo las verificadas salen en el directorio',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  value: verificada,
                                  onChanged: ocupado
                                      ? null
                                      : (x) => _cambiar(v, 'isVerified', x),
                                ),
                                SwitchListTile(
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                  title: const Text('Activa'),
                                  subtitle: const Text(
                                    'Desactivarla la retira sin borrar nada',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  value: activa,
                                  onChanged: ocupado
                                      ? null
                                      : (x) => _cambiar(v, 'isActive', x),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ClinicaScreen(veterinaria: v),
                                      ),
                                    ),
                                    icon: const Icon(Icons.storefront,
                                        size: 18),
                                    label: const Text('Ver su tienda'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
