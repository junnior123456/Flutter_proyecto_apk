import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/services/image_service.dart';
import '../../../../core/services/theme_service.dart';
import '../../../../core/services/theme_notifier.dart';
import '../../../../core/services/user_profile_notifier.dart';
import '../../../../core/services/google_auth_service.dart';
import '../../../../core/services/profile_service.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validation_utils.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  
  // Services
  final ImageService _imageService = ImageService();
  final ThemeService _themeService = ThemeService();
  final ThemeNotifier _themeNotifier = ThemeNotifier();
  final UserProfileNotifier _profileNotifier = UserProfileNotifier();
  final GoogleAuthService _googleAuth = GoogleAuthService();
  final ProfileService _profileService = ProfileService();

  // State variables
  bool _isLoading = false;
  File? _selectedImage;
  String _selectedColor = 'orange';
  bool _isDarkMode = false;
  bool _hasUnsavedChanges = false; // Nueva variable para rastrear cambios
  
  // Profile data
  UserProfile? _originalProfile;
  
  // Original values for comparison
  String _originalColor = 'orange';
  bool _originalDarkMode = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    
    // Agregar listeners para detectar cambios en los campos de texto
    _nameController.addListener(_updateChangesState);
    _emailController.addListener(_updateChangesState);
    _phoneController.addListener(_updateChangesState);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// 🚀 Inicializar todos los datos necesarios
  Future<void> _initializeData() async {
    await _loadUserProfile();
    await _loadThemePreferences();
  }

  /// 👤 Cargar perfil del usuario
  Future<void> _loadUserProfile() async {
    try {
      Logger.userOperation('Loading user profile for editing');
      
      await _profileNotifier.loadProfile();
      final profile = _profileNotifier.currentProfile;
      
      if (profile != null) {
        setState(() {
          _originalProfile = profile;
          _nameController.text = profile.name;
          _emailController.text = profile.email;
          _phoneController.text = profile.phone ?? '';
        });
        
        Logger.userOperation('Profile loaded successfully', userId: profile.id.toString(), data: {
          'name': profile.name,
          'email': profile.email,
          'hasImage': profile.image?.isNotEmpty == true,
        });
      } else {
        throw Exception('No se pudo cargar el perfil del usuario');
      }
    } catch (e) {
      Logger.error('Error loading user profile', tag: 'EditProfileScreen', error: e);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error cargando perfil: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadThemePreferences() async {
    final color = await _themeService.getColorPreference();
    final darkMode = await _themeService.getDarkModePreference();
    setState(() {
      _selectedColor = color;
      _isDarkMode = darkMode;
      // Guardar valores originales para comparación
      _originalColor = color;
      _originalDarkMode = darkMode;
    });
  }

  /// 🔍 Verificar si hay cambios pendientes
  bool _hasChanges() {
    if (_originalProfile == null) return false;
    
    // Verificar cambios en los campos de texto
    final nameChanged = _nameController.text.trim() != _originalProfile!.name;
    final emailChanged = _emailController.text.trim() != _originalProfile!.email;
    final phoneChanged = _phoneController.text.trim() != (_originalProfile!.phone ?? '');
    
    // Verificar cambios en imagen
    final imageChanged = _selectedImage != null;
    
    // Verificar cambios en tema
    final colorChanged = _selectedColor != _originalColor;
    final darkModeChanged = _isDarkMode != _originalDarkMode;
    
    final hasChanges = nameChanged || emailChanged || phoneChanged || imageChanged || colorChanged || darkModeChanged;
    
    // Debug log
    print('🔍 _hasChanges: $hasChanges');
    print('  - nameChanged: $nameChanged');
    print('  - emailChanged: $emailChanged');
    print('  - phoneChanged: $phoneChanged');
    print('  - imageChanged: $imageChanged (selectedImage: ${_selectedImage != null})');
    print('  - colorChanged: $colorChanged');
    print('  - darkModeChanged: $darkModeChanged');
    
    return hasChanges;
  }

  /// 🔄 Actualizar estado de cambios
  void _updateChangesState() {
    final hasChanges = _hasChanges();
    if (_hasUnsavedChanges != hasChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
      print('🔄 Estado de cambios actualizado: $_hasUnsavedChanges');
    }
  }

  Future<void> _showImageSourceDialog() async {
    try {
      final selectedImage = await _imageService.showImageSourceDialog(context);

      if (selectedImage != null) {
        print('📸 Nueva imagen seleccionada: ${selectedImage.path}');
        setState(() {
          _selectedImage = selectedImage;
          _hasUnsavedChanges = true; // Marcar directamente que hay cambios
        });
        print('🔄 Estado actualizado - _selectedImage: ${_selectedImage != null}');
        print('🔄 _hasUnsavedChanges: $_hasUnsavedChanges');
      }
    } catch (e) {
      print('❌ Error seleccionando imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error seleccionando imagen: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Método removido - ahora se usa el widget ImagePickerDialog

  /// 💾 Guardar cambios del perfil
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate() || _originalProfile == null) return;

    // Validar datos del formulario
    final validationErrors = ValidationUtils.validateUserProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
    );

    if (validationErrors.isNotEmpty) {
      final errorMessage = validationErrors.values.join('\n');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Errores de validación:\n$errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Logger.userOperation('Saving profile changes', userId: _originalProfile!.id.toString());

      // 1. Actualizar perfil en el backend usando ProfileService
      Map<String, dynamic>? updatedUserData;
      
      if (_selectedImage != null) {
        Logger.imageOperation('Updating profile with new image');
        updatedUserData = await _profileService.updateProfileWithImage(
          userId: _originalProfile!.id,
          name: ValidationUtils.cleanText(_nameController.text),
          email: ValidationUtils.normalizeEmail(_emailController.text),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
          imageFile: _selectedImage!,
        );
      } else {
        Logger.userOperation('Updating profile without image');
        updatedUserData = await _profileService.updateProfile(
          userId: _originalProfile!.id,
          name: ValidationUtils.cleanText(_nameController.text),
          email: ValidationUtils.normalizeEmail(_emailController.text),
          phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        );
      }

      if (updatedUserData != null) {
        // 2. Sincronizar perfil en el notifier con datos reales del backend
        await _profileNotifier.syncWithBackendData(updatedUserData);
        
        Logger.userOperation('Profile updated successfully', userId: _originalProfile!.id.toString());
      } else {
        throw Exception('Error actualizando perfil en el servidor');
      }

      // 3. Guardar preferencias de tema
      await _themeService.saveColorPreference(_selectedColor);
      await _themeService.saveDarkModePreference(_isDarkMode);

      // 4. Actualizar tema inmediatamente
      await _themeNotifier.updateTheme();

      // 5. Actualizar valores originales después de guardar exitosamente
      setState(() {
        _originalColor = _selectedColor;
        _originalDarkMode = _isDarkMode;
        _selectedImage = null; // Limpiar imagen seleccionada
        _hasUnsavedChanges = false; // Resetear estado de cambios
      });

      if (mounted) {
        // 6. Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Perfil actualizado correctamente'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // 7. Esperar un momento y regresar
        await Future.delayed(const Duration(milliseconds: 500));
        
        // 8. Retornar con los datos actualizados
        Navigator.pop(context, {
          'updated': true,
          'profile': _profileNotifier.currentProfile?.toJson(),
        });
      }
    } catch (e) {
      Logger.error('Error saving profile', tag: 'EditProfileScreen', error: e, stackTrace: StackTrace.current);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: (_isLoading || !_hasUnsavedChanges) ? null : _saveProfile,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _isLoading 
                    ? Colors.white.withOpacity(0.3)
                    : _hasUnsavedChanges
                        ? Colors.white.withOpacity(0.9)
                        : Colors.white.withOpacity(0.3),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Guardar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _hasUnsavedChanges ? Colors.white : Colors.white.withOpacity(0.6),
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Foto de perfil
                _buildProfileImage(),
                const SizedBox(height: 24),

                // Información personal
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),

                // Personalización
                _buildCustomizationSection(),
                const SizedBox(height: 24),

                // Seguridad
                _buildSecuritySection(),
                
                // Espacio adicional al final
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    final currentImageUrl = _originalProfile?.image;
    
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).primaryColor,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (currentImageUrl != null && currentImageUrl.isNotEmpty)
                          ? NetworkImage(currentImageUrl)
                          : null,
                  child: _selectedImage == null && (currentImageUrl == null || currentImageUrl.isEmpty)
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[600],
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : _showImageSourceDialog,
                    icon: const Icon(Icons.camera_alt, color: Colors.white),
                    iconSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _selectedImage != null 
                ? 'Nueva imagen seleccionada' 
                : 'Toca para cambiar foto',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _selectedImage != null 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey[600],
              fontWeight: _selectedImage != null 
                  ? FontWeight.w500 
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Información Personal',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre completo',
                  prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa tu correo';
                  }
                  if (!value.contains('@')) {
                    return 'Por favor ingresa un correo válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.number,
                maxLength: 9,
                decoration: InputDecoration(
                  labelText: 'Teléfono (9 dígitos)',
                  hintText: '987654321',
                  prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                  ),
                  labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                  counterText: '', // Ocultar el contador de caracteres
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly, // Solo números
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (value.length != 9) {
                      return 'El teléfono debe tener exactamente 9 dígitos';
                    }
                    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                      return 'Solo se permiten números';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomizationSection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.palette_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Personalización',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Selector de color
              Text(
                'Color de tema',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _themeService.getColorNames().entries.map((entry) {
                  final isSelected = _selectedColor == entry.key;
                  return ChoiceChip(
                    label: Text(
                      entry.value,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Theme.of(context).primaryColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: Theme.of(context).primaryColor,
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                    checkmarkColor: Colors.white,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedColor = entry.key;
                          _hasUnsavedChanges = true;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 20),
              
              // Modo oscuro
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).primaryColor.withOpacity(0.3),
                  ),
                ),
                child: SwitchListTile(
                  title: Text(
                    'Modo oscuro',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  subtitle: Text(
                    'Usar tema oscuro en la aplicación',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor.withOpacity(0.7),
                    ),
                  ),
                  value: _isDarkMode,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecuritySection() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Theme.of(context).primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.security_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Seguridad',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildSecurityOption(
                icon: Icons.lock_outline,
                title: 'Cambiar contraseña',
                subtitle: 'Actualizar tu contraseña de acceso',
                onTap: () {
                  // Navegar a pantalla de cambio de contraseña
                },
              ),
              const Divider(height: 1),
              _buildSecurityOption(
                icon: Icons.verified_user_outlined,
                title: 'Verificar email',
                subtitle: 'Confirmar tu dirección de correo',
                onTap: () async {
                  final sent = await _googleAuth.sendEmailVerification();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(sent 
                          ? '✅ Email de verificación enviado'
                          : '❌ Error enviando email'),
                        backgroundColor: sent ? Theme.of(context).primaryColor : Colors.red,
                      ),
                    );
                  }
                },
              ),
              const Divider(height: 1),
              _buildSecurityOption(
                icon: Icons.account_circle_outlined,
                title: 'Conectar con Google',
                subtitle: 'Vincular cuenta de Google',
                onTap: () async {
                  final result = await _googleAuth.signInWithGoogle();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result != null 
                          ? '✅ Cuenta vinculada con Google'
                          : '❌ Error vinculando cuenta'),
                        backgroundColor: result != null ? Theme.of(context).primaryColor : Colors.red,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Theme.of(context).primaryColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Theme.of(context).primaryColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Theme.of(context).primaryColor.withOpacity(0.7),
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: Theme.of(context).primaryColor,
        size: 16,
      ),
      onTap: onTap,
    );
  }

}