import 'package:equatable/equatable.dart';
import '../models/penalty_model.dart';

abstract class PenaltyEvent extends Equatable {
  const PenaltyEvent();

  @override
  List<Object?> get props => [];
}

class LoadPenaltiesEvent extends PenaltyEvent {}

class AddPenaltyEvent extends PenaltyEvent {
  final PenaltyModel penalty;
  const AddPenaltyEvent(this.penalty);

  @override
  List<Object?> get props => [penalty];
}

class ResolvePenaltyEvent extends PenaltyEvent {
  final String penaltyId;
  const ResolvePenaltyEvent(this.penaltyId);

  @override
  List<Object?> get props => [penaltyId];
}

class DeletePenaltyEvent extends PenaltyEvent {
  final String penaltyId;
  const DeletePenaltyEvent(this.penaltyId);

  @override
  List<Object?> get props => [penaltyId];
}
