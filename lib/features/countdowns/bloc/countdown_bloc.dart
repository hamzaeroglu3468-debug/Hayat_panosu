import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/hive_service.dart';
import 'countdown_event.dart';
import 'countdown_state.dart';

class CountdownBloc extends Bloc<CountdownEvent, CountdownState> {
  CountdownBloc() : super(CountdownInitialState()) {
    on<LoadCountdownsEvent>(_onLoadCountdowns);
    on<AddCountdownEvent>(_onAddCountdown);
    on<DeleteCountdownEvent>(_onDeleteCountdown);
  }

  void _onLoadCountdowns(
      LoadCountdownsEvent event, Emitter<CountdownState> emit) {
    try {
      emit(CountdownLoadingState());
      final countdowns = HiveService.getCountdowns();
      emit(CountdownLoadedState(countdowns));
    } catch (e) {
      emit(CountdownErrorState(e.toString()));
    }
  }

  Future<void> _onAddCountdown(
      AddCountdownEvent event, Emitter<CountdownState> emit) async {
    try {
      await HiveService.saveCountdown(event.countdown);
      emit(CountdownLoadedState(HiveService.getCountdowns()));
    } catch (e) {
      emit(CountdownErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteCountdown(
      DeleteCountdownEvent event, Emitter<CountdownState> emit) async {
    try {
      await HiveService.deleteCountdown(event.countdownId);
      emit(CountdownLoadedState(HiveService.getCountdowns()));
    } catch (e) {
      emit(CountdownErrorState(e.toString()));
    }
  }
}
