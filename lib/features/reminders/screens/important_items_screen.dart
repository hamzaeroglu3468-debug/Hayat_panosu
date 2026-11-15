import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../tasks/bloc/task_state.dart';
import '../../weekly_planner/bloc/weekly_planner_bloc.dart';
import '../../weekly_planner/bloc/weekly_planner_event.dart';
import '../../weekly_planner/bloc/weekly_planner_state.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_event.dart';
import '../bloc/reminder_state.dart';

class ImportantItemsScreen extends StatelessWidget {
  const ImportantItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.priority_high_rounded, color: AppColors.important),
            SizedBox(width: 8),
            Text('Önemli Sayfası (!)'),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppColors.alertGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_rounded, color: Colors.white, size: 36),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Öncelikli & Kritik Maddeler',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Günlük görevler, haftalık program blokları ve hatırlatıcılardan (!) olarak işaretlenenler burada toplanır.',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 1: Important Reminders
          const Text(
            'Önemli Hatırlatıcılar',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              if (state is ReminderLoadedState) {
                final list =
                    state.reminders.where((r) => r.isImportant).toList();
                if (list.isEmpty) {
                  return _emptyNotice(
                      'Önemli olarak işaretlenmiş hatırlatıcı bulunmuyor.');
                }
                return Column(
                  children: list.map((reminder) {
                    final isDue = reminder.dueDate.isBefore(DateTime.now());
                    final dateStr =
                        DateFormat('dd.MM.yyyy HH:mm', 'tr_TR').format(reminder.dueDate);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            reminder.isDone
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: reminder.isDone
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                          onPressed: () {
                            context
                                .read<ReminderBloc>()
                                .add(ToggleReminderDoneEvent(reminder.id));
                          },
                        ),
                        title: Text(
                          reminder.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: reminder.isDone
                                ? TextDecoration.lineThrough
                                : null,
                            color: reminder.isDone
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reminder.note != null) Text(reminder.note!),
                            const SizedBox(height: 4),
                            Text(
                              'Son Tarih: $dateStr',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDue
                                    ? AppColors.danger
                                    : AppColors.textMuted,
                                fontWeight: isDue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          tooltip: 'Önemliden Çıkar',
                          icon: const Icon(Icons.bookmark_remove_rounded,
                              color: AppColors.important),
                          onPressed: () {
                            context.read<ReminderBloc>().add(
                                ToggleReminderImportantEvent(reminder.id));
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),

          const SizedBox(height: 24),

          // Section 2: Important Daily Tasks
          const Text(
            'Önemli Günlük Görevler',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<TaskBloc, TaskState>(
            builder: (context, state) {
              if (state is TaskLoadedState) {
                final list = state.tasks.where((t) => t.isImportant).toList();
                if (list.isEmpty) {
                  return _emptyNotice(
                      'Önemli olarak işaretlenmiş günlük görev bulunmuyor.');
                }
                return Column(
                  children: list.map((task) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: IconButton(
                          icon: Icon(
                            task.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: task.isCompleted
                                ? AppColors.success
                                : AppColors.textMuted,
                          ),
                          onPressed: () {
                            context
                                .read<TaskBloc>()
                                .add(ToggleTaskCompletionEvent(task.id));
                            context
                                .read<WeeklyPlannerBloc>()
                                .add(LoadWeeklyPlansEvent());
                          },
                        ),
                        title: Text(
                          task.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.isCompleted
                                ? AppColors.textMuted
                                : AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                          '${task.formattedTimeRange} • ${task.category}${task.isFromWeeklyPlan ? " (Haftalık Plandan)" : ""}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Önemliden Çıkar',
                          icon: const Icon(Icons.priority_high_rounded,
                              color: AppColors.important),
                          onPressed: () {
                            context
                                .read<TaskBloc>()
                                .add(ToggleTaskImportanceEvent(task.id));
                            context
                                .read<WeeklyPlannerBloc>()
                                .add(LoadWeeklyPlansEvent());
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),

          const SizedBox(height: 24),

          // Section 3: Important Weekly Program Blocks
          const Text(
            'Önemli Haftalık Program Blokları',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          BlocBuilder<WeeklyPlannerBloc, WeeklyPlannerState>(
            builder: (context, state) {
              if (state is WeeklyPlannerLoadedState) {
                final list = state.importantItems;
                if (list.isEmpty) {
                  return _emptyNotice(
                      'Haftalık programda önemli olarak işaretlenmiş blok bulunmuyor.');
                }
                return Column(
                  children: list.map((item) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.shortDayName,
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Text(
                            '${item.formattedTimeRange} • ${item.timeBlock} • ${item.category}'),
                        trailing: IconButton(
                          tooltip: 'Önemliden Çıkar',
                          icon: const Icon(Icons.bookmark_remove_rounded,
                              color: AppColors.important),
                          onPressed: () {
                            context.read<WeeklyPlannerBloc>().add(
                                ToggleWeeklyPlanImportanceEvent(item.id));
                            context.read<TaskBloc>().add(LoadTasksEvent());
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  Widget _emptyNotice(String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
      ),
    );
  }
}
