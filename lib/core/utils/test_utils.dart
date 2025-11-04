import 'dart:io';
import 'dart:math';
import '../../domain/entities/pet.dart';
import '../../domain/entities/pet_category.dart';

/// 🧪 Utilidades para testing y datos de prueba
class TestUtils {
  static final Random _random = Random();

  /// 🐕 Generar mascota de prueba
  static Pet generateMockPet({
    String? id,
    String? name,
    bool? isRisk,
    PetCategory? category,
  }) {
    final petId = id ?? 'test_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
    final petName = name ?? _generateRandomPetName();
    final petCategory = category ?? PetCategory.selectableCategories[_random.nextInt(PetCategory.selectableCategories.length)];
    
    return Pet(
      id: petId,
      name: petName,
      description: _generateRandomDescription(),
      imageUrl: _generateRandomImageUrl(),
      isRisk: isRisk ?? _random.nextBool(),
      createdAt: DateTime.now().subtract(Duration(days: _random.nextInt(30))),
      userId: 'test_user_${_random.nextInt(100)}',
      age: _generateRandomAge(),
      breed: _generateRandomBreed(petCategory),
      gender: _random.nextBool() ? 'Macho' : 'Hembra',
      size: ['Pequeño', 'Mediano', 'Grande'][_random.nextInt(3)],
      isVaccinated: _random.nextBool(),
      isSterilized: _random.nextBool(),
      contactName: _generateRandomContactName(),
      contactPhone: _generateRandomPhone(),
      contactEmail: _generateRandomEmail(),
      address: _generateRandomAddress(),
      category: petCategory,
    );
  }

  /// 📋 Generar lista de mascotas de prueba
  static List<Pet> generateMockPetList({
    int count = 10,
    bool? isRisk,
    PetCategory? category,
  }) {
    return List.generate(count, (index) => generateMockPet(
      isRisk: isRisk,
      category: category,
    ));
  }

