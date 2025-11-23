/// 🔍 Utilidades de validación para la aplicación
class ValidationUtils {
  
  /// 📧 Validar formato de email
  static bool isValidEmail(String email) {
    if (email.trim().isEmpty) return false;
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      caseSensitive: false,
    );
    
    return emailRegex.hasMatch(email.trim());
  }

  /// 📱 Validar formato de teléfono (flexible para Perú)
  static bool isValidPhone(String phone) {
    if (phone.trim().isEmpty) return false;
    
    // Remover espacios y caracteres especiales, solo mantener dígitos
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Debe tener entre 7 y 11 dígitos (más flexible)
    return cleanPhone.length >= 7 && cleanPhone.length <= 11 && RegExp(r'^[0-9]+$').hasMatch(cleanPhone);
  }

  /// 👤 Validar nombre (no vacío, longitud mínima)
  static bool isValidName(String name, {int minLength = 2}) {
    final trimmedName = name.trim();
    return trimmedName.isNotEmpty && trimmedName.length >= minLength;
  }

  /// 📝 Validar descripción (no vacía, longitud mínima)
  static bool isValidDescription(String description, {int minLength = 5}) {
    final trimmedDescription = description.trim();
    return trimmedDescription.isNotEmpty && trimmedDescription.length >= minLength;
  }

  /// 🔢 Validar edad de mascota
  static bool isValidPetAge(String age) {
    if (age.trim().isEmpty) return true; // Opcional
    
    // Puede ser número + unidad (ej: "2 años", "6 meses")
    final ageRegex = RegExp(r'^\d+\s*(año|años|mes|meses|semana|semanas|día|días)?s?$', caseSensitive: false);
    return ageRegex.hasMatch(age.trim());
  }

  /// 🐕 Validar raza de mascota
  static bool isValidBreed(String breed) {
    if (breed.trim().isEmpty) return true; // Opcional
    
    final trimmedBreed = breed.trim();
    // Solo letras, espacios y guiones
    final breedRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-]+$');
    return breedRegex.hasMatch(trimmedBreed) && trimmedBreed.length >= 2;
  }

  /// 📍 Validar dirección
  static bool isValidAddress(String address, {int minLength = 5}) {
    final trimmedAddress = address.trim();
    return trimmedAddress.isNotEmpty && trimmedAddress.length >= minLength;
  }

  /// 🔍 Validar ID de categoría
  static bool isValidCategoryId(int categoryId) {
    return categoryId > 0 && categoryId <= 10; // Asumiendo máximo 10 categorías
  }

  /// 📋 Validar datos completos de mascota
  static Map<String, String> validatePetData({
    required String name,
    required String description,
    required int categoryId,
    String? age,
    String? breed,
    String? contactName,
    String? contactPhone,
    String? contactEmail,
    String? address,
  }) {
    final errors = <String, String>{};

    // Validaciones obligatorias
    if (!isValidName(name)) {
      errors['name'] = 'El nombre debe tener al menos 2 caracteres';
    }

    if (!isValidDescription(description)) {
      errors['description'] = 'La descripción debe tener al menos 5 caracteres';
    }

    if (!isValidCategoryId(categoryId)) {
      errors['categoryId'] = 'Debe seleccionar una categoría válida';
    }

    // Validaciones opcionales
    if (age != null && age.isNotEmpty && !isValidPetAge(age)) {
      errors['age'] = 'Formato de edad inválido (ej: "2 años", "6 meses")';
    }

    if (breed != null && breed.isNotEmpty && !isValidBreed(breed)) {
      errors['breed'] = 'La raza solo puede contener letras y espacios';
    }

    if (contactName != null && contactName.isNotEmpty && !isValidName(contactName)) {
      errors['contactName'] = 'El nombre de contacto debe tener al menos 2 caracteres';
    }

    if (contactPhone != null && contactPhone.isNotEmpty && !isValidPhone(contactPhone)) {
      errors['contactPhone'] = 'El teléfono debe tener entre 7 y 11 dígitos';
    }

    if (contactEmail != null && contactEmail.isNotEmpty && !isValidEmail(contactEmail)) {
      errors['contactEmail'] = 'El formato del email es inválido';
    }

    if (address != null && address.isNotEmpty && !isValidAddress(address)) {
      errors['address'] = 'La dirección debe tener al menos 5 caracteres';
    }

    return errors;
  }

  /// 👤 Validar datos de perfil de usuario
  static Map<String, String> validateUserProfile({
    required String name,
    required String email,
    String? phone,
  }) {
    final errors = <String, String>{};

    if (!isValidName(name)) {
      errors['name'] = 'El nombre debe tener al menos 2 caracteres';
    }

    if (!isValidEmail(email)) {
      errors['email'] = 'El formato del email es inválido';
    }

    if (phone != null && phone.isNotEmpty && !isValidPhone(phone)) {
      errors['phone'] = 'El teléfono debe tener entre 7 y 11 dígitos';
    }

    return errors;
  }

  /// 🔐 Validar contraseña
  static Map<String, String> validatePassword(String password, {String? confirmPassword}) {
    final errors = <String, String>{};

    if (password.length < 6) {
      errors['password'] = 'La contraseña debe tener al menos 6 caracteres';
    }

    if (confirmPassword != null && password != confirmPassword) {
      errors['confirmPassword'] = 'Las contraseñas no coinciden';
    }

    // Verificar que tenga al menos una letra y un número
    if (!RegExp(r'^(?=.*[A-Za-z])(?=.*\d)').hasMatch(password)) {
      errors['password'] = 'La contraseña debe contener al menos una letra y un número';
    }

    return errors;
  }

  /// 🧹 Limpiar y formatear texto
  static String cleanText(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// 📱 Formatear teléfono (formato peruano)
  static String formatPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length == 9) {
      // Formato peruano: XXX XXX XXX
      return '${cleanPhone.substring(0, 3)} ${cleanPhone.substring(3, 6)} ${cleanPhone.substring(6)}';
    }
    
    return cleanPhone; // Retornar sin formato si no coincide
  }

  /// 📧 Normalizar email
  static String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }
}