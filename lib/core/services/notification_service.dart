import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/notification.dart';
import '../../data/models/notification_model.dart';
import '../utils/logger.dart';

/// Servicio de Notificaciones
/// Capa de Servicios - Clean Architecture
class NotificationService {
  static const String baseUrl = 'http://10.0.2.2:3000/api';

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
        
        if (data is List) {
          final notifications = data
              .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
              .toList();
          
          Logger.info(
            'Retrieved ${notifications.length} notifications',
            tag: 'NotificationService',
          );
          
          return notifications;
        } else if (data is Map && data['data'] != null) {
          final notificationsData = data['data'] as List;
          final notifications = notificationsData
              .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
              .toList();
          
          Logger.info(
            'Retrieved ${notifications.length} notifications',
            tag: 'NotificationService',
          );
          
          return notifications;
        }
        
        return [];
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

  /// ✅ Marcar notificación como leída
  Future<void> markAsRead(int notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación');
      }

      final cleanToken = token.replaceFirst('Bearer ', '').trim();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      Logger.apiResponse('PATCH', '/notifications/$notificationId/read', response.statusCode);

      if (response.statusCode == 200) {
        Logger.info('Notification marked as read', tag: 'NotificationService');
        return;
      }

      throw Exception('Error al marcar notificación como leída: ${response.statusCode}');
    } catch (e) {
      Logger.error('Error marking notification as read', tag: 'NotificationService', error: e);
      rethrow;
    }
  }

  /// ✅ Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación');
      }

      final cleanToken = token.replaceFirst('Bearer ', '').trim();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/notifications/read-all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      Logger.apiResponse('PATCH', '/notifications/read-all', response.statusCode);

      if (response.statusCode == 200) {
        Logger.info('All notifications marked as read', tag: 'NotificationService');
        return;
      }

      throw Exception('Error al marcar todas las notificaciones como leídas: ${response.statusCode}');
    } catch (e) {
      Logger.error('Error marking all notifications as read', tag: 'NotificationService', error: e);
      rethrow;
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

  /// 🔄 Crear notificaciones de prueba (solo para desarrollo)
  Future<List<Notification>> createMockNotifications() async {
    Logger.warning('Using mock notifications for development', tag: 'NotificationService');
    
    return [
      Notification(
        id: 1,
        userId: 1,
        type: NotificationType.adoptionRequest,
        title: 'Nueva solicitud de adopción',
        message: 'María García quiere adoptar a Max',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        fromUserId: 2,
        petId: 110,
      ),
      Notification(
        id: 2,
        userId: 1,
        type: NotificationType.newComment,
        title: 'Nuevo comentario',
        message: 'Juan comentó en tu publicación de Luna',
        isRead: false,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        fromUserId: 3,
        petId: 111,
      ),
      Notification(
        id: 3,
        userId: 1,
        type: NotificationType.petStatusChanged,
        title: 'Mascota en riesgo reportada',
        message: 'Rocky ha sido reportado como en riesgo',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        readAt: DateTime.now().subtract(const Duration(hours: 12)),
        petId: 112,
      ),
      Notification(
        id: 4,
        userId: 1,
        type: NotificationType.adoptionAccepted,
        title: 'Adopción aceptada',
        message: 'Tu solicitud de adopción para Bella fue aceptada',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        readAt: DateTime.now().subtract(const Duration(days: 1)),
        petId: 113,
      ),
      Notification(
        id: 5,
        userId: 1,
        type: NotificationType.systemMessage,
        title: 'Bienvenido a PawFinder',
        message: 'Gracias por unirte a nuestra comunidad de amantes de las mascotas',
        isRead: true,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        readAt: DateTime.now().subtract(const Duration(days: 6)),
      ),
    ];
  }
}
