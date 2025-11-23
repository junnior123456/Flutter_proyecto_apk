import 'package:equatable/equatable.dart';

abstract class AdoptionEvent extends Equatable {
  const AdoptionEvent();

  @override
  List<Object?> get props => [];
}

class FetchAdoptionRequests extends AdoptionEvent {
  const FetchAdoptionRequests({this.userId, this.status});
  
  final int? userId;
  final String? status;

  @override
  List<Object?> get props => [userId, status];
}

class CreateAdoptionRequest extends AdoptionEvent {
  const CreateAdoptionRequest({
    required this.petId,
    required this.adopterId,
    required this.notes,
  });
  
  final int petId;
  final int adopterId;
  final String notes;

  @override
  List<Object?> get props => [petId, adopterId, notes];
}

class UpdateAdoptionStatus extends AdoptionEvent {
  const UpdateAdoptionStatus({
    required this.requestId,
    required this.status,
  });
  
  final int requestId;
  final String status;

  @override
  List<Object?> get props => [requestId, status];
}

class DeleteAdoptionRequest extends AdoptionEvent {
  const DeleteAdoptionRequest(this.requestId);
  
  final int requestId;

  @override
  List<Object?> get props => [requestId];
}

class RefreshAdoptionRequests extends AdoptionEvent {
  const RefreshAdoptionRequests();
}
