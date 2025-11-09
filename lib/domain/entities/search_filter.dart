import 'package:equatable/equatable.dart';
import 'pet_category.dart';
import 'pet.dart';

class SearchFilter extends Equatable {
  final String? query;
  final PetCategory? category;
  final String? breed;
  final String? gender;
  final String? size;
  final String? age;
  final bool? isVaccinated;
  final bool? isSterilized;
  final PetStatus? status;
  final String? location;
  final double? latitude;
  final double? longitude;
  final double? radiusKm;
  final bool? isRisk;
  final String? temperament;
  final bool? hasSpecialNeeds;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final String? sortBy;
  final bool? sortDescending;
  final int? limit;
  final int? offset;

  const SearchFilter({
    this.query,
    this.category,
    this.breed,
    this.gender,
    this.size,
    this.age,
    this.isVaccinated,
    this.isSterilized,
    this.status,
    this.location,
    this.latitude,
    this.longitude,
    this.radiusKm,
    this.isRisk,
    this.temperament,
    this.hasSpecialNeeds,
    this.createdAfter,
    this.createdBefore,
    this.sortBy,
    this.sortDescending,
    this.limit,
    this.offset,
  });

  // Factory constructors para filtros comunes
  factory SearchFilter.empty() => const SearchFilter();

  factory SearchFilter.byCategory(PetCategory category) => SearchFilter(
        category: category,
        status: PetStatus.available,
      );

  factory SearchFilter.nearby({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
  }) =>
      SearchFilter(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        status: PetStatus.available,
      );

  factory SearchFilter.forAdoption() => const SearchFilter(
        isRisk: false,
        status: PetStatus.available,
      );

  factory SearchFilter.atRisk() => const SearchFilter(
        isRisk: true,
        status: PetStatus.available,
      );

  factory SearchFilter.recent() => SearchFilter(
        createdAfter: DateTime.now().subtract(const Duration(days: 7)),
        status: PetStatus.available,
        sortBy: 'createdAt',
        sortDescending: true,
      );

  // Getters útiles
  bool get isEmpty =>
      query == null &&
      category == null &&
      breed == null &&
      gender == null &&
      size == null &&
      age == null &&
      isVaccinated == null &&
      isSterilized == null &&
      status == null &&
      location == null &&
      latitude == null &&
      longitude == null &&
      radiusKm == null &&
      isRisk == null &&
      temperament == null &&
      hasSpecialNeeds == null &&
      createdAfter == null &&
      createdBefore == null &&
      sortBy == null &&
      sortDescending == null;

  bool get hasLocationFilter => latitude != null && longitude != null;
  bool get hasDateFilter => createdAfter != null || createdBefore != null;
  bool get hasSorting => sortBy != null;
  bool get hasPagination => limit != null || offset != null;

  int get activeFiltersCount {
    int count = 0;
    if (query != null && query!.isNotEmpty) count++;
    if (category != null) count++;
    if (breed != null && breed!.isNotEmpty) count++;
    if (gender != null && gender!.isNotEmpty) count++;
    if (size != null && size!.isNotEmpty) count++;
    if (age != null && age!.isNotEmpty) count++;
    if (isVaccinated != null) count++;
    if (isSterilized != null) count++;
    if (status != null) count++;
    if (location != null && location!.isNotEmpty) count++;
    if (hasLocationFilter) count++;
    if (isRisk != null) count++;
    if (temperament != null && temperament!.isNotEmpty) count++;
    if (hasSpecialNeeds != null) count++;
    if (hasDateFilter) count++;
    return count;
  }

