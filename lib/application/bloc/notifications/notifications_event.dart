import 'package:equatable/equatable.dart';

abstract class NotificationsEvent extends Equatable {
  const NotificationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotifications extends NotificationsEvent {
  const FetchNotifications({this.userId});
  
  final int? userId;

  @override
  List<Object?> get props => [userId];
}

class FetchUnreadNotifications extends NotificationsEvent {
  const FetchUnreadNotifications({this.userId});
  
  final int? userId;

  @override
  List<Object?> get props => [userId];
}

class MarkNotificationAsRead extends NotificationsEvent {
  const MarkNotificationAsRead(this.notificationId);
  
  final int notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class DeleteNotification extends NotificationsEvent {
  const DeleteNotification(this.notificationId);
  
  final int notificationId;

  @override
  List<Object?> get props => [notificationId];
}

class RefreshNotifications extends NotificationsEvent {
  const RefreshNotifications();
}
