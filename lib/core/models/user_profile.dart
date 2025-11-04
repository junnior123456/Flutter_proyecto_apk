class UserProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? image; // Cambiar de imageUrl a image como el profesor

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.image,
  });

  // Implementación EXACTA del profesor
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      image: json['image'] ?? '', // Como el profesor
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
    };
  }

  UserProfile copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? image,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      image: image ?? this.image,
    );
  }
}