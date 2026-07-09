import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/auth_service.dart';

/// Botón flotante que abre el panel de administración.
/// Sólo se muestra si el usuario tiene el rol ADMIN según el JWT/login.
class AdminFAB extends StatelessWidget {
  const AdminFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      // Antes se comprobaba comparando el email con uno escrito en el código.
      // Ahora se usa el rol real que devuelve el backend.
      future: AuthService().isAdmin(),
      builder: (context, snapshot) {
        if (snapshot.data != true) return const SizedBox.shrink();
        return FloatingActionButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.adminPanel),
          backgroundColor: Colors.red,
          heroTag: "admin_fab",
          child: const Icon(
            Icons.admin_panel_settings,
            color: Colors.white,
          ),
        );
      },
    );
  }
}
