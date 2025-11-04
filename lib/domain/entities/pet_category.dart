enum PetCategory {
  all('Todos', '🐾', 0),
  dog('Perros', '🐕', 1),
  cat('Gatos', '🐱', 2),
  bird('Aves', '🐦', 3),
  rabbit('Conejos', '🐰', 4),
  other('Otros', '🐹', 5);

  const PetCategory(this.displayName, this.emoji, this.id);
  
  final String displayName;
  final String emoji;
  final int id; // ID para la base de datos

  String get fullName => '$emoji $displayName';

  /// Obtener categoría por ID de base de datos
  static PetCategory fromId(int id) {
    return PetCategory.values.firstWhere(
      (category) => category.id == id,
      orElse: () => PetCategory.other,
    );
  }

  /// Obtener todas las categorías excepto "Todos" (para formularios)
  static List<PetCategory> get selectableCategories {
    return PetCategory.values.where((category) => category != PetCategory.all).toList();
  }
}