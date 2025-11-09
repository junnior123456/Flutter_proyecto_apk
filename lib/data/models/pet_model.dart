import '../../domain/entities/pet.dart';
import '../../domain/entities/pet_category.dart';
import 'user_model.dart';

class PetModel extends Pet {
  const PetModel({
    required super.id,
    required super.name,
    required super.imageUrl,
    required super.isRisk,
    required super.createdAt,
    required super.updatedAt,
    required super.userId,
    required super.categoryId,
    super.description,
    super.address,
    super.age,
    super.breed,
    super.gender,
    super.size,
    super.isVaccinated,
    super.isSterilized,
    super.contactName,
    super.contactPhone,
    super.contactEmail,
    super.category,
    super.status,
    super.latitude,
    super.longitude,
    super.medicalHistory,
    super.specialNeeds,
    super.temperament,
    super.isActive,
    super.images,
    super.user,
  });

  factory PetModel.fromJson(Map<String, dynamic> json) {
    return PetModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      isRisk: json['isRisk'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      userId: json['userId'] as int,
      categoryId: json['categoryId'] as int,
      address: json['address'] as String? ?? '',
      age: json['age'] as String? ?? '',
      breed: json['breed'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Macho',
      size: json['size'] as String? ?? 'Mediano',
      isVaccinated: json['isVaccinated'] as bool? ?? false,
      isSterilized: json['isSterilized'] as bool? ?? false,
      contactName: json['contactName'] as String? ?? '',
      contactPhone: json['contactPhone'] as String? ?? '',
      contactEmail: json['contactEmail'] as String? ?? '',
      category: _parsePetCategory(json['category']),
      status: _parsePetStatus(json['status'] as String?),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      medicalHistory: json['medicalHistory'] as String?,
      specialNeeds: json['specialNeeds'] as String?,
      temperament: json['temperament'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      images: _parseImages(json['images']),
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
    );
  }

  static PetCategory _parsePetCategory(dynamic categoryData) {
    if (categoryData is Map<String, dynamic>) {
      final name = categoryData['name'] as String?;
      return _categoryFromString(name);
    } else if (categoryData is String) {
      return _categoryFromString(categoryData);
    }
    return PetCategory.dog;
  }

  static PetCategory _categoryFromString(String? categoryName) {
    switch (categoryName?.toLowerCase()) {
      case 'perros':
      case 'dog':
        return PetCategory.dog;
      case 'gatos':
      case 'cat':
        return PetCategory.cat;
      case 'aves':
      case 'bird':
        return PetCategory.bird;
      case 'otros':
      case 'other':
        return PetCategory.other;
      default:
        return PetCategory.dog;
    }
  }

  static PetStatus _parsePetStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return PetStatus.available;
      case 'pending':
        return PetStatus.pending;
      case 'adopted':
        return PetStatus.adopted;
      case 'removed':
        return PetStatus.removed;
      default:
        return PetStatus.available;
    }
  }

  static List<String> _parseImages(dynamic imagesData) {
    if (imagesData is List) {
      return imagesData
          .map((img) {
            if (img is Map<String, dynamic>) {
              return img['url'] as String? ?? '';
            } else if (img is String) {
              return img;
            }
            return '';
          })
          .where((url) => url.isNotEmpty)
          .toList();
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'isRisk': isRisk,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
      'categoryId': categoryId,
      'address': address,
      'age': age,
      'breed': breed,
      'gender': gender,
      'size': size,
      'isVaccinated': isVaccinated,
      'isSterilized': isSterilized,
      'contactName': contactName,
      'contactPhone': contactPhone,
      'contactEmail': contactEmail,
      'status': status.name,
      'latitude': latitude,
      'longitude': longitude,
      'medicalHistory': medicalHistory,
      'specialNeeds': specialNeeds,
      'temperament': temperament,
      'isActive': isActive,
      'images': images,
    };
  }

  factory PetModel.fromEntity(Pet pet) {
    return PetModel(
      id: pet.id,
      name: pet.name,
      description: pet.description,
      imageUrl: pet.imageUrl,
      isRisk: pet.isRisk,
      createdAt: pet.createdAt,
      updatedAt: pet.updatedAt,
      userId: pet.userId,
      categoryId: pet.categoryId,
      address: pet.address,
      age: pet.age,
      breed: pet.breed,
      gender: pet.gender,
      size: pet.size,
      isVaccinated: pet.isVaccinated,
      isSterilized: pet.isSterilized,
      contactName: pet.contactName,
      contactPhone: pet.contactPhone,
      contactEmail: pet.contactEmail,
      category: pet.category,
      status: pet.status,
      latitude: pet.latitude,
      longitude: pet.longitude,
      medicalHistory: pet.medicalHistory,
      specialNeeds: pet.specialNeeds,
      temperament: pet.temperament,
      isActive: pet.isActive,
      images: pet.images,
      user: pet.user,
    );
  }

  Pet toEntity() {
    return Pet(
      id: id,
      name: name,
      description: description,
      imageUrl: imageUrl,
      isRisk: isRisk,
      createdAt: createdAt,
      updatedAt: updatedAt,
      userId: userId,
      categoryId: categoryId,
      address: address,
      age: age,
      breed: breed,
      gender: gender,
      size: size,
      isVaccinated: isVaccinated,
      isSterilized: isSterilized,
      contactName: contactName,
      contactPhone: contactPhone,
      contactEmail: contactEmail,
      category: category,
      status: status,
      latitude: latitude,
      longitude: longitude,
      medicalHistory: medicalHistory,
      specialNeeds: specialNeeds,
      temperament: temperament,
      isActive: isActive,
      images: images,
      user: user,
    );
  }
}