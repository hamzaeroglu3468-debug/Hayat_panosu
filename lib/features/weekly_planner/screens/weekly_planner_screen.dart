import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../bloc/weekly_planner_bloc.dart';
import '../bloc/weekly_planner_event.dart';
import '../bloc/weekly_planner_state.dart';
import '../models/weekly_plan_item_model.dart';
import 'add_weekly_plan_dialog.dart';
import 'weekly_plan_detail_sheet.dart';

class WeeklyPlannerScreen extends StatefulWidget {
  const WeeklyPlannerScreen({super.key});

  @override
  State<WeeklyPlannerScreen> createState() => _WeeklyPlannerScreenState();
}

class _WeeklyPlannerScreenState extends State<WeeklyPlannerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    final initialDay = DateTime.now().weekday; // 1..7
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: (initialDay - 1).clamp(0, 6),
    );
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        context
            .read<WeeklyPlannerBloc>()
            .add(SelectWeekdayEvent(_tabController.index + 1));
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayWeekday = DateTime.now().weekday;

    return BlocBuilder<WeeklyPlannerBloc, WeeklyPlannerState>(
      builder: (context, state) {
        final items = state is WeeklyPlannerLoadedState ? state.items : <WeeklyPlanItemModel>[];
        final currentDay = (_tabController.index + 1).clamp(1, 7);

        return Scaffold(
          appBar: AppBar(
            title: const Row(
              children: [
                Icon(Icons.calendar_view_week_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Text('Haftalık Program & Planlayıcı'),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(68),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: AppColors.border, width: 1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  tabAlignment: TabAlignment.start,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 3,
                  labelColor: AppColors.textPrimary,
                  unselectedLabelColor: AppColors.textMuted,
                  onTap: (index) {
                    context
                        .read<WeeklyPlannerBloc>()
                        .add(SelectWeekdayEvent(index + 1));
                  },
                  tabs: List.generate(7, (index) {
                    final dayNum = index + 1;
                    final isToday = dayNum == todayWeekday;
                    final dayCount =
                        items.where((i) => i.dayOfWeek == dayNum).length;

                    return Tab(
                      height: 60,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                WeeklyPlanItemModel.dayNames[index],
                                style: TextStyle(
                                  fontWeight: isToday
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              if (isToday) ...[
                                const SizedBox(width: 4),
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: AppColors.secondary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 1),
                            decoration: BoxDecoration(
                              color: dayCount > 0
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : AppColors.surfaceLight.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '$dayCount Blok',
                              style: TextStyle(
                                fontSize: 10,
                                color: dayCount > 0
                                    ? AppColors.primaryLight
                                    : AppColors.textMuted,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: Text(
              '${WeeklyPlanItemModel.dayNames[currentDay - 1]} Planı Ekle',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
            onPressed: () =>
                AddWeeklyPlanDialog.show(context, initialDayOfWeek: currentDay),
          ),
          body: state is WeeklyPlannerLoadedState
              ? TabBarView(
                  controller: _tabController,
                  children: List.generate(7, (index) {
                    final dayNum = index + 1;
                    return _buildDayScheduleView(context, state, dayNum);
                  }),
                )
              : const Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Widget _buildDayScheduleView(
      BuildContext context, WeeklyPlannerLoadedState state, int dayOfWeek) {
    final dayItems = state.itemsForDay(dayOfWeek);
    final groupedBlocks = state.itemsGroupedByBlock(dayOfWeek);
    final dayName = WeeklyPlanItemModel.dayNames[dayOfWeek - 1];
    final isToday = dayOfWeek == DateTime.now().weekday;
    final syncedCount = dayItems.where((i) => i.isSyncedToDaily).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      children: [
        // Day Summary Header Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppColors.cardGradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isToday
                  ? AppColors.secondary.withValues(alpha: 0.5)
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.secondary.withValues(alpha: 0.15)
                      : AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isToday ? Icons.today_rounded : Icons.event_note_rounded,
                  color: isToday ? AppColors.secondary : AppColors.primaryLight,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '$dayName Programı',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (isToday) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'BUGÜN',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Toplam ${dayItems.length} zaman bloğu • $syncedCount tanesi Günlük Akış ile senkronize',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (dayItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    color: AppColors.textMuted, size: 42),
                const SizedBox(height: 12),
                Text(
                  '$dayName günü için henüz haftalık rutin veya ders bloğu eklenmemiş.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  onPressed: () => AddWeeklyPlanDialog.show(
                    context,
                    initialDayOfWeek: dayOfWeek,
                  ),
                  icon: const Icon(Icons.add),
                  label: Text('$dayName İçin İlk Bloğu Ekle'),
                ),
              ],
            ),
          )
        else
          ...groupedBlocks.entries.map((entry) {
            final blockTitle = entry.key;
            final blockItems = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 6),
                  child: Row(
                    children: [
                      Icon(
                        _blockIcon(blockTitle),
                        size: 18,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        blockTitle,
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Divider(
                          color: AppColors.border.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                ...blockItems
                    .map((item) => _buildWeeklyItemCard(context, item)),
                const SizedBox(height: 10),
              ],
            );
          }),
      ],
    );
  }

  IconData _blockIcon(String blockTitle) {
    if (blockTitle.contains('Sabah')) return Icons.wb_sunny_outlined;
    if (blockTitle.contains('Öğle')) return Icons.light_mode_outlined;
    if (blockTitle.contains('Akşam')) return Icons.nights_stay_outlined;
    return Icons.schedule_rounded;
  }

  Widget _buildWeeklyItemCard(BuildContext context, WeeklyPlanItemModel item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isImportant
              ? AppColors.important.withValues(alpha: 0.5)
              : AppColors.border,
          width: item.isImportant ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => WeeklyPlanDetailSheet.show(context, item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Time range + Category + Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time_rounded,
                              size: 13, color: AppColors.primaryLight),
                          const SizedBox(width: 4),
                          Text(
                            item.formattedTimeRange,
                            style: const TextStyle(
                              color: AppColors.primaryLight,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        item.category,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (item.hasReminder)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.notifications_active_rounded,
                            size: 16, color: AppColors.warning),
                      ),
                    if (item.hasPenalty)
                      const Padding(
                        padding: EdgeInsets.only(right: 6),
                        child: Icon(Icons.gavel_rounded,
                            size: 16, color: AppColors.danger),
                      ),
                    if (item.isImportant)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.important,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          '!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title & Description
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            style: TextStyle(
                              color: item.isCompletedToday
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              decoration: item.isCompletedToday
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                          if (item.description != null &&
                              item.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.description!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Footer Row: One-click transfer/sync to Daily Flow + Detail hint
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () {
                        context
                            .read<WeeklyPlannerBloc>()
                            .add(ToggleWeeklyPlanSyncEvent(item.id));
                        context.read<TaskBloc>().add(LoadTasksEvent());
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            duration: const Duration(seconds: 2),
                            backgroundColor: item.isSyncedToDaily
                                ? AppColors.surfaceLight
                                : AppColors.secondary,
                            content: Text(
                              item.isSyncedToDaily
                                  ? '"${item.title}" günlük akıştan çıkarıldı.'
                                  : '"${item.title}" Günlük Akış ve Görevler listesine aktarıldı!',
                              style: TextStyle(
                                color: item.isSyncedToDaily
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: item.isSyncedToDaily
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.secondary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: item.isSyncedToDaily
                                ? AppColors.success.withValues(alpha: 0.4)
                                : AppColors.secondary.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item.isSyncedToDaily
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.sync_rounded,
                              size: 14,
                              color: item.isSyncedToDaily
                                  ? AppColors.success
                                  : AppColors.secondary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              item.isSyncedToDaily
                                  ? 'Günlük Akışta Senkronize'
                                  : 'Tek Tıkla Günlük Akışa Aktar',
                              style: TextStyle(
                                color: item.isSyncedToDaily
                                    ? AppColors.success
                                    : AppColors.secondary,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Row(
                      children: [
                        Text(
                          'Detay & Ceza/Alarm',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right,
                            size: 16, color: AppColors.textMuted),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
