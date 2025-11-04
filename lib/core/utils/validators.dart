class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El correo electrónico es requerido';
    }
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Por favor ingresa un correo válido';
    }
    
    return null;
  }
  
  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }
  
  // Confirm password validation
  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Por favor confirma tu contraseña';
    }
    
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    
    return null;
  }
  
  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    return null;
  }
  
  // Phone validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    
    final phoneRegex = RegExp(r'^[+]?[0-9]{9,15}$');
    if (!phoneRegex.hasMatch(value.replaceAll(' ', '').replaceAll('-', ''))) {
      return 'Por favor ingresa un teléfono válido';
    }
    
    return null;
  }
  
  // Required field validation
  static String? validateRequired(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }
  
  // Pet name validation
  static String? validatePetName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de la mascota es requerido';
    }
    
    if (value.isEmpty) {
      return 'El nombre debe tener al menos 1 carácter';
    }
    
    return null;
  }
  
  // URL validation (optional)
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }
    
    final urlRegex = RegExp(
      r'^https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&=]*)$'
    );
    
    if (!urlRegex.hasMatch(value)) {
      return 'Por favor ingresa una URL válida';
    }
    
    return null;
  }
  
  // Age validation
  static String? validateAge(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Age is optional
    }
    
    if (value.isEmpty) {
      return 'Por favor ingresa una edad válida';
    }
    
    return null;
  }
}