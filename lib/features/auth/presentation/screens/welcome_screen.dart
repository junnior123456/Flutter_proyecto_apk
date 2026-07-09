import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/app_styles.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppStyles.authGradient,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Responsive: se adapta a celular y tablet
              final bool isTablet = constraints.maxWidth >= 600;
              final double logoIcon = isTablet ? 100 : 80;
              final double logoPadding = isTablet ? 26 : 20;
              const double maxContentWidth = 480;

              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 24,
                    ),
                    child: ConstrainedBox(
                      // En pantallas altas ocupa todo; en cortas hace scroll
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 48,
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo y título
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(logoPadding),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.pets,
                                    size: logoIcon,
                                    color: const Color(0xFFFF9800),
                                  ),
                                ),
                                const SizedBox(height: 30),
                                const Text(
                                  'PawFinder',
                                  style: AppStyles.headingLarge,
                                ),
                                const SizedBox(height: 10),
                                const Text(
                                  'Conectando corazones con patitas',
                                  style: AppStyles.captionLight,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),

                            const SizedBox(height: 32),

                            // Descripción y características
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                children: [
                                  const Text(
                                    'Ayuda a reunir mascotas con sus familias en Tarapoto',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 32),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildFeature(
                                        Icons.search,
                                        'Buscar',
                                        () => _handleSearch(context),
                                      ),
                                      _buildFeature(
                                        Icons.add_circle,
                                        'Reportar',
                                        () => _handleReport(context),
                                      ),
                                      _buildFeature(
                                        Icons.favorite,
                                        'Adoptar',
                                        () => _handleAdopt(context),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Botones
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                children: [
                                  // Botón Iniciar Sesión
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, AppRoutes.login);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: Text(
                                        'Iniciar Sesión',
                                        style: AppStyles.buttonLarge
                                            .copyWith(color: AppColors.primary),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  // Botón Registrarse
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        Navigator.pushNamed(context, AppRoutes.register);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                            color: Colors.white, width: 2),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      child: const Text(
                                        'Registrarse',
                                        style: AppStyles.buttonLarge,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Enlace para continuar sin cuenta
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(
                                        context,
                                        AppRoutes.dashboard,
                                        arguments: {'isAuthenticated': false},
                                      );
                                    },
                                    child: const Text(
                                      'Continuar sin cuenta',
                                      style: AppStyles.linkWhite,
                                    ),
                                  ),

                                  // Botón de acceso al panel de admin
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pushNamed(context, AppRoutes.adminAccess);
                                    },
                                    child: const Text(
                                      '👑 Panel de Administración',
                                      style: AppStyles.linkWhite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // 🔍 Manejar búsqueda (acceso público)
  void _handleSearch(BuildContext context) {
    print('🔍 DEBUG: _handleSearch llamado');
    Navigator.pushNamed(
      context,
      AppRoutes.dashboard,
      arguments: {
        'isAuthenticated': false,
        'initialTab': 0, // Tab de búsqueda
      },
    );
  }

  // 📝 Manejar reporte (acceso público para ver, autenticación para reportar)
  void _handleReport(BuildContext context) {
    print('🔍 DEBUG: _handleReport llamado');
    print('🔍 DEBUG: Navegando a dashboard con tab 2 (riesgo)');

    Navigator.pushNamed(
      context,
      AppRoutes.dashboard,
      arguments: {
        'isAuthenticated': false,
        'initialTab': 2, // Tab de riesgo (índice 2)
      },
    );

    print('🔍 DEBUG: Navegación iniciada');
  }

  // ❤️ Manejar adopción (acceso público para ver, autenticación para adoptar)
  void _handleAdopt(BuildContext context) {
    print('🔍 DEBUG: _handleAdopt llamado');
    Navigator.pushNamed(
      context,
      AppRoutes.dashboard,
      arguments: {
        'isAuthenticated': false,
        'initialTab': 1, // Tab de adopción
      },
    );
  }
}
