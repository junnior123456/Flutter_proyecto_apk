import 'package:equatable/equatable.dart';
import 'user.dart';
import 'pet.dart';

enum NotificationType {
  adoptionRequest,
  adoptionAccepted,
  adoptionRejected,
  newComment,
  petStatusChanged,
  reportResolved,
  systemMessage,
}

class Notification extends Equatable {
  final int id;
  final int userId;
  final NotificationType type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  
  // Relaciones opcionales
  final int? fromUserId;
  final int? petId;
  final User? user;
  final User? fromUser;
  final Pet? pet;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
    this.fromUserId,
    this.petId,
    this.user,
    this.fromUser,
    this.pet,
  });

  // Getters útiles
  String get typeString {
    switch (type) {
      case NotificationType.adoptionRequest:
        return 'Solicitud de adopción';
      case NotificationType.adoptionAccepted:
        return 'Adopción aceptada';
      case NotificationType.adoptionRejected:
        return 'Adopción rechazada';
      case NotificationType.newComment:
        return 'Nuevo comentario';
      case NotificationType.petStatusChanged:
        return 'Estado de mascota actualizado';
      case NotificationType.reportResolved:
        return 'Reporte resuelto';
      case NotificationType.systemMessage:
        return 'Mensaje del sistema';
    }
  }

  Duration get timeSinceCreated => DateTime.now().difference(createdAt);
  Duration? get timeSinceRead => readAt?.let((date) => DateTime.now().difference(date));

  String get timeSinceCreatedString {
    final duration = timeSinceCreated;
    if (duration.inDays > 0) {
      return 'Hace ${duration.inDays} ${duration.inDays == 1 ? 'día' : 'días'}';
    } else if (duration.inHours > 0) {
      return 'Hace ${duration.inHours} ${duration.inHours == 1 ? 'hora' : 'horas'}';
    } else if (duration.inMinutes > 0) {
      return 'Hace ${duration.inMinutes} ${duration.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Hace unos momentos';
    }
  }

  String get priorityLevel {
    switch (type) {
      case NotificationType.adoptionRequest:
      case NotificationType.adoptionAccepted:
      case NotificationType.adoptionRejected:
        return 'Alta';
      case NotificationType.newComment:
      case NotificationType.petStatusChanged:
        return 'Media';
      case NotificationType.reportResolved:
      case NotificationType.systemMessage:
        return 'Baja';
    }
  }

  bool get isHighPriority => priorityLevel == 'Alta';
  bool get isMediumPriority => priorityLevel == 'Media';
  bool get isLowPriority => priorityLevel == 'Baja';

  String get senderName => fromUser?.displayName ?? 'Sistema';

  Notification copyWith({
    int? id,
    int? userId,
    NotificationType? type,
    String? title,
    String? message,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    int? fromUserId,
    int? petId,
    User? user,
    User? fromUser,
    Pet? pet,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      fromUserId: fromUserId ?? this.fromUserId,
      petId: petId ?? this.petId,
      user: user ?? this.user,
      fromUser: fromUser ?? this.fromUser,
      pet: pet ?? this.pet,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        type,
        title,
        message,
        data,
        isRead,
        createdAt,
        readAt,
        fromUserId,
        petId,
        user,
        fromUser,
        pet,
      ];

  @override
  String toString() {
    return 'Notification(id: $id, type: $type, title: $title, isRead: $isRead)';
  }
}

// Extension para el operador let
extension LetExtension<T> on T? {
  R? let<R>(R Function(T) transform) {
    if (this != null) {
      return transform(this!);
    }
    return null;
  }
}