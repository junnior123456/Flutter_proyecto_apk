import 'package:equatable/equatable.dart';
import 'user.dart';

enum ReportType {
  inappropriateContent,
  spam,
  fakeListing,
  abusiveBehavior,
  scam,
  other,
}

enum ReportStatus {
  pending,
  underReview,
  resolved,
  dismissed,
}

enum ReportableType {
  pet,
  comment,
  user,
}

class Report extends Equatable {
  final int id;
  final ReportType type;
  final ReportableType reportableType;
  final int reportableId;
  final String reason;
  final String? description;
  final ReportStatus status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? resolvedAt;
  
  // Relaciones
  final int reporterId;
  final int? reviewedById;
  final User? reporter;
  final User? reviewedBy;

  const Report({
    required this.id,
    required this.type,
    required this.reportableType,
    required this.reportableId,
    required this.reason,
    this.description,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
    this.resolvedAt,
    required this.reporterId,
    this.reviewedById,
    this.reporter,
    this.reviewedBy,
  });

  // Getters útiles
  String get typeString {
    switch (type) {
      case ReportType.inappropriateContent:
        return 'Contenido inapropiado';
      case ReportType.spam:
        return 'Spam';
      case ReportType.fakeListing:
        return 'Publicación falsa';
      case ReportType.abusiveBehavior:
        return 'Comportamiento abusivo';
      case ReportType.scam:
        return 'Estafa';
      case ReportType.other:
        return 'Otro';
    }
  }

  String get statusString {
    switch (status) {
      case ReportStatus.pending:
        return 'Pendiente';
      case ReportStatus.underReview:
        return 'En revisión';
      case ReportStatus.resolved:
        return 'Resuelto';
      case ReportStatus.dismissed:
        return 'Desestimado';
    }
  }

  String get reportableTypeString {
    switch (reportableType) {
      case ReportableType.pet:
        return 'Mascota';
      case ReportableType.comment:
        return 'Comentario';
      case ReportableType.user:
        return 'Usuario';
    }
  }

  bool get isPending => status == ReportStatus.pending;
  bool get isUnderReview => status == ReportStatus.underReview;
  bool get isResolved => status == ReportStatus.resolved;
  bool get isDismissed => status == ReportStatus.dismissed;

  bool get isOpen => isPending || isUnderReview;
  bool get isClosed => isResolved || isDismissed;

  Duration get timeSinceCreated => DateTime.now().difference(createdAt);
  Duration? get timeSinceResolved => resolvedAt?.let((date) => DateTime.now().difference(date));

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
      case ReportType.abusiveBehavior:
      case ReportType.scam:
        return 'Alta';
      case ReportType.inappropriateContent:
      case ReportType.fakeListing:
        return 'Media';
      case ReportType.spam:
      case ReportType.other:
        return 'Baja';
    }
  }

  Report copyWith({
    int? id,
    ReportType? type,
    ReportableType? reportableType,
    int? reportableId,
    String? reason,
    String? description,
    ReportStatus? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    int? reporterId,
    int? reviewedById,
    User? reporter,
    User? reviewedBy,
  }) {
    return Report(
      id: id ?? this.id,
      type: type ?? this.type,
      reportableType: reportableType ?? this.reportableType,
      reportableId: reportableId ?? this.reportableId,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      reporterId: reporterId ?? this.reporterId,
      reviewedById: reviewedById ?? this.reviewedById,
      reporter: reporter ?? this.reporter,
      reviewedBy: reviewedBy ?? this.reviewedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        reportableType,
        reportableId,
        reason,
        description,
        status,
        adminNotes,
        createdAt,
        updatedAt,
        resolvedAt,
        reporterId,
        reviewedById,
        reporter,
        reviewedBy,
      ];

  @override
  String toString() {
    return 'Report(id: $id, type: $type, status: $status, reportableType: $reportableType)';
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