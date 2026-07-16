import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

/// Traduce una excepción de red al motivo real, en lenguaje del usuario.
///
/// Sin esto la UI mostraba el `toString()` crudo de Dart ("ClientException with
/// SocketException: Failed host lookup...") y era imposible distinguir entre
/// quedarse sin internet, que la red bloquee el dominio o que un proxy
/// intercepte el TLS. Cada caso se resuelve distinto, así que el mensaje lo dice.
String describeNetworkError(Object error) {
  // http envuelve los errores de socket/TLS; hay que mirar la causa de dentro.
  final e = (error is http.ClientException) ? (error.toString()) : error;

  if (error is TimeoutException) {
    return 'El servidor no respondió a tiempo.\n\nLa red puede estar muy lenta o '
        'estar filtrando la conexión. Prueba con datos móviles.';
  }

  // TLS: típico de redes que inspeccionan el tráfico (proxy de universidad o
  // empresa) o de un portal cautivo que devuelve su propia página de login.
  // Ojo: Dart NO usa los certificados del sistema Android, así que esto falla
  // aunque el navegador del dispositivo sí abra la web.
  if (error is HandshakeException ||
      error is CertificateException ||
      error is TlsException ||
      _has(e, 'handshake') ||
      _has(e, 'certificate')) {
    return 'Esta red rechazó la conexión segura.\n\nSuele pasar en WiFi de '
        'universidades o empresas que inspeccionan el tráfico, o cuando falta '
        'iniciar sesión en el portal del WiFi. Abre el navegador para iniciar '
        'sesión en la red, o usa datos móviles.';
  }

  if (error is SocketException || error is http.ClientException) {
    if (_has(e, 'failed host lookup') ||
        _has(e, 'no address associated with hostname') ||
        _has(e, 'nodename nor servname')) {
      return 'No se encontró el servidor de PawFinder.\n\nEstás sin internet, o '
          'esta red bloquea el dominio (frecuente en WiFi de universidades). '
          'Revisa tu conexión o usa datos móviles.';
    }
    if (_has(e, 'network is unreachable')) {
      return 'No hay conexión a internet.\n\nActiva el WiFi o los datos móviles.';
    }
    if (_has(e, 'connection refused')) {
      return 'El servidor rechazó la conexión.\n\nPuede estar caído o en '
          'mantenimiento. Inténtalo en unos minutos.';
    }
    if (_has(e, 'connection reset') || _has(e, 'broken pipe')) {
      return 'La conexión se cortó a mitad.\n\nLa red puede ser inestable o '
          'estar bloqueando la app. Prueba con datos móviles.';
    }
    if (_has(e, 'timed out')) {
      return 'Se agotó el tiempo de espera al conectar.\n\nLa red puede estar '
          'muy lenta o filtrando la conexión. Prueba con datos móviles.';
    }
    return 'No se pudo conectar con el servidor.\n\nRevisa tu conexión a '
        'internet; si estás en un WiFi público puede estar bloqueando la app.';
  }

  // No es de red: mensaje del backend (credenciales, validación...). Se muestra
  // tal cual, pero sin el prefijo "Exception: " que Dart le pega delante.
  return error.toString().replaceFirst('Exception: ', '');
}

/// true si el error es de red (y no una respuesta de negocio del backend).
bool isNetworkError(Object error) =>
    error is SocketException ||
    error is http.ClientException ||
    error is TimeoutException ||
    error is TlsException;

bool _has(Object e, String needle) =>
    e.toString().toLowerCase().contains(needle);
