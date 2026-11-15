import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/database/hive_service.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  TaskBloc() : super(TaskInitialState()) {
    on<LoadTasksEvent>(_onLoadTasks);
    on<AddTaskEvent>(_onAddTask);
    on<UpdateTaskEvent>(_onUpdateTask);
    on<ToggleTaskCompletionEvent>(_onToggleTaskCompletion);
    on<ToggleTaskImportanceEvent>(_onToggleTaskImportance);
    on<DeleteTaskEvent>(_onDeleteTask);
  }

  void _onLoadTasks(LoadTasksEvent event, Emitter<TaskState> emit) {
    try {
      emit(TaskLoadingState());
      final tasks = HiveService.getTasks();
      emit(TaskLoadedState(tasks));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onAddTask(AddTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await HiveService.saveTask(event.task);
      final tasks = HiveService.getTasks();
      emit(TaskLoadedState(tasks));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTask(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await HiveService.saveTask(event.task);
      final tasks = HiveService.getTasks();
      emit(TaskLoadedState(tasks));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onToggleTaskCompletion(
      ToggleTaskCompletionEvent event, Emitter<TaskState> emit) async {
    try {
      final tasks = HiveService.getTasks();
      final index = tasks.indexWhere((t) => t.id == event.taskId);
      if (index != -1) {
        final current = tasks[index];
        final updated = current.copyWith(isCompleted: !current.isCompleted);
        await HiveService.saveTask(updated);
        emit(TaskLoadedState(HiveService.getTasks()));
      }
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onToggleTaskImportance(
      ToggleTaskImportanceEvent event, Emitter<TaskState> emit) async {
    try {
      final tasks = HiveService.getTasks();
      final index = tasks.indexWhere((t) => t.id == event.taskId);
      if (index != -1) {
        final current = tasks[index];
        final updated = current.copyWith(isImportant: !current.isImportant);
        await HiveService.saveTask(updated);
        emit(TaskLoadedState(HiveService.getTasks()));
      }
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }

  Future<void> _onDeleteTask(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await HiveService.deleteTask(event.taskId);
      final tasks = HiveService.getTasks();
      emit(TaskLoadedState(tasks));
    } catch (e) {
      emit(TaskErrorState(e.toString()));
    }
  }
}
