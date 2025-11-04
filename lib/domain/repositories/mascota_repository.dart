import '../entities/mascota.dart';

abstract class MascotaRepository {
  Future<List<Mascota>> getMascotas();
  Future<void> addMascota(Mascota mascota);
  Future<void> reportarMascotaEnRiesgo(String id, String categoria);
  Future<void> marcarMascotaFueraDeRiesgo(String id);
}
