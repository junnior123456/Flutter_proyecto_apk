import 'package:equatable/equatable.dart';
import 'pet_category.dart';
import 'user.dart';

enum PetStatus {
  available,
  pending,
  adopted,
  removed,
}

class Pet extends Equatable {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isRisk;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int userId;
  final String address;
  final String age;
  final String breed;
  final String gender;
  final String size;
  final bool isVaccinated;
  final bool isSterilized;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final PetCategory category;
  final int categoryId;
  final PetStatus status;
  final double? latitude;
  final double? longitude;
  final String? medicalHistory;
  final String? specialNeeds;
  final String? temperament;
  final bool isActive;
  final List<String> images;
  
  // Relaciones opcionales
  final User? user;

  const Pet({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isRisk,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.categoryId,
    this.description = '',
    this.address = '',
    this.age = '',
    this.breed = '',
    this.gender = 'Macho',
    this.size = 'Mediano',
    this.isVaccinated = false,
    this.isSterilized = false,
    this.contactName = '',
    this.contactPhone = '',
    this.contactEmail = '',
    this.category = PetCategory.dog,
    this.status = PetStatus.available,
    this.latitude,
    this.longitude,
    this.medicalHistory,
    this.specialNeeds,
    this.temperament,
    this.isActive = true,
    this.images = const [],
    this.user,
  });

  // Getters útiles
  String get statusString {
    switch (status) {
      case PetStatus.available:
        return 'Disponible';
      case PetStatus.pending:
        return 'Pendiente';
      case PetStatus.adopted:
        return 'Adoptado';
      case PetStatus.removed:
        return 'Removido';
    }
  }

  bool get isAvailable => status == PetStatus.available && isActive;
  bool get isPending => status == PetStatus.pending;
  bool get isAdopted => status == PetStatus.adopted;
  bool get isRemoved => status == PetStatus.removed;

  bool get hasLocation => latitude != null && longitude != null;
  bool get hasMedicalInfo => medicalHistory != null && medicalHistory!.isNotEmpty;
  bool get hasSpecialNeeds => specialNeeds != null && specialNeeds!.isNotEmpty;
  bool get hasMultipleImages => images.length > 1;

  String get ownerName => user?.displayName ?? contactName;
  String get primaryImage => images.isNotEmpty ? images.first : imageUrl;

  Duration get timeSinceCreated => DateTime.now().difference(createdAt);
  Duration get timeSinceUpdated => DateTime.now().difference(updatedAt);

  String get timeSinceCreatedString {
    final duration = timeSinceCreated;
    if (duration.inDays > 0) {
      return 'Hace ${duration.inDays} ${duration.inDays == 1 ? 'día' : 'días'}';
    } else if (duration.inHours > 0) {
      return 'Hace ${duration.inHours} ${duration.inHours == 1 ? 'hora' : 'horas'}';
    } else if (duration.inMinutes > 0) {
      return 'Hace ${duration.inMinutes} ${duration.inMinutes == 1 ? 'minuto' : 'minutos'}';
    } else {
      return 'Hace unos momentos';
    }
  }

  Pet copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isRisk,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? userId,
    int? categoryId,
    String? address,
    String? age,
    String? breed,
    String? gender,
    String? size,
    bool? isVaccinated,
    bool? isSterilized,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    PetCategory? category,
    PetStatus? status,
    double? latitude,
    double? longitude,
    String? medicalHistory,
    String? specialNeeds,
    String? temperament,
    bool? isActive,
    List<String>? images,
    User? user,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isRisk: isRisk ?? this.isRisk,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      address: address ?? this.address,
      age: age ?? this.age,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      size: size ?? this.size,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      isSterilized: isSterilized ?? this.isSterilized,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      contactEmail: contactEmail ?? this.contactEmail,
      category: category ?? this.category,
      status: status ?? this.status,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      temperament: temperament ?? this.temperament,
      isActive: isActive ?? this.isActive,
      images: images ?? this.images,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        isRisk,
        createdAt,
        updatedAt,
        userId,
        categoryId,
        address,
        age,
        breed,
        gender,
        size,
        isVaccinated,
        isSterilized,
        contactName,
        contactPhone,
        contactEmail,
        category,
        status,
        latitude,
        longitude,
        medicalHistory,
        specialNeeds,
        temperament,
        isActive,
        images,
        user,
      ];

  @override
  String toString() {
    return 'Pet(id: $id, name: $name, status: $status, isActive: $isActive)';
  }
}