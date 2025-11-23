import 'package:equatable/equatable.dart';

abstract class NotificationsState extends Equatable {
  const NotificationsState();

  @override
  List<Object?> get props => [];
}

class NotificationsInitial extends NotificationsState {
  const NotificationsInitial();
}

class NotificationsLoading extends NotificationsState {
  const NotificationsLoading();
}

class NotificationsLoaded extends NotificationsState {
  const NotificationsLoaded(this.notifications);
  
  final List<dynamic> notifications;

  @override
  List<Object?> get props => [notifications];
}

class UnreadNotificationsLoaded extends NotificationsState {
  const UnreadNotificationsLoaded(this.notifications);
  
  final List<dynamic> notifications;

  @override
  List<Object?> get props => [notifications];
}

class NotificationMarkedAsRead extends NotificationsState {
  const NotificationMarkedAsRead(this.notificationId);
  
  final int notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class NotificationDeleted extends NotificationsState {
  const NotificationDeleted(this.notificationId);
  
  final int notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class NotificationsError extends NotificationsState {
  const NotificationsError(this.message);
  
  final String message;

  @override
  List<Object?> get props => [message];
}
