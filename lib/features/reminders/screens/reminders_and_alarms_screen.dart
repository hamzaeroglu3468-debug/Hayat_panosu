import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../../core/widgets/live_clock_widget.dart';
import '../../penalties/bloc/penalty_bloc.dart';
import '../../penalties/bloc/penalty_event.dart';
import '../../penalties/bloc/penalty_state.dart';
import '../../penalties/screens/add_penalty_dialog.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../../tasks/bloc/task_state.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_event.dart';
import '../bloc/reminder_state.dart';
import '../models/reminder_model.dart';
import 'add_reminder_dialog.dart';
import 'important_items_screen.dart';

class RemindersAndAlarmsScreen extends StatefulWidget {
  const RemindersAndAlarmsScreen({super.key});

  @override
  State<RemindersAndAlarmsScreen> createState() =>
      _RemindersAndAlarmsScreenState();
}

class _RemindersAndAlarmsScreenState extends State<RemindersAndAlarmsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _onlyImportant = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAttachTaskReminderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return BlocBuilder<TaskBloc, TaskState>(
          builder: (context, state) {
            final tasks = state is TaskLoadedState ? state.tasks : [];
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.add_alarm_rounded, color: AppColors.warning),
                      SizedBox(width: 8),
                      Text(
                        'Göreve 24s Hatırlatıcı Bağla',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Seçtiğiniz görevin saatine (HH:mm) göre görsel hatırlatıcı oluşturulur.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (tasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'Henüz kayıtlı günlük görev bulunmuyor.',
                        style: TextStyle(color: AppColors.textMuted),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.warning.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.time,
                                style: const TextStyle(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            title: Text(
                              task.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              task.category,
                              style: const TextStyle(
                                color: AppColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                            trailing: ElevatedButton.icon(
                              onPressed: () {
                                final now = DateTime.now();
                                final due = AppTimeUtils.nextOccurrenceOfTime(
                                  task.time,
                                );
                                final reminder = ReminderModel(
                                  id: const Uuid().v4(),
                                  title:
                                      '${task.title} (${task.formattedTimeRange})',
                                  note:
                                      'Görev hatırlatıcısı • Saat: ${task.time}',
                                  dueDate: due,
                                  isImportant: task.isImportant,
                                  isDone: false,
                                  createdAt: now,
                                );
                                context
                                    .read<ReminderBloc>()
                                    .add(AddReminderEvent(reminder));
                                context.read<TaskBloc>().add(
                                      UpdateTaskEvent(
                                        task.copyWith(
                                          hasReminder: true,
                                          reminderNote:
                                              '${task.time} hatırlatıcısı aktif',
                                        ),
                                      ),
                                    );
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: AppColors.warning,
                                    content: Text(
                                      '"${task.title}" için ${task.time} (24s) hatırlatıcısı eklendi!',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.warning,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                              ),
                              icon: const Icon(Icons.bookmark_add_rounded, size: 15),
                              label: const Text(
                                'Bağla',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRemindersTab = _tabController.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.alarm_rounded, color: AppColors.warning),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Hatırlatıcılar & Cezalar',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          const LiveClockWidget(compact: true, showSeconds: true),
          IconButton(
            tooltip: 'Önemli Maddeler (!)',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ImportantItemsScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.priority_high_rounded,
              color: AppColors.important,
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: isRemindersTab ? AppColors.warning : AppColors.danger,
          labelColor: AppColors.textPrimary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: [
            Tab(
              child: BlocBuilder<ReminderBloc, ReminderState>(
                builder: (context, state) {
                  final activeCount = state is ReminderLoadedState
                      ? state.reminders.where((r) => !r.isDone).length
                      : 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.notifications_active_rounded, size: 17),
                      const SizedBox(width: 6),
                      Text('Hatırlatıcılar ($activeCount)'),
                    ],
                  );
                },
              ),
            ),
            Tab(
              child: BlocBuilder<PenaltyBloc, PenaltyState>(
                builder: (context, state) {
                  final unresolvedCount = state is PenaltyLoadedState
                      ? state.unresolvedCount
                      : 0;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.gavel_rounded, size: 17),
                      const SizedBox(width: 6),
                      Text('Minik Cezalar ($unresolvedCount)'),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: isRemindersTab ? AppColors.warning : AppColors.danger,
        foregroundColor: isRemindersTab ? Colors.black : Colors.white,
        icon: Icon(
          isRemindersTab ? Icons.add_alert_rounded : Icons.gavel_rounded,
        ),
        label: Text(
          isRemindersTab ? 'Yeni Hatırlatıcı' : 'Yeni Ceza Ekle',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          if (isRemindersTab) {
            AddReminderDialog.show(context);
          } else {
            AddPenaltyDialog.show(context);
          }
        },
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRemindersTab(context),
          _buildPenaltiesTab(context),
        ],
      ),
    );
  }

  Widget _buildRemindersTab(BuildContext context) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, state) {
        if (state is ReminderLoadedState) {
          final allReminders = state.reminders;
          final filtered = _onlyImportant
              ? allReminders.where((r) => r.isImportant).toList()
              : allReminders;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              // Header Card: Görsel Hatırlatıcı Takibi
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.cardGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.access_time_filled_rounded,
                            color: AppColors.warning,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '24 Saatlik Hatırlatıcı & Zaman Takibi',
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Tüm hatırlatıcılar HH:mm (24 saat) formatında görsel olarak takip edilir.',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => AddReminderDialog.show(context),
                            icon: const Icon(
                              Icons.add_alert_rounded,
                              size: 16,
                              color: AppColors.warning,
                            ),
                            label: const Text(
                              'Hatırlatıcı Ekle',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(
                                color: AppColors.warning.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                _showAttachTaskReminderSheet(context),
                            icon: const Icon(
                              Icons.add_task_rounded,
                              size: 16,
                              color: AppColors.secondary,
                            ),
                            label: const Text(
                              'Göreve Bağla',
                              style: TextStyle(fontSize: 12),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: BorderSide(
                                color:
                                    AppColors.secondary.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Filter Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Kayıtlı Hatırlatıcılar',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  FilterChip(
                    selected: _onlyImportant,
                    label: const Text(
                      'Sadece Önemli (!)',
                      style: TextStyle(fontSize: 12),
                    ),
                    selectedColor: AppColors.important.withValues(alpha: 0.25),
                    checkmarkColor: AppColors.important,
                    onSelected: (val) => setState(() => _onlyImportant = val),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              if (filtered.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Text(
                      'Kayıtlı hatırlatıcı bulunmuyor.',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                )
              else
                ...filtered.map((reminder) {
                  final time24Str = AppTimeUtils.formatTime(reminder.dueDate);
                  final dateStr = AppTimeUtils.formatDate(reminder.dueDate);
                  final isOverdue =
                      !reminder.isDone &&
                      reminder.dueDate.isBefore(DateTime.now());

                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: reminder.isImportant
                            ? AppColors.important.withValues(alpha: 0.5)
                            : AppColors.border,
                      ),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      leading: IconButton(
                        icon: Icon(
                          reminder.isDone
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked_rounded,
                          color: reminder.isDone
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        onPressed: () {
                          context
                              .read<ReminderBloc>()
                              .add(ToggleReminderDoneEvent(reminder.id));
                        },
                      ),
                      title: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              time24Str,
                              style: const TextStyle(
                                color: AppColors.warning,
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
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
                          ),
                        ],
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (reminder.note != null &&
                                reminder.note!.isNotEmpty)
                              Text(
                                reminder.note!,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              'Tarih: $dateStr • Saat: $time24Str',
                              style: TextStyle(
                                fontSize: 11,
                                color: isOverdue
                                    ? AppColors.danger
                                    : AppColors.textMuted,
                                fontWeight: isOverdue
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            tooltip: 'Önemli (!) İşaretle',
                            icon: Icon(
                              Icons.priority_high_rounded,
                              color: reminder.isImportant
                                  ? AppColors.important
                                  : AppColors.textMuted,
                            ),
                            onPressed: () {
                              context.read<ReminderBloc>().add(
                                    ToggleReminderImportantEvent(reminder.id),
                                  );
                            },
                          ),
                          IconButton(
                            tooltip: 'Sil',
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              context
                                  .read<ReminderBloc>()
                                  .add(DeleteReminderEvent(reminder.id));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildPenaltiesTab(BuildContext context) {
    return BlocBuilder<PenaltyBloc, PenaltyState>(
      builder: (context, state) {
        if (state is PenaltyLoadedState) {
          final active = state.activePenalties;
          final resolved =
              state.penalties.where((p) => p.isResolved).toList();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.danger.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.fitness_center_rounded,
                        color: AppColors.danger,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bekleyen Minik Cezalar: ${state.unresolvedCount}',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Aksatılan görevlerin cezalarını tamamlayarak disiplini koru!',
                            style: TextStyle(
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
              const Text(
                'Uygulanacak Cezalar',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              if (active.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.sentiment_very_satisfied_rounded,
                          color: AppColors.success,
                          size: 38,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Harika! Bekleyen hiç cezanız yok.',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...active.map((penalty) {
                  final dateStr =
                      AppTimeUtils.formatDateTime(penalty.createdAt);
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.danger,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  penalty.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                                onPressed: () {
                                  context
                                      .read<PenaltyBloc>()
                                      .add(DeletePenaltyEvent(penalty.id));
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.danger.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Ceza: ${penalty.penaltyAction}',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kayıt (24s): $dateStr',
                                style: const TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  context
                                      .read<PenaltyBloc>()
                                      .add(ResolvePenaltyEvent(penalty.id));
                                },
                                icon: const Icon(Icons.check, size: 16),
                                label: const Text('Cezayı Tamamladım'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.success,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 8,
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              if (resolved.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text(
                  'Tamamlanan Cezalar Arşivi',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ...resolved.map((penalty) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      dense: true,
                      leading: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 20,
                      ),
                      title: Text(
                        penalty.title,
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textMuted,
                        ),
                      ),
                      subtitle: Text(
                        'Ceza: ${penalty.penaltyAction}',
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: AppColors.textMuted,
                          fontSize: 12,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.replay_rounded, size: 18),
                        tooltip: 'Geri Al',
                        onPressed: () {
                          context
                              .read<PenaltyBloc>()
                              .add(ResolvePenaltyEvent(penalty.id));
                        },
                      ),
                    ),
                  );
                }),
              ],
            ],
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
