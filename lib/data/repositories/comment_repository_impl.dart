import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_datasource.dart';
import '../models/comment_model.dart';

class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource remoteDataSource;
  
  CommentRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<List<Comment>> getCommentsByPet(int petId, {int? limit, int? offset}) async {
    try {
      final commentModels = await remoteDataSource.getCommentsByPet(petId, limit: limit, offset: offset);
      return commentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get comments by pet: ${e.toString()}');
    }
  }
  
  @override
  Future<Comment> createComment(Comment comment) async {
    try {
      final commentData = CommentModel.fromEntity(comment).toCreateJson();
      final commentModel = await remoteDataSource.createComment(commentData);
      return commentModel.toEntity();
    } catch (e) {
      throw Exception('Failed to create comment: ${e.toString()}');
    }
  }
  
  @override
  Future<Comment> updateComment(Comment comment) async {
    try {
      final commentData = CommentModel.fromEntity(comment).toJson();
      final commentModel = await remoteDataSource.updateComment(comment.id, commentData);
      return commentModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update comment: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteComment(int commentId) async {
    try {
      await remoteDataSource.deleteComment(commentId);
    } catch (e) {
      throw Exception('Failed to delete comment: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Comment>> getCommentsByUser(int userId) async {
    try {
      final commentModels = await remoteDataSource.getCommentsByUser(userId);
      return commentModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get comments by user: ${e.toString()}');
    }
  }
}