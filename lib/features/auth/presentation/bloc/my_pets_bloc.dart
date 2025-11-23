import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../domain/entities/pet.dart';
import '../../../../core/services/my_pets_service.dart';

// Events
abstract class MyPetsEvent extends Equatable {
  const MyPetsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyPets extends MyPetsEvent {}

class UpdatePet extends MyPetsEvent {
  final int petId;
  final Map<String, dynamic> updateData;

  const UpdatePet({required this.petId, required this.updateData});

  @override
  List<Object?> get props => [petId, updateData];
}

class DeletePet extends MyPetsEvent {
  final int petId;

  const DeletePet({required this.petId});

  @override
  List<Object?> get props => [petId];
}

class RefreshMyPets extends MyPetsEvent {}

class AddNewPet extends MyPetsEvent {
  final Pet pet;

  const AddNewPet({required this.pet});

  @override
  List<Object?> get props => [pet];
}

// States
abstract class MyPetsState extends Equatable {
  const MyPetsState();

  @override
  List<Object?> get props => [];
}

class MyPetsInitial extends MyPetsState {}

class MyPetsLoading extends MyPetsState {}

class MyPetsLoaded extends MyPetsState {
  final List<Pet> pets;

  const MyPetsLoaded({required this.pets});

  @override
  List<Object?> get props => [pets];
}

class MyPetsError extends MyPetsState {
  final String message;

  const MyPetsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class MyPetsOperationSuccess extends MyPetsState {
  final String message;
  final List<Pet> pets;

  const MyPetsOperationSuccess({required this.message, required this.pets});

  @override
  List<Object?> get props => [message, pets];
}

// BLoC
class MyPetsBloc extends Bloc<MyPetsEvent, MyPetsState> {
  final MyPetsService _myPetsService;

  MyPetsBloc({required MyPetsService myPetsService})
      : _myPetsService = myPetsService,
        super(MyPetsInitial()) {
    on<LoadMyPets>(_onLoadMyPets);
    on<UpdatePet>(_onUpdatePet);
    on<DeletePet>(_onDeletePet);
    on<RefreshMyPets>(_onRefreshMyPets);
    on<AddNewPet>(_onAddNewPet);
  }

  Future<void> _onLoadMyPets(LoadMyPets event, Emitter<MyPetsState> emit) async {
    emit(MyPetsLoading());
    try {
      final pets = await _myPetsService.getMyPets();
      emit(MyPetsLoaded(pets: pets));
    } catch (e) {
      emit(MyPetsError(message: 'Error al cargar mascotas: ${e.toString()}'));
    }
  }

  Future<void> _onUpdatePet(UpdatePet event, Emitter<MyPetsState> emit) async {
    try {
      await _myPetsService.updatePet(event.petId, event.updateData);
      final pets = await _myPetsService.getMyPets();
      emit(MyPetsOperationSuccess(
        message: 'Mascota actualizada correctamente',
        pets: pets,
      ));
    } catch (e) {
      emit(MyPetsError(message: 'Error al actualizar mascota: ${e.toString()}'));
    }
  }

  Future<void> _onDeletePet(DeletePet event, Emitter<MyPetsState> emit) async {
    try {
      await _myPetsService.deletePet(event.petId);
      final pets = await _myPetsService.getMyPets();
      emit(MyPetsOperationSuccess(
        message: 'Mascota eliminada correctamente',
        pets: pets,
      ));
    } catch (e) {
      emit(MyPetsError(message: 'Error al eliminar mascota: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshMyPets(RefreshMyPets event, Emitter<MyPetsState> emit) async {
    try {
      final pets = await _myPetsService.getMyPets();
      emit(MyPetsLoaded(pets: pets));
    } catch (e) {
      emit(MyPetsError(message: 'Error al refrescar mascotas: ${e.toString()}'));
    }
  }

  Future<void> _onAddNewPet(AddNewPet event, Emitter<MyPetsState> emit) async {
    try {
      // Recargar todas las mascotas para obtener la lista actualizada
      final pets = await _myPetsService.getMyPets();
      emit(MyPetsOperationSuccess(
        message: 'Mascota publicada correctamente',
        pets: pets,
      ));
    } catch (e) {
      emit(MyPetsError(message: 'Error al cargar mascotas: ${e.toString()}'));
    }
  }
}