import 'package:flutter/material.dart';
import '../../core/constants/app_routes.dart';
import '../../core/services/user_profile_notifier.dart';

class AdminFAB extends StatelessWidget {
  const AdminFAB({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isUserAdmin(),
      builder: (context, snapshot) {
        if (snapshot.data == true) {
          return FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.adminPanel);
            },
            backgroundColor: Colors.red,
            child: const Icon(
              Icons.admin_panel_settings,
              color: Colors.white,
            ),
            heroTag: "admin_fab",
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Future<bool> _isUserAdmin() async {
    try {
      final profileNotifier = UserProfileNotifier();
      await profileNotifier.loadProfile();
      final profile = profileNotifier.currentProfile;
      
      // Verificar si el usuario tiene rol de ADMIN
      if (profile != null && profile.email == 'junniorchinchay@upeu.edu.pe') {
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }
}