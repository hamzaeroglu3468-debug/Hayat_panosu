import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/hive_service.dart';
import 'reminder_event.dart';
import 'reminder_state.dart';

class ReminderBloc extends Bloc<ReminderEvent, ReminderState> {
  ReminderBloc() : super(ReminderInitialState()) {
    on<LoadRemindersEvent>(_onLoadReminders);
    on<AddReminderEvent>(_onAddReminder);
    on<ToggleReminderImportantEvent>(_onToggleImportant);
    on<ToggleReminderDoneEvent>(_onToggleDone);
    on<DeleteReminderEvent>(_onDeleteReminder);
  }

  void _onLoadReminders(
    LoadRemindersEvent event,
    Emitter<ReminderState> emit,
  ) {
    try {
      emit(ReminderLoadingState());
      final reminders = HiveService.getReminders();
      emit(ReminderLoadedState(reminders));
    } catch (e) {
      emit(ReminderErrorState(e.toString()));
    }
  }

  Future<void> _onAddReminder(
    AddReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await HiveService.saveReminder(event.reminder);
      emit(ReminderLoadedState(HiveService.getReminders()));
    } catch (e) {
      emit(ReminderErrorState(e.toString()));
    }
  }

  Future<void> _onToggleImportant(
    ToggleReminderImportantEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final list = HiveService.getReminders();
      final idx = list.indexWhere((r) => r.id == event.reminderId);
      if (idx != -1) {
        final updated = list[idx].copyWith(isImportant: !list[idx].isImportant);
        await HiveService.saveReminder(updated);
        emit(ReminderLoadedState(HiveService.getReminders()));
      }
    } catch (e) {
      emit(ReminderErrorState(e.toString()));
    }
  }

  Future<void> _onToggleDone(
    ToggleReminderDoneEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      final list = HiveService.getReminders();
      final idx = list.indexWhere((r) => r.id == event.reminderId);
      if (idx != -1) {
        final updated = list[idx].copyWith(isDone: !list[idx].isDone);
        await HiveService.saveReminder(updated);
        emit(ReminderLoadedState(HiveService.getReminders()));
      }
    } catch (e) {
      emit(ReminderErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteReminder(
    DeleteReminderEvent event,
    Emitter<ReminderState> emit,
  ) async {
    try {
      await HiveService.deleteReminder(event.reminderId);
      emit(ReminderLoadedState(HiveService.getReminders()));
    } catch (e) {
      emit(ReminderErrorState(e.toString()));
    }
  }
}
