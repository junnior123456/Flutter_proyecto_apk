import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Services
import 'core/services/auth_service.dart';
import 'core/services/theme_notifier.dart';

// Core imports
import 'core/constants/app_strings.dart';
import 'core/constants/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/floating_pet_helper.dart';

// Screen imports
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/api_test_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';

// Feature imports
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_page.dart';
import 'features/auth/presentation/screens/register_page.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/reset_password_screen.dart';
import 'features/auth/presentation/screens/terms_and_conditions_screen.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/first_aid/presentation/screens/first_aid_screen.dart';
import 'features/first_aid/presentation/screens/pet_chat_screen.dart';
import 'presentation/screens/mascotas_list_screen.dart';
import 'presentation/screens/reportar_mascota_screen.dart';

// Application imports
import 'application/bloc/mascota_bloc_providers.dart';
import 'core/services/push_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (solo si no está inicializado)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase ya está inicializado, continuar
    print('Firebase ya inicializado: $e');
  }

  // Initialize AuthService
  await AuthService().initialize();

  // Set preferred orientations
  // Se habilitan también las orientaciones horizontales para que la app
  // rote correctamente en tablets (antes estaba bloqueada solo en vertical).
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ThemeNotifier _themeNotifier = ThemeNotifier();

  // Clave global del navegador: la usa el perrito flotante para navegar.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _themeNotifier.loadTheme();
    _themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: mascotaBlocProviders,
      child: MaterialApp(
        // App Information
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,

        // Navigator key + observador de rutas (para el perrito flotante)
        navigatorKey: _navigatorKey,
        navigatorObservers: [AppRouteTracker()],

        // Theme Configuration
        theme: _themeNotifier.lightTheme ?? AppTheme.lightTheme,
        darkTheme: _themeNotifier.darkTheme ?? AppTheme.darkTheme,
        themeMode: _themeNotifier.themeMode,

        // Localization (for future expansion)
        locale: const Locale('es', 'PE'), // Spanish (Peru)
        // Navigation Configuration
        // Arranca en el guardián de sesión: si hay token guardado entra directo
        // al dashboard; si no, va a la pantalla de bienvenida.
        home: const _SessionGate(),
        onGenerateRoute: _onGenerateRoute,

        // Error handling for unknown routes
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const WelcomeScreen());
        },

        // Global builder: limita el escalado de texto y añade el perrito
        // flotante 🐶 por encima de TODAS las pantallas.
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                (MediaQuery.of(context).textScaler.scale(1.0) * 1.0).clamp(
                  0.8,
                  1.2,
                ),
              ),
            ),
            child: Stack(
              alignment: Alignment.topLeft,
              children: [
                child ?? const SizedBox.shrink(),
                FloatingPetHelper(
                  navigatorKey: _navigatorKey,
                  helpRoute: AppRoutes.assistant,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    // Extraer argumentos si existen
    final args = settings.arguments as Map<String, dynamic>?;

    switch (settings.name) {
      case AppRoutes.welcome:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const WelcomeScreen(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const LoginPage(),
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const RegisterPage(),
        );

      case AppRoutes.dashboard:
        final isAuthenticated = args?['isAuthenticated'] as bool? ?? false;
        final initialTab = args?['initialTab'] as int? ?? 0;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => DashboardScreen(
            isAuthenticated: isAuthenticated,
            initialTab: initialTab,
          ),
        );

      case AppRoutes.pets:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const MascotasListScreen(),
        );

      case AppRoutes.reportPet:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ReportarMascotaScreen(),
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const HomeScreen(),
        );

      case AppRoutes.apiTest:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ApiTestScreen(),
        );

      case AppRoutes.editProfile:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const EditProfileScreen(),
        );

      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const ForgotPasswordScreen(),
        );

      case AppRoutes.resetPassword:
        final token = settings.arguments as String?;
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => ResetPasswordScreen(initialToken: token),
        );

      case AppRoutes.terms:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const TermsAndConditionsScreen(),
        );

      case AppRoutes.firstAid:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const FirstAidScreen(),
        );

      case AppRoutes.assistant:
        return MaterialPageRoute(
          settings: settings,
          builder: (context) => const PetChatScreen(),
        );

      default:
        return null;
    }
  }
}

/// Guardián de sesión: decide la primera pantalla según haya token guardado.
/// El JWT dura 30 días, así que el usuario no debe volver a loguearse al
/// cerrar y reabrir la app.
class _SessionGate extends StatefulWidget {
  const _SessionGate();

  @override
  State<_SessionGate> createState() => _SessionGateState();
}

class _SessionGateState extends State<_SessionGate> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final logged = await AuthService().isAuthenticated();
    if (!mounted) return;
    if (logged) {
      // Sesión restaurada: refresca el token de push por si rotó o caducó.
      unawaited(PushService().syncToken());
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.dashboard,
        arguments: {'isAuthenticated': true},
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
