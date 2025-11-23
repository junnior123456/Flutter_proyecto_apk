import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

/// Widget reutilizable para mostrar imágenes de mascotas con caché
/// Sigue Clean Architecture: Core/Widgets (capa de presentación compartida)
/// 
/// Maneja múltiples fuentes de imágenes:
/// - URLs de Firebase Storage (https://firebasestorage.googleapis.com/...)
/// - URLs de Pexels (https://images.pexels.com/...)
/// - URLs HTTP/HTTPS genéricas
/// - Rutas locales de archivos
class CachedPetImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CachedPetImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  /// Determina si la URL es una ruta local de archivo
  bool _isLocalFile(String url) {
    return !url.startsWith('http://') && 
           !url.startsWith('https://') &&
           (url.startsWith('/') || url.contains('\\') || url.startsWith('file://'));
  }

  /// Determina si la URL es válida para carga remota
  bool _isValidRemoteUrl(String url) {
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay URL, mostrar placeholder
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    final url = imageUrl!.trim();

    // Si es una ruta local, usar Image.file
    if (_isLocalFile(url)) {
      return _buildLocalImage(url);
    }

    // Si es una URL remota válida, usar CachedNetworkImage
    if (_isValidRemoteUrl(url)) {
      return _buildNetworkImage(url);
    }

    // URL no válida, mostrar error
    return _buildPlaceholder();
  }

  /// Construir imagen desde archivo local
  Widget _buildLocalImage(String filePath) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Image.file(
        File(filePath),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          debugPrint('❌ Error cargando imagen local: $filePath - Error: $error');
          return errorWidget ?? _buildErrorPlaceholder();
        },
      ),
    );
  }

  /// Construir imagen desde URL remota con caché
  Widget _buildNetworkImage(String url) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => placeholder ?? _buildLoadingPlaceholder(),
        errorWidget: (context, url, error) {
          debugPrint('❌ Error cargando imagen remota: $url');
          debugPrint('   Tipo de error: ${error.runtimeType}');
          debugPrint('   Detalles: $error');
          return errorWidget ?? _buildErrorPlaceholder(showRetry: true, url: url);
        },
        // Configuración de caché optimizada
        // Validar que width y height sean finitos antes de convertir a int
        memCacheWidth: _safeToInt(width),
        memCacheHeight: _safeToInt(height),
        maxWidthDiskCache: 1200,
        maxHeightDiskCache: 1200,
        // Headers para Firebase Storage
        httpHeaders: _getHttpHeaders(url),
        // Configuración de timeout
        fadeInDuration: const Duration(milliseconds: 300),
        fadeOutDuration: const Duration(milliseconds: 100),
      ),
    );
  }

  /// Convierte double a int de manera segura, manejando infinity y NaN
  /// Siguiendo Clean Architecture: validación en capa de presentación
  int? _safeToInt(double? value) {
    if (value == null) return null;
    if (value.isInfinite || value.isNaN) return null;
    if (value < 0) return null;
    if (value > 4096) return 4096; // Límite máximo razonable para imágenes
    return value.toInt();
  }

  /// Obtener headers HTTP apropiados según la URL
  Map<String, String>? _getHttpHeaders(String url) {
    // Firebase Storage requiere headers específicos
    if (url.contains('firebasestorage.googleapis.com')) {
      return {
        'Accept': 'image/*',
        'Cache-Control': 'max-age=3600',
      };
    }
    
    // Pexels y otras URLs genéricas
    return {
      'Accept': 'image/*',
      'User-Agent': 'PawFinder/1.0',
    };
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[200]!,
            Colors.grey[100]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Colors.orange,
              strokeWidth: 2.5,
            ),
            const SizedBox(height: 12),
            Text(
              'Cargando...',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.pets,
            size: 48,
            color: Colors.grey[500],
          ),
          const SizedBox(height: 12),
          Text(
            'Sin imagen',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorPlaceholder({bool showRetry = false, String? url}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.red[100]!,
            Colors.red[50]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.broken_image_outlined,
            size: 48,
            color: Colors.red[400],
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Error al cargar imagen',
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showRetry && url != null) ...[
            const SizedBox(height: 8),
            Text(
              'Verifica tu conexión',
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

