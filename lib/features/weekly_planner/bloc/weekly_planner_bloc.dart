import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/hive_service.dart';
import 'weekly_planner_event.dart';
import 'weekly_planner_state.dart';

class WeeklyPlannerBloc extends Bloc<WeeklyPlannerEvent, WeeklyPlannerState> {
  WeeklyPlannerBloc() : super(WeeklyPlannerInitialState()) {
    on<LoadWeeklyPlansEvent>(_onLoadWeeklyPlans);
    on<SelectWeekdayEvent>(_onSelectWeekday);
    on<AddWeeklyPlanItemEvent>(_onAddWeeklyPlanItem);
    on<UpdateWeeklyPlanItemEvent>(_onUpdateWeeklyPlanItem);
    on<ToggleWeeklyPlanSyncEvent>(_onToggleSync);
    on<ToggleWeeklyPlanCompletionEvent>(_onToggleCompletion);
    on<ToggleWeeklyPlanImportanceEvent>(_onToggleImportance);
    on<DeleteWeeklyPlanItemEvent>(_onDeleteWeeklyPlanItem);
  }

  int get _currentSelectedDay {
    final s = state;
    if (s is WeeklyPlannerLoadedState) {
      return s.selectedDayOfWeek;
    }
    return DateTime.now().weekday;
  }

  void _onLoadWeeklyPlans(
      LoadWeeklyPlansEvent event, Emitter<WeeklyPlannerState> emit) {
    try {
      final selectedDay = _currentSelectedDay;
      final items = HiveService.getWeeklyPlans();
      emit(WeeklyPlannerLoadedState(
        items: items,
        selectedDayOfWeek: selectedDay,
      ));
    } catch (e) {
      emit(WeeklyPlannerErrorState(e.toString()));
    }
  }

  void _onSelectWeekday(
      SelectWeekdayEvent event, Emitter<WeeklyPlannerState> emit) {
    final s = state;
    if (s is WeeklyPlannerLoadedState) {
      emit(s.copyWith(selectedDayOfWeek: event.dayOfWeek));
    } else {
      emit(WeeklyPlannerLoadedState(
        items: HiveService.getWeeklyPlans(),
        selectedDayOfWeek: event.dayOfWeek,
      ));
    }
  }

  Future<void> _onAddWeeklyPlanItem(
      AddWeeklyPlanItemEvent event, Emitter<WeeklyPlannerState> emit) async {
    try {
      await HiveService.saveWeeklyPlan(event.item);
      emit(WeeklyPlannerLoadedState(
        items: HiveService.getWeeklyPlans(),
        selectedDayOfWeek: event.item.dayOfWeek,
      ));
    } catch (e) {
      emit(WeeklyPlannerErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateWeeklyPlanItem(
      UpdateWeeklyPlanItemEvent event, Emitter<WeeklyPlannerState> emit) async {
    try {
      await HiveService.saveWeeklyPlan(event.item);
      emit(WeeklyPlannerLoadedState(
        items: HiveService.getWeeklyPlans(),
        selectedDayOfWeek: _currentSelectedDay,
      ));
    } catch (e) {
      emit(WeeklyPlannerErrorState(e.toString()));
    }
  }

  Future<void> _onToggleSync(
      ToggleWeeklyPlanSyncEvent event, Emitter<WeeklyPlannerState> emit) async {
    try {
      final items = HiveService.getWeeklyPlans();
      final idx = items.indexWhere((i) => i.id == event.itemId);
      if (idx != -1) {
        final current = items[idx];
        final updated = current.copyWith(isSyncedToDaily: !current.isSyncedToDaily);
        await HiveService.saveWeeklyPlan(updated);
        emit(WeeklyPlannerLoadedState(
          items: HiveService.getWeeklyPlans(),
          selectedDayOfWeek: _currentSelectedDay,
        ));
      }
    } catch (e) {
      emit(WeeklyPlannerErrorState(e.toString()));
    }
  }

  Future<void> _onToggleCompletion(
      ToggleWeeklyPlanCompletionEvent event, Emitter<WeeklyPlannerState> emit) async {
    try {
      final items = HiveService.getWeeklyPlans();
      final idx = items.indexWhere((i) => i.id == event.itemId);
      if (idx != -1) {
        final current = items[idx];
        final updated = current.copyWith(isCompletedToday: !current.isCompletedToday);
        await HiveService.saveWeeklyPlan(updated);
        emit(WeeklyPlannerLoadedState(
          items: HiveService.getWeeklyPlans(),
          selectedDayOfWeek: _currentSelectedDay,
        ));
      }
    } catch (e) {
      emit(WeeklyPlannerErrorState(e.toString()));
    }
  }

  Future<void> _onToggleImportance(
      ToggleWeeklyPlanImportanceEvent event, Emitter<WeeklyPlannerState> emit) async {
    try {
      final items = HiveService.getWeeklyPlans();
      final idx = items.indexWhere((i) => i.id == event.itemId);
      if (idx != -1) {
        final current = items[idx];
        final updated = current.copyWith(isImportant: !current.isImportant);
        await HiveService.saveWeeklyPlan(updated);
        emit(WeeklyPlannerLoadedState(
          items: HiveService.getWeeklyPlans(),
          selectedDayOfWeek: _currentSelectedDay,
        ));
      }
    } catch (e) {
      emit(WeeklyPlannerErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteWeeklyPlanItem(
      DeleteWeeklyPlanItemEvent event, Emitter<WeeklyPlannerState> emit) async {
    try {
      await HiveService.deleteWeeklyPlan(event.itemId);
      emit(WeeklyPlannerLoadedState(
        items: HiveService.getWeeklyPlans(),
        selectedDayOfWeek: _currentSelectedDay,
      ));
    } catch (e) {
      emit(WeeklyPlannerErrorState(e.toString()));
    }
  }
}
