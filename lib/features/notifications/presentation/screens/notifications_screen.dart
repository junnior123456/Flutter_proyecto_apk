import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/notification.dart' as app_notification;
import '../../../../core/services/notification_service.dart';
import '../bloc/notifications_bloc.dart';

/// Pantalla de Notificaciones
/// Muestra notificaciones de adopción y riesgo
/// Clean Architecture - Capa de Presentación
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NotificationsBloc(
        notificationService: NotificationService(),
      )..add(LoadNotifications()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: Colors.orange,
        actions: [
          // Solo botón de refrescar
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<NotificationsBloc>().add(RefreshNotifications());
            },
            tooltip: 'Actualizar',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Todas'),
            Tab(text: 'Adopción'),
            Tab(text: 'Riesgo'),
          ],
        ),
      ),
      body: BlocConsumer<NotificationsBloc, NotificationsState>(
        listener: (context, state) {
          if (state is NotificationOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            // Recargar después de una operación exitosa
            context.read<NotificationsBloc>().add(LoadNotifications());
          }
          // Removido el listener de errores para evitar mostrar errores antiguos
        },
        builder: (context, state) {
          if (state is NotificationsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }

          if (state is NotificationsError) {
            return _buildErrorView(context, state.message);
          }

          if (state is NotificationsLoaded ||
              state is NotificationOperationSuccess) {
            final notifications = state is NotificationsLoaded
                ? state.filteredNotifications
                : (state as NotificationOperationSuccess).notifications;

            if (notifications.isEmpty) {
              return _buildEmptyView();
            }

            // Filtrar notificaciones por tipo
            final adoptionNotifications = notifications.where((n) =>
              n.type == app_notification.NotificationType.adoptionRequest ||
              n.type == app_notification.NotificationType.adoptionAccepted ||
              n.type == app_notification.NotificationType.adoptionRejected ||
              n.type == app_notification.NotificationType.adoptionRequestSent ||
              n.type == app_notification.NotificationType.newPet ||
              n.type == app_notification.NotificationType.petPublished
            ).toList();

            final riskNotifications = notifications.where((n) =>
              n.type == app_notification.NotificationType.petInRisk ||
              n.type == app_notification.NotificationType.petRiskPublished ||
              n.type == app_notification.NotificationType.petStatusChanged ||
              n.type == app_notification.NotificationType.reportResolved
            ).toList();

            // TabBarView con filtros
            return TabBarView(
              controller: _tabController,
              children: [
                // Tab: Todas
                _buildNotificationsList(context, notifications),
                // Tab: Adopción
                _buildNotificationsList(context, adoptionNotifications),
                // Tab: Riesgo
                _buildNotificationsList(context, riskNotifications),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    List<app_notification.Notification> notifications,
  ) {
    if (notifications.isEmpty) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationsBloc>().add(RefreshNotifications());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(context, notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    BuildContext context,
    app_notification.Notification notification,
  ) {
    return Dismissible(
      key: Key('notification_${notification.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 32),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Eliminar notificación'),
            content: const Text('¿Estás seguro de eliminar esta notificación?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context
            .read<NotificationsBloc>()
            .add(DeleteNotification(notificationId: notification.id));
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            _showNotificationDetails(context, notification);
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono según tipo
                _buildNotificationIcon(notification),
                const SizedBox(width: 16),
                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Mensaje
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Solo tiempo
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            notification.timeSinceCreatedString,
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(app_notification.Notification notification) {
    IconData icon;
    Color color;

    switch (notification.type) {
      case app_notification.NotificationType.adoptionRequest:
        icon = Icons.pets;
        color = Colors.blue;
        break;
      case app_notification.NotificationType.adoptionAccepted:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case app_notification.NotificationType.adoptionRejected:
        icon = Icons.cancel;
        color = Colors.red;
        break;
      case app_notification.NotificationType.adoptionRequestSent:
        icon = Icons.send;
        color = Colors.blue;
        break;
      case app_notification.NotificationType.newComment:
        icon = Icons.comment;
        color = Colors.purple;
        break;
      case app_notification.NotificationType.petStatusChanged:
        icon = Icons.warning_amber_rounded;
        color = Colors.orange;
        break;
      case app_notification.NotificationType.reportResolved:
        icon = Icons.check_circle_outline;
        color = Colors.teal;
        break;
      case app_notification.NotificationType.petPublished:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case app_notification.NotificationType.newPet:
        icon = Icons.pets;
        color = Colors.green;
        break;
      case app_notification.NotificationType.petInRisk:
        icon = Icons.warning;
        color = Colors.red;
        break;
      case app_notification.NotificationType.petRiskPublished:
        icon = Icons.warning_amber;
        color = Colors.orange;
        break;
      case app_notification.NotificationType.newDonation:
        icon = Icons.volunteer_activism;
        color = Colors.pink;
        break;
      case app_notification.NotificationType.welcome:
        icon = Icons.waving_hand;
        color = Colors.orange;
        break;
      case app_notification.NotificationType.systemMessage:
        icon = Icons.info;
        color = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay notificaciones',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando recibas notificaciones\naparecerán aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Error al cargar notificaciones',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<NotificationsBloc>().add(LoadNotifications());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetails(
    BuildContext context,
    app_notification.Notification notification,
  ) {
    // Si es una notificación de mascota, mostrar detalles completos
    if ((notification.type == app_notification.NotificationType.newPet ||
            notification.type == app_notification.NotificationType.petInRisk) &&
        notification.pet != null) {
      _showPetDetails(context, notification);
      return;
    }

    // Para otros tipos de notificación, mostrar el diálogo estándar
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de arrastre
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Icono y título
              Row(
                children: [
                  _buildNotificationIcon(notification),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notification.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification.typeString,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Mensaje completo
              Text(
                notification.message,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              // Información adicional
              _buildInfoRow(
                Icons.access_time,
                'Recibida',
                notification.timeSinceCreatedString,
              ),
              if (notification.isRead && notification.readAt != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.done_all,
                  'Leída',
                  notification.timeSinceRead != null
                      ? 'Hace ${notification.timeSinceRead!.inHours} horas'
                      : 'Sí',
                ),
              ],
              const SizedBox(height: 12),
              _buildInfoRow(
                Icons.priority_high,
                'Prioridad',
                notification.priorityLevel,
              ),
              if (notification.senderName != 'Sistema') ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.person,
                  'De',
                  notification.senderName,
                ),
              ],
              const SizedBox(height: 32),
              // Botón de cerrar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Cerrar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPetDetails(
    BuildContext context,
    app_notification.Notification notification,
  ) {
    final pet = notification.pet!;
    final owner = notification.fromUser;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Indicador de arrastre
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Imagen de la mascota
              Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(pet.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            pet.name,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (pet.isRisk)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'EN RIESGO',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pet.category.displayName,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Descripción
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      pet.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Información del animal
                    const Text(
                      'Información',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.pets, 'Raza', pet.breed),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.cake, 'Edad', pet.age),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.wc, 'Género', pet.gender),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.straighten, 'Tamaño', pet.size),
                    const SizedBox(height: 24),
                    // Información del publicador
                    const Text(
                      'Publicado por',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.orange,
                          backgroundImage: owner?.image != null
                              ? NetworkImage(owner!.image!)
                              : null,
                          child: owner?.image == null
                              ? const Icon(Icons.person,
                                  size: 30, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                owner?.displayName ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (owner?.email != null)
                                Text(
                                  owner!.email,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.phone, 'Teléfono', pet.contactPhone),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.location_on, 'Ubicación', pet.address),
                    const SizedBox(height: 32),
                    // Botón de cerrar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text('Cerrar'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }


}
