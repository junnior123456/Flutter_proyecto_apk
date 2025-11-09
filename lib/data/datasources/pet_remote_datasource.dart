import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/services/http_service.dart';
import '../../core/utils/logger.dart';
import '../models/models.dart';

abstract class PetRemoteDataSource {
  Future<List<PetModel>> getAllPets({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? status,
  });

  Future<PetModel?> getPetById(int id);

  Future<List<PetModel>> getPetsByUser(
    int userId, {
    int page = 1,
    int limit = 10,
    String? status,
  });

  Future<PetModel> createPet(PetModel pet);

  Future<PetModel> updatePet(PetModel pet);

  Future<void> deletePet(int id);

  Future<List<PetModel>> searchPets(Map<String, dynamic> filters);

  Future<List<PetModel>> getPetsNearby(
    double latitude,
    double longitude, {
    double radius = 10.0,
    int page = 1,
    int limit = 10,
  });

  Future<List<PetImageModel>> addPetImages(int petId, List<String> imageUrls);

  Future<void> removePetImage(int petId, int imageId);

  Future<PetImageModel> setPrimaryImage(int petId, int imageId);

  Future<PetModel> updatePetStatus(int petId, String status);

  Future<Map<String, dynamic>> getPetStats();

  Future<Map<String, dynamic>> getUserPetStats(int userId);
}

class PetRemoteDataSourceImpl implements PetRemoteDataSource {
  final HttpService _httpService;

  PetRemoteDataSourceImpl(this._httpService);

