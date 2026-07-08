import '../../domain/entities/mascota.dart';
import '../../domain/repositories/mascota_repository.dart';

class AddMascota {
  final MascotaRepository repository;
  AddMascota(this.repository);

  Future<void> call(Mascota mascota) async {
    await repository.addMascota(mascota);
  }
}
