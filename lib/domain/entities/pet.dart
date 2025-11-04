import 'pet_category.dart';

class Pet {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isRisk;
  final DateTime createdAt;
  final String userId;
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

  Pet({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.isRisk,
    required this.createdAt,
    required this.userId,
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
  });

  Pet copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isRisk,
    DateTime? createdAt,
    String? userId,
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
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isRisk: isRisk ?? this.isRisk,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
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
    );
  }
}