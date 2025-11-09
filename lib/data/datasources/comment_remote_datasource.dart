import '../models/comment_model.dart';
import 'http_service.dart';

abstract class CommentRemoteDataSource {
  Future<List<CommentModel>> getCommentsByPet(int petId, {int? limit, int? offset});
  Future<CommentModel> createComment(Map<String, dynamic> commentData);
  Future<CommentModel> updateComment(int commentId, Map<String, dynamic> commentData);
  Future<void> deleteComment(int commentId);
  Future<List<CommentModel>> getCommentsByUser(int userId);
}

class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final HttpService httpService;
  
  CommentRemoteDataSourceImpl({required this.httpService});
  
  @override
  Future<List<CommentModel>> getCommentsByPet(int petId, {int? limit, int? offset}) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      if (offset != null) queryParams['offset'] = offset.toString();
      
      final response = await httpService.get('/comments/pet/$petId', queryParams: queryParams);
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> commentsJson = response['data'];
        return commentsJson.map((json) => CommentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error loading comments: ${e.toString()}');
    }
  }
  
  @override
  Future<CommentModel> createComment(Map<String, dynamic> commentData) async {
    try {
      final response = await httpService.post('/comments', body: commentData);
      
      if (response['success'] == true && response['data'] != null) {
        return CommentModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to create comment: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error creating comment: ${e.toString()}');
    }
  }
  
  @override
  Future<CommentModel> updateComment(int commentId, Map<String, dynamic> commentData) async {
    try {
      final response = await httpService.put('/comments/$commentId', body: commentData);
      
      if (response['success'] == true && response['data'] != null) {
        return CommentModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to update comment: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error updating comment: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteComment(int commentId) async {
    try {
      final response = await httpService.delete('/comments/$commentId');
      
      if (response['success'] != true) {
        throw Exception('Failed to delete comment: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error deleting comment: ${e.toString()}');
    }
  }
  
  @override
  Future<List<CommentModel>> getCommentsByUser(int userId) async {
    try {
      final response = await httpService.get('/comments/user/$userId');
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> commentsJson = response['data'];
        return commentsJson.map((json) => CommentModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user comments: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error loading user comments: ${e.toString()}');
    }
  }
}