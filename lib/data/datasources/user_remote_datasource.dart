import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'http_service.dart';

abstract class UserRemoteDataSource {
  Future<UserModel> getUserProfile(int userId);
  Future<UserModel> updateUserProfile(int userId, Map<String, dynamic> userData);
  Future<void> deleteUserAccount(int userId);
  Future<UserModel> uploadProfileImage(int userId, File imageFile);
  Future<List<UserModel>> searchUsers(String query);
  Future<UserModel> getCurrentUser();
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final HttpService httpService;
  
  UserRemoteDataSourceImpl({required this.httpService});
  
  @override
  Future<UserModel> getUserProfile(int userId) async {
    try {
      final response = await httpService.get('/users/$userId');
      
      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to get user profile: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error getting user profile: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await httpService.get('/users/profile');
      
      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to get current user: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error getting current user: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> updateUserProfile(int userId, Map<String, dynamic> userData) async {
    try {
      final response = await httpService.put('/users/$userId', body: userData);
      
      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to update user profile: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error updating user profile: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteUserAccount(int userId) async {
    try {
      final response = await httpService.delete('/users/$userId');
      
      if (response['success'] != true) {
        throw Exception('Failed to delete user account: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error deleting user account: ${e.toString()}');
    }
  }
  
  @override
  Future<UserModel> uploadProfileImage(int userId, File imageFile) async {
    try {
      final multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      );
      
      final response = await httpService.postMultipart(
        '/users/$userId/image',
        {},
        [multipartFile],
      );
      
      if (response['success'] == true && response['data'] != null) {
        return UserModel.fromJson(response['data']);
      } else {
        throw Exception('Failed to upload profile image: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error uploading profile image: ${e.toString()}');
    }
  }
  
  @override
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final response = await httpService.get('/users/search', queryParams: {
        'query': query,
      });
      
      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> usersJson = response['data'];
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search users: ${response['message']}');
      }
    } catch (e) {
      throw Exception('Error searching users: ${e.toString()}');
    }
  }
}