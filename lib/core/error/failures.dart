import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Error de conexión. Verifica tu internet.',
    super.code = 'NETWORK_FAILURE',
  });
}

class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Error del servidor. Inténtalo más tarde.',
    super.code = 'SERVER_FAILURE',
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Datos inválidos.',
    super.code = 'VALIDATION_FAILURE',
  });
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Recurso no encontrado.',
    super.code = 'NOT_FOUND_FAILURE',
  });
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'No autorizado. Inicia sesión.',
    super.code = 'UNAUTHORIZED_FAILURE',
  });
}

class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Error de caché local.',
    super.code = 'CACHE_FAILURE',
  });
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Ha ocurrido un error inesperado.',
    super.code = 'UNKNOWN_FAILURE',
  });
}