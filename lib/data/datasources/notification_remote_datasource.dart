import '../models/notification_model.dart';
import 'http_service.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({int? limit, int? offset});
  Future<List<NotificationModel>> getUnreadNotifications();
  Future<NotificationModel> markAsRead(int notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(int notificationId);
  Future<Map<String, dynamic>> getNotificationSettings();
  Future<void> updateNotificationSettings(Map<String, dynamic> settings);
  Future<void> updateNotificationToken(String token);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final HttpService httpService;
  
  NotificationRemoteDataSourceImpl({required this.httpService});
  
  @override
  Future<List<NotificationModel>> getNotifications({int? limit, int? offset}) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      
      final response = await httpService.get('/notifications', queryParams: queryParams);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> notificationsJson = response['data'];
        return notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load notifications: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error loading notifications: ${e.toString()}');
    }
  }
  
  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    try {
      final response = await httpService.get('/notifications/unread');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> notificationsJson = response['data'];
        return notificationsJson.map((json) => NotificationModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load unread notifications: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error loading unread notifications: ${e.toString()}');
    }
  }
  
  @override
  Future<NotificationModel> markAsRead(int notificationId) async {
    try {
      final response = await httpService.put('/notifications/$notificationId/read');
      
      if (response['success'] == true && response['data'] != null) {
        return NotificationModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to mark notification as read: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error marking notification as read: ${e.toString()}');
    }
  }
  
  @override
  Future<void> markAllAsRead() async {
    try {
      final response = await httpService.put('/notifications/read-all');
      
      if (response['success'] != true) {
        throw Exception('Failed to mark all notifications as read: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error marking all notifications as read: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await httpService.delete('/notifications/$notificationId');
      
      if (response['success'] != true) {
        throw Exception('Failed to delete notification: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error deleting notification: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getNotificationSettings() async {
    try {
      final response = await httpService.get('/notifications/settings');
      
      if (response['success'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load notification settings: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error loading notification settings: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateNotificationSettings(Map<String, dynamic> settings) async {
    try {
      final response = await httpService.put('/notifications/settings', body: settings);
      
      if (response['success'] != true) {
        throw Exception('Failed to update notification settings: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error updating notification settings: ${e.toString()}');
    }
  }
  
  @override
  Future<void> updateNotificationToken(String token) async {
    try {
      final response = await httpService.put('/notifications/token', body: {
        'notificationToken': token,
      });
      
      if (response['success'] != true) {
        throw Exception('Failed to update notification token: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error updating notification token: ${e.toString()}');
    }
  }
}