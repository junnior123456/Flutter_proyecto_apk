import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'token_manager.dart';

class AdoptionService {
  final TokenManager _tokenManager = TokenManager();

  /// 📤 Enviar solicitud de adopción
  Future<Map<String, dynamic>> sendAdoptionRequest({
    required int petId,
    required String personalInfo,
    required String livingSituation,
    required String adoptionReason,
    String? previousExperience,
    String? familyComposition,
    String? workSchedule,
    bool? hasYard,
    bool? hasOtherPets,
    // ✅ Campos adicionales para animales en riesgo
    String? rescuePlan,
    String? medicalCare,
    bool? canProvideMedicalCare,
    bool? hasTransportation,
  }) async {
    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/adoption/request'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'petId': petId,
          'personalInfo': personalInfo,
          'livingSituation': livingSituation,
          'adoptionReason': adoptionReason,
          if (previousExperience != null) 'previousExperience': previousExperience,
          if (familyComposition != null) 'familyComposition': familyComposition,
          if (workSchedule != null) 'workSchedule': workSchedule,
          if (hasYard != null) 'hasYard': hasYard,
          if (hasOtherPets != null) 'hasOtherPets': hasOtherPets,
          // ✅ Campos adicionales para animales en riesgo
          if (rescuePlan != null) 'rescuePlan': rescuePlan,
          if (medicalCare != null) 'medicalCare': medicalCare,
          if (canProvideMedicalCare != null) 'canProvideMedicalCare': canProvideMedicalCare,
          if (hasTransportation != null) 'hasTransportation': hasTransportation,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error al enviar solicitud');
      }
    } catch (e) {
      print('❌ Error en sendAdoptionRequest: $e');
      rethrow;
    }
  }

  /// 📋 Obtener mis solicitudes (como adoptante)
  Future<List<Map<String, dynamic>>> getMyRequests() async {
    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/adoption/requests/my-requests'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Error al obtener solicitudes');
      }
    } catch (e) {
      print('❌ Error en getMyRequests: $e');
      rethrow;
    }
  }

  /// 📥 Obtener solicitudes recibidas (como publicador)
  Future<List<Map<String, dynamic>>> getReceivedRequests() async {
    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/adoption/requests/received'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        return List<Map<String, dynamic>>.from(data['data'] ?? []);
      } else {
        throw Exception(data['message'] ?? 'Error al obtener solicitudes recibidas');
      }
    } catch (e) {
      print('❌ Error en getReceivedRequests: $e');
      rethrow;
    }
  }

  /// ✅ Aceptar solicitud de adopción
  Future<Map<String, dynamic>> acceptRequest({
    required int requestId,
    required String donorComments,
  }) async {
    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/adoption/request/$requestId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': 'approved',
          'donorComments': donorComments,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error al aceptar solicitud');
      }
    } catch (e) {
      print('❌ Error en acceptRequest: $e');
      rethrow;
    }
  }

  /// ❌ Rechazar solicitud de adopción
  Future<Map<String, dynamic>> rejectRequest({
    required int requestId,
    required String rejectionReason,
  }) async {
    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/adoption/request/$requestId/status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': 'rejected',
          'rejectionReason': rejectionReason,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error al rechazar solicitud');
      }
    } catch (e) {
      print('❌ Error en rejectRequest: $e');
      rethrow;
    }
  }

  /// 🔍 Verificar si ya existe una solicitud para una mascota
  Future<bool> hasExistingRequest(int petId) async {
    try {
      final myRequests = await getMyRequests();
      return myRequests.any((request) => 
        request['petId'] == petId && 
        request['status'] == 'pending'
      );
    } catch (e) {
      print('❌ Error en hasExistingRequest: $e');
      return false;
    }
  }

  /// 🗑️ Cancelar solicitud
  Future<void> cancelRequest(int requestId) async {
    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/adoption/request/$requestId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode != 200 || data['ok'] != true) {
        throw Exception(data['message'] ?? 'Error al cancelar solicitud');
      }
    } catch (e) {
      print('❌ Error en cancelRequest: $e');
      rethrow;
    }
  }

  /// ✅ Donante confirma entrega de mascota
  Future<Map<String, dynamic>> donorConfirmDelivery(int requestId) async {
    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/adoption/request/$requestId/donor-confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error al confirmar entrega');
      }
    } catch (e) {
      print('❌ Error en donorConfirmDelivery: $e');
      rethrow;
    }
  }

  /// ✅ Adoptante confirma recepción de mascota
  Future<Map<String, dynamic>> adopterConfirmReception(int requestId) async {
    try {
      final token = await _tokenManager.getToken();
      if (token == null) {
        throw Exception('No hay token de autenticación');
      }

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/adoption/request/$requestId/adopter-confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['ok'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Error al confirmar recepción');
      }
    } catch (e) {
      print('❌ Error en adopterConfirmReception: $e');
      rethrow;
    }
  }

  /// ✅ Completar adopción (legacy - ahora usa donorConfirmDelivery)
  Future<Map<String, dynamic>> completeAdoption(int requestId) async {
    return await donorConfirmDelivery(requestId);
  }
}