  @override
  Future<List<PetModel>> getAllPets({
    int page = 1,
    int limit = 10,
    int? categoryId,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (categoryId != null) {
        queryParams['category'] = categoryId.toString();
      }

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _httpService.get(
        '/api/pets',
        queryParams: queryParams,
      );

      if (response['ok'] == true && response['data'] != null) {
        final petsData = response['data']['pets'] as List;
        return petsData.map((json) => PetModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      Logger.error('Error getting all pets: $e');
      rethrow;
    }
  }

  @override
  Future<PetModel?> getPetById(int id) async {
    try {
      final response = await _httpService.get('/api/pets/$id');

      if (response['ok'] == true && response['data'] != null) {
        return PetModel.fromJson(response['data']);
      }

      return null;
    } catch (e) {
      Logger.error('Error getting pet by id: $e');
      rethrow;
    }
  }

  @override
  Future<List<PetModel>> getPetsByUser(
    int userId, {
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (status != null) {
        queryParams['status'] = status;
      }

      final response = await _httpService.get(
        '/api/pets/my-pets',
        queryParams: queryParams,
      );

      if (response['ok'] == true && response['data'] != null) {
        final petsData = response['data']['pets'] as List;
        return petsData.map((json) => PetModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      Logger.error('Error getting pets by user: $e');
      rethrow;
    }
  }

  @override
  Future<PetModel> createPet(PetModel pet) async {
    try {
      final response = await _httpService.post(
        '/api/pets',
        data: pet.toJson(),
      );

      if (response['ok'] == true && response['data'] != null) {
        return PetModel.fromJson(response['data']);
      }

      throw Exception('Failed to create pet');
    } catch (e) {
      Logger.error('Error creating pet: $e');
      rethrow;
    }
  }

  @override
  Future<PetModel> updatePet(PetModel pet) async {
    try {
      final response = await _httpService.patch(
        '/api/pets/${pet.id}',
        data: pet.toJson(),
      );

      if (response['ok'] == true && response['data'] != null) {
        return PetModel.fromJson(response['data']);
      }

      throw Exception('Failed to update pet');
    } catch (e) {
      Logger.error('Error updating pet: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePet(int id) async {
    try {
      final response = await _httpService.delete('/api/pets/$id');

      if (response['ok'] != true) {
        throw Exception('Failed to delete pet');
      }
    } catch (e) {
      Logger.error('Error deleting pet: $e');
      rethrow;
    }
  }

  @override
  Future<List<PetModel>> searchPets(Map<String, dynamic> filters) async {
    try {
      final response = await _httpService.post(
        '/api/pets/search',
        data: filters,
      );

      if (response['ok'] == true && response['data'] != null) {
        final petsData = response['data']['pets'] as List;
        return petsData.map((json) => PetModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      Logger.error('Error searching pets: $e');
      rethrow;
    }
  }

  @override
  Future<List<PetModel>> getPetsNearby(
    double latitude,
    double longitude, {
    double radius = 10.0,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'lat': latitude.toString(),
        'lng': longitude.toString(),
        'radius': radius.toString(),
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final response = await _httpService.get(
        '/api/pets/nearby',
        queryParams: queryParams,
      );

      if (response['ok'] == true && response['data'] != null) {
        final petsData = response['data']['pets'] as List;
        return petsData.map((json) => PetModel.fromJson(json)).toList();
      }

      return [];
    } catch (e) {
      Logger.error('Error getting nearby pets: $e');
      rethrow;
    }
  }

  @override
  Future<List<PetImageModel>> addPetImages(int petId, List<String> imageUrls) async {
    try {
      // Crear FormData para subir múltiples imágenes
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('${_httpService.baseUrl}/api/pets/$petId/images'),
      );

      // Agregar headers de autenticación
      final token = await _httpService.getAuthToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Agregar imágenes como archivos
      for (int i = 0; i < imageUrls.length; i++) {
        final imageUrl = imageUrls[i];
        if (imageUrl.startsWith('http')) {
          // Si es una URL, descargar la imagen primero
          final imageResponse = await http.get(Uri.parse(imageUrl));
          request.files.add(
            http.MultipartFile.fromBytes(
              'images',
              imageResponse.bodyBytes,
              filename: 'image_$i.jpg',
            ),
          );
        } else {
          // Si es un archivo local
          request.files.add(
            await http.MultipartFile.fromPath('images', imageUrl),
          );
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      final responseData = json.decode(response.body);

      if (responseData['ok'] == true && responseData['data'] != null) {
        final imagesData = responseData['data']['uploadedImages'] as List;
        return imagesData.map((json) => PetImageModel.fromJson(json)).toList();
      }

      throw Exception('Failed to add pet images');
    } catch (e) {
      Logger.error('Error adding pet images: $e');
      rethrow;
    }
  }

  @override
  Future<void> removePetImage(int petId, int imageId) async {
    try {
      final response = await _httpService.delete('/api/pets/$petId/images/$imageId');

      if (response['ok'] != true) {
        throw Exception('Failed to remove pet image');
      }
    } catch (e) {
      Logger.error('Error removing pet image: $e');
      rethrow;
    }
  }

  @override
  Future<PetImageModel> setPrimaryImage(int petId, int imageId) async {
    try {
      final response = await _httpService.patch('/api/pets/$petId/images/$imageId/primary');

      if (response['ok'] == true && response['data'] != null) {
        return PetImageModel.fromJson(response['data']);
      }

      throw Exception('Failed to set primary image');
    } catch (e) {
      Logger.error('Error setting primary image: $e');
      rethrow;
    }
  }

  @override
  Future<PetModel> updatePetStatus(int petId, String status) async {
    try {
      final response = await _httpService.patch(
        '/api/pets/$petId/status',
        data: {'status': status},
      );

      if (response['ok'] == true && response['data'] != null) {
        return PetModel.fromJson(response['data']);
      }

      throw Exception('Failed to update pet status');
    } catch (e) {
      Logger.error('Error updating pet status: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getPetStats() async {
    try {
      final response = await _httpService.get('/api/pets/stats/general');

      if (response['ok'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }

      return {};
    } catch (e) {
      Logger.error('Error getting pet stats: $e');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> getUserPetStats(int userId) async {
    try {
      final response = await _httpService.get('/api/pets/stats/my-stats');

      if (response['ok'] == true && response['data'] != null) {
        return response['data'] as Map<String, dynamic>;
      }

      return {};
    } catch (e) {
      Logger.error('Error getting user pet stats: $e');
      rethrow;
    }
  }
}