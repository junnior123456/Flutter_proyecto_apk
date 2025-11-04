import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/mascota.dart';
import '../../application/bloc/mascota_bloc.dart';
import '../../application/bloc/mascota_event.dart';

class MascotaDetailScreen extends StatelessWidget {
  final Mascota mascota;

  const MascotaDetailScreen({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(mascota.nombre),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen de la mascota
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[300],
              ),
              child: mascota.foto.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        mascota.foto,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.pets, size: 100);
                        },
                      ),
                    )
                  : const Icon(Icons.pets, size: 100),
            ),
            const SizedBox(height: 20),

            // Estado de la mascota
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getEstadoColor(mascota.estado),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                mascota.estado.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Información básica
            _buildInfoCard("Información Básica", [
              _buildInfoRow("Nombre", mascota.nombre),
              _buildInfoRow("Tipo", mascota.tipo),
              _buildInfoRow("Raza", mascota.raza),
              _buildInfoRow("Edad", mascota.edad),
            ]),

            const SizedBox(height: 16),

            // Contacto
            _buildInfoCard("Contacto", [
              _buildInfoRow("Dueño", mascota.dueno),
              _buildInfoRow("Teléfono", mascota.telefono),
              _buildInfoRow("Ubicación", mascota.ubicacion),
            ]),

            const SizedBox(height: 16),

            // Descripción
            if (mascota.descripcion.isNotEmpty) ...[
              _buildInfoCard("Descripción", [
                Text(
                  mascota.descripcion,
                  style: const TextStyle(fontSize: 16),
                ),
              ]),
              const SizedBox(height: 20),
            ],

            // Botones de acción
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _mostrarDialogoContacto(context);
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text("Contactar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: mascota.estado == 'perdido'
                        ? () => _reportarEncontrado(context)
                        : null,
                    icon: const Icon(Icons.favorite),
                    label: Text(mascota.estado == 'perdido' 
                        ? "Encontrado" 
                        : "Adoptar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEstadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'perdido':
        return Colors.red;
      case 'adopcion':
        return Colors.blue;
      case 'encontrado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _mostrarDialogoContacto(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contacto"),
          content: Text("Puedes contactar a ${mascota.dueno} al número: ${mascota.telefono}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  void _reportarEncontrado(BuildContext context) {
    context.read<MascotaBloc>().add(MarcarMascotaFueraRiesgoEvent(mascota.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("¡Gracias! Se ha reportado como fuera de riesgo."),
        backgroundColor: Colors.green,
      ),
    );
  }
}