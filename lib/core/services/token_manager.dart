import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';
import '../utils/logger.dart';

/// 🔐 Gestor profesional de tokens JWT
/// Maneja automáticamente la expiración y refresh de tokens
class TokenManager {
  static final TokenManager _instance = TokenManager._internal();
  factory TokenManager() => _instance;
  TokenManager._internal();

  final AuthService _authService = AuthService();
  
  // Control de refresh en progreso
  bool _isRefreshing = false;
  List<Function> _refreshCallbacks = [];

  /// 🔑 Obtener token (sin validación)
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      Logger.error('Error getting token', tag: 'TokenManager', error: e);
      return null;
    }
  }

  /// 🔑 Obtener token válido (con refresh automático si es necesario)
  Future<String?> getValidToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      if (token == null) {
        Logger.warning('No token available', tag: 'TokenManager');
        return null;
      }

      // Verificar si el token está por expirar (menos de 5 minutos)
      if (_isTokenExpiringSoon(token)) {
        Logger.info('Token expiring soon, refreshing...', tag: 'TokenManager');
        return await _refreshTokenIfNeeded();
      }

      return token;
    } catch (e) {
      Logger.error('Error getting valid token', tag: 'TokenManager', error: e);
      return null;
    }
  }

  /// 🔄 Manejar error 401 (token expirado)
  Future<String?> handleUnauthorized() async {
    Logger.warning('Handling 401 Unauthorized', tag: 'TokenManager');
    
    // Si ya hay un refresh en progreso, esperar
    if (_isRefreshing) {
      Logger.info('Refresh already in progress, waiting...', tag: 'TokenManager');
      return await _waitForRefresh();
    }

    // Iniciar refresh
    return await _refreshTokenIfNeeded();
  }

  /// 🔄 Refrescar token si es necesario
  Future<String?> _refreshTokenIfNeeded() async {
    if (_isRefreshing) {
      return await _waitForRefresh();
    }

    _isRefreshing = true;
    Logger.info('Starting token refresh', tag: 'TokenManager');

    try {
      // Intentar refrescar el token
      final success = await _authService.refreshToken();
      
      if (success) {
        // Obtener el nuevo token
        final prefs = await SharedPreferences.getInstance();
        final newToken = prefs.getString('auth_token');
        
        Logger.info('Token refreshed successfully', tag: 'TokenManager');
        
        // Notificar a los callbacks esperando
        _notifyRefreshCallbacks(newToken);
        
        return newToken;
      } else {
        Logger.error('Token refresh failed', tag: 'TokenManager');
        
        // Notificar fallo
        _notifyRefreshCallbacks(null);
        
        // Limpiar sesión
        await _authService.logout();
        
        return null;
      }
    } catch (e) {
      Logger.error('Error refreshing token', tag: 'TokenManager', error: e);
      
      // Notificar fallo
      _notifyRefreshCallbacks(null);
      
      // Limpiar sesión
      await _authService.logout();
      
      return null;
    } finally {
      _isRefreshing = false;
      _refreshCallbacks.clear();
    }
  }

  /// ⏳ Esperar a que termine el refresh en progreso
  Future<String?> _waitForRefresh() async {
    final completer = Completer<String?>();
    
    _refreshCallbacks.add((String? token) {
      completer.complete(token);
    });

    return completer.future;
  }

  /// 📢 Notificar a los callbacks esperando
  void _notifyRefreshCallbacks(String? token) {
    for (var callback in _refreshCallbacks) {
      callback(token);
    }
  }

  /// ⏰ Verificar si el token está por expirar
  bool _isTokenExpiringSoon(String token) {
    try {
      // Decodificar el token JWT
      final parts = token.split('.');
      if (parts.length != 3) return false;

      // Decodificar el payload
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> data = json.decode(decoded);

      // Obtener tiempo de expiración
      final exp = data['exp'] as int?;
      if (exp == null) return false;

      // Verificar si expira en menos de 5 minutos
      final expirationDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();
      final difference = expirationDate.difference(now);

      return difference.inMinutes < 5;
    } catch (e) {
      Logger.error('Error checking token expiration', tag: 'TokenManager', error: e);
      return false;
    }
  }

  /// 🗑️ Limpiar token
  Future<void> clearToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      Logger.info('Token cleared', tag: 'TokenManager');
    } catch (e) {
      Logger.error('Error clearing token', tag: 'TokenManager', error: e);
    }
  }
}
