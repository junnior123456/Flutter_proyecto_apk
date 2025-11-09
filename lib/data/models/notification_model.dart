import '../../domain/entities/notification.dart';
import 'user_model.dart';
import 'pet_model.dart';

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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      type: _parseNotificationType(json['type'] as String),
      title: json['title'] as String,
      message: json['message'] as String,
      data: json['data'] as Map<String, dynamic>?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      readAt: json['readAt'] != null
          ? DateTime.parse(json['readAt'] as String)
          : null,
      fromUserId: json['fromUserId'] as int?,
      petId: json['petId'] as int?,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      fromUser: json['fromUser'] != null ? UserModel.fromJson(json['fromUser']) : null,
      pet: json['pet'] != null ? PetModel.fromJson(json['pet']) : null,
    );
  }

  static NotificationType _parseNotificationType(String type) {
    switch (type.toLowerCase()) {
      case 'adoption_request':
        return NotificationType.adoptionRequest;
      case 'adoption_accepted':
        return NotificationType.adoptionAccepted;
      case 'adoption_rejected':
        return NotificationType.adoptionRejected;
      case 'new_comment':
        return NotificationType.newComment;
      case 'pet_status_changed':
        return NotificationType.petStatusChanged;
      case 'report_resolved':
        return NotificationType.reportResolved;
      case 'system_message':
        return NotificationType.systemMessage;
      default:
        return NotificationType.systemMessage;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
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
}