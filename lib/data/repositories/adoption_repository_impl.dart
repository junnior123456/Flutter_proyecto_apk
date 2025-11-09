import '../../domain/entities/adoption_request.dart';
import '../../domain/repositories/adoption_repository.dart';
import '../datasources/adoption_remote_datasource.dart';
import '../models/adoption_request_model.dart';

class AdoptionRepositoryImpl implements AdoptionRepository {
  final AdoptionRemoteDataSource remoteDataSource;
  
  AdoptionRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<List<AdoptionRequest>> getAdoptionRequests({int? limit, int? offset}) async {
    try {
      final requestModels = await remoteDataSource.getAdoptionRequests(limit: limit, offset: offset);
      return requestModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get adoption requests: ${e.toString()}');
    }
  }
  
  @override
  Future<List<AdoptionRequest>> getAdoptionRequestsByPet(int petId) async {
    try {
      final requestModels = await remoteDataSource.getAdoptionRequestsByPet(petId);
      return requestModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get adoption requests by pet: ${e.toString()}');
    }
  }
  
  @override
  Future<List<AdoptionRequest>> getAdoptionRequestsByUser(int userId) async {
    try {
      final requestModels = await remoteDataSource.getAdoptionRequestsByUser(userId);
      return requestModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get adoption requests by user: ${e.toString()}');
    }
  }
  
  @override
  Future<AdoptionRequest> getAdoptionRequestById(int id) async {
    try {
      final requestModel = await remoteDataSource.getAdoptionRequestById(id);
      return requestModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get adoption request by id: ${e.toString()}');
    }
  }
  
  @override
  Future<AdoptionRequest> createAdoptionRequest(AdoptionRequest request) async {
    try {
      final requestData = AdoptionRequestModel.fromEntity(request).toCreateJson();
      final requestModel = await remoteDataSource.createAdoptionRequest(requestData);
      return requestModel.toEntity();
    } catch (e) {
      throw Exception('Failed to create adoption request: ${e.toString()}');
    }
  }
  
  @override
  Future<AdoptionRequest> updateAdoptionRequestStatus(int id, AdoptionRequestStatus status, {String? rejectionReason}) async {
    try {
      final requestModel = await remoteDataSource.updateAdoptionRequestStatus(id, status.name, rejectionReason: rejectionReason);
      return requestModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update adoption request status: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteAdoptionRequest(int id) async {
    try {
      await remoteDataSource.deleteAdoptionRequest(id);
    } catch (e) {
      throw Exception('Failed to delete adoption request: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getAdoptionStats() async {
    try {
      return await remoteDataSource.getAdoptionStats();
    } catch (e) {
      throw Exception('Failed to get adoption stats: ${e.toString()}');
    }
  }
}