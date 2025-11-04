import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';
import 'auth_service.dart';
import 'profile_service.dart';
import '../utils/logger.dart';

class UserProfileNotifier extends ChangeNotifier {
  static final UserProfileNotifier _instance = UserProfileNotifier._internal();
  factory UserProfileNotifier() => _instance;
  UserProfileNotifier._internal();

  final AuthService _authService = AuthService();
  final ProfileService _profileService = ProfileService();
  
  UserProfile? _currentProfile;
  UserProfile? get currentProfile => _currentProfile;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  String? _lastError;
  String? get lastError => _lastError;

  /// 📖 Cargar perfil con sincronización completa
  Future<void> loadProfile() async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.userOperation('Loading user profile');
      
      // 1. Intentar obtener perfil actualizado del backend
      final backendData = await _profileService.getCurrentUserProfile();
      
      if (backendData != null) {
        // DEBUG: Log de datos del backend
        print('🔍 DEBUG UserProfileNotifier: Backend data image field: ${backendData['image']}');
        
        // Convertir datos del backend al modelo UserProfile
        _currentProfile = UserProfile(
          id: backendData['id'] ?? 1,
          name: backendData['name'] ?? 'Usuario',
          email: backendData['email'] ?? 'usuario@ejemplo.com',
          phone: backendData['phone'] ?? '',
          image: backendData['image'] ?? '', // EXACTO como el profesor
        );
        
        // DEBUG: Log del perfil creado
        print('🔍 DEBUG UserProfileNotifier: Created profile image: ${_currentProfile!.image}');
        
        // Sincronizar con preferencias locales
        await _saveProfileLocally(_currentProfile!);
        
        Logger.userOperation('Profile loaded from backend', userId: _currentProfile!.id.toString(), data: {
          'name': _currentProfile!.name,
          'email': _currentProfile!.email,
          'hasImage': _currentProfile!.image?.isNotEmpty == true,
        });
      } else {
        // 2. Fallback: cargar desde AuthService
        await _loadFromAuthService();
      }
      
    } catch (e) {
      Logger.error('Error loading profile from backend', tag: 'UserProfileNotifier', error: e);
      _setError('Error cargando perfil: ${e.toString()}');
      
      // Fallback: cargar desde AuthService o almacenamiento local
      await _loadFromAuthService();
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 🔐 Cargar desde AuthService como fallback
  Future<void> _loadFromAuthService() async {
    try {
      Logger.userOperation('Loading profile from AuthService as fallback');
      
      final userData = await _authService.getCurrentUser();
      
      if (userData != null) {
        _currentProfile = UserProfile(
          id: userData['id'] ?? 1,
          name: userData['name'] ?? 'Usuario',
          email: userData['email'] ?? 'usuario@ejemplo.com',
          phone: userData['phone'],
          image: userData['image'],
        );
        
        await _saveProfileLocally(_currentProfile!);
        Logger.userOperation('Profile loaded from AuthService', userId: _currentProfile!.id.toString());
      } else {
        // Último fallback: almacenamiento local
        await _loadFromLocalStorage();
      }
    } catch (e) {
      Logger.error('Error loading from AuthService', tag: 'UserProfileNotifier', error: e);
      await _loadFromLocalStorage();
    }
  }

  /// 📱 Cargar desde almacenamiento local (último fallback)
  Future<void> _loadFromLocalStorage() async {
    try {
      Logger.storageOperation('Loading profile from local storage');
      
      final prefs = await SharedPreferences.getInstance();
      final profileData = prefs.getString('user_profile');
      
      if (profileData != null) {
        final profileJson = json.decode(profileData);
        _currentProfile = UserProfile.fromJson(profileJson);
        Logger.storageOperation('Profile loaded from local storage', success: true);
      } else {
        // Perfil por defecto solo si no hay nada
        _currentProfile = UserProfile(
          id: 1,
          name: 'Usuario Demo',
          email: 'usuario@ejemplo.com',
          phone: null,
        );
        await _saveProfileLocally(_currentProfile!);
        Logger.warning('Using default profile - no data found', tag: 'UserProfileNotifier');
      }
    } catch (e) {
      Logger.error('Error loading from local storage', tag: 'UserProfileNotifier', error: e);
      _currentProfile = UserProfile(
        id: 1,
        name: 'Usuario Demo',
        email: 'usuario@ejemplo.com',
        phone: null,
      );
    }
  }

  /// 💾 Guardar perfil con sincronización completa
  Future<void> saveProfile(UserProfile profile) async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.userOperation('Saving user profile', userId: profile.id.toString());
      
      _currentProfile = profile;
      
      // 1. Guardar en almacenamiento local inmediatamente
      await _saveProfileLocally(profile);
      
      // 2. Intentar sincronizar con backend (sin bloquear la UI)
      _syncWithBackendAsync(profile);
      
      Logger.userOperation('Profile saved locally', userId: profile.id.toString());
    } catch (e) {
      Logger.error('Error saving profile', tag: 'UserProfileNotifier', error: e);
      _setError('Error guardando perfil: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /// 🔄 Sincronización asíncrona con backend (no bloquea UI)
  Future<void> _syncWithBackendAsync(UserProfile profile) async {
    try {
      // Esta operación se ejecuta en background
      // TODO: Implementar sincronización con backend cuando esté disponible
      Logger.debug('Background sync with backend initiated', tag: 'UserProfileNotifier');
    } catch (e) {
      Logger.warning('Background sync failed', tag: 'UserProfileNotifier', error: e);
      // No mostrar error al usuario ya que los datos locales están guardados
    }
  }

  /// 💾 Guardar en almacenamiento local
  Future<void> _saveProfileLocally(UserProfile profile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile', json.encode(profile.toJson()));
      Logger.storageOperation('Profile saved to local storage', success: true);
    } catch (e) {
      Logger.error('Error saving profile locally', tag: 'UserProfileNotifier', error: e);
      rethrow;
    }
  }

  /// 🔄 Actualizar perfil
  Future<void> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
  }) async {
    if (_currentProfile == null) {
      Logger.warning('Cannot update profile - no current profile loaded', tag: 'UserProfileNotifier');
      return;
    }

    Logger.userOperation('Updating profile fields', userId: _currentProfile!.id.toString());

    final updatedProfile = _currentProfile!.copyWith(
      name: name,
      email: email,
      phone: phone,
      image: imageUrl,
    );

    await saveProfile(updatedProfile);
  }

  /// 🖼️ Actualizar solo la imagen
  Future<void> updateProfileImage(String imageUrl) async {
    if (_currentProfile == null) {
      Logger.warning('Cannot update profile image - no current profile loaded', tag: 'UserProfileNotifier');
      return;
    }
    
    Logger.imageOperation('Updating profile image', details: imageUrl);
    
    final updatedProfile = _currentProfile!.copyWith(image: imageUrl);
    await saveProfile(updatedProfile);
  }

  /// 🗑️ Eliminar imagen de perfil
  Future<void> removeProfileImage() async {
    if (_currentProfile == null) {
      Logger.warning('Cannot remove profile image - no current profile loaded', tag: 'UserProfileNotifier');
      return;
    }
    
    Logger.imageOperation('Removing profile image');
    
    final updatedProfile = _currentProfile!.copyWith(image: null);
    await saveProfile(updatedProfile);
  }

  /// 🚪 Limpiar perfil (para logout)
  Future<void> clearProfile() async {
    try {
      Logger.userOperation('Clearing user profile');
      
      _currentProfile = null;
      _isLoading = false;
      _lastError = null;
      
      // Limpiar almacenamiento local
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_profile');
      
      notifyListeners();
      Logger.userOperation('Profile cleared successfully');
    } catch (e) {
      Logger.error('Error clearing profile', tag: 'UserProfileNotifier', error: e);
    }
  }

  /// 🔄 Sincronizar con nuevo usuario autenticado
  Future<void> syncWithAuthenticatedUser() async {
    Logger.userOperation('Syncing with authenticated user');
    await loadProfile();
  }

  /// 🔄 Sincronizar con datos del backend
  Future<void> syncWithBackendData(Map<String, dynamic> backendData) async {
    try {
      Logger.userOperation('Syncing profile with backend data');
      
      _currentProfile = UserProfile(
        id: backendData['id'] ?? _currentProfile?.id ?? 1,
        name: backendData['name'] ?? _currentProfile?.name ?? 'Usuario',
        email: backendData['email'] ?? _currentProfile?.email ?? 'usuario@ejemplo.com',
        phone: backendData['phone'],
        image: backendData['image'] ?? backendData['imageUrl'], // Priorizar 'image' del backend
      );
      
      await _saveProfileLocally(_currentProfile!);
      notifyListeners();
      
      Logger.userOperation('Profile synced with backend successfully', userId: _currentProfile!.id.toString(), data: {
        'imageUrl': _currentProfile!.image,
        'name': _currentProfile!.name,
      });
    } catch (e) {
      Logger.error('Error syncing with backend data', tag: 'UserProfileNotifier', error: e);
      _setError('Error sincronizando con servidor');
    }
  }

  /// 🔄 Refrescar perfil desde backend
  Future<void> refreshFromBackend() async {
    _setLoading(true);
    _clearError();
    
    try {
      Logger.userOperation('Refreshing profile from backend');
      
      final backendData = await _profileService.refreshProfileFromBackend();
      if (backendData != null) {
        await syncWithBackendData(backendData);
      } else {
        throw Exception('No se pudo obtener datos del backend');
      }
    } catch (e) {
      Logger.error('Error refreshing from backend', tag: 'UserProfileNotifier', error: e);
      _setError('Error refrescando perfil: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  // Métodos de estado interno
  void _setLoading(bool loading) {
    _isLoading = loading;
  }

  void _setError(String? error) {
    _lastError = error;
  }

  void _clearError() {
    _lastError = null;
  }


}