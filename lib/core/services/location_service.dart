/// Ubicación del usuario, para buscar veterinarias cerca.
///
/// Envuelve geolocator en un único sitio y devuelve mensajes ya escritos para
/// enseñar al usuario: cada motivo de fallo (GPS apagado, permiso denegado,
/// permiso bloqueado para siempre) necesita una salida distinta y es fácil
/// tratarlos todos como "no se pudo".
library;

import 'package:geolocator/geolocator.dart';
import '../utils/logger.dart';

class LocationService {
  /// Devuelve (posición, error). Uno de los dos siempre es null.
  Future<(Position?, String?)> posicionActual() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return (
          null,
          'Activa la ubicación del teléfono para ver las veterinarias cercanas',
        );
      }

      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        return (
          null,
          'Necesito permiso de ubicación para buscar veterinarias cerca de ti',
        );
      }

      // deniedForever: pedirlo otra vez ya no abre el diálogo del sistema,
      // hay que mandar al usuario a los ajustes.
      if (permiso == LocationPermission.deniedForever) {
        return (
          null,
          'El permiso de ubicación está bloqueado. Actívalo en los ajustes del teléfono.',
        );
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return (posicion, null);
    } catch (e) {
      Logger.debug('❌ Error obteniendo la ubicación: $e');
      return (null, 'No se pudo obtener tu ubicación. Inténtalo de nuevo.');
    }
  }
}
