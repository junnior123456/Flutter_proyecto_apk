import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/donation_model.dart';
import '../config/api_config.dart';
import '../utils/logger.dart';
import 'auth_service.dart';

/// 💰 Servicio de Donaciones
class DonationService {
  static final DonationService _instance = DonationService._internal();
  factory DonationService() => _instance;
  DonationService._internal();

  final AuthService _authService = AuthService();

  /// 📊 Obtener todas las donaciones del usuario
  Future<List<DonationModel>> getUserDonations() async {
    try {
      Logger.info('Obteniendo donaciones del usuario', tag: 'DonationService');
      
      final token = await _authService.getToken();
      if (token == null) {
        Logger.warning('No hay token disponible', tag: 'DonationService');
        return [];
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donations/my-donations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      Logger.apiResponse('GET', '/donations/my-donations', response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final donations = data.map((json) => DonationModel.fromJson(json)).toList();
        
        Logger.info('Donaciones obtenidas: ${donations.length}', tag: 'DonationService');
        return donations;
      } else {
        Logger.error('Error al obtener donaciones: ${response.statusCode}', 
                    tag: 'DonationService', error: response.body);
        return [];
      }
    } catch (e) {
      Logger.error('Error en getUserDonations', tag: 'DonationService', error: e);
      return [];
    }
  }

  /// 💳 Crear nueva donación
  Future<DonationModel?> createDonation({
    required double amount,
    required String paymentMethod,
    String? message,
    String? transactionId,
  }) async {
    try {
      Logger.info('Creando donación: S/ $amount', tag: 'DonationService');
      
      final token = await _authService.getToken();
      if (token == null) {
        Logger.warning('No hay token disponible', tag: 'DonationService');
        return null;
      }

      final body = {
        'amount': amount,
        'currency': 'PEN',
        'paymentMethod': paymentMethod,
        'message': message,
        'transactionId': transactionId,
      };

      Logger.apiRequest('POST', '/donations', body: body);

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/donations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      Logger.apiResponse('POST', '/donations', response.statusCode);

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final donation = DonationModel.fromJson(data);
        
        Logger.info('Donación creada exitosamente: ${donation.id}', tag: 'DonationService');
        return donation;
      } else {
        Logger.error('Error al crear donación: ${response.statusCode}', 
                    tag: 'DonationService', error: response.body);
        return null;
      }
    } catch (e) {
      Logger.error('Error en createDonation', tag: 'DonationService', error: e);
      return null;
    }
  }

  /// ✅ Confirmar donación
  Future<bool> confirmDonation(String donationId, String transactionId) async {
    try {
      Logger.info('Confirmando donación: $donationId', tag: 'DonationService');
      
      final token = await _authService.getToken();
      if (token == null) {
        Logger.warning('No hay token disponible', tag: 'DonationService');
        return false;
      }

      final body = {
        'transactionId': transactionId,
        'status': 'completed',
      };

      Logger.apiRequest('PUT', '/donations/$donationId/confirm', body: body);

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/donations/$donationId/confirm'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(body),
      );

      Logger.apiResponse('PUT', '/donations/$donationId/confirm', response.statusCode);

      if (response.statusCode == 200) {
        Logger.info('Donación confirmada exitosamente', tag: 'DonationService');
        return true;
      } else {
        Logger.error('Error al confirmar donación: ${response.statusCode}', 
                    tag: 'DonationService', error: response.body);
        return false;
      }
    } catch (e) {
      Logger.error('Error en confirmDonation', tag: 'DonationService', error: e);
      return false;
    }
  }

  /// 📈 Obtener estadísticas de donaciones
  Future<DonationStatsModel?> getDonationStats() async {
    try {
      Logger.info('Obteniendo estadísticas de donaciones', tag: 'DonationService');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donations/stats'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      Logger.apiResponse('GET', '/donations/stats', response.statusCode);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final stats = DonationStatsModel.fromJson(data);
        
        Logger.info('Estadísticas obtenidas: S/ ${stats.totalAmount}', tag: 'DonationService');
        return stats;
      } else {
        Logger.error('Error al obtener estadísticas: ${response.statusCode}', 
                    tag: 'DonationService', error: response.body);
        return null;
      }
    } catch (e) {
      Logger.error('Error en getDonationStats', tag: 'DonationService', error: e);
      return null;
    }
  }

  /// 🎯 Obtener donaciones recientes (públicas)
  Future<List<DonationModel>> getRecentDonations({int limit = 10}) async {
    try {
      Logger.info('Obteniendo donaciones recientes', tag: 'DonationService');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donations/recent?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      Logger.apiResponse('GET', '/donations/recent', response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final donations = data.map((json) => DonationModel.fromJson(json)).toList();
        
        Logger.info('Donaciones recientes obtenidas: ${donations.length}', tag: 'DonationService');
        return donations;
      } else {
        Logger.error('Error al obtener donaciones recientes: ${response.statusCode}', 
                    tag: 'DonationService', error: response.body);
        return [];
      }
    } catch (e) {
      Logger.error('Error en getRecentDonations', tag: 'DonationService', error: e);
      return [];
    }
  }

  /// 🏆 Obtener top donadores
  Future<List<Map<String, dynamic>>> getTopDonors({int limit = 5}) async {
    try {
      Logger.info('Obteniendo top donadores', tag: 'DonationService');
      
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/donations/top-donors?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      Logger.apiResponse('GET', '/donations/top-donors', response.statusCode);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        
        Logger.info('Top donadores obtenidos: ${data.length}', tag: 'DonationService');
        return List<Map<String, dynamic>>.from(data);
      } else {
        Logger.error('Error al obtener top donadores: ${response.statusCode}', 
                    tag: 'DonationService', error: response.body);
        return [];
      }
    } catch (e) {
      Logger.error('Error en getTopDonors', tag: 'DonationService', error: e);
      return [];
    }
  }

  /// 💰 Validar monto de donación
  static bool isValidAmount(double amount) {
    return amount > 0 && amount <= 10000; // Máximo S/ 10,000
  }

  /// 🔄 Formatear monto
  static String formatAmount(double amount, {String currency = 'S/'}) {
    return '$currency ${amount.toStringAsFixed(2)}';
  }

  /// 📅 Formatear fecha
  static String formatDate(DateTime date) {
    final months = [
      'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// 🎨 Obtener color por método de pago
  static String getPaymentMethodColor(String method) {
    switch (method.toLowerCase()) {
      case 'yape':
        return '#6B2C91';
      case 'plin':
        return '#0066CC';
      case 'bcp':
        return '#003366';
      case 'interbank':
        return '#00A651';
      default:
        return '#666666';
    }
  }
}
