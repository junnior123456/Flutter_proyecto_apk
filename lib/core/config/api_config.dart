import 'package:flutter/foundation.dart';
import 'dart:io';

/// Configuración de la API para conectar con el backend NestJS
class ApiConfig {
  // 🌐 URL base del backend NestJS
  static String get baseUrl {
    if (kIsWeb) {
      // En web, conectar directamente a localhost
      return 'http://localhost:3000/api';
    } else if (Platform.isAndroid) {
      // En Android, usar la IP real del host para Genymotion
      return 'http://192.168.18.97:3000/api'; // IP WiFi del host
    } else if (Platform.isIOS) {
      // En iOS Simulator, localhost funciona
      return 'http://localhost:3000/api';
    } else {
      // Fallback para otras plataformas
      return 'http://localhost:3000/api';
    }
  }

  // 🔄 URLs alternativas para probar en caso de fallo
  static List<String> get alternativeUrls => [
    'http://192.168.56.1:3000/api',  // Genymotion host bridge
    'http://192.168.56.2:3000/api',  // Genymotion alternativa
    'http://10.0.2.2:3000/api',      // Android Studio Emulator
    'http://10.0.3.2:3000/api',      // Genymotion NAT
    'http://localhost:3000/api',     // Localhost directo
    'http://127.0.0.1:3000/api',     // IP local
  ];
  
  // 📱 Endpoints principales
  static const String users = '/users';
  static const String roles = '/roles';
  static const String auth = '/auth';
  static const String pets = '/pets';
  static const String rooms = '/rooms';
  static const String bookings = '/bookings';
  
  // 🔐 Headers por defecto
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
  
  // 📸 Headers para subida de archivos
  static const Map<String, String> multipartHeaders = {
    'Content-Type': 'multipart/form-data',
    'Accept': 'application/json',
  };
  
  // ⏱️ Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // 🔗 URLs completas
  static String get usersUrl => baseUrl + users;
  static String get rolesUrl => baseUrl + roles;
  static String get authUrl => baseUrl + auth;
  static String get petsUrl => baseUrl + pets;
  static String get roomsUrl => baseUrl + rooms;
  static String get bookingsUrl => baseUrl + bookings;
  
  // 🔧 Métodos de utilidad
  static String userUploadUrl(int userId) => '$usersUrl/upload/$userId';
  static String userByIdUrl(int userId) => '$usersUrl/$userId';
}