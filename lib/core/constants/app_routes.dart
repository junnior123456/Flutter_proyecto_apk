class AppRoutes {
  // Auth routes
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String terms = '/terms';

  // Main app routes
  static const String dashboard = '/dashboard';
  static const String pets = '/mascotas';
  static const String reportPet = '/reportar';
  static const String petDetail = '/mascota-detalle';

  // Profile routes
  static const String profile = '/perfil';
  static const String settings = '/configuracion';
  static const String notifications = '/notificaciones';
  static const String help = '/ayuda';
  static const String about = '/acerca';

  // Other routes
  static const String emergency = '/emergencia';
  static const String favorites = '/favoritos';
  static const String myPets = '/mis-mascotas';

  // Main app routes
  static const String home = '/home'; // 🟡 Agregado aquí
  static const String apiTest = '/api-test'; // 🧪 Pantalla de prueba de API
  static const String editProfile = '/edit-profile'; // ✏️ Editar perfil
  static const String petsAdoption = '/pets-adoption'; // 🐾 Mascotas en adopción
  static const String adminPanel = '/admin-panel'; // 👑 Panel de administración
  static const String adminAccess = '/admin-access'; // 🔑 Acceso administrativo
  static const String firstAid = '/primeros-auxilios'; // 🐶 Primeros auxilios y cuidados
  static const String assistant = '/asistente'; // 🐶 Asistente/bot para perritos
}
