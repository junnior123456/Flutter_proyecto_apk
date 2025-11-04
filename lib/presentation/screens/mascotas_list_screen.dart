import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../application/bloc/mascota_bloc.dart';
import '../../application/bloc/mascota_event.dart';
import '../../application/bloc/mascota_state.dart';
import '../widgets/mascota_card.dart';
import 'reportar_mascota_screen.dart';

class MascotasListScreen extends StatefulWidget {
  const MascotasListScreen({super.key});

  @override
  State<MascotasListScreen> createState() => _MascotasListScreenState();
}

class _MascotasListScreenState extends State<MascotasListScreen> {

  @override
  void initState() {
    super.initState();
    context.read<MascotaBloc>().add(LoadMascotas());
  }

  void _openReport(String estadoPredeterminado) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReportarMascotaScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mascotas')),
      body: BlocBuilder<MascotaBloc, MascotaState>(
        builder: (context, state) {
          if (state is MascotaLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MascotaLoaded) {
              final adoptables = state.mascotas.where((m) => m.estado == 'adopcion').toList();
              final riesgos = state.mascotas.where((m) => m.estado == 'riesgo').toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          title: 'Poner en Adopción',
                          subtitle: 'Publicar perros para adoptar (sujeto a aceptación del admin)',
                          icon: Icons.pets,
                          onAdd: () => _openReport('adopcion'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          title: 'Perritos en Riesgo',
                          subtitle: 'Ver perros publicados en riesgo',
                          icon: Icons.warning,
                          onAdd: () => _openReport('perdido'),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Lista de riesgos
                  const Text('Perritos en Riesgo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  riesgos.isEmpty
                      ? const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Text('Aquí verás los perritos en riesgo publicados.'),
                        ))
                      : Column(children: riesgos.map((m) => MascotaCard(mascota: m)).toList()),

                  const SizedBox(height: 20),

                  // Lista de adopción
                  const Text('Poner en Adopción', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  adoptables.isEmpty
                      ? const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24.0),
                          child: Text('Aquí verás los perritos publicados para adopción.'),
                        ))
                      : Column(children: adoptables.map((m) => MascotaCard(mascota: m)).toList()),
                ],
              ),
            );
          } else if (state is MascotaError) {
            return Center(child: Text(state.message));
          }
          return const Center(child: Text('No hay mascotas disponibles.'));
        },
      ),
    );
  }

  Widget _buildActionCard({required String title, required String subtitle, required IconData icon, required VoidCallback onAdd}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: Colors.orange),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
              IconButton(onPressed: onAdd, icon: const Icon(Icons.add, color: Colors.orange)),
            ],
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
