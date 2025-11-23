import 'package:flutter/material.dart';
import '../../../../core/services/adoption_service.dart';
import '../../../../core/constants/app_colors.dart';
import '../dialogs/accept_request_dialog.dart';
import '../dialogs/reject_request_dialog.dart';

class ReceivedRequestsScreen extends StatefulWidget {
  const ReceivedRequestsScreen({super.key});

  @override
  State<ReceivedRequestsScreen> createState() => _ReceivedRequestsScreenState();
}

class _ReceivedRequestsScreenState extends State<ReceivedRequestsScreen> {
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
      final requests = await _adoptionService.getReceivedRequests();
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

  Future<void> _handleAccept(Map<String, dynamic> request) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AcceptRequestDialog(request: request),
    );

    if (result != null && mounted) {
      try {
        await _adoptionService.acceptRequest(
          requestId: request['id'],
          donorComments: result['message']!,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Solicitud aceptada exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          _loadRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al aceptar solicitud: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleComplete(Map<String, dynamic> request) async {
    // Mostrar diálogo de confirmación
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.blue),
            SizedBox(width: 12),
            Text('Completar Adopción'),
          ],
        ),
        content: Text(
          '¿Confirmas que has entregado a ${request['pet']?['name'] ?? 'la mascota'} a ${request['adopter']?['name'] ?? 'el adoptante'}?\n\nEl adoptante deberá confirmar la recepción para finalizar el proceso.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            child: const Text('Confirmar Entrega'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _adoptionService.completeAdoption(request['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Entrega confirmada. Esperando confirmación del adoptante.'),
              backgroundColor: Colors.blue,
            ),
          );
          _loadRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al completar adopción: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReject(Map<String, dynamic> request) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => RejectRequestDialog(request: request),
    );

    if (reason != null && mounted) {
      try {
        await _adoptionService.rejectRequest(
          requestId: request['id'],
          rejectionReason: reason,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Solicitud rechazada'),
              backgroundColor: Colors.orange,
            ),
          );
          _loadRequests();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al rechazar solicitud: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  /// 👁️ Mostrar detalles completos de la solicitud
  void _showRequestDetails(Map<String, dynamic> request) {
    final pet = request['pet'] as Map<String, dynamic>?;
    final adopter = request['adopter'] as Map<String, dynamic>?;
    final status = request['status'] as String;
    
    final petName = pet?['name'] ?? 'Mascota';
    final adopterName = '${adopter?['name'] ?? ''} ${adopter?['lastname'] ?? ''}'.trim();
    final adopterEmail = adopter?['email'] ?? '';
    final adopterPhone = adopter?['phone'] ?? 'No proporcionado';
    
    final createdAt = DateTime.parse(request['createdAt']);
    final formattedDate = '${createdAt.day}/${createdAt.month}/${createdAt.year}';

    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            maxWidth: 500,
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.orange[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.pets, color: Colors.orange[700], size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Solicitud de Adopción',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[900],
                            ),
                          ),
                          Text(
                            'Para: $petName',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),

              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Estado
                      Center(child: _buildStatusBadge(status)),
                      
                      const SizedBox(height: 20),
                      
                      // Información del adoptante
                      _buildDetailSection(
                        icon: Icons.person,
                        title: 'Información del Adoptante',
                        children: [
                          _buildDetailRow('Nombre', adopterName),
                          _buildDetailRow('Email', adopterEmail),
                          _buildDetailRow('Teléfono', adopterPhone),
                          _buildDetailRow('Fecha de solicitud', formattedDate),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Información personal
                      if (request['personalInfo'] != null)
                        _buildDetailSection(
                          icon: Icons.info,
                          title: 'Información Personal',
                          children: [
                            Text(
                              request['personalInfo'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Situación de vivienda
                      if (request['livingSituation'] != null)
                        _buildDetailSection(
                          icon: Icons.home,
                          title: 'Situación de Vivienda',
                          children: [
                            Text(
                              request['livingSituation'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Motivo de adopción
                      if (request['adoptionReason'] != null)
                        _buildDetailSection(
                          icon: Icons.favorite,
                          title: 'Motivo de Adopción',
                          children: [
                            Text(
                              request['adoptionReason'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Experiencia previa
                      if (request['previousExperience'] != null && 
                          request['previousExperience'].toString().isNotEmpty)
                        _buildDetailSection(
                          icon: Icons.pets,
                          title: 'Experiencia con Mascotas',
                          children: [
                            Text(
                              request['previousExperience'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      
                      const SizedBox(height: 20),
                      
                      // Características adicionales
                      _buildDetailSection(
                        icon: Icons.checklist,
                        title: 'Características',
                        children: [
                          _buildCheckRow(
                            'Tiene patio',
                            request['hasYard'] == true,
                          ),
                          _buildCheckRow(
                            'Tiene otras mascotas',
                            request['hasOtherPets'] == true,
                          ),
                        ],
                      ),
                      
                      // Información de respuesta
                      if (status == 'approved' && request['donorComments'] != null) ...[
                        const SizedBox(height: 20),
                        _buildDetailSection(
                          icon: Icons.check_circle,
                          title: 'Tu Respuesta (Aceptada)',
                          color: Colors.green,
                          children: [
                            Text(
                              request['donorComments'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                      
                      if (status == 'rejected' && request['rejectionReason'] != null) ...[
                        const SizedBox(height: 20),
                        _buildDetailSection(
                          icon: Icons.cancel,
                          title: 'Razón del Rechazo',
                          color: Colors.red,
                          children: [
                            Text(
                              request['rejectionReason'].toString(),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              // Botones de acción
              if (status == 'pending')
                // Botones para solicitudes pendientes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border(
                      top: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleAccept(request);
                          },
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text('Aceptar'),
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
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);
                            _handleReject(request);
                          },
                          icon: const Icon(Icons.close, size: 20),
                          label: const Text('Rechazar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else if (status == 'approved')
                // Botón para completar adopción (solicitudes aprobadas)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    border: Border(
                      top: BorderSide(color: Colors.blue[200]!),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleComplete(request);
                      },
                      icon: const Icon(Icons.check_circle, size: 20),
                      label: const Text('Completar Adopción'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📋 Widget para sección de detalles
  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required List<Widget> children,
    Color? color,
  }) {
    final sectionColor = color ?? Colors.orange;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sectionColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: sectionColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: sectionColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: sectionColor.withOpacity(0.9),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  /// 📝 Widget para fila de detalle
  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Widget para checkbox de característica
  Widget _buildCheckRow(String label, bool value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            value ? Icons.check_circle : Icons.cancel,
            color: value ? Colors.green : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitudes Recibidas', style: TextStyle(color: Colors.white)),
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
            'No tienes solicitudes recibidas',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando alguien solicite adoptar tus mascotas\naparecerán aquí',
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
    final adopter = request['adopter'] as Map<String, dynamic>?;
    
    final petName = pet?['name'] ?? 'Mascota';
    final adopterName = '${adopter?['name'] ?? ''} ${adopter?['lastname'] ?? ''}'.trim();
    final adopterEmail = adopter?['email'] ?? '';
    
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
            // Encabezado
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Para: $petName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'De: $adopterName',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(status),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Email del adoptante
            Row(
              children: [
                const Icon(Icons.email, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    adopterEmail,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Fecha
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Recibida: $formattedDate',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),
            
            // Vista previa de información
            const Divider(height: 24),
            
            // Información resumida del adoptante
            if (request['personalInfo'] != null) ...[
              const Text(
                '📋 Información del adoptante:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                request['personalInfo'].toString().length > 50
                    ? '${request['personalInfo'].toString().substring(0, 50)}...'
                    : request['personalInfo'].toString(),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
            
            if (request['adoptionReason'] != null) ...[
              const SizedBox(height: 8),
              const Text(
                '💭 Motivo de adopción:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                request['adoptionReason'].toString().length > 50
                    ? '${request['adoptionReason'].toString().substring(0, 50)}...'
                    : request['adoptionReason'].toString(),
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
            
            // Botón para ver detalles completos
            const SizedBox(height: 12),
            Center(
              child: TextButton.icon(
                onPressed: () => _showRequestDetails(request),
                icon: const Icon(Icons.visibility, size: 18),
                label: const Text('Ver Detalles Completos'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.orange,
                ),
              ),
            ),
            
            // Botones de acción (solo si está pendiente)
            if (status == 'pending') ...[
              const Divider(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAccept(request),
                      icon: const Icon(Icons.check, size: 20),
                      label: const Text('Aceptar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _handleReject(request),
                      icon: const Icon(Icons.close, size: 20),
                      label: const Text('Rechazar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            
            // Información de respuesta (si ya fue respondida)
            if (status == 'approved') ...[
              const Divider(height: 24),
              _buildApprovedInfo(request),
              const SizedBox(height: 12),
              // Botón para confirmar entrega
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handleCompleteAdoption(request),
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  label: const Text('Confirmar Entrega de Mascota'),
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
            ] else if (status == 'awaiting_adopter_confirmation') ...[
              const Divider(height: 24),
              _buildAwaitingAdopterInfo(request),
            ] else if (status == 'rejected') ...[
              const Divider(height: 24),
              _buildRejectedInfo(request),
            ] else if (status == 'completed') ...[
              const Divider(height: 24),
              _buildCompletedInfo(request),
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
        text = 'Esperando Adoptante';
        icon = Icons.hourglass_empty;
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
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                'Solicitud Aceptada',
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
              '💬 Tu mensaje:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              donorComments,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
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
              '📝 Razón del rechazo:',
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

  Widget _buildAwaitingAdopterInfo(Map<String, dynamic> request) {
    final donorConfirmedAt = request['donorConfirmedAt'] != null 
        ? DateTime.parse(request['donorConfirmedAt'])
        : null;
    final adopterConfirmedAt = request['adopterConfirmedAt'] != null 
        ? DateTime.parse(request['adopterConfirmedAt'])
        : null;
    
    // Si el adoptante ya confirmó pero el donante no
    if (adopterConfirmedAt != null && donorConfirmedAt == null) {
      return Column(
        children: [
          Container(
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
                      '¡El adoptante confirmó que recogió la mascota!',
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
                  '✅ El adoptante confirmó que recogió la mascota',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                const Text(
                  '👇 Ahora confirma que entregaste la mascota para completar la adopción',
                  style: TextStyle(fontSize: 14),
                ),
                if (adopterConfirmedAt != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Recogida el: ${adopterConfirmedAt.day}/${adopterConfirmedAt.month}/${adopterConfirmedAt.year}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Botón para confirmar entrega
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _handleCompleteAdoption(request),
              icon: const Icon(Icons.check_circle, size: 20),
              label: const Text('Confirmar que Entregué la Mascota'),
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
        ],
      );
    }
    
    // Si el donante ya confirmó pero el adoptante no
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
              Icon(Icons.hourglass_empty, color: Colors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Esperando Confirmación del Adoptante',
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
            '✅ Ya confirmaste la entrega',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          const Text(
            '⏳ Esperando que el adoptante confirme que recibió la mascota',
            style: TextStyle(fontSize: 14),
          ),
          if (donorConfirmedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Confirmaste el: ${donorConfirmedAt.day}/${donorConfirmedAt.month}/${donorConfirmedAt.year}',
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
            '🎉 La mascota ha sido entregada exitosamente',
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
              'Fecha de finalización: ${completedAt.day}/${completedAt.month}/${completedAt.year}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ],
      ),
    );
  }

  /// ✅ Confirmar entrega de mascota (Donante)
  Future<void> _handleCompleteAdoption(Map<String, dynamic> request) async {
    final pet = request['pet'] as Map<String, dynamic>?;
    final adopter = request['adopter'] as Map<String, dynamic>?;
    final petName = pet?['name'] ?? 'la mascota';
    final adopterName = '${adopter?['name'] ?? ''} ${adopter?['lastname'] ?? ''}'.trim();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.blue),
            SizedBox(width: 8),
            Text('Confirmar Entrega'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿Confirmas que entregaste a $petName a $adopterName?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📋 Proceso de confirmación:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('1️⃣ Tú confirmas la entrega'),
                  Text('2️⃣ El adoptante confirma la recepción'),
                  Text('3️⃣ La adopción se completa ✅'),
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
            child: const Text('Confirmar Entrega'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await _adoptionService.donorConfirmDelivery(request['id']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Entrega confirmada. Esperando confirmación del adoptante.'),
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
              content: Text('Error al confirmar entrega: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
