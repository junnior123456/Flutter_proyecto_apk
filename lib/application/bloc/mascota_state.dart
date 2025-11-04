import '../../domain/entities/mascota.dart';

abstract class MascotaState {}

class MascotaInitial extends MascotaState {}
class MascotaLoading extends MascotaState {}
class MascotaLoaded extends MascotaState {
  final List<Mascota> mascotas;
  MascotaLoaded(this.mascotas);
}
class MascotaError extends MascotaState {
  final String message;
  MascotaError(this.message);
}
