abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({
    required this.message,
    this.code,
    this.details,
  });

  @override
  String toString() {
    return 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Error de conexión. Verifica tu internet.',
    super.code = 'NETWORK_ERROR',
    super.details,
  });
}

class ServerException extends AppException {
  const ServerException({
    super.message = 'Error del servidor. Inténtalo más tarde.',
    super.code = 'SERVER_ERROR',
    super.details,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Datos inválidos.',
    super.code = 'VALIDATION_ERROR',
    super.details,
  });
}

class NotFoundException extends AppException {
  const NotFoundException({
    super.message = 'Recurso no encontrado.',
    super.code = 'NOT_FOUND',
    super.details,
  });
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'No autorizado. Inicia sesión.',
    super.code = 'UNAUTHORIZED',
    super.details,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Tiempo de espera agotado.',
    super.code = 'TIMEOUT',
    super.details,
  });
}

class CacheException extends AppException {
  const CacheException({
    super.message = 'Error de caché.',
    super.code = 'CACHE_ERROR',
    super.details,
  });
}