import '../../domain/entities/report.dart';
import 'user_model.dart';

class ReportModel extends Report {
  const ReportModel({
    required super.id,
    required super.type,
    required super.reportableType,
    required super.reportableId,
    required super.reason,
    super.description,
    required super.status,
    super.adminNotes,
    required super.createdAt,
    required super.updatedAt,
    super.resolvedAt,
    required super.reporterId,
    super.reviewedById,
    super.reporter,
    super.reviewedBy,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as int,
      type: _parseReportType(json['type'] as String),
      reportableType: _parseReportableType(json['reportableType'] as String),
      reportableId: json['reportableId'] as int,
      reason: json['reason'] as String,
      description: json['description'] as String?,
      status: _parseReportStatus(json['status'] as String),
      adminNotes: json['adminNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      reporterId: json['reporterId'] as int,
      reviewedById: json['reviewedById'] as int?,
      reporter: json['reporter'] != null ? UserModel.fromJson(json['reporter']) : null,
      reviewedBy: json['reviewedBy'] != null ? UserModel.fromJson(json['reviewedBy']) : null,
    );
  }

  static ReportType _parseReportType(String type) {
    switch (type.toLowerCase()) {
      case 'inappropriate_content':
        return ReportType.inappropriateContent;
      case 'spam':
        return ReportType.spam;
      case 'fake_listing':
        return ReportType.fakeListing;
      case 'abusive_behavior':
        return ReportType.abusiveBehavior;
      case 'scam':
        return ReportType.scam;
      case 'other':
        return ReportType.other;
      default:
        return ReportType.other;
    }
  }

  static ReportableType _parseReportableType(String type) {
    switch (type.toLowerCase()) {
      case 'pet':
        return ReportableType.pet;
      case 'comment':
        return ReportableType.comment;
      case 'user':
        return ReportableType.user;
      default:
        return ReportableType.pet;
    }
  }

  static ReportStatus _parseReportStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReportStatus.pending;
      case 'under_review':
        return ReportStatus.underReview;
      case 'resolved':
        return ReportStatus.resolved;
      case 'dismissed':
        return ReportStatus.dismissed;
      default:
        return ReportStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'reportableType': reportableType.name,
      'reportableId': reportableId,
      'reason': reason,
      'description': description,
      'status': status.name,
      'adminNotes': adminNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'reporterId': reporterId,
      'reviewedById': reviewedById,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'type': type.name,
      'reportableType': reportableType.name,
      'reportableId': reportableId,
      'reason': reason,
      'description': description,
    };
  }

  factory ReportModel.fromEntity(Report report) {
    return ReportModel(
      id: report.id,
      type: report.type,
      reportableType: report.reportableType,
      reportableId: report.reportableId,
      reason: report.reason,
      description: report.description,
      status: report.status,
      adminNotes: report.adminNotes,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
      resolvedAt: report.resolvedAt,
      reporterId: report.reporterId,
      reviewedById: report.reviewedById,
      reporter: report.reporter,
      reviewedBy: report.reviewedBy,
    );
  }

  Report toEntity() {
    return Report(
      id: id,
      type: type,
      reportableType: reportableType,
      reportableId: reportableId,
      reason: reason,
      description: description,
      status: status,
      adminNotes: adminNotes,
      createdAt: createdAt,
      updatedAt: updatedAt,
      resolvedAt: resolvedAt,
      reporterId: reporterId,
      reviewedById: reviewedById,
      reporter: reporter,
      reviewedBy: reviewedBy,
    );
  }
}