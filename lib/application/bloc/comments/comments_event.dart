import 'package:equatable/equatable.dart';

abstract class CommentsEvent extends Equatable {
  const CommentsEvent();

  @override
  List<Object?> get props => [];
}

class FetchCommentsByPet extends CommentsEvent {
  const FetchCommentsByPet(this.petId);
  
  final int petId;

  @override
  List<Object?> get props => [petId];
}

class CreateComment extends CommentsEvent {
  const CreateComment({
    required this.petId,
    required this.userId,
    required this.text,
  });
  
  final int petId;
  final int userId;
  final String text;

  @override
  List<Object?> get props => [petId, userId, text];
}

class UpdateComment extends CommentsEvent {
  const UpdateComment({
    required this.commentId,
    required this.text,
  });
  
  final int commentId;
  final String text;

  @override
  List<Object?> get props => [commentId, text];
}

class DeleteComment extends CommentsEvent {
  const DeleteComment(this.commentId);
  
  final int commentId;

  @override
  List<Object?> get props => [commentId];
}

class RefreshComments extends CommentsEvent {
  const RefreshComments();
}
