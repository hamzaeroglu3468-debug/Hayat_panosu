import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/navigation/main_layout_screen.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../tasks/bloc/task_state.dart';
import '../../tasks/models/task_model.dart';
import '../../tasks/screens/add_task_dialog.dart';
import '../../tasks/screens/task_detail_sheet.dart';
import '../../weekly_planner/bloc/weekly_planner_bloc.dart';
import '../../weekly_planner/bloc/weekly_planner_event.dart';
import '../../weekly_planner/screens/weekly_planner_screen.dart';

class DailyFlowSection extends StatefulWidget {
  const DailyFlowSection({super.key});

  @override
  State<DailyFlowSection> createState() => _DailyFlowSectionState();
}

class _DailyFlowSectionState extends State<DailyFlowSection> {
  String _filter = 'all'; // 'all', 'daily', 'weekly'

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        if (state is TaskLoadedState) {
          final allTasks = state.tasks;
          final weeklyCount = allTasks.where((t) => t.isFromWeeklyPlan).length;
          final dailyCount = allTasks.where((t) => !t.isFromWeeklyPlan).length;

          final filteredTasks = allTasks.where((t) {
            if (_filter == 'daily') return !t.isFromWeeklyPlan;
            if (_filter == 'weekly') return t.isFromWeeklyPlan;
            return true;
          }).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header & Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Entegre Günlük Akış & Görevler',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${state.completedCount} / ${allTasks.length} Tamamlandı • $weeklyCount Haftalık Plan, $dailyCount Özel Görev',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton.filledTonal(
                        tooltip: 'Haftalık Program Sekmesine Geç',
                        onPressed: () {
                          final switched =
                              MainLayoutScreen.switchTab(context, 1);
                          if (!switched) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const WeeklyPlannerScreen(),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.calendar_view_week_rounded,
                            size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.secondary.withValues(alpha: 0.15),
                          foregroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton.filledTonal(
                        tooltip: 'Yeni Günlük Görev Ekle',
                        onPressed: () => AddTaskDialog.show(context),
                        icon: const Icon(Icons.add, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          foregroundColor: AppColors.primaryLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.progress,
                  backgroundColor: AppColors.surfaceLight.withValues(alpha: 0.5),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),

              // Filter Chips (Tümü | Günlük Görevler | Haftalık Plandan Yansıyanlar)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Birleşik Akış (${allTasks.length})',
                      value: 'all',
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Haftalık Plandan ($weeklyCount)',
                      value: 'weekly',
                      accentColor: AppColors.secondary,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Özel Görevler ($dailyCount)',
                      value: 'daily',
                      accentColor: AppColors.primaryLight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Task List
              if (filteredTasks.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      'Bu filtrede görüntülenecek görev veya haftalık plan bulunmuyor.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    ),
                  ),
                )
              else
                ...filteredTasks.map((task) => _buildTaskCard(context, task)),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String value,
    Color accentColor = AppColors.primary,
  }) {
    final isSelected = _filter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: 0.2)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? accentColor : AppColors.textSecondary,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, TaskModel task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isImportant
              ? AppColors.important.withValues(alpha: 0.5)
              : (task.isFromWeeklyPlan
                  ? AppColors.secondary.withValues(alpha: 0.35)
                  : AppColors.border),
          width: task.isImportant ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => TaskDetailSheet.show(context, task),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Completion Checkbox
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    task.isCompleted
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: task.isCompleted
                        ? AppColors.success
                        : AppColors.textMuted,
                    size: 24,
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
                const SizedBox(width: 12),

                // Time Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: task.isFromWeeklyPlan
                        ? AppColors.secondary.withValues(alpha: 0.15)
                        : AppColors.surfaceLight.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    task.formattedTimeRange,
                    style: TextStyle(
                      color: task.isFromWeeklyPlan
                          ? AppColors.secondary
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title, Source Badge & Metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: task.isCompleted
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (task.isFromWeeklyPlan)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Haftalık Plan',
                                style: TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Text(
                            task.category,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 11,
                            ),
                          ),
                          if (task.hasReminder)
                            const Icon(Icons.notifications_active_rounded,
                                size: 12, color: AppColors.warning),
                          if (task.hasPenalty)
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.gavel_rounded,
                                    size: 11, color: AppColors.danger),
                                SizedBox(width: 2),
                                Text(
                                  'Cezalı',
                                  style: TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Important (!) Indicator
                if (task.isImportant)
                  const Padding(
                    padding: EdgeInsets.only(left: 6),
                    child: Icon(Icons.priority_high_rounded,
                        color: AppColors.important, size: 20),
                  ),

                const SizedBox(width: 4),
                const Icon(Icons.chevron_right,
                    size: 18, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
