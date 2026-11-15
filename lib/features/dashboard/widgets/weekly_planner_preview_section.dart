import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../weekly_planner/bloc/weekly_planner_bloc.dart';
import '../../weekly_planner/bloc/weekly_planner_event.dart';
import '../../weekly_planner/bloc/weekly_planner_state.dart';
import '../../weekly_planner/models/weekly_plan_item_model.dart';
import '../../weekly_planner/screens/add_weekly_plan_dialog.dart';
import '../../weekly_planner/screens/weekly_plan_detail_sheet.dart';
import '../../weekly_planner/screens/weekly_planner_screen.dart';

class WeeklyPlannerPreviewSection extends StatelessWidget {
  const WeeklyPlannerPreviewSection({super.key});

  @override
  Widget build(BuildContext context) {
    final todayWeekday = DateTime.now().weekday;

    return BlocBuilder<WeeklyPlannerBloc, WeeklyPlannerState>(
      builder: (context, state) {
        if (state is WeeklyPlannerLoadedState) {
          final selectedDay = state.selectedDayOfWeek;
          final dayItems = state.itemsForDay(selectedDay);

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_view_week_rounded,
                            color: AppColors.primaryLight,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Haftalık Program & Planlayıcı',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Pazartesi - Pazar Blok & Rutin Yönetimi',
                              style: TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const WeeklyPlannerScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 15),
                      label: const Text('Tam Ekran'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Pazartesi - Pazar Interactive Day Selector Strip
                SizedBox(
                  height: 58,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 7,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final dayNum = index + 1;
                      final isSelected = dayNum == selectedDay;
                      final isToday = dayNum == todayWeekday;
                      final count = state.itemsForDay(dayNum).length;

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          context
                              .read<WeeklyPlannerBloc>()
                              .add(SelectWeekdayEvent(dayNum));
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 56,
                          decoration: BoxDecoration(
                            gradient: isSelected ? AppColors.primaryGradient : null,
                            color: isSelected
                                ? null
                                : AppColors.surfaceLight.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isToday && !isSelected
                                  ? AppColors.secondary
                                  : (isSelected
                                      ? Colors.transparent
                                      : AppColors.border),
                              width: isToday ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                WeeklyPlanItemModel.shortDayNames[index],
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '$count blok',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : AppColors.textMuted,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Selected Day Subheader + Add Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${WeeklyPlanItemModel.dayNames[selectedDay - 1]} Rutin & Ders Blokları (${dayItems.length})',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    InkWell(
                      onTap: () => AddWeeklyPlanDialog.show(
                        context,
                        initialDayOfWeek: selectedDay,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_outline,
                              size: 15, color: AppColors.secondary),
                          SizedBox(width: 4),
                          Text(
                            'Blok Ekle',
                            style: TextStyle(
                              color: AppColors.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                if (dayItems.isEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    alignment: Alignment.center,
                    child: Text(
                      '${WeeklyPlanItemModel.dayNames[selectedDay - 1]} günü için planlanmış blok yok.',
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 12),
                    ),
                  )
                else
                  ...dayItems.take(3).map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: AppColors.background.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.isImportant
                              ? AppColors.important.withValues(alpha: 0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 2),
                        onTap: () => WeeklyPlanDetailSheet.show(context, item),
                        leading: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.startTime,
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: item.isCompletedToday
                                      ? AppColors.textMuted
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  decoration: item.isCompletedToday
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                            ),
                            if (item.isImportant)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.priority_high_rounded,
                                    size: 15, color: AppColors.important),
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${item.timeBlock} • ${item.category}',
                          style: const TextStyle(
                              color: AppColors.textMuted, fontSize: 11),
                        ),
                        trailing: IconButton(
                          tooltip: item.isSyncedToDaily
                              ? 'Günlük Akışta Aktif (Kaldırmak için dokun)'
                              : 'Tek Tıkla Günlük Akışa Aktar',
                          icon: Icon(
                            item.isSyncedToDaily
                                ? Icons.sync_rounded
                                : Icons.add_task_rounded,
                            size: 18,
                            color: item.isSyncedToDaily
                                ? AppColors.success
                                : AppColors.secondary,
                          ),
                          onPressed: () {
                            context
                                .read<WeeklyPlannerBloc>()
                                .add(ToggleWeeklyPlanSyncEvent(item.id));
                            context.read<TaskBloc>().add(LoadTasksEvent());
                          },
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
