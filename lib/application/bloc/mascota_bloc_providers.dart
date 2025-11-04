import 'package:flutter_bloc/flutter_bloc.dart';
import 'mascota_bloc.dart';
import '../usecases/get_mascotas.dart';
import '../usecases/add_mascota.dart';
import '../usecases/reportar_mascota.dart';
import '../../infrastructure/repositories/mascota_repository_impl.dart';
import '../../infrastructure/data_sources/mascota_mock_data_source.dart';

List<BlocProvider> get mascotaBlocProviders {
  // Instancias de dependencias
  final mockDataSource = MascotaMockDataSource();
  final repository = MascotaRepositoryImpl(mockDataSource);
  
  // Casos de uso
  final getMascotas = GetMascotas(repository);
  final addMascota = AddMascota(repository);
  final reportarMascota = ReportarMascota(repository);

  return [
    BlocProvider<MascotaBloc>(
      create: (context) => MascotaBloc(
        getMascotas: getMascotas,
        addMascota: addMascota,
        reportarMascota: reportarMascota,
      ),
    ),
  ];
}