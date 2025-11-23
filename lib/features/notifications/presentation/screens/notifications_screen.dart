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
  bool _showOnlyUnread = false;

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
          // Filtro: Solo no leídas
          IconButton(
            icon: Icon(
              _showOnlyUnread ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: () {
              setState(() {
                _showOnlyUnread = !_showOnlyUnread;
              });
              context.read<NotificationsBloc>().add(
                    FilterNotifications(showOnlyUnread: _showOnlyUnread),
                  );
            },
            tooltip: _showOnlyUnread ? 'Mostrar todas' : 'Solo no leídas',
          ),
          // Marcar todas como leídas
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: () {
              _showMarkAllAsReadDialog(context);
            },
            tooltip: 'Marcar todas como leídas',
          ),
          // Refrescar
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
          } else if (state is NotificationsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 3),
              ),
            );
          }
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

            final unreadCount = state is NotificationsLoaded
                ? state.unreadCount
                : (state as NotificationOperationSuccess).unreadCount;

            if (notifications.isEmpty) {
              return _buildEmptyView();
            }

            return TabBarView(
              controller: _tabController,
              children: [
                // Todas las notificaciones
                _buildNotificationsList(context, notifications, unreadCount),
                // Solo adopción
                _buildNotificationsList(
                  context,
                  notifications
                      .where((n) =>
                          n.type == app_notification.NotificationType.adoptionRequest ||
                          n.type == app_notification.NotificationType.adoptionAccepted ||
                          n.type == app_notification.NotificationType.adoptionRejected)
                      .toList(),
                  unreadCount,
                ),
                // Solo riesgo
                _buildNotificationsList(
                  context,
                  notifications
                      .where((n) =>
                          n.type == app_notification.NotificationType.petStatusChanged ||
                          n.type == app_notification.NotificationType.reportResolved)
                      .toList(),
                  unreadCount,
                ),
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
    int unreadCount,
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
        elevation: notification.isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: notification.isRead
                ? Colors.transparent
                : Colors.orange.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (!notification.isRead) {
              context.read<NotificationsBloc>().add(
                    MarkNotificationAsRead(notificationId: notification.id),
                  );
            }
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
                      // Título y badge no leído
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
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
                      // Tiempo y tipo
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
                          const Spacer(),
                          _buildPriorityBadge(notification),
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
      case app_notification.NotificationType.systemMessage:
        icon = Icons.info;
        color = Colors.grey;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey;
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

  Widget _buildPriorityBadge(app_notification.Notification notification) {
    Color color;
    String text;

    if (notification.isHighPriority) {
      color = Colors.red;
      text = 'Alta';
    } else if (notification.isMediumPriority) {
      color = Colors.orange;
      text = 'Media';
    } else {
      color = Colors.grey;
      text = 'Baja';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
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
              // Botones de acción
              Row(
                children: [
                  if (!notification.isRead)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          context.read<NotificationsBloc>().add(
                                MarkNotificationAsRead(
                                  notificationId: notification.id,
                                ),
                              );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.done),
                        label: const Text('Marcar como leída'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                          side: const BorderSide(color: Colors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (!notification.isRead) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmDelete(context, notification);
                      },
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
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

  void _showMarkAllAsReadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Marcar todas como leídas'),
        content: const Text(
          '¿Estás seguro de marcar todas las notificaciones como leídas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            onPressed: () {
              Navigator.pop(dialogContext);
              context
                  .read<NotificationsBloc>()
                  .add(MarkAllNotificationsAsRead());
            },
            child: const Text('Marcar todas'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, app_notification.Notification notification) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar notificación'),
        content: const Text('¿Estás seguro de eliminar esta notificación?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<NotificationsBloc>().add(
                    DeleteNotification(notificationId: notification.id),
                  );
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
