import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../../reminders/bloc/reminder_bloc.dart';
import '../../reminders/bloc/reminder_event.dart';
import '../../reminders/models/reminder_model.dart';
import '../bloc/task_bloc.dart';
import '../bloc/task_event.dart';
import '../models/task_model.dart';

/// 24 Saat Formatına (HH:mm) uygun örnek Görev / Saat Ekleme Widget'ı.
/// Saat seçicide `alwaysUse24HourFormat: true` zorunluluğunu uygular.
class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const AddTaskDialog(),
    );
  }

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _penaltyController = TextEditingController();

  String _startTime = '10:00';
  String _endTime = '11:00';
  String _category = 'Kişisel';
  bool _isImportant = false;
  bool _hasReminder = false;
  bool _hasPenalty = false;

  final List<String> _categories = [
    'Kişisel',
    'İş / Yazılım',
    'Sağlık',
    'Eğitim',
    'Finans',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _penaltyController.dispose();
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
      setState(() {
        final formatted = AppTimeUtils.formatTimeOfDay(picked);
        if (isStart) {
          _startTime = formatted;
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
    final newTask = TaskModel(
      id: const Uuid().v4(),
      title: title,
      description: _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim(),
      time: _startTime,
      endTime: _endTime,
      category: _category,
      isImportant: _isImportant,
      hasReminder: _hasReminder,
      reminderNote: _hasReminder ? '$_startTime (24s) hatırlatıcısı aktif' : null,
      hasPenalty: _hasPenalty,
      penaltyNote: _hasPenalty && _penaltyController.text.trim().isNotEmpty
          ? _penaltyController.text.trim()
          : (_hasPenalty ? '20 Şınav veya 50 TL kumbaraya' : null),
      createdAt: now,
    );

    context.read<TaskBloc>().add(AddTaskEvent(newTask));

    if (_hasReminder) {
      final due = AppTimeUtils.nextOccurrenceOfTime(_startTime);
      final reminder = ReminderModel(
        id: const Uuid().v4(),
        title: '$title (${newTask.formattedTimeRange})',
        note: 'Günlük görev alarmı • Saat: $_startTime',
        dueDate: due,
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
          Icon(Icons.add_task_rounded, color: AppColors.primary),
          SizedBox(width: 8),
          Text(
            'Yeni Görev Ekle (24s)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 370,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Görev Başlığı *',
                  hintText: 'Örn: Kod İncelemesi Yap',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Açıklama (Opsiyonel)',
                  hintText: 'Detaylar veya adımlar...',
                ),
              ),
              const SizedBox(height: 12),

              // 24 Saat Formatında Başlangıç ve Bitiş Saati Seçiciler (HH:mm)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pickTime(isStart: true),
                      icon: const Icon(
                        Icons.access_time_rounded,
                        size: 17,
                        color: AppColors.primaryLight,
                      ),
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
                      icon: const Icon(
                        Icons.schedule_send_rounded,
                        size: 17,
                        color: AppColors.secondary,
                      ),
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

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                dropdownColor: AppColors.surface,
                items: _categories.map((c) {
                  return DropdownMenuItem(
                    value: c,
                    child: Text(c, style: const TextStyle(fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 8),

              // Important toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Row(
                  children: [
                    Icon(
                      Icons.priority_high,
                      color: AppColors.important,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text('Önemli (!) İşaretle', style: TextStyle(fontSize: 14)),
                  ],
                ),
                value: _isImportant,
                activeThumbColor: AppColors.important,
                onChanged: (val) => setState(() => _isImportant = val),
              ),

              // 24h Reminder toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$_startTime İçin Hatırlatıcı Ekle',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                value: _hasReminder,
                activeThumbColor: AppColors.warning,
                onChanged: (val) => setState(() => _hasReminder = val),
              ),

              // Penalty toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Row(
                  children: [
                    Icon(
                      Icons.gavel_rounded,
                      color: AppColors.danger,
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text('Minik Ceza Ekle', style: TextStyle(fontSize: 14)),
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
                    labelText: 'Ceza Açıklaması',
                    hintText: 'Örn: 20 Şınav veya 50 TL kumbaraya',
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
          child: const Text(
            'İptal',
            style: TextStyle(color: AppColors.textMuted),
          ),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
