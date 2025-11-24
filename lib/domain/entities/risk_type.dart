/// 🚨 Tipos de riesgo para mascotas
enum RiskType {
  // 🏥 Salud
  injured,
  sick,
  malnourished,
  dehydrated,
  unvaccinated,
  parasites,
  
  // 🏚️ Abandono
  streetAbandoned,
  precariousConditions,
  hitByVehicle,
  extremeWeather,
  lostDisoriented,
  
  // ⚠️ Peligro
  dangerousZone,
  animalAbuse,
  streetFights,
  disasterZone,
  
  // 👶 Vulnerabilidad
  puppyWithoutMother,
  elderlyFragile,
  pregnant,
  disabled,
  traumatized,
}

extension RiskTypeExtension on RiskType {
  /// Obtener etiqueta en español
  String get label {
    switch (this) {
      // Salud
      case RiskType.injured:
        return 'Herido/Lesionado';
      case RiskType.sick:
        return 'Enfermo';
      case RiskType.malnourished:
        return 'Desnutrido/Hambriento';
      case RiskType.dehydrated:
        return 'Deshidratado';
      case RiskType.unvaccinated:
        return 'Sin vacunas';
      case RiskType.parasites:
        return 'Con parásitos';
      
      // Abandono
      case RiskType.streetAbandoned:
        return 'Abandonado en la calle';
      case RiskType.precariousConditions:
        return 'Condiciones precarias';
      case RiskType.hitByVehicle:
        return 'Atropellado';
      case RiskType.extremeWeather:
        return 'Expuesto a clima extremo';
      case RiskType.lostDisoriented:
        return 'Solo y desorientado';
      
      // Peligro
      case RiskType.dangerousZone:
        return 'En zona peligrosa';
      case RiskType.animalAbuse:
        return 'Maltrato animal';
      case RiskType.streetFights:
        return 'Peleas callejeras';
      case RiskType.disasterZone:
        return 'Zona de desastre';
      
      // Vulnerabilidad
      case RiskType.puppyWithoutMother:
        return 'Cachorro sin madre';
      case RiskType.elderlyFragile:
        return 'Anciano y frágil';
      case RiskType.pregnant:
        return 'Hembra preñada';
      case RiskType.disabled:
        return 'Con discapacidad';
      case RiskType.traumatized:
        return 'Traumatizado';
    }
  }

  /// Obtener categoría
  String get category {
    switch (this) {
      case RiskType.injured:
      case RiskType.sick:
      case RiskType.malnourished:
      case RiskType.dehydrated:
      case RiskType.unvaccinated:
      case RiskType.parasites:
        return 'Salud';
      
      case RiskType.streetAbandoned:
      case RiskType.precariousConditions:
      case RiskType.hitByVehicle:
      case RiskType.extremeWeather:
      case RiskType.lostDisoriented:
        return 'Abandono';
      
      case RiskType.dangerousZone:
      case RiskType.animalAbuse:
      case RiskType.streetFights:
      case RiskType.disasterZone:
        return 'Peligro';
      
      case RiskType.puppyWithoutMother:
      case RiskType.elderlyFragile:
      case RiskType.pregnant:
      case RiskType.disabled:
      case RiskType.traumatized:
        return 'Vulnerabilidad';
    }
  }

  /// Obtener icono (ya no se usa, mantenido por compatibilidad)
  String get icon {
    return ''; // Los iconos ahora se manejan en la UI con Material Icons
  }

  /// Convertir a string para backend
  String toBackendString() {
    return toString().split('.').last;
  }

  /// Crear desde string del backend
  static RiskType? fromBackendString(String value) {
    try {
      return RiskType.values.firstWhere(
        (type) => type.toBackendString() == value,
      );
    } catch (e) {
      return null;
    }
  }
}

/// Helper para agrupar tipos de riesgo por categoría
class RiskTypeGroups {
  static List<RiskType> get health => [
    RiskType.injured,
    RiskType.sick,
    RiskType.malnourished,
    RiskType.dehydrated,
    RiskType.unvaccinated,
    RiskType.parasites,
  ];

  static List<RiskType> get abandonment => [
    RiskType.streetAbandoned,
    RiskType.precariousConditions,
    RiskType.hitByVehicle,
    RiskType.extremeWeather,
    RiskType.lostDisoriented,
  ];

  static List<RiskType> get danger => [
    RiskType.dangerousZone,
    RiskType.animalAbuse,
    RiskType.streetFights,
    RiskType.disasterZone,
  ];

  static List<RiskType> get vulnerability => [
    RiskType.puppyWithoutMother,
    RiskType.elderlyFragile,
    RiskType.pregnant,
    RiskType.disabled,
    RiskType.traumatized,
  ];

  static Map<String, List<RiskType>> get all => {
    'Salud': health,
    'Abandono': abandonment,
    'Peligro': danger,
    'Vulnerabilidad': vulnerability,
  };
}
