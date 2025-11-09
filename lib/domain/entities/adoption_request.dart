import 'package:equatable/equatable.dart';
import 'user.dart';
import 'pet.dart';

enum AdoptionRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
}

class AdoptionRequest extends Equatable {
  final int id;
  final int petId;
  final int adopterId;
  final String personalInfo;
  final String motivation;
  final AdoptionRequestStatus status;
  final String? rejectionReason;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? reviewedAt;
  
  // Relaciones opcionales
  final Pet? pet;
  final User? adopter;

  const AdoptionRequest({
    required this.id,
    required this.petId,
    required this.adopterId,
    required this.personalInfo,
    required this.motivation,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
    required this.updatedAt,
    this.reviewedAt,
    this.pet,
    this.adopter,
  });

  // Getters útiles
  String get statusString {
    switch (status) {
      case AdoptionRequestStatus.pending:
        return 'Pendiente';
      case AdoptionRequestStatus.accepted:
        return 'Aceptada';
      case AdoptionRequestStatus.rejected:
        return 'Rechazada';
      case AdoptionRequestStatus.cancelled:
        return 'Cancelada';
    }
  }

  bool get isPending => status == AdoptionRequestStatus.pending;
  bool get isAccepted => status == AdoptionRequestStatus.accepted;
  bool get isRejected => status == AdoptionRequestStatus.rejected;
  bool get isCancelled => status == AdoptionRequestStatus.cancelled;

  bool get isActive => isPending;
  bool get isCompleted => isAccepted || isRejected || isCancelled;

  Duration get timeSinceCreated => DateTime.now().difference(createdAt);
  Duration? get timeSinceReviewed => reviewedAt?.let((date) => DateTime.now().difference(date));

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

  AdoptionRequest copyWith({
    int? id,
    int? petId,
    int? adopterId,
    String? personalInfo,
    String? motivation,
    AdoptionRequestStatus? status,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? reviewedAt,
    Pet? pet,
    User? adopter,
  }) {
    return AdoptionRequest(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      adopterId: adopterId ?? this.adopterId,
      personalInfo: personalInfo ?? this.personalInfo,
      motivation: motivation ?? this.motivation,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      pet: pet ?? this.pet,
      adopter: adopter ?? this.adopter,
    );
  }

  @override
  List<Object?> get props => [
        id,
        petId,
        adopterId,
        personalInfo,
        motivation,
        status,
        rejectionReason,
        createdAt,
        updatedAt,
        reviewedAt,
        pet,
        adopter,
      ];

  @override
  String toString() {
    return 'AdoptionRequest(id: $id, petId: $petId, status: $status)';
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