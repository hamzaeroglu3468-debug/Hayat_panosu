import 'package:equatable/equatable.dart';
import '../models/weekly_plan_item_model.dart';

abstract class WeeklyPlannerState extends Equatable {
  const WeeklyPlannerState();

  @override
  List<Object?> get props => [];
}

class WeeklyPlannerInitialState extends WeeklyPlannerState {}

class WeeklyPlannerLoadingState extends WeeklyPlannerState {}

class WeeklyPlannerLoadedState extends WeeklyPlannerState {
  final List<WeeklyPlanItemModel> items;
  final int selectedDayOfWeek;

  const WeeklyPlannerLoadedState({
    required this.items,
    required this.selectedDayOfWeek,
  });

  List<WeeklyPlanItemModel> itemsForDay(int day) {
    final filtered = items.where((i) => i.dayOfWeek == day).toList();
    filtered.sort((a, b) => a.startTime.compareTo(b.startTime));
    return filtered;
  }

  List<WeeklyPlanItemModel> get selectedDayItems => itemsForDay(selectedDayOfWeek);

  List<WeeklyPlanItemModel> get todayItems =>
      itemsForDay(DateTime.now().weekday);

  List<WeeklyPlanItemModel> get importantItems =>
      items.where((i) => i.isImportant).toList();

  Map<String, List<WeeklyPlanItemModel>> itemsGroupedByBlock(int day) {
    final dayItems = itemsForDay(day);
    final Map<String, List<WeeklyPlanItemModel>> grouped = {};
    for (final item in dayItems) {
      grouped.putIfAbsent(item.timeBlock, () => []).add(item);
    }
    return grouped;
  }

  WeeklyPlannerLoadedState copyWith({
    List<WeeklyPlanItemModel>? items,
    int? selectedDayOfWeek,
  }) {
    return WeeklyPlannerLoadedState(
      items: items ?? this.items,
      selectedDayOfWeek: selectedDayOfWeek ?? this.selectedDayOfWeek,
    );
  }

  @override
  List<Object?> get props => [items, selectedDayOfWeek];
}

class WeeklyPlannerErrorState extends WeeklyPlannerState {
  final String message;
  const WeeklyPlannerErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
