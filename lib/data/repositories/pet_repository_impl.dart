import 'dart:io';
import '../../domain/entities/pet.dart';
import '../../domain/entities/search_filter.dart';
import '../../domain/repositories/pet_repository.dart';
import '../datasources/pet_remote_datasource.dart';
import '../models/pet_model.dart';

class PetRepositoryImpl implements PetRepository {
  final PetRemoteDataSource remoteDataSource;
  
  PetRepositoryImpl({required this.remoteDataSource});
  
  @override
  Future<List<Pet>> getAllPets({int? limit, int? offset}) async {
    try {
      final petModels = await remoteDataSource.getAllPets(limit: limit, offset: offset);
      return petModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all pets: ${e.toString()}');
    }
  }
  
  @override
  Future<Pet> getPetById(int id) async {
    try {
      final petModel = await remoteDataSource.getPetById(id);
      return petModel.toEntity();
    } catch (e) {
      throw Exception('Failed to get pet by id: ${e.toString()}');
    }
  }
  
  @override
  Future<Pet> createPet(Pet pet) async {
    try {
      final petData = PetModel.fromEntity(pet).toJson();
      final petModel = await remoteDataSource.createPet(petData);
      return petModel.toEntity();
    } catch (e) {
      throw Exception('Failed to create pet: ${e.toString()}');
    }
  }
  
  @override
  Future<Pet> updatePet(Pet pet) async {
    try {
      final petData = PetModel.fromEntity(pet).toJson();
      final petModel = await remoteDataSource.updatePet(pet.id, petData);
      return petModel.toEntity();
    } catch (e) {
      throw Exception('Failed to update pet: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deletePet(int id) async {
    try {
      await remoteDataSource.deletePet(id);
    } catch (e) {
      throw Exception('Failed to delete pet: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Pet>> searchPets(SearchFilter filter) async {
    try {
      final petModels = await remoteDataSource.searchPets(filter);
      return petModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search pets: ${e.toString()}');
    }
  }
  
  @override
  Future<Pet> uploadPetImages(int petId, List<File> imageFiles) async {
    try {
      final petModel = await remoteDataSource.uploadPetImages(petId, imageFiles);
      return petModel.toEntity();
    } catch (e) {
      throw Exception('Failed to upload pet images: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Pet>> getPetsByUser(int userId) async {
    try {
      final petModels = await remoteDataSource.getPetsByUser(userId);
      return petModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get pets by user: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Pet>> getNearbyPets(double latitude, double longitude, {double radiusKm = 10.0}) async {
    try {
      final petModels = await remoteDataSource.getNearbyPets(latitude, longitude, radiusKm: radiusKm);
      return petModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get nearby pets: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Pet>> getPetsByCategory(String categoryName) async {
    try {
      final petModels = await remoteDataSource.getPetsByCategory(categoryName);
      return petModels.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get pets by category: ${e.toString()}');
    }
  }
}