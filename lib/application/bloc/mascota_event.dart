import '../../domain/entities/mascota.dart';

abstract class MascotaEvent {}

class LoadMascotas extends MascotaEvent {}

class AddMascotaEvent extends MascotaEvent {
  final Mascota mascota;
  AddMascotaEvent(this.mascota);
}

class ReportarMascotaRiesgoEvent extends MascotaEvent {
  final String id;
  final String categoria;
  ReportarMascotaRiesgoEvent(this.id, this.categoria);
}

class MarcarMascotaFueraRiesgoEvent extends MascotaEvent {
  final String id;
  MarcarMascotaFueraRiesgoEvent(this.id);
}
