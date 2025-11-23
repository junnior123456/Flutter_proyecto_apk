import 'package:flutter_bloc/flutter_bloc.dart';
import 'mascota_bloc.dart';
import 'pets/pets_bloc.dart';
import 'adoption/adoption_bloc.dart';
import 'comments/comments_bloc.dart';
import 'notifications/notifications_bloc.dart';
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
    // Legacy MascotaBloc (keep for backward compatibility)
    BlocProvider<MascotaBloc>(
      create: (context) => MascotaBloc(
        getMascotas: getMascotas,
        addMascota: addMascota,
        reportarMascota: reportarMascota,
      ),
    ),
    
    // New BLoCs for Clean Architecture
    BlocProvider<PetsBloc>(
      create: (context) => PetsBloc(),
    ),
    
    BlocProvider<AdoptionBloc>(
      create: (context) => AdoptionBloc(),
    ),
    
    BlocProvider<CommentsBloc>(
      create: (context) => CommentsBloc(),
    ),
    
    BlocProvider<NotificationsBloc>(
      create: (context) => NotificationsBloc(),
    ),
  ];
}