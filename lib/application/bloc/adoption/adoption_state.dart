import 'package:equatable/equatable.dart';

abstract class AdoptionState extends Equatable {
  const AdoptionState();

  @override
  List<Object?> get props => [];
}

class AdoptionInitial extends AdoptionState {
  const AdoptionInitial();
}

class AdoptionLoading extends AdoptionState {
  const AdoptionLoading();
}

class AdoptionLoaded extends AdoptionState {
  const AdoptionLoaded(this.adoptionRequests);
  
  final List<dynamic> adoptionRequests;

  @override
  List<Object?> get props => [adoptionRequests];
}

class AdoptionCreated extends AdoptionState {
  const AdoptionCreated(this.request);
  
  final dynamic request;

  @override
  List<Object?> get props => [request];
}

class AdoptionUpdated extends AdoptionState {
  const AdoptionUpdated(this.request);
  
  final dynamic request;

  @override
  List<Object?> get props => [request];
}

class AdoptionDeleted extends AdoptionState {
  const AdoptionDeleted(this.requestId);
  
  final int requestId;

  @override
  List<Object?> get props => [requestId];
}

class AdoptionError extends AdoptionState {
  const AdoptionError(this.message);
  
  final String message;

  @override
  List<Object?> get props => [message];
}
