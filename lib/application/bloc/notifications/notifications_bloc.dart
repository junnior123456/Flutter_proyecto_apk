import 'package:flutter_bloc/flutter_bloc.dart';
import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  NotificationsBloc() : super(const NotificationsInitial()) {
    on<FetchNotifications>(_onFetchNotifications);
    on<FetchUnreadNotifications>(_onFetchUnreadNotifications);
    on<MarkNotificationAsRead>(_onMarkAsRead);
    on<DeleteNotification>(_onDeleteNotification);
    on<RefreshNotifications>(_onRefreshNotifications);
  }

  Future<void> _onFetchNotifications(
    FetchNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    try {
      // TODO: Implement actual API call to NotificationsService
      // final notifications = await notificationsService.getNotifications(
      //   userId: event.userId ?? 0,
      // );
      emit(const NotificationsLoaded([]));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onFetchUnreadNotifications(
    FetchUnreadNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    try {
      // TODO: Implement actual API call
      // final notifications = await notificationsService.getUnreadNotifications(
      //   userId: event.userId ?? 0,
      // );
      emit(const UnreadNotificationsLoaded([]));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onMarkAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      // TODO: Implement actual API call
      // await notificationsService.markAsRead(event.notificationId);
      // emit(NotificationMarkedAsRead(event.notificationId));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onDeleteNotification(
    DeleteNotification event,
    Emitter<NotificationsState> emit,
  ) async {
    try {
      // TODO: Implement actual API call
      // await notificationsService.deleteNotification(event.notificationId);
      // emit(NotificationDeleted(event.notificationId));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }

  Future<void> _onRefreshNotifications(
    RefreshNotifications event,
    Emitter<NotificationsState> emit,
  ) async {
    emit(const NotificationsLoading());
    try {
      // TODO: Implement refresh logic
      emit(const NotificationsLoaded([]));
    } catch (e) {
      emit(NotificationsError(e.toString()));
    }
  }
}
