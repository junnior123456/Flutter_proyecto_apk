import 'package:flutter_bloc/flutter_bloc.dart';
import 'pets_event.dart';
import 'pets_state.dart';
import '../../../core/services/pet_service.dart';

class PetsBloc extends Bloc<PetsEvent, PetsState> {
  final PetService _petService = PetService();

  PetsBloc() : super(PetsInitial()) {
    on<FetchPets>(_onFetchPets);
    on<RefreshPets>(_onRefreshPets);
  }

  Future<void> _onFetchPets(FetchPets event, Emitter<PetsState> emit) async {
    emit(PetsLoading());
    try {
      final pets = await _petService.getAllPets(categoryId: event.categoryId);
      emit(PetsLoaded(pets));
    } catch (e) {
      emit(PetsError(e.toString()));
    }
  }

  Future<void> _onRefreshPets(RefreshPets event, Emitter<PetsState> emit) async {
    try {
      final pets = await _petService.getAllPets();
      emit(PetsLoaded(pets));
    } catch (e) {
      emit(PetsError(e.toString()));
    }
  }
}
