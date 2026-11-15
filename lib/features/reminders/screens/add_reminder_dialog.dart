import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/time_utils.dart';
import '../bloc/reminder_bloc.dart';
import '../bloc/reminder_event.dart';
import '../models/reminder_model.dart';

class AddReminderDialog extends StatefulWidget {
  final bool defaultImportant;
  const AddReminderDialog({super.key, this.defaultImportant = false});

  static Future<void> show(
    BuildContext context, {
    bool defaultImportant = false,
  }) {
    return showDialog(
      context: context,
      builder: (ctx) => AddReminderDialog(defaultImportant: defaultImportant),
    );
  }

  @override
  State<AddReminderDialog> createState() => _AddReminderDialogState();
}

class _AddReminderDialogState extends State<AddReminderDialog> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  late DateTime _dueDate;
  late TimeOfDay _alarmTime;
  late bool _isImportant;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _alarmTime = const TimeOfDay(hour: 9, minute: 0);
    _dueDate = DateTime(
      now.year,
      now.month,
      now.day + 1,
      _alarmTime.hour,
      _alarmTime.minute,
    );
    _isImportant = widget.defaultImportant;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dueDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _alarmTime.hour,
          _alarmTime.minute,
        );
      });
    }
  }

  Future<void> _pickAlarmTime() async {
    final picked = await AppTimeUtils.show24HourTimePicker(
      context,
      initialTime: _alarmTime,
      helpText: 'HATIRLATICI SAATİ SEÇİN (24 SAAT - HH:mm)',
    );
    if (picked != null) {
      setState(() {
        _alarmTime = picked;
        _dueDate = DateTime(
          _dueDate.year,
          _dueDate.month,
          _dueDate.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newReminder = ReminderModel(
      id: const Uuid().v4(),
      title: title,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      dueDate: _dueDate,
      isImportant: _isImportant,
      isDone: false,
      createdAt: DateTime.now(),
    );

    context.read<ReminderBloc>().add(AddReminderEvent(newReminder));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = AppTimeUtils.formatDate(_dueDate);
    final timeStr = AppTimeUtils.formatTimeOfDay(_alarmTime);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.add_alert_rounded, color: AppColors.warning),
          SizedBox(width: 8),
          Text(
            'Hatırlatıcı Ekle (24s)',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Hatırlatıcı Başlığı *',
                  hintText: 'Örn: Faturayı Öde / İlaç Al',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Not (Opsiyonel)',
                  hintText: 'Ek ayrıntılar...',
                ),
              ),
              const SizedBox(height: 12),

              // Tarih ve 24 Saat Formatlı Alarm Saati Seçimi
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_rounded, size: 17),
                      label: Text('Tarih: $dateStr'),
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
                      onPressed: _pickAlarmTime,
                      icon: const Icon(
                        Icons.access_time_filled_rounded,
                        size: 17,
                        color: AppColors.warning,
                      ),
                      label: Text('Saat: $timeStr'),
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

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Row(
                  children: [
                    Icon(
                      Icons.priority_high_rounded,
                      color: AppColors.important,
                      size: 20,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Önemli (!) Olarak İşaretle',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                subtitle: const Text(
                  'Ana Panoda ünlemle vurgulanır ve Önemli Sayfası\'nda listelenir.',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                value: _isImportant,
                activeThumbColor: AppColors.important,
                onChanged: (val) => setState(() => _isImportant = val),
              ),
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
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.black,
          ),
          child: const Text(
            'Kaydet',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
