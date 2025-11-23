import 'package:equatable/equatable.dart';

abstract class PetsEvent extends Equatable {
  const PetsEvent();

  @override
  List<Object?> get props => [];
}

class FetchPets extends PetsEvent {
  final int? categoryId;
  const FetchPets({this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

class RefreshPets extends PetsEvent {}
