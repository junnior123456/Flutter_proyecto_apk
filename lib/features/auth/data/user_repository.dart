import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  static const _usersKey = 'app_users_v1';

  // Guarda un usuario simple: {"email":..., "password":..., "name":...}
  Future<void> saveUser(Map<String, String> user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await _getAllUsers(prefs);
      
      // Normalize email before saving
      if (user['email'] != null) {
        user['email'] = user['email']!.trim().toLowerCase();
      }
      
      users.add(user);
      final encoded = jsonEncode(users);
      await prefs.setString(_usersKey, encoded);
      
      print('User saved successfully: ${user['email']}');
    } catch (e) {
      print('Error saving user: $e');
      throw Exception('Failed to save user');
    }
  }

  Future<List<Map<String, String>>> _getAllUsers(SharedPreferences prefs) async {
    final raw = prefs.getString(_usersKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => Map<String, String>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> emailExists(String email) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await _getAllUsers(prefs);
      
      // Normalize email for comparison
      email = email.trim().toLowerCase();
      
      return users.any((u) => (u['email']?.trim().toLowerCase() ?? '') == email);
    } catch (e) {
      print('Error checking email existence: $e');
      return false;
    }
  }

  Future<bool> validateCredentials(String email, String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final users = await _getAllUsers(prefs);
      
      // Normalize email for comparison (lowercase and trim)
      email = email.trim().toLowerCase();
      
      return users.any((u) => 
        (u['email']?.trim().toLowerCase() ?? '') == email && 
        (u['password'] ?? '') == password
      );
    } catch (e) {
      print('Error validating credentials: $e');
      return false;
    }
  }
}
