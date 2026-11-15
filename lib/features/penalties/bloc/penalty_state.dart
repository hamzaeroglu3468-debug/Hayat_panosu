import 'package:equatable/equatable.dart';
import '../models/penalty_model.dart';

abstract class PenaltyState extends Equatable {
  const PenaltyState();

  @override
  List<Object?> get props => [];
}

class PenaltyInitialState extends PenaltyState {}

class PenaltyLoadingState extends PenaltyState {}

class PenaltyLoadedState extends PenaltyState {
  final List<PenaltyModel> penalties;

  const PenaltyLoadedState(this.penalties);

  int get unresolvedCount => penalties.where((p) => !p.isResolved).length;
  List<PenaltyModel> get activePenalties =>
      penalties.where((p) => !p.isResolved).toList();

  @override
  List<Object?> get props => [penalties];
}

class PenaltyErrorState extends PenaltyState {
  final String message;
  const PenaltyErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
