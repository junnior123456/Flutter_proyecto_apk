import 'package:flutter/material.dart';
import '../../../../core/services/adoption_service.dart';
import '../../../../core/constants/app_colors.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final AdoptionService _adoptionService = AdoptionService();
  List<Map<String, dynamic>> _requests = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  Future<void> _loadRequests() async {
    setState(() => _isLoading = true);
    
    try {
      final requests = await _adoptionService.getMyRequests();
      setState(() {
        _requests = requests;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      
      // No mostrar error si es por falta de autenticación
      final errorMessage = e.toString();
      if (!errorMessage.contains('Unauthorized') && 
          !errorMessage.contains('No hay token')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al cargar solicitudes: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Solicitudes', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : _requests.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadRequests,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      final request = _requests[index];
                      return _buildRequestCard(request);
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tienes solicitudes',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Envía una solicitud de adopción para verla aquí',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final status = request['status'] as String;
    final pet = request['pet'] as Map<String, dynamic>?;
    final petName = pet?['name'] ?? 'Mascota';
    final petImage = pet?['images'] != null && (pet!['images'] as List).isNotEmpty
        ? pet['images'][0]['imageUrl']
        : null;
    final createdAt = DateTime.parse(request['createdAt']);
    final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year}';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Imagen de la mascota
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: petImage != null
                      ? Image.network(
                          petImage,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.pets, color: Colors.grey),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.pets, color: Colors.grey),
                        ),
                ),
                const SizedBox(width: 12),
                // Información
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        petName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enviada: $formattedDate',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                // Badge de estado
                _buildStatusBadge(status),
              ],
            ),
            
            // Información adicional según el estado
            if (status == 'approved') ...[
              const Divider(height: 24),
              _buildApprovedInfo(request),
            ] else if (status == 'awaiting_adopter_confirmation') ...[
              const Divider(height: 24),
              _buildAwaitingConfirmationInfo(request),
              const SizedBox(height: 12),
              // Botón para confirmar recepción
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleConfirmReception(request),
                  icon: const Icon(Icons.check_circle, size: 20),
                  label: const Text('Confirmar que Recibí la Mascota'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ] else if (status == 'rejected') ...[
              const Divider(height: 24),
              _buildRejectedInfo(request),
            ] else if (status == 'completed') ...[
              const Divider(height: 24),
              _buildCompletedInfo(request),
            ] else if (status == 'pending') ...[
              const Divider(height: 24),
              Text(
                '⏳ Esperando respuesta del dueño',
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Pendiente';
        icon = Icons.schedule;
        break;
      case 'approved':
        color = Colors.green;
        text = 'Aceptada';
        icon = Icons.check_circle;
        break;
      case 'rejected':
        color = Colors.red;
        text = 'Rechazada';
        icon = Icons.cancel;
        break;
      case 'awaiting_adopter_confirmation':
        color = Colors.orange;
        text = 'Confirmar Recepción';
        icon = Icons.touch_app;
        break;
      case 'completed':
        color = Colors.green;
        text = 'Completada';
        icon = Icons.celebration;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovedInfo(Map<String, dynamic> request) {
    final donorComments = request['donorComments'] as String?;
    final pet = request['pet'] as Map<String, dynamic>?;
    final petOwner = pet?['user'] as Map<String, dynamic>?;
    final ownerPhone = petOwner?['phone'] ?? 'No disponible';
    
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '¡Solicitud Aceptada!',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (donorComments != null && donorComments.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  '💬 Mensaje del dueño:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  donorComments,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.phone, size: 16, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    'Teléfono: $ownerPhone',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                '📞 Coordina con el dueño para recoger la mascota',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Botón para confirmar que recogió la mascota
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _handleAdopterConfirmPickup(request),
            icon: const Icon(Icons.pets, size: 20),
            label: const Text('Ya Recogí la Mascota'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedInfo(Map<String, dynamic> request) {
    final rejectionReason = request['rejectionReason'] as String?;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.cancel, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                'Solicitud Rechazada',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              '📝 Razón:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              rejectionReason,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAwaitingConfirmationInfo(Map<String, dynamic> request) {
    final donorConfirmedAt = request['donorConfirmedAt'] != null 
        ? DateTime.parse(request['donorConfirmedAt'])
        : null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.touch_app, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                '¡El dueño confirmó la entrega!',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '✅ El dueño ya confirmó que te entregó la mascota',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            '👇 Ahora confirma que la recibiste para completar la adopción',
            style: TextStyle(fontSize: 14),
          ),
          if (donorConfirmedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Entregada el: ${donorConfirmedAt.day}/${donorConfirmedAt.month}/${donorConfirmedAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedInfo(Map<String, dynamic> request) {
    final completedAt = request['completedAt'] != null 
        ? DateTime.parse(request['completedAt'])
        : null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.celebration, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                '¡Adopción Completada!',
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            '🎉 ¡Felicidades! Has adoptado exitosamente a esta mascota',
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            '✅ Ambas partes confirmaron la adopción',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          if (completedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Fecha de adopción: ${completedAt.day}/${completedAt.month}/${completedAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ Adoptante confirma que recogió la mascota (desde estado approved)
  Future<void> _handleAdopterConfirmPickup(Map<String, dynamic> request) async {
    final pet = request['pet'] as Map<String, dynamic>?;
    final petName = pet?['name'] ?? 'la mascota';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.pets, color: Colors.blue),
            SizedBox(width: 8),
            Text('Confirmar Recogida'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Confirmas que ya recogiste a $petName?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Al confirmar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• Notificarás al dueño que recogiste la mascota'),
                  Text('• El dueño deberá confirmar la entrega'),
                  Text('• Cuando ambos confirmen, la adopción se completará'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, Ya la Recogí'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _adoptionService.adopterConfirmReception(request['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Confirmado. Esperando que el dueño confirme la entrega.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 4),
            ),
          );
          _loadRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al confirmar: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// ✅ Confirmar recepción de mascota (Adoptante)
  Future<void> _handleConfirmReception(Map<String, dynamic> request) async {
    final pet = request['pet'] as Map<String, dynamic>?;
    final petName = pet?['name'] ?? 'la mascota';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.celebration, color: Colors.green),
            SizedBox(width: 8),
            Text('Confirmar Recepción'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Confirmas que recibiste a $petName?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '🎉 ¡Última confirmación!',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• La adopción se completará'),
                  Text('• Ambas partes quedarán confirmadas'),
                  Text('• La mascota será oficialmente tuya'),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _adoptionService.adopterConfirmReception(request['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('🎉 ¡Adopción completada exitosamente! ¡Felicidades!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          _loadRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al confirmar recepción: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
