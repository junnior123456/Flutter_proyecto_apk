import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String lastname;
  final String email;
  final String? phone;
  final String? image;
  final String? address;
  final String? bio;
  final bool isActive;
  final bool isVerified;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.lastname,
    required this.email,
    this.phone,
    this.image,
    this.address,
    this.bio,
    this.isActive = true,
    this.isVerified = false,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getters útiles
  String get fullName => '$name $lastname'.trim();
  
  String get displayName => fullName.isNotEmpty ? fullName : email;
  
  bool get hasProfileImage => image != null && image!.isNotEmpty;
  
  bool get hasCompleteProfile => 
      name.isNotEmpty && 
      lastname.isNotEmpty && 
      phone != null && 
      address != null;

  User copyWith({
    int? id,
    String? name,
    String? lastname,
    String? email,
    String? phone,
    String? image,
    String? address,
    String? bio,
    bool? isActive,
    bool? isVerified,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        lastname,
        email,
        phone,
        image,
        address,
        bio,
        isActive,
        isVerified,
        lastLoginAt,
        createdAt,
        updatedAt,
      ];

  @override
  String toString() {
    return 'User(id: $id, name: $fullName, email: $email, isActive: $isActive)';
  }
}