  /// 👤 Generar datos de usuario de prueba
  static Map<String, dynamic> generateMockUserData({
    String? name,
    String? email,
  }) {
    return {
      'id': _random.nextInt(1000) + 1,
      'name': name ?? _generateRandomUserName(),
      'email': email ?? _generateRandomEmail(),
      'phone': _generateRandomPhone(),
      'imageUrl': _generateRandomAvatarUrl(),
      'createdAt': DateTime.now().subtract(Duration(days: _random.nextInt(365))).toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// 📸 Crear archivo de imagen de prueba
  static Future<File> createMockImageFile({String? fileName}) async {
    final tempDir = Directory.systemTemp;
    final file = File('${tempDir.path}/${fileName ?? 'test_image_${DateTime.now().millisecondsSinceEpoch}.jpg'}');
    
    // Crear un archivo de imagen simple (1x1 pixel JPEG)
    final imageBytes = [
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43,
      0x00, 0x08, 0x06, 0x06, 0x07, 0x06, 0x05, 0x08, 0x07, 0x07, 0x07, 0x09,
      0x09, 0x08, 0x0A, 0x0C, 0x14, 0x0D, 0x0C, 0x0B, 0x0B, 0x0C, 0x19, 0x12,
      0x13, 0x0F, 0x14, 0x1D, 0x1A, 0x1F, 0x1E, 0x1D, 0x1A, 0x1C, 0x1C, 0x20,
      0x24, 0x2E, 0x27, 0x20, 0x22, 0x2C, 0x23, 0x1C, 0x1C, 0x28, 0x37, 0x29,
      0x2C, 0x30, 0x31, 0x34, 0x34, 0x34, 0x1F, 0x27, 0x39, 0x3D, 0x38, 0x32,
      0x3C, 0x2E, 0x33, 0x34, 0x32, 0xFF, 0xC0, 0x00, 0x11, 0x08, 0x00, 0x01,
      0x00, 0x01, 0x01, 0x01, 0x11, 0x00, 0x02, 0x11, 0x01, 0x03, 0x11, 0x01,
      0xFF, 0xC4, 0x00, 0x14, 0x00, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08, 0xFF, 0xC4,
      0x00, 0x14, 0x10, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0xDA, 0x00, 0x0C,
      0x03, 0x01, 0x00, 0x02, 0x11, 0x03, 0x11, 0x00, 0x3F, 0x00, 0x8A, 0x00,
      0xFF, 0xD9
    ];
    
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// 🧪 Simular respuesta HTTP exitosa
  static Map<String, dynamic> mockSuccessResponse({
    required Map<String, dynamic> data,
    String message = 'Success',
  }) {
    return {
      'success': true,
      'message': message,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// ❌ Simular respuesta HTTP de error
  static Map<String, dynamic> mockErrorResponse({
    required String message,
    int statusCode = 400,
    String? error,
  }) {
    return {
      'success': false,
      'message': message,
      'error': error ?? 'Bad Request',
      'statusCode': statusCode,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// ⏱️ Simular delay de red
  static Future<void> simulateNetworkDelay({
    Duration min = const Duration(milliseconds: 100),
    Duration max = const Duration(milliseconds: 2000),
  }) async {
    final delay = Duration(
      milliseconds: min.inMilliseconds + 
        _random.nextInt(max.inMilliseconds - min.inMilliseconds),
    );
    await Future.delayed(delay);
  }

  /// 🎲 Simular fallo de red aleatorio
  static bool shouldSimulateNetworkFailure({double failureRate = 0.1}) {
    return _random.nextDouble() < failureRate;
  }

  // Métodos privados para generar datos aleatorios

  static String _generateRandomPetName() {
    final names = [
      'Max', 'Bella', 'Charlie', 'Luna', 'Cooper', 'Lucy', 'Rocky', 'Daisy',
      'Buddy', 'Lola', 'Milo', 'Sadie', 'Bear', 'Molly', 'Tucker', 'Sophie',
      'Jack', 'Chloe', 'Duke', 'Zoe', 'Oliver', 'Lily', 'Zeus', 'Penny',
      'Toby', 'Maggie', 'Leo', 'Ruby', 'Buster', 'Stella'
    ];
    return names[_random.nextInt(names.length)];
  }

  static String _generateRandomDescription() {
    final descriptions = [
      'Mascota muy cariñosa y juguetona, perfecta para familias con niños.',
      'Animal tranquilo y obediente, ideal para personas mayores.',
      'Muy activo y energético, necesita mucho ejercicio diario.',
      'Mascota rescatada que busca un hogar lleno de amor.',
      'Excelente compañero, muy leal y protector.',
      'Animal joven y curioso, le encanta explorar y jugar.',
      'Mascota adulta muy bien educada y socializada.',
      'Necesita cuidados especiales pero es muy amoroso.',
    ];
    return descriptions[_random.nextInt(descriptions.length)];
  }

  static String _generateRandomImageUrl() {
    final imageIds = List.generate(20, (index) => 100 + index);
    final randomId = imageIds[_random.nextInt(imageIds.length)];
    return 'https://picsum.photos/400/300?random=$randomId';
  }

  static String _generateRandomAge() {
    final ages = [
      '2 meses', '6 meses', '1 año', '2 años', '3 años', '5 años', '8 años'
    ];
    return ages[_random.nextInt(ages.length)];
  }

  static String _generateRandomBreed(PetCategory category) {
    final breeds = {
      PetCategory.dog: ['Labrador', 'Golden Retriever', 'Bulldog', 'Beagle', 'Poodle', 'Mestizo'],
      PetCategory.cat: ['Persa', 'Siamés', 'Maine Coon', 'Británico', 'Mestizo'],
      PetCategory.bird: ['Canario', 'Periquito', 'Cacatúa', 'Loro'],
      PetCategory.rabbit: ['Holandés', 'Angora', 'Enano'],
      PetCategory.hamster: ['Sirio', 'Ruso', 'Chino'],
    };
    
    final categoryBreeds = breeds[category] ?? ['Mestizo'];
    return categoryBreeds[_random.nextInt(categoryBreeds.length)];
  }

  static String _generateRandomContactName() {
    final names = [
      'Ana García', 'Carlos López', 'María Rodríguez', 'José Martínez',
      'Laura Sánchez', 'Miguel Torres', 'Carmen Flores', 'Antonio Ruiz'
    ];
    return names[_random.nextInt(names.length)];
  }

  static String _generateRandomPhone() {
    return '${_random.nextInt(900) + 100}-${_random.nextInt(900) + 100}-${_random.nextInt(9000) + 1000}';
  }

  static String _generateRandomEmail() {
    final domains = ['gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com'];
    final names = ['user', 'contact', 'info', 'admin', 'test'];
    final name = names[_random.nextInt(names.length)];
    final domain = domains[_random.nextInt(domains.length)];
    final number = _random.nextInt(999) + 1;
    return '$name$number@$domain';
  }

  static String _generateRandomAddress() {
    final streets = ['Calle Principal', 'Avenida Central', 'Calle del Sol', 'Avenida Norte'];
    final numbers = _random.nextInt(999) + 1;
    final street = streets[_random.nextInt(streets.length)];
    return '$street $numbers, Ciudad, Estado';
  }

  static String _generateRandomUserName() {
    final firstNames = ['Ana', 'Carlos', 'María', 'José', 'Laura', 'Miguel'];
    final lastNames = ['García', 'López', 'Rodríguez', 'Martínez', 'Sánchez'];
    final firstName = firstNames[_random.nextInt(firstNames.length)];
    final lastName = lastNames[_random.nextInt(lastNames.length)];
    return '$firstName $lastName';
  }

  static String _generateRandomAvatarUrl() {
    final avatarId = _random.nextInt(100) + 1;
    return 'https://i.pravatar.cc/150?img=$avatarId';
  }
}