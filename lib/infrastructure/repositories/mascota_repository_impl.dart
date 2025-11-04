import '../../domain/entities/mascota.dart';
import '../../domain/repositories/mascota_repository.dart';
import '../data_sources/mascota_mock_data_source.dart';

class MascotaRepositoryImpl implements MascotaRepository {
  final MascotaMockDataSource dataSource;
  MascotaRepositoryImpl(this.dataSource);

  @override
  Future<List<Mascota>> getMascotas() async {
    return dataSource.getMascotas();
  }

  @override
  Future<void> addMascota(Mascota mascota) async {
    dataSource.addMascota(mascota);
  }

  @override
  Future<void> reportarMascotaEnRiesgo(String id, String categoria) async {
    dataSource.reportarMascotaEnRiesgo(id, categoria);
  }

  @override
  Future<void> marcarMascotaFueraDeRiesgo(String id) async {
    dataSource.marcarMascotaFueraDeRiesgo(id);
  }
}
