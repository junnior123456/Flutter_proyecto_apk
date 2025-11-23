import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/notification.dart';
import '../../../../core/services/notification_service.dart';

// Events
abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationsEvent {}

class LoadUnreadNotifications extends NotificationsEvent {}

class MarkNotificationAsRead extends NotificationsEvent {
  final int notificationId;

  const MarkNotificationAsRead({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsRead extends NotificationsEvent {}

class DeleteNotification extends NotificationsEvent {
  final int notificationId;

  const DeleteNotification({required this.notificationId});

  @override
  List<Object?> get props => [notificationId];
}

class RefreshNotifications extends NotificationsEvent {}

class FilterNotifications extends NotificationsEvent {
  final bool? showOnlyUnread;
  final NotificationType? filterByType;

  const FilterNotifications({
    this.showOnlyUnread,
    this.filterByType,
  });

  @override
  List<Object?> get props => [showOnlyUnread, filterByType];
}

// States
abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final List<Notification> notifications;
  final int unreadCount;
  final bool? showOnlyUnread;
  final NotificationType? filterByType;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    this.showOnlyUnread,
    this.filterByType,
  });

  List<Notification> get filteredNotifications {
    var filtered = notifications;

    if (showOnlyUnread == true) {
      filtered = filtered.where((n) => !n.isRead).toList();
    }

    if (filterByType != null) {
      filtered = filtered.where((n) => n.type == filterByType).toList();
    }

    return filtered;
  }

  List<Notification> get unreadNotifications {
    return notifications.where((n) => !n.isRead).toList();
  }

  List<Notification> get readNotifications {
    return notifications.where((n) => n.isRead).toList();
  }

  @override
  List<Object?> get props => [notifications, unreadCount, showOnlyUnread, filterByType];
}

class NotificationsError extends NotificationsState {
  final String message;

  const NotificationsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class NotificationOperationSuccess extends NotificationsState {
  final String message;
  final List<Notification> notifications;
  final int unreadCount;

  const NotificationOperationSuccess({
    required this.message,
    required this.notifications,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [message, notifications, unreadCount];
}

// BLoC
class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final NotificationService _notificationService;

  NotificationsBloc({required NotificationService notificationService})
      : _notificationService = notificationService,
        super(NotificationsInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<LoadUnreadNotifications>(_onLoadUnreadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsRead>(_onMarkAllNotificationsAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<RefreshNotifications>(_onRefreshNotifications);
    on<FilterNotifications>(_onFilterNotifications);
  }

  Future<void> _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(NotificationsLoading());
    try {
      // Intentar cargar desde backend
      try {
        final notifications = await _notificationService.getNotifications();
        final unreadCount = await _notificationService.getUnreadCount();
        emit(NotificationsLoaded(
          notifications: notifications,
          unreadCount: unreadCount,
        ));
      } catch (e) {
        // Si falla, usar notificaciones mock para desarrollo
        print('⚠️ Backend no disponible, usando notificaciones mock');
        final mockNotifications = await _notificationService.createMockNotifications();
        final unreadCount = mockNotifications.where((n) => !n.isRead).length;
        emit(NotificationsLoaded(
          notifications: mockNotifications,
          unreadCount: unreadCount,
        ));
      }
    } catch (e) {
      emit(NotificationsError(
        message: 'Error al cargar notificaciones: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadUnreadNotifications(
    LoadUnreadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final notifications = await _notificationService.getUnreadNotifications();
      final unreadCount = notifications.length;
      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        showOnlyUnread: true,
      ));
    } catch (e) {
      emit(NotificationsError(
        message: 'Error al cargar notificaciones no leídas: ${e.toString()}',
      ));
    }
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _notificationService.markAsRead(event.notificationId);
      
      // Recargar notificaciones
      final notifications = await _notificationService.getNotifications();
      final unreadCount = await _notificationService.getUnreadCount();
      
      emit(NotificationOperationSuccess(
        message: 'Notificación marcada como leída',
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError(
        message: 'Error al marcar notificación como leída: ${e.toString()}',
      ));
    }
  }

  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _notificationService.markAllAsRead();
      
      // Recargar notificaciones
      final notifications = await _notificationService.getNotifications();
      
      emit(NotificationOperationSuccess(
        message: 'Todas las notificaciones marcadas como leídas',
        notifications: notifications,
        unreadCount: 0,
      ));
    } catch (e) {
      emit(NotificationsError(
        message: 'Error al marcar todas las notificaciones como leídas: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      await _notificationService.deleteNotification(event.notificationId);
      
      // Recargar notificaciones
      final notifications = await _notificationService.getNotifications();
      final unreadCount = await _notificationService.getUnreadCount();
      
      emit(NotificationOperationSuccess(
        message: 'Notificación eliminada',
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError(
        message: 'Error al eliminar notificación: ${e.toString()}',
      ));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      final notifications = await _notificationService.getNotifications();
      final unreadCount = await _notificationService.getUnreadCount();
      emit(NotificationsLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
      ));
    } catch (e) {
      emit(NotificationsError(
        message: 'Error al refrescar notificaciones: ${e.toString()}',
      ));
    }
  }

  Future<void> _onFilterNotifications(
    FilterNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    if (state is NotificationsLoaded) {
      final currentState = state as NotificationsLoaded;
      emit(NotificationsLoaded(
        notifications: currentState.notifications,
        unreadCount: currentState.unreadCount,
        showOnlyUnread: event.showOnlyUnread,
        filterByType: event.filterByType,
      ));
    }
  }
}
