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
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../bloc/weekly_planner_bloc.dart';
import '../bloc/weekly_planner_event.dart';
import '../models/weekly_plan_item_model.dart';

class WeeklyPlanDetailSheet extends StatelessWidget {
  final WeeklyPlanItemModel item;

  const WeeklyPlanDetailSheet({super.key, required this.item});

  static void show(BuildContext context, WeeklyPlanItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WeeklyPlanDetailSheet(item: item),
    );
  }

  void _refreshTasks(BuildContext context) {
    context.read<TaskBloc>().add(LoadTasksEvent());
  }

  void _attachReminder(BuildContext context) {
    final now = DateTime.now();
    final reminder = ReminderModel(
      id: const Uuid().v4(),
      title: '[${item.dayName}] ${item.title} (${item.formattedTimeRange})',
      note: item.reminderNote ??
          'Haftalık programdaki "${item.title}" bloğu için hatırlatıcı ve alarm.',
      dueDate: now.add(const Duration(hours: 3)),
      isImportant: item.isImportant,
      isDone: false,
      createdAt: now,
    );

    context.read<ReminderBloc>().add(AddReminderEvent(reminder));

    final updated = item.copyWith(
      hasReminder: true,
      reminderNote: '${item.dayName} ${item.startTime} alarmı aktif',
    );
    context.read<WeeklyPlannerBloc>().add(UpdateWeeklyPlanItemEvent(updated));
    _refreshTasks(context);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.warning,
        content: Text(
          '"${item.title}" için hatırlatıcı bağlandı!',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _triggerPenalty(BuildContext context) {
    final actionText = (item.penaltyNote != null && item.penaltyNote!.isNotEmpty)
        ? item.penaltyNote!
        : '30 Şınav + 50 TL Ceza Kumbarasına';

    final penalty = PenaltyModel(
      id: const Uuid().v4(),
      title: '[${item.dayName}] ${item.title} Aksatıldı',
      penaltyAction: actionText,
      relatedTaskId: item.id,
      isResolved: false,
      createdAt: DateTime.now(),
    );

    context.read<PenaltyBloc>().add(AddPenaltyEvent(penalty));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.danger,
        content: Text(
          'Minik Ceza Kesildi: $actionText',
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

          // Day, TimeBlock, Category & Important badges
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '${item.dayName} • ${item.timeBlock}',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: Text(
                  item.category,
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item.isImportant)
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
            item.title,
            style: TextStyle(
              color: item.isCompletedToday
                  ? AppColors.textMuted
                  : AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              decoration:
                  item.isCompletedToday ? TextDecoration.lineThrough : null,
            ),
          ),
          const SizedBox(height: 8),

          // Time slot & Sync status
          Row(
            children: [
              const Icon(Icons.access_time_rounded,
                  size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Saat Dilimi: ${item.formattedTimeRange}',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.isSyncedToDaily
                      ? AppColors.success.withValues(alpha: 0.15)
                      : AppColors.surfaceLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.isSyncedToDaily
                          ? Icons.sync_rounded
                          : Icons.sync_disabled_rounded,
                      size: 13,
                      color: item.isSyncedToDaily
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.isSyncedToDaily
                          ? 'Günlük Akışta Aktif'
                          : 'Sadece Haftalık Planda',
                      style: TextStyle(
                        color: item.isSyncedToDaily
                            ? AppColors.success
                            : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (item.description != null && item.description!.isNotEmpty) ...[
            const Text(
              'Rutin / Çalışma Planı Açıklaması',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
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
                item.description!,
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Penalty Card
          if (item.hasPenalty && item.penaltyNote != null) ...[
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
                      color: AppColors.danger, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bağlı Minik Ceza Kuralı:',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.penaltyNote!,
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
            const SizedBox(height: 14),
          ],

          // One-click Sync to Daily Flow Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                context
                    .read<WeeklyPlannerBloc>()
                    .add(ToggleWeeklyPlanSyncEvent(item.id));
                _refreshTasks(context);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: item.isSyncedToDaily
                        ? AppColors.surfaceLight
                        : AppColors.secondary,
                    content: Text(
                      item.isSyncedToDaily
                          ? '"${item.title}" günlük akış senkronizasyonundan çıkarıldı.'
                          : '"${item.title}" Günlük Akış ve Görevler listesine aktarıldı!',
                      style: TextStyle(
                        color: item.isSyncedToDaily ? Colors.white : Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
              icon: Icon(
                item.isSyncedToDaily
                    ? Icons.sync_disabled_rounded
                    : Icons.send_time_extension_rounded,
                size: 18,
                color: AppColors.secondary,
              ),
              label: Text(
                item.isSyncedToDaily
                    ? 'Günlük Akış Senkronizasyonunu Kapat'
                    : 'Tek Tıkla Günlük Akış ve Görevlere Aktar',
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.secondary, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Quick Integration Row: Hatırlatıcı Bağla | Önemli (!) Sayfasına Taşı
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
                        .read<WeeklyPlannerBloc>()
                        .add(ToggleWeeklyPlanImportanceEvent(item.id));
                    _refreshTasks(context);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.priority_high_rounded,
                    size: 16,
                    color: item.isImportant
                        ? AppColors.important
                        : AppColors.textSecondary,
                  ),
                  label: Text(
                    item.isImportant ? 'Önemliden Çıkar' : 'Önemli (!) Taşı',
                    style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: item.isImportant
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

          // Bottom Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context
                        .read<WeeklyPlannerBloc>()
                        .add(ToggleWeeklyPlanCompletionEvent(item.id));
                    _refreshTasks(context);
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    item.isCompletedToday
                        ? Icons.replay_rounded
                        : Icons.check_circle_outline_rounded,
                  ),
                  label: Text(
                    item.isCompletedToday ? 'Geri Al' : 'Tamamlandı İşaretle',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: item.isCompletedToday
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
              if (!item.hasPenalty) ...[
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
                  context
                      .read<WeeklyPlannerBloc>()
                      .add(DeleteWeeklyPlanItemEvent(item.id));
                  _refreshTasks(context);
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
