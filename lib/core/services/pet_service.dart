import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/pet.dart';
import '../../domain/entities/pet_category.dart';
import 'http_service.dart';
import 'image_service.dart';
import 'auth_service.dart';
import '../utils/logger.dart';
import '../utils/validation_utils.dart';

class PetService {
  static final PetService _instance = PetService._internal();
  factory PetService() => _instance;
  PetService._internal();

  final HttpService _httpService = HttpService();
  final ImageService _imageService = ImageService();

  /// 📋 Obtener todas las mascotas
  Future<List<Pet>> getAllPets({int? categoryId}) async {
    try {
      Logger.petOperation('Getting all pets', data: {'categoryId': categoryId});

      final token = await _getToken();
      if (token != null) {
        _httpService.setAuthToken(token);
      }

      String endpoint = '/pets';
      if (categoryId != null) {
        endpoint += '?category=$categoryId';
      }

      final response = await _httpService.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final pets = data.map((json) => _petFromJson(json)).toList();

        Logger.petOperation('Retrieved ${pets.length} pets successfully');
        return pets;
      } else {
        throw Exception('Error al obtener mascotas: ${response.statusCode}');
      }
    } catch (e) {
      Logger.error('Error getting all pets', tag: 'PetService', error: e);
      return [];
    }
  }

  /// 🏠 Obtener mascotas para adopción
  Future<List<Pet>> getPetsForAdoption({int? categoryId}) async {
    try {
      Logger.petOperation(
        'Getting pets for adoption',
        data: {'categoryId': categoryId},
      );

      final token = await _getToken();
      if (token != null) {
        _httpService.setAuthToken(token);
      }

      String endpoint = '/pets/adoption';
      if (categoryId != null) {
        endpoint += '?category=$categoryId';
      }

      final response = await _httpService.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final pets = data.map((json) => _petFromJson(json)).toList();

        Logger.petOperation(
          'Retrieved ${pets.length} adoption pets successfully',
        );
        return pets;
      } else {
        throw Exception(
          'Error al obtener mascotas para adopción: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error('Error getting adoption pets', tag: 'PetService', error: e);
      return [];
    }
  }

  /// ⚠️ Obtener mascotas en riesgo
  Future<List<Pet>> getPetsInRisk({int? categoryId}) async {
    try {
      Logger.petOperation(
        'Getting pets in risk',
        data: {'categoryId': categoryId},
      );

      final token = await _getToken();
      if (token != null) {
        _httpService.setAuthToken(token);
      }

      String endpoint = '/pets/risk';
      if (categoryId != null) {
        endpoint += '?category=$categoryId';
      }

      final response = await _httpService.get(endpoint);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final pets = data.map((json) => _petFromJson(json)).toList();

        Logger.petOperation('Retrieved ${pets.length} risk pets successfully');
        return pets;
      } else {
        throw Exception(
          'Error al obtener mascotas en riesgo: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error('Error getting risk pets', tag: 'PetService', error: e);
      return [];
    }
  }

  /// ➕ Crear nueva mascota con manejo mejorado de imágenes
  Future<Pet?> createPet({
    required String name,
    required String description,
    required int categoryId,
    required bool isRisk,
    File? imageFile,
    String? age,
    String? breed,
    String? gender,
    String? size,
    bool? isVaccinated,
    bool? isSterilized,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? address,
  }) async {
    try {
      // Obtener token (se creará automáticamente en desarrollo si no existe)
      final token = await _getToken();
      if (token == null && !_authService.isDevelopmentMode) {
        throw Exception('No hay token de autenticación');
      }

      // Validar datos antes de proceder
      final validationErrors = validatePetData(
        name: name,
        description: description,
        categoryId: categoryId,
        age: age,
        breed: breed,
        contactName: contactName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        address: address,
      );

      if (validationErrors.isNotEmpty) {
        final errorMessage = validationErrors.values.join(', ');
        throw Exception('Datos inválidos: $errorMessage');
      }

      Logger.petOperation(
        'Creating new pet',
        data: {
          'name': name,
          'categoryId': categoryId,
          'isRisk': isRisk,
          'hasImage': imageFile != null,
        },
      );

      if (token != null) {
        _httpService.setAuthToken(token);
      }

      String? imageUrl;

      // 1. Si hay imagen, subirla a Firebase primero
      if (imageFile != null) {
        Logger.imageOperation('Uploading pet image to Firebase Storage');

        // Generar ID temporal para la mascota
        final tempPetId = DateTime.now().millisecondsSinceEpoch.toString();
        imageUrl = await _imageService.uploadPetImage(imageFile, tempPetId);

        if (imageUrl == null) {
          throw Exception('Error subiendo imagen a Firebase Storage');
        }

        Logger.imageOperation(
          'Pet image uploaded to Firebase',
          details: imageUrl,
          success: true,
        );
      }

      // 2. Crear mascota en backend con URL de imagen (si existe)
      Logger.petOperation('Creating pet in backend');

      final petData = _cleanPetData(
        name: name,
        description: description,
        categoryId: categoryId,
        isRisk: isRisk,
        imageUrl: imageUrl,
        age: age,
        breed: breed,
        gender: gender,
        size: size,
        isVaccinated: isVaccinated,
        isSterilized: isSterilized,
        contactName: contactName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        address: address,
      );

      final response = await _httpService.post('/pets', body: petData);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final createdPet = _petFromJson(data);

        Logger.petOperation(
          'Pet created successfully',
          petId: createdPet.id.toString(),
          data: data,
        );
        return createdPet;
      } else {
        // Si falla la creación del backend, limpiar imagen de Firebase
        if (imageUrl != null) {
          Logger.warning(
            'Backend pet creation failed, cleaning up Firebase image',
            tag: 'PetService',
          );
          await _imageService.deleteFromFirebase(imageUrl);
        }
        throw Exception(
          'Error al crear mascota en backend: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error(
        'Error creating pet',
        tag: 'PetService',
        error: e,
        stackTrace: StackTrace.current,
      );
      rethrow; // Re-lanzar para manejo en UI
    }
  }

  /// 🔄 Convertir JSON a Pet con validación
  Pet _petFromJson(Map<String, dynamic> json) {
    try {
      return Pet(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
        name: json['name']?.toString() ?? 'Sin nombre',
        description: json['description']?.toString() ?? '',
        imageUrl: json['imageUrl']?.toString() ?? '',
        isRisk: json['isRisk'] == true || json['isRisk'] == 'true',
        createdAt:
            DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        updatedAt:
            DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
            DateTime.now(),
        userId: json['userId'] is int ? json['userId'] : int.tryParse(json['userId']?.toString() ?? '1') ?? 1,
        categoryId: json['categoryId'] is int ? json['categoryId'] : int.tryParse(json['categoryId']?.toString() ?? '1') ?? 1,
        age: json['age']?.toString() ?? '',
        breed: json['breed']?.toString() ?? '',
        gender: json['gender']?.toString() ?? 'Macho',
        size: json['size']?.toString() ?? 'Mediano',
        isVaccinated:
            json['isVaccinated'] == true || json['isVaccinated'] == 'true',
        isSterilized:
            json['isSterilized'] == true || json['isSterilized'] == 'true',
        contactName: json['contactName']?.toString() ?? '',
        contactPhone: json['contactPhone']?.toString() ?? '',
        contactEmail: json['contactEmail']?.toString() ?? '',
        address: json['address']?.toString() ?? '',
        category: PetCategory.fromId(json['categoryId'] ?? 1),
      );
    } catch (e) {
      Logger.error('Error parsing pet JSON', tag: 'PetService', error: e);
      // Retornar pet con datos mínimos válidos
      return Pet(
        id: int.parse('${DateTime.now().millisecondsSinceEpoch}'.substring(0, 9)),
        name: 'Error al cargar',
        description: 'Error al cargar datos',
        imageUrl: '',
        isRisk: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        userId: 1,
        categoryId: 1,
        age: '',
        breed: '',
        gender: 'Macho',
        size: 'Mediano',
        isVaccinated: false,
        isSterilized: false,
        contactName: '',
        contactPhone: '',
        contactEmail: '',
        address: '',
        category: PetCategory.dog,
      );
    }
  }

  /// 💾 Crear mascota localmente como fallback
  Pet _createLocalPet({
    required String name,
    required String description,
    required int categoryId,
    required bool isRisk,
    String? imageUrl,
    String? age,
    String? breed,
    String? gender,
    String? size,
    bool? isVaccinated,
    bool? isSterilized,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? address,
  }) {
    Logger.petOperation('Creating local pet as fallback', data: {'name': name});

    return Pet(
      id: int.parse('${DateTime.now().millisecondsSinceEpoch}'.substring(0, 9)),
      name: name,
      description: description,
      imageUrl: imageUrl ?? '',
      isRisk: isRisk,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      userId: 1,
      categoryId: 1,
      age: age ?? '',
      breed: breed ?? '',
      gender: gender ?? 'Macho',
      size: size ?? 'Mediano',
      isVaccinated: isVaccinated ?? false,
      isSterilized: isSterilized ?? false,
      contactName: contactName ?? '',
      contactPhone: contactPhone ?? '',
      contactEmail: contactEmail ?? '',
      address: address ?? '',
      category: PetCategory.fromId(categoryId),
    );
  }

  /// 🔄 Crear mascota con fallback automático
  Future<Pet?> createPetWithFallback({
    required String name,
    required String description,
    required int categoryId,
    required bool isRisk,
    File? imageFile,
    String? age,
    String? breed,
    String? gender,
    String? size,
    bool? isVaccinated,
    bool? isSterilized,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? address,
  }) async {
    try {
      // Intentar crear en backend primero
      final backendPet = await createPet(
        name: name,
        description: description,
        categoryId: categoryId,
        isRisk: isRisk,
        imageFile: imageFile,
        age: age,
        breed: breed,
        gender: gender,
        size: size,
        isVaccinated: isVaccinated,
        isSterilized: isSterilized,
        contactName: contactName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        address: address,
      );

      if (backendPet != null) {
        return backendPet;
      }
    } catch (e) {
      Logger.warning(
        'Backend pet creation failed, using local fallback',
        tag: 'PetService',
        error: e,
      );
    }

    // Fallback: crear mascota local
    String? localImagePath;
    if (imageFile != null) {
      localImagePath = imageFile.path;
      Logger.imageOperation(
        'Using local image path as fallback',
        details: localImagePath,
      );
    }

    return _createLocalPet(
      name: name,
      description: description,
      categoryId: categoryId,
      isRisk: isRisk,
      imageUrl: localImagePath,
      age: age,
      breed: breed,
      gender: gender,
      size: size,
      isVaccinated: isVaccinated,
      isSterilized: isSterilized,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      address: address,
    );
  }

  /// 🔄 Reintentar operación con backoff exponencial
  Future<T?> _retryOperation<T>(
    Future<T> Function() operation,
    String operationName, {
    int maxRetries = 3,
    Duration initialDelay = const Duration(seconds: 1),
  }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxRetries) {
      try {
        Logger.debug(
          'Attempting $operationName (attempt ${attempt + 1}/$maxRetries)',
          tag: 'PetService',
        );
        return await operation();
      } catch (e) {
        attempt++;

        if (attempt >= maxRetries) {
          Logger.error(
            '$operationName failed after $maxRetries attempts',
            tag: 'PetService',
            error: e,
          );
          rethrow;
        }

        Logger.warning(
          '$operationName failed, retrying in ${delay.inSeconds}s',
          tag: 'PetService',
          error: e,
        );
        await Future.delayed(delay);
        delay *= 2; // Backoff exponencial
      }
    }

    return null;
  }

  /// 🔍 Validar datos de mascota usando ValidationUtils
  Map<String, String> validatePetData({
    required String name,
    required String description,
    required int categoryId,
    String? age,
    String? breed,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? address,
  }) {
    return ValidationUtils.validatePetData(
      name: name,
      description: description,
      categoryId: categoryId,
      age: age,
      breed: breed,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      address: address,
    );
  }

  /// 🧹 Limpiar y formatear datos de mascota
  Map<String, dynamic> _cleanPetData({
    required String name,
    required String description,
    required int categoryId,
    required bool isRisk,
    String? imageUrl,
    String? age,
    String? breed,
    String? gender,
    String? size,
    bool? isVaccinated,
    bool? isSterilized,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? address,
  }) {
    return {
      'name': ValidationUtils.cleanText(name),
      'description': ValidationUtils.cleanText(description),
      'categoryId': categoryId,
      'isRisk': isRisk,
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (age != null && age.isNotEmpty) 'age': ValidationUtils.cleanText(age),
      if (breed != null && breed.isNotEmpty)
        'breed': ValidationUtils.cleanText(breed),
      if (gender != null) 'gender': gender,
      if (size != null) 'size': size,
      if (isVaccinated != null) 'isVaccinated': isVaccinated,
      if (isSterilized != null) 'isSterilized': isSterilized,
      if (contactName != null && contactName.isNotEmpty)
        'contactName': ValidationUtils.cleanText(contactName),
      if (contactPhone != null && contactPhone.isNotEmpty)
        'contactPhone': ValidationUtils.formatPhone(contactPhone),
      if (contactEmail != null && contactEmail.isNotEmpty)
        'contactEmail': ValidationUtils.normalizeEmail(contactEmail),
      if (address != null && address.isNotEmpty)
        'address': ValidationUtils.cleanText(address),
    };
  }

  /// 🔄 Crear mascota con URL de imagen (ya subida a Firebase)
  Future<Pet?> createPetWithImageUrl({
    required String name,
    required String description,
    required int categoryId,
    required bool isRisk,
    String? imageUrl,
    String? age,
    String? breed,
    String? gender,
    String? size,
    bool? isVaccinated,
    bool? isSterilized,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? address,
  }) async {
    try {
      // Obtener token (se creará automáticamente en desarrollo si no existe)
      final token = await _getToken();
      if (token == null && !_authService.isDevelopmentMode) {
        throw Exception('No hay token de autenticación');
      }

      // Validar datos antes de proceder
      final validationErrors = validatePetData(
        name: name,
        description: description,
        categoryId: categoryId,
        age: age,
        breed: breed,
        contactName: contactName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        address: address,
      );

      if (validationErrors.isNotEmpty) {
        final errorMessage = validationErrors.values.join(', ');
        throw Exception('Datos inválidos: $errorMessage');
      }

      Logger.petOperation(
        'Creating new pet with Firebase URL',
        data: {
          'name': name,
          'categoryId': categoryId,
          'isRisk': isRisk,
          'hasImageUrl': imageUrl != null,
        },
      );

      if (token != null) {
        _httpService.setAuthToken(token);
      }

      // Crear mascota en backend con URL de imagen de Firebase
      Logger.petOperation('Creating pet in backend with Firebase URL');

      final petData = _cleanPetData(
        name: name,
        description: description,
        categoryId: categoryId,
        isRisk: isRisk,
        imageUrl: imageUrl,
        age: age,
        breed: breed,
        gender: gender,
        size: size,
        isVaccinated: isVaccinated,
        isSterilized: isSterilized,
        contactName: contactName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        address: address,
      );

      final response = await _httpService.post('/pets', body: petData);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final createdPet = _petFromJson(data);

        Logger.petOperation(
          'Pet created successfully with Firebase URL',
          petId: createdPet.id.toString(),
          data: data,
        );
        return createdPet;
      } else {
        throw Exception(
          'Error al crear mascota en backend: ${response.statusCode}',
        );
      }
    } catch (e) {
      Logger.error(
        'Error creating pet with image URL',
        tag: 'PetService',
        error: e,
        stackTrace: StackTrace.current,
      );

      // Fallback: crear mascota local
      Logger.warning(
        'Backend pet creation failed, using local fallback',
        tag: 'PetService',
        error: e,
      );
      return _createLocalPet(
        name: name,
        description: description,
        categoryId: categoryId,
        isRisk: isRisk,
        imageUrl: imageUrl,
        age: age,
        breed: breed,
        gender: gender,
        size: size,
        isVaccinated: isVaccinated,
        isSterilized: isSterilized,
        contactName: contactName,
        contactPhone: contactPhone,
        contactEmail: contactEmail,
        address: address,
      );
    }
  }

  final AuthService _authService = AuthService();

  /// 🔑 Obtener token de autenticación (con fallback automático)
  Future<String?> _getToken() async {
    try {
      final token = await _authService.getToken();
      Logger.storageOperation('Get auth token', success: token != null);
      return token;
    } catch (e) {
      Logger.error('Error getting auth token', tag: 'PetService', error: e);
      return null;
    }
  }
}
