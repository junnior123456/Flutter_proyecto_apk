/// Enlaces a los documentos legales de PawFinder.
///
/// Google Play exige que la política de privacidad y la vía para borrar los
/// datos estén en una URL pública accesible fuera de la app, no sólo dentro.
/// Se sirven como HTML estático desde el propio servidor.
class LegalLinks {
  static const String base = 'http://167.99.4.161/legal';

  static const String indice = '$base/index.html';
  static const String privacidad = '$base/privacidad.html';
  static const String terminos = '$base/terminos.html';
  static const String copyright = '$base/copyright.html';
  static const String avisoIa = '$base/ia.html';
  static const String eliminarCuenta = '$base/eliminar-cuenta.html';

  /// Correo del agente de derechos de autor (notificaciones de retiro).
  static const String correoCopyright = 'copyright@tudominio.com';
  static const String correoPrivacidad = 'privacidad@tudominio.com';
}
