import '../../domain/entities/adoption_request.dart';
import 'user_model.dart';
import 'pet_model.dart';

class AdoptionRequestModel extends AdoptionRequest {
  const AdoptionRequestModel({
    required super.id,
    required super.petId,
    required super.adopterId,
    required super.personalInfo,
    required super.motivation,
    required super.status,
    super.rejectionReason,
    required super.createdAt,
    required super.updatedAt,
    super.reviewedAt,
    super.pet,
    super.adopter,
  });

  factory AdoptionRequestModel.fromJson(Map<String, dynamic> json) {
    return AdoptionRequestModel(
      id: json['id'] as int,
      petId: json['petId'] as int,
      adopterId: json['adopterId'] as int,
      personalInfo: json['personalInfo'] as String,
      motivation: json['motivation'] as String,
      status: _parseStatus(json['status'] as String),
      rejectionReason: json['rejectionReason'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      reviewedAt: json['reviewedAt'] != null
          ? DateTime.parse(json['reviewedAt'] as String)
          : null,
      pet: json['pet'] != null ? PetModel.fromJson(json['pet']) : null,
      adopter: json['adopter'] != null ? UserModel.fromJson(json['adopter']) : null,
    );
  }

  static AdoptionRequestStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AdoptionRequestStatus.pending;
      case 'accepted':
        return AdoptionRequestStatus.accepted;
      case 'rejected':
        return AdoptionRequestStatus.rejected;
      case 'cancelled':
        return AdoptionRequestStatus.cancelled;
      default:
        return AdoptionRequestStatus.pending;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'adopterId': adopterId,
      'personalInfo': personalInfo,
      'motivation': motivation,
      'status': status.name,
      'rejectionReason': rejectionReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'petId': petId,
      'personalInfo': personalInfo,
      'motivation': motivation,
    };
  }

  factory AdoptionRequestModel.fromEntity(AdoptionRequest request) {
    return AdoptionRequestModel(
      id: request.id,
      petId: request.petId,
      adopterId: request.adopterId,
      personalInfo: request.personalInfo,
      motivation: request.motivation,
      status: request.status,
      rejectionReason: request.rejectionReason,
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
      reviewedAt: request.reviewedAt,
      pet: request.pet,
      adopter: request.adopter,
    );
  }

  AdoptionRequest toEntity() {
    return AdoptionRequest(
      id: id,
      petId: petId,
      adopterId: adopterId,
      personalInfo: personalInfo,
      motivation: motivation,
      status: status,
      rejectionReason: rejectionReason,
      createdAt: createdAt,
      updatedAt: updatedAt,
      reviewedAt: reviewedAt,
      pet: pet,
      adopter: adopter,
    );
  }
}