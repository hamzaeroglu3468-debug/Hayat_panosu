import 'package:equatable/equatable.dart';
import '../models/reminder_model.dart';

abstract class ReminderState extends Equatable {
  const ReminderState();

  @override
  List<Object?> get props => [];
}

class ReminderInitialState extends ReminderState {}

class ReminderLoadingState extends ReminderState {}

class ReminderLoadedState extends ReminderState {
  final List<ReminderModel> reminders;

  const ReminderLoadedState(this.reminders);

  List<ReminderModel> get importantReminders =>
      reminders.where((r) => r.isImportant && !r.isDone).toList();

  int get importantCount => importantReminders.length;

  bool get hasActiveImportant => importantCount > 0;

  @override
  List<Object?> get props => [reminders];
}

class ReminderErrorState extends ReminderState {
  final String message;
  const ReminderErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
