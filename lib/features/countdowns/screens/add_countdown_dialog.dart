import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/countdown_bloc.dart';
import '../bloc/countdown_event.dart';
import '../models/countdown_model.dart';

class AddCountdownDialog extends StatefulWidget {
  const AddCountdownDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (ctx) => const AddCountdownDialog(),
    );
  }

  @override
  State<AddCountdownDialog> createState() => _AddCountdownDialogState();
}

class _AddCountdownDialogState extends State<AddCountdownDialog> {
  final _titleController = TextEditingController();
  DateTime _targetDate = DateTime.now().add(const Duration(days: 30));
  String _category = 'Hedef';

  final List<String> _categories = ['Hedef', 'Sınav / Proje', 'Tatil', 'Özel Gün', 'Diğer'];

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null) {
      setState(() => _targetDate = picked);
    }
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final newCountdown = CountdownModel(
      id: const Uuid().v4(),
      title: title,
      targetDate: _targetDate,
      category: _category,
      createdAt: DateTime.now(),
    );

    context.read<CountdownBloc>().add(AddCountdownEvent(newCountdown));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy').format(_targetDate);

    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: AppColors.secondary),
          SizedBox(width: 8),
          Text('Yeni Geri Sayım', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Etkinlik / Hedef Adı *',
                  hintText: 'Örn: Finaller / Tatil Başlangıcı',
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_rounded, size: 18),
                label: Text('Hedef Tarih: $dateStr'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary,
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                dropdownColor: AppColors.surface,
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
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
            backgroundColor: AppColors.secondary,
            foregroundColor: Colors.black,
          ),
          child: const Text('Başlat', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}
