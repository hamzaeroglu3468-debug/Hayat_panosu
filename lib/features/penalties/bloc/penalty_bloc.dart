import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/hive_service.dart';
import 'penalty_event.dart';
import 'penalty_state.dart';

class PenaltyBloc extends Bloc<PenaltyEvent, PenaltyState> {
  PenaltyBloc() : super(PenaltyInitialState()) {
    on<LoadPenaltiesEvent>(_onLoadPenalties);
    on<AddPenaltyEvent>(_onAddPenalty);
    on<ResolvePenaltyEvent>(_onResolvePenalty);
    on<DeletePenaltyEvent>(_onDeletePenalty);
  }

  void _onLoadPenalties(LoadPenaltiesEvent event, Emitter<PenaltyState> emit) {
    try {
      emit(PenaltyLoadingState());
      final penalties = HiveService.getPenalties();
      emit(PenaltyLoadedState(penalties));
    } catch (e) {
      emit(PenaltyErrorState(e.toString()));
    }
  }

  Future<void> _onAddPenalty(
      AddPenaltyEvent event, Emitter<PenaltyState> emit) async {
    try {
      await HiveService.savePenalty(event.penalty);
      emit(PenaltyLoadedState(HiveService.getPenalties()));
    } catch (e) {
      emit(PenaltyErrorState(e.toString()));
    }
  }

  Future<void> _onResolvePenalty(
      ResolvePenaltyEvent event, Emitter<PenaltyState> emit) async {
    try {
      final list = HiveService.getPenalties();
      final idx = list.indexWhere((p) => p.id == event.penaltyId);
      if (idx != -1) {
        final current = list[idx];
        final updated = current.copyWith(
          isResolved: !current.isResolved,
          resolvedAt: current.isResolved ? null : DateTime.now(),
        );
        await HiveService.savePenalty(updated);
        emit(PenaltyLoadedState(HiveService.getPenalties()));
      }
    } catch (e) {
      emit(PenaltyErrorState(e.toString()));
    }
  }

  Future<void> _onDeletePenalty(
      DeletePenaltyEvent event, Emitter<PenaltyState> emit) async {
    try {
      await HiveService.deletePenalty(event.penaltyId);
      emit(PenaltyLoadedState(HiveService.getPenalties()));
    } catch (e) {
      emit(PenaltyErrorState(e.toString()));
    }
  }
}
