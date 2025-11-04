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

// Screen imports
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/api_test_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';

// Feature imports
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_page.dart';
import 'features/auth/presentation/screens/register_page.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'presentation/screens/mascotas_list_screen.dart';
import 'presentation/screens/reportar_mascota_screen.dart';

// Application imports
import 'application/bloc/mascota_bloc_providers.dart';

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
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
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

        // Theme Configuration
        theme: _themeNotifier.lightTheme ?? AppTheme.lightTheme,
        darkTheme: _themeNotifier.darkTheme ?? AppTheme.darkTheme,
        themeMode: _themeNotifier.themeMode,

        // Localization (for future expansion)
        locale: const Locale('es', 'PE'), // Spanish (Peru)
        // Navigation Configuration
        initialRoute: AppRoutes.welcome,
        onGenerateRoute: _onGenerateRoute,
        
        // Error handling for unknown routes
        onUnknownRoute: (settings) {
          return MaterialPageRoute(builder: (context) => const WelcomeScreen());
        },

        // Global error handling
        builder: (context, child) {
          return MediaQuery(
            // Prevent text scaling beyond reasonable limits
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                (MediaQuery.of(context).textScaler.scale(1.0) * 1.0).clamp(
                  0.8,
                  1.2,
                ),
              ),
            ),
            child: child ?? const SizedBox.shrink(),
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
        return MaterialPageRoute(builder: (context) => const WelcomeScreen());
      
      case AppRoutes.login:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      
      case AppRoutes.register:
        return MaterialPageRoute(builder: (context) => const RegisterPage());
      
      case AppRoutes.dashboard:
        final isAuthenticated = args?['isAuthenticated'] as bool? ?? false;
        final initialTab = args?['initialTab'] as int? ?? 0;
        return MaterialPageRoute(
          builder: (context) => DashboardScreen(
            isAuthenticated: isAuthenticated,
            initialTab: initialTab,
          ),
        );
      
      case AppRoutes.pets:
        return MaterialPageRoute(builder: (context) => const MascotasListScreen());
      
      case AppRoutes.reportPet:
        return MaterialPageRoute(builder: (context) => const ReportarMascotaScreen());
      
      case AppRoutes.home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      
      case AppRoutes.apiTest:
        return MaterialPageRoute(builder: (context) => const ApiTestScreen());
      
      case AppRoutes.editProfile:
        return MaterialPageRoute(builder: (context) => const EditProfileScreen());
      
      default:
        return null;
    }
  }
}
