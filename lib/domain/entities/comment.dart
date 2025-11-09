import 'package:equatable/equatable.dart';
import 'user.dart';
import 'pet.dart';

class Comment extends Equatable {
  final int id;
  final int petId;
  final int userId;
  final String content;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Relaciones opcionales
  final Pet? pet;
  final User? user;

  const Comment({
    required this.id,
    required this.petId,
    required this.userId,
    required this.content,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.pet,
    this.user,
  });

  // Getters útiles
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

  bool get isEdited => updatedAt.isAfter(createdAt.add(const Duration(seconds: 1)));

  String get authorName => user?.displayName ?? 'Usuario desconocido';

  Comment copyWith({
    int? id,
    int? petId,
    int? userId,
    String? content,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    Pet? pet,
    User? user,
  }) {
    return Comment(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pet: pet ?? this.pet,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        id,
        petId,
        userId,
        content,
        isActive,
        createdAt,
        updatedAt,
        pet,
        user,
      ];

  @override
  String toString() {
    return 'Comment(id: $id, petId: $petId, userId: $userId, content: ${content.length > 50 ? '${content.substring(0, 50)}...' : content})';
  }
}