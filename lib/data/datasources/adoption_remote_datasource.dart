import '../../core/services/http_service.dart';
import '../../core/utils/logger.dart';
import '../models/models.dart';

abstract class AdoptionRemoteDataSource {
  Future<AdoptionRequestModel> createAdoptionRequest(AdoptionRequestModel request);

  Future<AdoptionRequestModel?> getAdoptionRequestById(int id);

  Future<List<AdoptionRequestModel>> getAdoptionRequestsByPet(
    int petId, {
    int page = 1,
    int limit = 10,
  });

  Future<List<AdoptionRequestModel>> getMyAdoptionRequests({
    int page = 1,
    int limit = 10,
  });

  Future<List<AdoptionRequestModel>> getReceivedRequests({
    int page = 1,
    int limit = 10,
  });

  Future<AdoptionRequestModel> updateRequestStatus(
    int requestId,
    String status, {
    String? donorComments,
    String? rejectionReason,
  });

  Future<AdoptionRequestModel> completeAdoption(int requestId);

  Future<void> cancelRequest(int requestId);

  Future<Map<String, dynamic>> getAdoptionStats();
}

class AdoptionRemoteDataSourceImpl implements AdoptionRemoteDataSource {
  final HttpService _httpService;

  AdoptionRemoteDataSourceImpl(this._httpService);

  @override
  Future<AdoptionRequestModel> createAdoptionRequest(AdoptionRequestModel request) async {
    try {
      final response = await _httpService.post(
        '/api/adoption/request',
        data: request.toJson(),
      );

      if (response['ok'] == true && response['data'] != null) {
        return AdoptionRequestModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Failed to create adoption request');
    } catch (e) {
      Logger.error('Error creating adoption request: $e');
      rethrow;
    }
  }

  @override
  Future<AdoptionRequestModel?> getAdoptionRequestById(int id) async {
    try {
      final response = await _httpService.get('/api/adoption/request/$id');

      if (response['ok'] == true && response['data'] != null) {
        return AdoptionRequestModel.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      Logger.error('Error getting adoption request by id: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdoptionRequestModel>> getAdoptionRequestsByPet(
    int petId, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpService.get(
        '/api/adoption/requests/pet/$petId',
        queryParams: queryParams,
      );

      if (response['ok'] == true && response['data'] != null) {
        final requestsData = response['data'] as List;
        return requestsData.map((json) => AdoptionRequestModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      Logger.error('Error getting adoption requests by pet: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdoptionRequestModel>> getMyAdoptionRequests({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpService.get(
        '/api/adoption/requests/my-requests',
        queryParams: queryParams,
      );

      if (response['ok'] == true && response['data'] != null) {
        final requestsData = response['data'] as List;
        return requestsData.map((json) => AdoptionRequestModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      Logger.error('Error getting my adoption requests: $e');
      rethrow;
    }
  }

  @override
  Future<List<AdoptionRequestModel>> getReceivedRequests({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpService.get(
        '/api/adoption/requests/received',
        queryParams: queryParams,
      );

      if (response['ok'] == true && response['data'] != null) {
        final requestsData = response['data'] as List;
        return requestsData.map((json) => AdoptionRequestModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      Logger.error('Error getting received requests: $e');
      rethrow;
    }
  }

  @override
  Future<AdoptionRequestModel> updateRequestStatus(
    int requestId,
    String status, {
    String? donorComments,
    String? rejectionReason,
  }) async {
    try {
      final data = <String, dynamic>{
        'status': status,
      };

      if (donorComments != null) {
        data['donorComments'] = donorComments;
      }

      if (rejectionReason != null) {
        data['rejectionReason'] = rejectionReason;
      }

      final response = await _httpService.put(
        '/api/adoption/request/$requestId/status',
        data: data,
      );

      if (response['ok'] == true && response['data'] != null) {
        return AdoptionRequestModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Failed to update request status');
    } catch (e) {
      Logger.error('Error updating request status: $e');
      rethrow;
    }
  }

  @override
  Future<AdoptionRequestModel> completeAdoption(int requestId) async {
    try {
      final response = await _httpService.put('/api/adoption/request/$requestId/complete');

      if (response['ok'] == true && response['data'] != null) {
        return AdoptionRequestModel.fromJson(response['data']);
      }

      throw Exception(response['message'] ?? 'Failed to complete adoption');
    } catch (e) {
      Logger.error('Error completing adoption: $e');
      rethrow;
    }
  }

  @override
  Future<void> cancelRequest(int requestId) async {
    try {
      final response = await _httpService.delete('/api/adoption/request/$requestId');

      if (response['ok'] != true) {
        throw Exception(response['message'] ?? 'Failed to cancel request');
      }
    } catch (e) {
      Logger.error('Error canceling request: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getAdoptionStats() async {
    try {
      final response = await _httpService.get('/api/adoption/stats');

      if (response['ok'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }

      return {};
    } catch (e) {
      Logger.error('Error getting adoption stats: $e');
      rethrow;
    }
  }
}