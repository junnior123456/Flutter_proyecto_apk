import 'package:flutter/foundation.dart';

/// 📊 Niveles de log
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 📝 Sistema de logging centralizado
class Logger {
  static const String _tag = 'PawFinder';

  /// 🎨 Colores para diferentes niveles
  static const Map<LogLevel, String> _colors = {
    LogLevel.debug: '\x1B[36m', // Cyan
    LogLevel.info: '\x1B[32m',  // Green
    LogLevel.warning: '\x1B[33m', // Yellow
    LogLevel.error: '\x1B[31m', // Red
  };

  static const String _reset = '\x1B[0m';

  /// 📝 Log genérico
  static void _log(LogLevel level, String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode && level == LogLevel.debug) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.name.toUpperCase().padRight(7);
    final tagStr = tag ?? _tag;
    final color = _colors[level] ?? '';
    
    final logMessage = '$color[$timestamp] $levelStr [$tagStr] $message$_reset';
    
    switch (level) {
      case LogLevel.debug:
        debugPrint(logMessage);
        break;
      case LogLevel.info:
        debugPrint(logMessage);
        break;
      case LogLevel.warning:
        debugPrint(logMessage);
        if (error != null) debugPrint('Error: $error');
        break;
      case LogLevel.error:
        debugPrint(logMessage);
        if (error != null) debugPrint('Error: $error');
        if (stackTrace != null) debugPrint('StackTrace: $stackTrace');
        break;
    }
  }

  /// 🐛 Debug log
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// ℹ️ Info log
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// ⚠️ Warning log
  static void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  /// ❌ Error log
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, tag: tag, error: error, stackTrace: stackTrace);
  }

  /// 🌐 API Request log
  static void apiRequest(String method, String endpoint, {Map<String, dynamic>? body, Map<String, String>? headers}) {
    final message = '$method $endpoint';
    debug(message, tag: 'API_REQUEST');
    
    if (headers != null && headers.isNotEmpty) {
      debug('Headers: $headers', tag: 'API_REQUEST');
    }
    
    if (body != null && body.isNotEmpty) {
      debug('Body: $body', tag: 'API_REQUEST');
    }
  }

  /// 🌐 API Response log
  static void apiResponse(String method, String endpoint, int statusCode, {String? body, Duration? duration}) {
    final durationStr = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
    final message = '$method $endpoint -> $statusCode$durationStr';
    
    if (statusCode >= 200 && statusCode < 300) {
      info(message, tag: 'API_RESPONSE');
    } else if (statusCode >= 400) {
      warning(message, tag: 'API_RESPONSE');
    } else {
      debug(message, tag: 'API_RESPONSE');
    }
    
    if (body != null && kDebugMode) {
      debug('Response Body: $body', tag: 'API_RESPONSE');
    }
  }

  /// 📸 Image operation log
  static void imageOperation(String operation, {String? details, bool success = true}) {
    final message = '$operation${details != null ? ' - $details' : ''}';
    
    if (success) {
      info('✅ $message', tag: 'IMAGE');
    } else {
      warning('❌ $message', tag: 'IMAGE');
    }
  }

  /// 👤 User operation log
  static void userOperation(String operation, {String? userId, Map<String, dynamic>? data}) {
    final userStr = userId != null ? ' (User: $userId)' : '';
    final message = '$operation$userStr';
    
    info(message, tag: 'USER');
    
    if (data != null && kDebugMode) {
      debug('Data: $data', tag: 'USER');
    }
  }

  /// 🐾 Pet operation log
  static void petOperation(String operation, {String? petId, Map<String, dynamic>? data}) {
    final petStr = petId != null ? ' (Pet: $petId)' : '';
    final message = '$operation$petStr';
    
    info(message, tag: 'PET');
    
    if (data != null && kDebugMode) {
      debug('Data: $data', tag: 'PET');
    }
  }

  /// 🔐 Auth operation log
  static void authOperation(String operation, {bool success = true, String? details}) {
    final message = '$operation${details != null ? ' - $details' : ''}';
    
    if (success) {
      info('✅ $message', tag: 'AUTH');
    } else {
      warning('❌ $message', tag: 'AUTH');
    }
  }

  /// 💾 Storage operation log
  static void storageOperation(String operation, {String? key, bool success = true}) {
    final keyStr = key != null ? ' ($key)' : '';
    final message = '$operation$keyStr';
    
    if (success) {
      debug('✅ $message', tag: 'STORAGE');
    } else {
      warning('❌ $message', tag: 'STORAGE');
    }
  }

  /// 🎯 Performance log
  static void performance(String operation, Duration duration, {String? details}) {
    final message = '$operation took ${duration.inMilliseconds}ms${details != null ? ' - $details' : ''}';
    
    if (duration.inMilliseconds > 1000) {
      warning(message, tag: 'PERFORMANCE');
    } else {
      debug(message, tag: 'PERFORMANCE');
    }
  }
}