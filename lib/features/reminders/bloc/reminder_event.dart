import 'package:equatable/equatable.dart';
import '../models/reminder_model.dart';

abstract class ReminderEvent extends Equatable {
  const ReminderEvent();

  @override
  List<Object?> get props => [];
}

class LoadRemindersEvent extends ReminderEvent {}

class AddReminderEvent extends ReminderEvent {
  final ReminderModel reminder;
  const AddReminderEvent(this.reminder);

  @override
  List<Object?> get props => [reminder];
}

class ToggleReminderImportantEvent extends ReminderEvent {
  final String reminderId;
  const ToggleReminderImportantEvent(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class ToggleReminderDoneEvent extends ReminderEvent {
  final String reminderId;
  const ToggleReminderDoneEvent(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}

class DeleteReminderEvent extends ReminderEvent {
  final String reminderId;
  const DeleteReminderEvent(this.reminderId);

  @override
  List<Object?> get props => [reminderId];
}
