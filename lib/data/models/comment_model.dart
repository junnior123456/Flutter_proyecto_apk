import '../../domain/entities/comment.dart';
import 'user_model.dart';
import 'pet_model.dart';

class CommentModel extends Comment {
  const CommentModel({
    required super.id,
    required super.petId,
    required super.userId,
    required super.content,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
    super.pet,
    super.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as int,
      petId: json['petId'] as int,
      userId: json['userId'] as int,
      content: json['content'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      pet: json['pet'] != null ? PetModel.fromJson(json['pet']) : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'userId': userId,
      'content': content,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'petId': petId,
      'content': content,
    };
  }

  factory CommentModel.fromEntity(Comment comment) {
    return CommentModel(
      id: comment.id,
      petId: comment.petId,
      userId: comment.userId,
      content: comment.content,
      isActive: comment.isActive,
      createdAt: comment.createdAt,
      updatedAt: comment.updatedAt,
      pet: comment.pet,
      user: comment.user,
    );
  }

  Comment toEntity() {
    return Comment(
      id: id,
      petId: petId,
      userId: userId,
      content: content,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      pet: pet,
      user: user,
    );
  }
}