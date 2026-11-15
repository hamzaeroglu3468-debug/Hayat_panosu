import 'package:equatable/equatable.dart';
import '../models/weekly_plan_item_model.dart';

abstract class WeeklyPlannerEvent extends Equatable {
  const WeeklyPlannerEvent();

  @override
  List<Object?> get props => [];
}

class LoadWeeklyPlansEvent extends WeeklyPlannerEvent {}

class SelectWeekdayEvent extends WeeklyPlannerEvent {
  final int dayOfWeek; // 1 = Pazartesi ... 7 = Pazar
  const SelectWeekdayEvent(this.dayOfWeek);

  @override
  List<Object?> get props => [dayOfWeek];
}

class AddWeeklyPlanItemEvent extends WeeklyPlannerEvent {
  final WeeklyPlanItemModel item;
  const AddWeeklyPlanItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class UpdateWeeklyPlanItemEvent extends WeeklyPlannerEvent {
  final WeeklyPlanItemModel item;
  const UpdateWeeklyPlanItemEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class ToggleWeeklyPlanSyncEvent extends WeeklyPlannerEvent {
  final String itemId;
  const ToggleWeeklyPlanSyncEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ToggleWeeklyPlanCompletionEvent extends WeeklyPlannerEvent {
  final String itemId;
  const ToggleWeeklyPlanCompletionEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ToggleWeeklyPlanImportanceEvent extends WeeklyPlannerEvent {
  final String itemId;
  const ToggleWeeklyPlanImportanceEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class DeleteWeeklyPlanItemEvent extends WeeklyPlannerEvent {
  final String itemId;
  const DeleteWeeklyPlanItemEvent(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
