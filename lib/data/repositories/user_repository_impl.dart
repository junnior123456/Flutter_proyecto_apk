import 'dart:io';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/user_remote_datasource.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  
  UserRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<User> getUserProfile(int userId) async {
    try {
      final userModel = await remoteDataSource.getUserProfile(userId);
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get user profile: ${e.toString()}');
    }
  }
  
  @override
  Future<User> getCurrentUser() async {
    try {
      final userModel = await remoteDataSource.getCurrentUser();
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get current user: ${e.toString()}');
    }
  }
  
  @override
  Future<User> updateUserProfile(int userId, User user) async {
    try {
      final userData = UserModel.fromEntity(user).toJson();
      final userModel = await remoteDataSource.updateUserProfile(userId, userData);
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update user profile: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteUserAccount(int userId) async {
    try {
      await remoteDataSource.deleteUserAccount(userId);
    } catch (e) {
      throw Exception('Failed to delete user account: ${e.toString()}');
    }
  }
  
  @override
  Future<User> uploadProfileImage(int userId, File imageFile) async {
    try {
      final userModel = await remoteDataSource.uploadProfileImage(userId, imageFile);
      return userModel.toEntity();
    } catch (e) {
      throw Exception('Failed to upload profile image: ${e.toString()}');
    }
  }
  
  @override
  Future<List<User>> searchUsers(String query) async {
    try {
      final userModels = await remoteDataSource.searchUsers(query);
      return userModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search users: ${e.toString()}');
    }
  }
}