  String get description {
    if (isEmpty) return 'Sin filtros';
    
    List<String> parts = [];
    
    if (query != null && query!.isNotEmpty) {
      parts.add('Búsqueda: "$query"');
    }
    
    if (category != null) {
      parts.add('Categoría: ${category!.name}');
    }
    
    if (isRisk == true) {
      parts.add('En riesgo');
    } else if (isRisk == false) {
      parts.add('Para adopción');
    }
    
    if (hasLocationFilter) {
      parts.add('Cerca de ubicación (${radiusKm ?? 10}km)');
    }
    
    if (activeFiltersCount > parts.length) {
      parts.add('${activeFiltersCount - parts.length} filtros más');
    }
    
    return parts.join(', ');
  }

  SearchFilter copyWith({
    String? query,
    PetCategory? category,
    String? breed,
    String? gender,
    String? size,
    String? age,
    bool? isVaccinated,
    bool? isSterilized,
    PetStatus? status,
    String? location,
    double? latitude,
    double? longitude,
    double? radiusKm,
    bool? isRisk,
    String? temperament,
    bool? hasSpecialNeeds,
    DateTime? createdAfter,
    DateTime? createdBefore,
    String? sortBy,
    bool? sortDescending,
    int? limit,
    int? offset,
  }) {
    return SearchFilter(
      query: query ?? this.query,
      category: category ?? this.category,
      breed: breed ?? this.breed,
      gender: gender ?? this.gender,
      size: size ?? this.size,
      age: age ?? this.age,
      isVaccinated: isVaccinated ?? this.isVaccinated,
      isSterilized: isSterilized ?? this.isSterilized,
      status: status ?? this.status,
      location: location ?? this.location,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radiusKm: radiusKm ?? this.radiusKm,
      isRisk: isRisk ?? this.isRisk,
      temperament: temperament ?? this.temperament,
      hasSpecialNeeds: hasSpecialNeeds ?? this.hasSpecialNeeds,
      createdAfter: createdAfter ?? this.createdAfter,
      createdBefore: createdBefore ?? this.createdBefore,
      sortBy: sortBy ?? this.sortBy,
      sortDescending: sortDescending ?? this.sortDescending,
      limit: limit ?? this.limit,
      offset: offset ?? this.offset,
    );
  }

  SearchFilter clearFilter() => const SearchFilter();

  SearchFilter withPagination({int? limit, int? offset}) => copyWith(
        limit: limit,
        offset: offset,
      );

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    
    if (query != null) map['query'] = query;
    if (category != null) map['category'] = category!.name;
    if (breed != null) map['breed'] = breed;
    if (gender != null) map['gender'] = gender;
    if (size != null) map['size'] = size;
    if (age != null) map['age'] = age;
    if (isVaccinated != null) map['isVaccinated'] = isVaccinated;
    if (isSterilized != null) map['isSterilized'] = isSterilized;
    if (status != null) map['status'] = status!.name;
    if (location != null) map['location'] = location;
    if (latitude != null) map['latitude'] = latitude;
    if (longitude != null) map['longitude'] = longitude;
    if (radiusKm != null) map['radiusKm'] = radiusKm;
    if (isRisk != null) map['isRisk'] = isRisk;
    if (temperament != null) map['temperament'] = temperament;
    if (hasSpecialNeeds != null) map['hasSpecialNeeds'] = hasSpecialNeeds;
    if (createdAfter != null) map['createdAfter'] = createdAfter!.toIso8601String();
    if (createdBefore != null) map['createdBefore'] = createdBefore!.toIso8601String();
    if (sortBy != null) map['sortBy'] = sortBy;
    if (sortDescending != null) map['sortDescending'] = sortDescending;
    if (limit != null) map['limit'] = limit;
    if (offset != null) map['offset'] = offset;
    
    return map;
  }

  @override
  List<Object?> get props => [
        query,
        category,
        breed,
        gender,
        size,
        age,
        isVaccinated,
        isSterilized,
        status,
        location,
        latitude,
        longitude,
        radiusKm,
        isRisk,
        temperament,
        hasSpecialNeeds,
        createdAfter,
        createdBefore,
        sortBy,
        sortDescending,
        limit,
        offset,
      ];

  @override
  String toString() {
    return 'SearchFilter(${description})';
  }
}