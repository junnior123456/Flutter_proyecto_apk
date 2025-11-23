import 'package:equatable/equatable.dart';

abstract class CommentsState extends Equatable {
  const CommentsState();

  @override
  List<Object?> get props => [];
}

class CommentsInitial extends CommentsState {
  const CommentsInitial();
}

class CommentsLoading extends CommentsState {
  const CommentsLoading();
}

class CommentsLoaded extends CommentsState {
  const CommentsLoaded(this.comments);
  
  final List<dynamic> comments;

  @override
  List<Object?> get props => [comments];
}

class CommentCreated extends CommentsState {
  const CommentCreated(this.comment);
  
  final dynamic comment;

  @override
  List<Object?> get props => [comment];
}

class CommentUpdated extends CommentsState {
  const CommentUpdated(this.comment);
  
  final dynamic comment;

  @override
  List<Object?> get props => [comment];
}

class CommentDeleted extends CommentsState {
  const CommentDeleted(this.commentId);
  
  final int commentId;

  @override
  List<Object?> get props => [commentId];
}

class CommentsError extends CommentsState {
  const CommentsError(this.message);
  
  final String message;

  @override
  List<Object?> get props => [message];
}
