import '../../domain/repositories/mascota_repository.dart';

class ReportarMascota {
  final MascotaRepository repository;
  ReportarMascota(this.repository);

  Future<void> call(String id, String categoria) async {
    await repository.reportarMascotaEnRiesgo(id, categoria);
  }

  Future<void> marcarFueraDeRiesgo(String id) async {
    await repository.marcarMascotaFueraDeRiesgo(id);
  }
}
