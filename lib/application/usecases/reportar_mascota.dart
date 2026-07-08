import '../../domain/repositories/mascota_repository.dart';

class ReportarMascota {
  final MascotaRepository repository;
  ReportarMascota(this.repository);

  Future<void> call(String id, String categoria) async {
    return await repository.reportarMascotaEnRiesgo(id, categoria);
  }

  Future<void> marcarFueraDeRiesgo(String id) async {
    return await repository.marcarMascotaFueraDeRiesgo(id);
  }
}
