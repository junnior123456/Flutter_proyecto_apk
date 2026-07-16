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

  /// Categorías que la app ofrece hoy: solo perros y gatos.
  ///
  /// `bird`, `rabbit` y `other` siguen en el enum (y en la BD) para que las
  /// publicaciones antiguas se sigan leyendo bien, pero no se ofrecen: toda la
  /// capa de IA es canina (PawMatch pide tamano_perro / energia_perro /
  /// edad_perro_anos), así que publicar un ave prometía algo que la app no
  /// cumple. Para volver a abrirlas, añádelas aquí.
  static const List<PetCategory> offered = [dog, cat];

  /// Para los formularios de publicar (sin "Todos").
  static List<PetCategory> get selectableCategories => offered;

  /// Para los chips de filtro del dashboard ("Todos" + las ofrecidas).
  static List<PetCategory> get filterCategories => [all, ...offered];
}