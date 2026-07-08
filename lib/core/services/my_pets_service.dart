import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/pet.dart';
import '../../data/models/pet_model.dart';
import 'token_manager.dart';

class MyPetsService {
  static const String baseUrl = 'http://167.99.4.161/api';
  final TokenManager _tokenManager = TokenManager();

  /// 📋 Obtener las mascotas del usuario autenticado
  Future<List<Pet>> getMyPets() async {
    try {
      // Verificar si hay token guardado
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('auth_token');
      print('🔍 Token en SharedPreferences: ${savedToken != null ? "Existe (${savedToken.length} chars)" : "NO EXISTE"}');
      
      final token = await _tokenManager.getToken();
      print('🔑 Token obtenido por TokenManager: ${token != null ? "Sí (${token.substring(0, min(20, token.length))}...)" : "No"}');

      if (token == null || token.isEmpty) {
        print('❌ NO HAY TOKEN - Usuario debe iniciar sesión');
        throw Exception('No hay token de autenticación. Por favor inicia sesión nuevamente.');
      }

      // Limpiar el token si tiene "Bearer " al inicio
      final cleanToken = token.replaceFirst('Bearer ', '').trim();
      
      final response = await http.get(
        Uri.parse('$baseUrl/pets/my-pets?limit=100'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('📋 GET /pets/my-pets - Status: ${response.statusCode}');
      print('🔑 Token usado: Bearer ${cleanToken.substring(0, 20)}...');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('📦 Respuesta completa: $data');
        
        if (data['ok'] == true && data['data'] != null) {
          // Verificar si data['data'] tiene la estructura correcta
          if (data['data']['data'] != null && data['data']['data'] is List) {
            final petsData = data['data']['data'] as List;
            print('✅ Mascotas encontradas: ${petsData.length}');
            return petsData.map((json) => PetModel.fromJson(json as Map<String, dynamic>)).toList();
          } else {
            print('⚠️ No hay mascotas o estructura incorrecta');
            return []; // Retornar lista vacía si no hay mascotas
          }
        }
      }

      throw Exception('Error al obtener mis mascotas: ${response.statusCode}');
    } catch (e) {
      print('❌ Error en getMyPets: $e');
      rethrow;
    }
  }

  /// ✏️ Actualizar una mascota
  Future<PetModel> updatePet(int petId, Map<String, dynamic> updateData) async {
    print('🔄 [UPDATE] Iniciando actualización de mascota $petId');
    print('📋 [UPDATE] Datos: $updateData');
    try {
      final token = await _tokenManager.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación. Por favor inicia sesión nuevamente.');
      }

      // Limpiar el token si tiene "Bearer " al inicio
      final cleanToken = token.replaceFirst('Bearer ', '').trim();
      
      final response = await http.patch(
        Uri.parse('$baseUrl/pets/$petId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
        body: json.encode(updateData),
      );

      print('✏️ PATCH /pets/$petId - Status: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Actualización exitosa en el servidor');
        // Por ahora, simplemente devolver un PetModel básico para confirmar que funciona
        // Luego recargaremos la lista completa
        return PetModel(
          id: petId,
          name: updateData['name'] ?? 'Actualizado',
          imageUrl: '',
          isRisk: false,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          userId: 0,
          categoryId: 1,
        );
      }

      throw Exception('Error al actualizar mascota: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ Error en updatePet: $e');
      rethrow;
    }
  }

  /// 🗑️ Eliminar una mascota
  Future<void> deletePet(int petId) async {
    try {
      final token = await _tokenManager.getToken();

      if (token == null || token.isEmpty) {
        throw Exception('No hay token de autenticación. Por favor inicia sesión nuevamente.');
      }

      // Limpiar el token si tiene "Bearer " al inicio
      final cleanToken = token.replaceFirst('Bearer ', '').trim();
      
      final response = await http.delete(
        Uri.parse('$baseUrl/pets/$petId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $cleanToken',
        },
      );

      print('🗑️ DELETE /pets/$petId - Status: ${response.statusCode}');
      print('📦 Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // El backend devuelve { message: "Mascota eliminada exitosamente" }
        if (data['message'] != null) {
          return;
        }
      }

      throw Exception('Error al eliminar mascota: ${response.statusCode} - ${response.body}');
    } catch (e) {
      print('❌ Error en deletePet: $e');
      rethrow;
    }
  }
}
