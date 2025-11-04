import 'package:flutter/material.dart';
import '../../domain/entities/mascota.dart';
import '../screens/mascota_detail_screen.dart';

class MascotaCard extends StatelessWidget {
  final Mascota mascota;
  const MascotaCard({super.key, required this.mascota});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: mascota.foto.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  mascota.foto,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.pets, size: 40);
                  },
                ),
              )
            : const Icon(Icons.pets, size: 40),
        title: Text(mascota.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${mascota.tipo} - ${mascota.raza}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getEstadoColor(mascota.estado),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                mascota.estado.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Icon(
          _getEstadoIcon(mascota.estado),
          color: _getEstadoColor(mascota.estado),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MascotaDetailScreen(mascota: mascota),
            ),
          );
        },
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

  IconData _getEstadoIcon(String estado) {
    switch (estado.toLowerCase()) {
      case 'perdido':
        return Icons.warning;
      case 'adopcion':
        return Icons.volunteer_activism;
      case 'encontrado':
        return Icons.check_circle;
      default:
        return Icons.pets;
    }
  }
}
