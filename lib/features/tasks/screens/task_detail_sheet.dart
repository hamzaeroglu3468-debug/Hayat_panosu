import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../penalties/bloc/penalty_bloc.dart';
import '../../penalties/bloc/penalty_event.dart';
import '../../penalties/models/penalty_model.dart';
import '../../reminders/bloc/reminder_bloc.dart';
import '../../reminders/bloc/reminder_event.dart';
import '../../reminders/models/reminder_model.dart';
import '../../weekly_planner/bloc/weekly_planner_bloc.dart';
import '../../weekly_planner/bloc/weekly_planner_event.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../models/task_model.dart';

class TaskDetailSheet extends StatelessWidget {
  final TaskModel task;

  const TaskDetailSheet({super.key, required this.task});

  static void show(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TaskDetailSheet(task: task),
    );
  }

  void _syncWeeklyBloc(BuildContext context) {
    context.read<WeeklyPlannerBloc>().add(LoadWeeklyPlansEvent());
  }

  void _attachReminder(BuildContext context) {
    final now = DateTime.now();
    final newReminder = ReminderModel(
      id: const Uuid().v4(),
      title: '${task.title} (${task.formattedTimeRange})',
      note: task.reminderNote ??
          '${task.isFromWeeklyPlan ? "Haftalık Program" : "Günlük Akış"} görevi için otomatik oluşturulan alarm/hatırlatıcı.',
      dueDate: now.add(const Duration(hours: 2)),
      isImportant: task.isImportant,
      isDone: false,
      createdAt: now,
    );
    context.read<ReminderBloc>().add(AddReminderEvent(newReminder));

    final updatedTask = task.copyWith(
      hasReminder: true,
      reminderNote: 'Alarm & Hatırlatıcı Bağlandı (${task.time})',
    );
    context.read<TaskBloc>().add(UpdateTaskEvent(updatedTask));
    _syncWeeklyBloc(context);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.warning,
        content: Text(
          '"${task.title}" için hatırlatıcı ve alarm bağlandı!',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _triggerPenalty(BuildContext context) {
    final penaltyText = (task.penaltyNote != null && task.penaltyNote!.isNotEmpty)
        ? task.penaltyNote!
        : '25 Şınav veya 50 TL Ceza Kumbarasına';

    final penalty = PenaltyModel(
      id: const Uuid().v4(),
      title: '${task.title} Aksatıldı',
      penaltyAction: penaltyText,
      relatedTaskId: task.id,
      isResolved: false,
      createdAt: DateTime.now(),
    );

    context.read<PenaltyBloc>().add(AddPenaltyEvent(penalty));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.danger,
        content: Text(
          'Minik Ceza Kesildi: $penaltyText',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category, Source Badge & Importance Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  task.category,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (task.isFromWeeklyPlan)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.calendar_view_week_rounded,
                          color: AppColors.secondary, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Haftalık Programdan Senkronize',
                        style: TextStyle(
                          color: AppColors.secondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              if (task.isImportant)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.important.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.important.withValues(alpha: 0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.priority_high, color: AppColors.important, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'Önemli (!)',
                        style: TextStyle(
                          color: AppColors.important,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            task.title,
            style: TextStyle(
              color: task.isCompleted ? AppColors.textMuted : AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 8),

          // Time & Block info
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Saat Dilimi: ${task.formattedTimeRange}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              if (task.timeBlock != null && task.timeBlock!.isNotEmpty) ...[
                const SizedBox(width: 12),
                const Icon(Icons.view_day_outlined,
                    size: 15, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text(
                  task.timeBlock!,
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Description
          if (task.description != null && task.description!.isNotEmpty) ...[
            const Text(
              'Açıklama & Plan Detayı',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                task.description!,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Reminder status card
          if (task.hasReminder) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.notifications_active_rounded,
                      color: AppColors.warning, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      task.reminderNote ?? 'Bu görev için aktif hatırlatıcı tanımlı.',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Penalty warning card
          if (task.hasPenalty && task.penaltyNote != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppColors.danger, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bağlı Minik Ceza:',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.penaltyNote!,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _triggerPenalty(context),
                    icon: const Icon(Icons.gavel_rounded, size: 15),
                    label: const Text('Ceza Kes'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      backgroundColor: AppColors.danger.withValues(alpha: 0.15),
                      textStyle: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Quick Integration Row: Hatırlatıcı Bağla | Önemli (!) Sayfasına Taşı | Ceza Kes
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _attachReminder(context),
                  icon: const Icon(Icons.alarm_add_rounded,
                      size: 16, color: AppColors.warning),
                  label: const Text(
                    'Hatırlatıcı Bağla',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.warning.withValues(alpha: 0.4)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context
                        .read<TaskBloc>()
                        .add(ToggleTaskImportanceEvent(task.id));
                    _syncWeeklyBloc(context);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.priority_high_rounded,
                    size: 16,
                    color: task.isImportant
                        ? AppColors.important
                        : AppColors.textSecondary,
                  ),
                  label: Text(
                    task.isImportant ? 'Önemliden Çıkar' : 'Önemli (!) Taşı',
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: task.isImportant
                          ? AppColors.important
                          : AppColors.border,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Main Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<TaskBloc>()
                        .add(ToggleTaskCompletionEvent(task.id));
                    _syncWeeklyBloc(context);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    task.isCompleted
                        ? Icons.replay_rounded
                        : Icons.check_circle_outline_rounded,
                  ),
                  label: Text(
                    task.isCompleted ? 'Tamamlanmadı İşaretle' : 'Görevi Tamamla',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: task.isCompleted
                        ? AppColors.surfaceLight
                        : AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              if (!task.hasPenalty) ...[
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'Yapılmadı: Minik Ceza Kes',
                  onPressed: () => _triggerPenalty(context),
                  icon: const Icon(Icons.gavel_rounded, color: AppColors.danger),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 8),
              IconButton.filledTonal(
                tooltip: 'Sil',
                onPressed: () {
                  context.read<TaskBloc>().add(DeleteTaskEvent(task.id));
                  _syncWeeklyBloc(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.delete_outline, color: AppColors.danger),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
