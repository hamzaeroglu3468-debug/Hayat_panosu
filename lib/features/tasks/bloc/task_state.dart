import 'package:equatable/equatable.dart';
import '../models/task_model.dart';

abstract class TaskState extends Equatable {
  const TaskState();

  @override
  List<Object?> get props => [];
}

class TaskInitialState extends TaskState {}

class TaskLoadingState extends TaskState {}

class TaskLoadedState extends TaskState {
  final List<TaskModel> tasks;

  const TaskLoadedState(this.tasks);

  int get completedCount => tasks.where((t) => t.isCompleted).length;
  int get pendingCount => tasks.where((t) => !t.isCompleted).length;
  double get progress => tasks.isEmpty ? 0.0 : (completedCount / tasks.length);

  @override
  List<Object?> get props => [tasks];
}

class TaskErrorState extends TaskState {
  final String message;
  const TaskErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
