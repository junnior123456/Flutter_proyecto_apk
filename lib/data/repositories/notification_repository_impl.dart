import '../../domain/entities/notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  
  NotificationRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<List<Notification>> getNotifications({int? limit, int? offset}) async {
    try {
      final notificationModels = await remoteDataSource.getNotifications(limit: limit, offset: offset);
      return notificationModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Notification>> getUnreadNotifications() async {
    try {
      final notificationModels = await remoteDataSource.getUnreadNotifications();
      return notificationModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get unread notifications: ${e.toString()}');
    }
  }
  
  @override
  Future<Notification> markAsRead(int notificationId) async {
    try {
      final notificationModel = await remoteDataSource.markAsRead(notificationId);
      return notificationModel.toEntity();
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }
  
  @override
  Future<void> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteNotification(int notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      return await remoteDataSource.getNotificationSettings();
    } catch (e) {
      throw Exception('Failed to get notification settings: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      await remoteDataSource.updateNotificationSettings(settings);
    } catch (e) {
      throw Exception('Failed to update notification settings: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateNotificationToken(String token) async {
    try {
      await remoteDataSource.updateNotificationToken(token);
    } catch (e) {
      throw Exception('Failed to update notification token: ${e.toString()}');
    }
  }
}