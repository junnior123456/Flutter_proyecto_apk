import 'package:flutter_bloc/flutter_bloc.dart';
// ...existing code...
import '../usecases/get_mascotas.dart';
import '../usecases/add_mascota.dart';
import '../usecases/reportar_mascota.dart';
import 'mascota_event.dart';
import 'mascota_state.dart';

class MascotaBloc extends Bloc<MascotaEvent, MascotaState> {
  final GetMascotas getMascotas;
  final AddMascota addMascota;
  final ReportarMascota reportarMascota;

  MascotaBloc({
    required this.getMascotas,
    required this.addMascota,
    required this.reportarMascota,
  }) : super(MascotaInitial()) {
    on<LoadMascotas>((event, emit) async {
      emit(MascotaLoading());
      try {
        final mascotas = await getMascotas();
        emit(MascotaLoaded(mascotas));
      } catch (e) {
        emit(MascotaError('Error al cargar mascotas'));
      }
    });

    on<AddMascotaEvent>((event, emit) async {
      emit(MascotaLoading());
      try {
        await addMascota(event.mascota);
        final mascotas = await getMascotas();
        emit(MascotaLoaded(mascotas));
      } catch (e) {
        emit(MascotaError('Error al agregar mascota'));
      }
    });

    on<ReportarMascotaRiesgoEvent>((event, emit) async {
      emit(MascotaLoading());
      try {
        await reportarMascota(event.id, event.categoria);
        final mascotas = await getMascotas();
        emit(MascotaLoaded(mascotas));
      } catch (e) {
        emit(MascotaError('Error al reportar mascota'));
      }
    });

    on<MarcarMascotaFueraRiesgoEvent>((event, emit) async {
      try {
        await reportarMascota.marcarFueraDeRiesgo(event.id);
        final mascotas = await getMascotas();
        emit(MascotaLoaded(mascotas));
      } catch (e) {
        emit(MascotaError('Error al marcar mascota fuera de riesgo'));
      }
    });
  }
}
