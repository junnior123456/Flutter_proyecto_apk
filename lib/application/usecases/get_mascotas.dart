import '../../domain/entities/mascota.dart';
import '../../domain/repositories/mascota_repository.dart';

class GetMascotas {
  final MascotaRepository repository;
  GetMascotas(this.repository);

  Future<List<Mascota>> call() async {
    return await repository.getMascotas();
  }
}
