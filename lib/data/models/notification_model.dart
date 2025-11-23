import '../../domain/entities/notification.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/pet.dart';
import 'user_model.dart';
import 'pet_model.dart';

/// Modelo de datos para Notificación
/// Capa de Datos - Clean Architecture
class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    required super.title,
    required super.message,
    super.data,
    super.isRead,
    required super.createdAt,
    super.readAt,
    super.fromUserId,
    super.petId,
    super.user,
    super.fromUser,
    super.pet,
  });

  /// Crear desde JSON (backend)
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      type: _parseNotificationType(json['type'] as String?),
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null 
          ? DateTime.parse(json['readAt'] as String) 
          : null,
      fromUserId: json['fromUserId'] as int?,
      petId: json['petId'] as int?,
      user: json['user'] != null 
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>) 
          : null,
      fromUser: json['fromUser'] != null 
          ? UserModel.fromJson(json['fromUser'] as Map<String, dynamic>) 
          : null,
      pet: json['pet'] != null 
          ? PetModel.fromJson(json['pet'] as Map<String, dynamic>) 
          : null,
    );
  }

  /// Parsear tipo de notificación desde string
  static NotificationType _parseNotificationType(String? type) {
    switch (type?.toLowerCase()) {
      case 'adoption_request':
      case 'adoptionrequest':
        return NotificationType.adoptionRequest;
      case 'adoption_accepted':
      case 'adoptionaccepted':
        return NotificationType.adoptionAccepted;
      case 'adoption_rejected':
      case 'adoptionrejected':
        return NotificationType.adoptionRejected;
      case 'new_comment':
      case 'newcomment':
        return NotificationType.newComment;
      case 'pet_status_changed':
      case 'petstatuschanged':
        return NotificationType.petStatusChanged;
      case 'report_resolved':
      case 'reportresolved':
        return NotificationType.reportResolved;
      case 'system_message':
      case 'systemmessage':
        return NotificationType.systemMessage;
      default:
        return NotificationType.systemMessage;
    }
  }

  /// Convertir a JSON (para enviar al backend)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': _notificationTypeToString(type),
      'title': title,
      'message': message,
      'data': data,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      'readAt': readAt?.toIso8601String(),
      'fromUserId': fromUserId,
      'petId': petId,
    };
  }

  /// Convertir tipo de notificación a string
  static String _notificationTypeToString(NotificationType type) {
    switch (type) {
      case NotificationType.adoptionRequest:
        return 'adoption_request';
      case NotificationType.adoptionAccepted:
        return 'adoption_accepted';
      case NotificationType.adoptionRejected:
        return 'adoption_rejected';
      case NotificationType.newComment:
        return 'new_comment';
      case NotificationType.petStatusChanged:
        return 'pet_status_changed';
      case NotificationType.reportResolved:
        return 'report_resolved';
      case NotificationType.systemMessage:
        return 'system_message';
    }
  }

  /// Convertir a entidad del dominio
  Notification toEntity() {
    return Notification(
      id: id,
      userId: userId,
      type: type,
      title: title,
      message: message,
      data: data,
      isRead: isRead,
      createdAt: createdAt,
      readAt: readAt,
      fromUserId: fromUserId,
      petId: petId,
      user: user,
      fromUser: fromUser,
      pet: pet,
    );
  }

  /// Crear desde entidad del dominio
  factory NotificationModel.fromEntity(Notification notification) {
    return NotificationModel(
      id: notification.id,
      userId: notification.userId,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      data: notification.data,
      isRead: notification.isRead,
      createdAt: notification.createdAt,
      readAt: notification.readAt,
      fromUserId: notification.fromUserId,
      petId: notification.petId,
      user: notification.user,
      fromUser: notification.fromUser,
      pet: notification.pet,
    );
  }
}
