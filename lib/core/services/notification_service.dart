import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/notification.dart';
import '../../data/models/notification_model.dart';
import '../utils/logger.dart';

/// Servicio de Notificaciones
/// Capa de Servicios - Clean Architecture
class NotificationService {
  static const String baseUrl = 'http://167.99.4.161/api';

  /// 📋 Obtener todas las notificaciones del usuario
  Future<List<Notification>> getNotifications({
    bool? isRead,
    int limit = 50,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      Logger.info('Getting notifications', tag: 'NotificationService');

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación');
      }

      final cleanToken = token.replaceFirst('Bearer ', '').trim();
      
      // Construir query params
      final queryParams = <String, String>{
        'limit': limit.toString(),
        if (isRead != null) 'isRead': isRead.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/notifications').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      Logger.apiResponse('GET', '/notifications', response.statusCode);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // El backend devuelve: {ok: true, data: {notifications: [...], pagination: {...}}}
        List<dynamic> notificationsData;
        
        if (data is List) {
          // Array directo
          notificationsData = data;
        } else if (data is Map) {
          // Objeto con estructura
          if (data['ok'] == true && data['data'] != null) {
            final dataObj = data['data'];
            if (dataObj is Map && dataObj['notifications'] != null) {
              // Estructura con paginación: {notifications: [...], pagination: {...}}
              notificationsData = dataObj['notifications'] as List;
            } else if (dataObj is List) {
              // Array directo en 'data'
              notificationsData = dataObj;
            } else {
              Logger.info('No notifications found', tag: 'NotificationService');
              return [];
            }
          } else if (data['data'] != null) {
            // Estructura sin 'ok': {data: [...]}
            final dataObj = data['data'];
            if (dataObj is Map && dataObj['notifications'] != null) {
              notificationsData = dataObj['notifications'] as List;
            } else if (dataObj is List) {
              notificationsData = dataObj;
            } else {
              Logger.info('No notifications found', tag: 'NotificationService');
              return [];
            }
          } else {
            Logger.info('No notifications found', tag: 'NotificationService');
            return [];
          }
        } else {
          Logger.warning('Unexpected response format', tag: 'NotificationService');
          return [];
        }
        
        final notifications = notificationsData
            .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        
        Logger.info(
          'Retrieved ${notifications.length} notifications',
          tag: 'NotificationService',
        );
        
        return notifications;
      }

      throw Exception('Error al obtener notificaciones: ${response.statusCode}');
    } catch (e) {
      Logger.error('Error getting notifications', tag: 'NotificationService', error: e);
      rethrow;
    }
  }

  /// 📬 Obtener notificaciones no leídas
  Future<List<Notification>> getUnreadNotifications() async {
    return getNotifications(isRead: false);
  }

  /// 🔔 Obtener contador de notificaciones no leídas
  Future<int> getUnreadCount() async {
    try {
      final unreadNotifications = await getUnreadNotifications();
      return unreadNotifications.length;
    } catch (e) {
      Logger.error('Error getting unread count', tag: 'NotificationService', error: e);
      return 0;
    }
  }



  /// 🗑️ Eliminar notificación
  Future<void> deleteNotification(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación');
      }

      final cleanToken = token.replaceFirst('Bearer ', '').trim();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/notifications/$notificationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      Logger.apiResponse('DELETE', '/notifications/$notificationId', response.statusCode);

      if (response.statusCode == 200) {
        Logger.info('Notification deleted', tag: 'NotificationService');
        return;
      }

      throw Exception('Error al eliminar notificación: ${response.statusCode}');
    } catch (e) {
      Logger.error('Error deleting notification', tag: 'NotificationService', error: e);
      rethrow;
    }
  }

}
