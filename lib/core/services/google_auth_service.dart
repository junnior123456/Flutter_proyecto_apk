import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  /// 🔐 Iniciar sesión con Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      print('🔐 Iniciando autenticación con Google...');

      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('❌ Usuario canceló la autenticación');
        return null;
      }

      print('✅ Usuario seleccionado: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      
      print('✅ Autenticación exitosa: ${userCredential.user?.email}');
      return userCredential;
    } catch (e) {
      print('❌ Error en autenticación con Google: $e');
      return null;
    }
  }

  /// 📧 Verificar si el email está verificado
  Future<bool> isEmailVerified() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    await user.reload();
    return user.emailVerified;
  }

  /// 📨 Enviar email de verificación
  Future<bool> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.sendEmailVerification();
      print('✅ Email de verificación enviado a: ${user.email}');
      return true;
    } catch (e) {
      print('❌ Error enviando email de verificación: $e');
      return false;
    }
  }

  /// 🔄 Reenviar email de verificación
  Future<bool> resendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Verificar si ya está verificado
      await user.reload();
      if (user.emailVerified) {
        print('✅ El email ya está verificado');
        return true;
      }

      await user.sendEmailVerification();
      print('✅ Email de verificación reenviado');
      return true;
    } catch (e) {
      print('❌ Error reenviando email de verificación: $e');
      return false;
    }
  }

  /// 🔑 Enviar email de restablecimiento de contraseña
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      print('✅ Email de restablecimiento enviado a: $email');
      return true;
    } catch (e) {
      print('❌ Error enviando email de restablecimiento: $e');
      return false;
    }
  }

  /// 🔐 Reautenticar usuario antes de cambios sensibles
  Future<bool> reauthenticateUser(String password) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.email == null) return false;

      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      print('✅ Usuario reautenticado correctamente');
      return true;
    } catch (e) {
      print('❌ Error en reautenticación: $e');
      return false;
    }
  }

  /// 🔄 Cambiar contraseña
  Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      // Primero reautenticar
      final isReauthenticated = await reauthenticateUser(currentPassword);
      if (!isReauthenticated) return false;

      // Cambiar contraseña
      final user = _auth.currentUser;
      if (user == null) return false;

      await user.updatePassword(newPassword);
      print('✅ Contraseña actualizada correctamente');
      return true;
    } catch (e) {
      print('❌ Error cambiando contraseña: $e');
      return false;
    }
  }

  /// 🚪 Cerrar sesión
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      print('✅ Sesión cerrada correctamente');
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
    }
  }

  /// 👤 Obtener usuario actual
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// 📧 Obtener email del usuario actual
  String? getCurrentUserEmail() {
    return _auth.currentUser?.email;
  }

  /// 🔍 Verificar si hay usuario autenticado
  bool isUserSignedIn() {
    return _auth.currentUser != null;
  }

  /// 📱 Stream de cambios de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}