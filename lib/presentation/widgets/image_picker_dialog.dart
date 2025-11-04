import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/usecases/image/take_photo_usecase.dart';
import '../../domain/usecases/image/pick_gallery_image_usecase.dart';

/// 📸 Widget de diálogo para selección de imagen
class ImagePickerDialog extends StatelessWidget {
  final String title;
  final bool allowDelete;
  final VoidCallback? onDelete;
  final TakePhotoUseCase takePhotoUseCase;
  final PickGalleryImageUseCase pickGalleryImageUseCase;

  const ImagePickerDialog({
    super.key,
    this.title = 'Seleccionar imagen',
    this.allowDelete = false,
    this.onDelete,
    required this.takePhotoUseCase,
    required this.pickGalleryImageUseCase,
  });

  /// 📱 Mostrar diálogo de selección de imagen
  static Future<File?> show(
    BuildContext context, {
    String title = 'Seleccionar imagen',
    bool allowDelete = false,
    VoidCallback? onDelete,
    required TakePhotoUseCase takePhotoUseCase,
    required PickGalleryImageUseCase pickGalleryImageUseCase,
  }) {
    return showModalBottomSheet<File?>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ImagePickerDialog(
          title: title,
          allowDelete: allowDelete,
          onDelete: onDelete,
          takePhotoUseCase: takePhotoUseCase,
          pickGalleryImageUseCase: pickGalleryImageUseCase,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle del modal
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          
          // Título
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // Opciones
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildImageOption(
                context: context,
                icon: Icons.photo_camera,
                label: 'Cámara',
                onTap: () => _handleCameraSelection(context),
              ),
              _buildImageOption(
                context: context,
                icon: Icons.photo_library,
                label: 'Galería',
                onTap: () => _handleGallerySelection(context),
              ),
              if (allowDelete)
                _buildImageOption(
                  context: context,
                  icon: Icons.delete,
                  label: 'Eliminar',
                  color: Colors.red,
                  onTap: () => _handleDelete(context),
                ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  /// 🎨 Construir opción de imagen
  Widget _buildImageOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final primaryColor = color ?? Theme.of(context).primaryColor;
    
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// 📸 Manejar selección de cámara
  Future<void> _handleCameraSelection(BuildContext context) async {
    try {
      final image = await takePhotoUseCase.execute();
      
      // Cerrar diálogo y retornar imagen
      Navigator.pop(context, image);
    } catch (e) {
      // Cerrar diálogo sin imagen
      Navigator.pop(context);
      
      // Mostrar error después de cerrar el diálogo
      Future.delayed(const Duration(milliseconds: 100), () {
        _showErrorSnackBar(context, 'Error con la cámara: ${e.toString()}');
      });
    }
  }

  /// 🖼️ Manejar selección de galería
  Future<void> _handleGallerySelection(BuildContext context) async {
    try {
      final image = await pickGalleryImageUseCase.execute();
      
      // Cerrar diálogo y retornar imagen
      Navigator.pop(context, image);
    } catch (e) {
      // Cerrar diálogo sin imagen
      Navigator.pop(context);
      
      // Mostrar error después de cerrar el diálogo
      Future.delayed(const Duration(milliseconds: 100), () {
        _showErrorSnackBar(context, 'Error con la galería: ${e.toString()}');
      });
    }
  }

  /// 🗑️ Manejar eliminación
  void _handleDelete(BuildContext context) {
    Navigator.pop(context); // Cerrar diálogo
    onDelete?.call();
  }

  /// ⏳ Mostrar diálogo de carga
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(width: 20),
              Expanded(child: Text(message)),
            ],
          ),
        );
      },
    );
  }

  /// 🚨 Mostrar mensaje de error
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'Configuración',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Implementar apertura de configuración
            // openAppSettings();
          },
        ),
      ),
    );
  }
}