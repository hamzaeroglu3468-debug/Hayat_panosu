import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../reminders/bloc/reminder_bloc.dart';
import '../../reminders/bloc/reminder_event.dart';
import '../../reminders/models/reminder_model.dart';
import '../../tasks/bloc/task_bloc.dart';
import '../../tasks/bloc/task_event.dart';
import '../bloc/weekly_planner_bloc.dart';
import '../bloc/weekly_planner_event.dart';
import '../models/weekly_plan_item_model.dart';

class AddWeeklyPlanDialog extends StatefulWidget {
  final int? initialDayOfWeek;

  const AddWeeklyPlanDialog({super.key, this.initialDayOfWeek});

  static Future<void> show(BuildContext context, {int? initialDayOfWeek}) {
    return showDialog(
      context: context,
      builder: (ctx) => AddWeeklyPlanDialog(initialDayOfWeek: initialDayOfWeek),
    );
  }

  @override
  State<AddWeeklyPlanDialog> createState() => _AddWeeklyPlanDialogState();
}

class _AddWeeklyPlanDialogState extends State<AddWeeklyPlanDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _penaltyController = TextEditingController();
  final _reminderController = TextEditingController();

  late int _dayOfWeek;
  String _startTime = '09:00';
  String _endTime = '10:30';
  String _timeBlock = 'Sabah Bloğu';
  String _category = 'Ders / Eğitim';
  bool _isImportant = false;
  bool _hasPenalty = false;
  bool _hasReminder = false;
  bool _isSyncedToDaily = true;

  final List<String> _timeBlocks = [
    'Sabah Bloğu',
    'Öğle Bloğu',
    'Öğleden Sonra',
    'Akşam Bloğu',
  ];

  final List<String> _categories = [
    'Ders / Eğitim',
    'İş / Yazılım',
    'Spor / Sağlık',
    'Kişisel Rutin',
    'Finans',
  ];

  @override
  void initState() {
    super.initState();
    _dayOfWeek = widget.initialDayOfWeek ?? DateTime.now().weekday;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _penaltyController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  Future<void> _pickTime({required bool isStart}) async {
    final initial = AppTimeUtils.parseTimeOfDay(isStart ? _startTime : _endTime);
    final picked = await AppTimeUtils.show24HourTimePicker(
      context,
      initialTime: initial,
      helpText: isStart
          ? 'BAŞLANGIÇ SAATİ (24 SAAT - HH:mm)'
          : 'BİTİŞ SAATİ (24 SAAT - HH:mm)',
    );
    if (picked != null) {
      final formatted = AppTimeUtils.formatTimeOfDay(picked);
      setState(() {
        if (isStart) {
          _startTime = formatted;
          // Saat dilimine göre otomatik blok önerisi
          if (picked.hour < 12) {
            _timeBlock = 'Sabah Bloğu';
          } else if (picked.hour < 14) {
            _timeBlock = 'Öğle Bloğu';
          } else if (picked.hour < 18) {
            _timeBlock = 'Öğleden Sonra';
          } else {
            _timeBlock = 'Akşam Bloğu';
          }
        } else {
          _endTime = formatted;
        }
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final now = DateTime.now();
    final newItem = WeeklyPlanItemModel(
      id: const Uuid().v4(),
      dayOfWeek: _dayOfWeek,
      startTime: _startTime,
      endTime: _endTime,
      timeBlock: _timeBlock,
      title: title,
      description:
          _descController.text.trim().isEmpty ? null : _descController.text.trim(),
      category: _category,
      isImportant: _isImportant,
      hasPenalty: _hasPenalty,
      penaltyNote: _hasPenalty && _penaltyController.text.trim().isNotEmpty
          ? _penaltyController.text.trim()
          : (_hasPenalty ? '25 Şınav veya 50 TL Ceza Kumbarasına' : null),
      hasReminder: _hasReminder,
      reminderNote: _hasReminder && _reminderController.text.trim().isNotEmpty
          ? _reminderController.text.trim()
          : (_hasReminder ? '$_startTime öncesi hatırlatma alarmı' : null),
      isSyncedToDaily: _isSyncedToDaily,
      isCompletedToday: false,
      createdAt: now,
    );

    context.read<WeeklyPlannerBloc>().add(AddWeeklyPlanItemEvent(newItem));
    context.read<TaskBloc>().add(LoadTasksEvent());

    // Eğer hatırlatıcı seçildiyse ReminderBloc'a da otomatik ekle
    if (_hasReminder) {
      final reminder = ReminderModel(
        id: const Uuid().v4(),
        title: '[${newItem.dayName}] ${newItem.title} (${newItem.formattedTimeRange})',
        note: newItem.reminderNote ?? 'Haftalık program hatırlatıcısı',
        dueDate: now.add(const Duration(days: 1)),
        isImportant: _isImportant,
        isDone: false,
        createdAt: now,
      );
      context.read<ReminderBloc>().add(AddReminderEvent(reminder));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.calendar_view_week_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Haftalık Programa Ekle',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gün Seçimi (Pazartesi - Pazar)
              DropdownButtonFormField<int>(
                initialValue: _dayOfWeek,
                decoration: const InputDecoration(
                  labelText: 'Gün Seçin',
                  prefixIcon: Icon(Icons.today_rounded, size: 18),
                ),
                dropdownColor: AppColors.surface,
                items: List.generate(7, (index) {
                  final day = index + 1;
                  return DropdownMenuItem(
                    value: day,
                    child: Text(WeeklyPlanItemModel.dayNames[index]),
                  );
                }),
                onChanged: (val) {
                  if (val != null) setState(() => _dayOfWeek = val);
                },
              ),
              const SizedBox(height: 12),

              // Başlık
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Rutin / Ders / Çalışma Planı Başlığı *',
                  hintText: 'Örn: Algoritma Çalışma Bloğu / Spor',
                ),
              ),
              const SizedBox(height: 12),

              // Başlangıç & Bitiş Saati
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(isStart: true),
                      icon: const Icon(Icons.schedule_rounded, size: 16),
                      label: Text('Başla: $_startTime'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(isStart: false),
                      icon: const Icon(Icons.schedule_send_rounded, size: 16),
                      label: Text('Bitiş: $_endTime'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textPrimary,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Blok & Kategori
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _timeBlock,
                      decoration: const InputDecoration(
                        labelText: 'Zaman Bloğu',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      dropdownColor: AppColors.surface,
                      items: _timeBlocks.map((b) {
                        return DropdownMenuItem(
                          value: b,
                          child: Text(b, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _timeBlock = val);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _category,
                      decoration: const InputDecoration(
                        labelText: 'Kategori',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                      dropdownColor: AppColors.surface,
                      items: _categories.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c, style: const TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _category = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Açıklama / Hedef Detayı (Opsiyonel)',
                  hintText: 'Konu başlıkları, hedefler veya notlar...',
                ),
              ),
              const SizedBox(height: 8),

              // Günlük Akış Senkronizasyonu
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Row(
                  children: [
                    Icon(Icons.sync_rounded, color: AppColors.secondary, size: 18),
                    SizedBox(width: 6),
                    Text('Günlük Akış ile Senkronize Et',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                subtitle: const Text(
                  'Aktif olduğunda o günün Günlük Akış ve Görevler listesine yansır.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                value: _isSyncedToDaily,
                activeThumbColor: AppColors.secondary,
                onChanged: (val) => setState(() => _isSyncedToDaily = val),
              ),

              // Önemli (!) İşaretleme
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Row(
                  children: [
                    Icon(Icons.priority_high_rounded,
                        color: AppColors.important, size: 18),
                    SizedBox(width: 6),
                    Text('Önemli Sayfası\'na Taşı (!)',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
                value: _isImportant,
                activeThumbColor: AppColors.important,
                onChanged: (val) => setState(() => _isImportant = val),
              ),

              // Hatırlatıcı Bağlama
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Row(
                  children: [
                    Icon(Icons.alarm_add_rounded,
                        color: AppColors.warning, size: 18),
                    SizedBox(width: 6),
                    Text('Hatırlatıcı & Alarm Bağla',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
                value: _hasReminder,
                activeThumbColor: AppColors.warning,
                onChanged: (val) => setState(() => _hasReminder = val),
              ),
              if (_hasReminder) ...[
                const SizedBox(height: 6),
                TextField(
                  controller: _reminderController,
                  decoration: const InputDecoration(
                    labelText: 'Hatırlatıcı Notu',
                    hintText: 'Örn: Başlamadan 15 dk önce alarm çalsın',
                  ),
                ),
              ],

              // Minik Ceza
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Row(
                  children: [
                    Icon(Icons.gavel_rounded, color: AppColors.danger, size: 18),
                    SizedBox(width: 6),
                    Text('Minik Ceza Mekanizması Bağla',
                        style: TextStyle(fontSize: 13)),
                  ],
                ),
                value: _hasPenalty,
                activeThumbColor: AppColors.danger,
                onChanged: (val) => setState(() => _hasPenalty = val),
              ),
              if (_hasPenalty) ...[
                const SizedBox(height: 6),
                TextField(
                  controller: _penaltyController,
                  decoration: const InputDecoration(
                    labelText: 'Yapılmazsa Uygulanacak Ceza',
                    hintText: 'Örn: 30 Şınav veya 50 TL kumbaraya',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal', style: TextStyle(color: AppColors.textMuted)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Programa Ekle',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
