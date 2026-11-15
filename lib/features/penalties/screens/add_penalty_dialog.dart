import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/penalty_bloc.dart';
import '../bloc/penalty_event.dart';
import '../models/penalty_model.dart';

class AddPenaltyDialog extends StatefulWidget {
  final String? relatedTaskId;
  final String? defaultTitle;

  const AddPenaltyDialog({
    super.key,
    this.relatedTaskId,
    this.defaultTitle,
  });

  static Future<void> show(BuildContext context, {String? relatedTaskId, String? defaultTitle}) {
    return showDialog(
      context: context,
      builder: (ctx) => AddPenaltyDialog(
        relatedTaskId: relatedTaskId,
        defaultTitle: defaultTitle,
      ),
    );
  }

  @override
  State<AddPenaltyDialog> createState() => _AddPenaltyDialogState();
}

class _AddPenaltyDialogState extends State<AddPenaltyDialog> {
  final _titleController = TextEditingController();
  final _actionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.defaultTitle != null) {
      _titleController.text = widget.defaultTitle!;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final action = _actionController.text.trim();
    if (title.isEmpty || action.isEmpty) return;

    final newPenalty = PenaltyModel(
      id: const Uuid().v4(),
      title: title,
      penaltyAction: action,
      relatedTaskId: widget.relatedTaskId,
      isResolved: false,
      createdAt: DateTime.now(),
    );

    context.read<PenaltyBloc>().add(AddPenaltyEvent(newPenalty));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.gavel_rounded, color: AppColors.danger),
          SizedBox(width: 8),
          Text('Yeni Ceza Kaydı', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  labelText: 'İhlal Edilen Görev / Sebep *',
                  hintText: 'Örn: Sabah Sporu Aksatıldı',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _actionController,
                decoration: const InputDecoration(
                  labelText: 'Uygulanacak Minik Ceza *',
                  hintText: 'Örn: 30 Şınav / 50 TL ceza kumbarasına',
                ),
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
            backgroundColor: AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: const Text('Ceza Kes'),
        ),
      ],
    );
  }
}
