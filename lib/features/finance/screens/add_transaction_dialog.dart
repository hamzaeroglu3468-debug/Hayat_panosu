import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../models/transaction_model.dart';

class AddTransactionDialog extends StatefulWidget {
  final bool defaultIsIncome;

  const AddTransactionDialog({super.key, this.defaultIsIncome = false});

  static Future<void> show(BuildContext context, {bool defaultIsIncome = false}) {
    return showDialog(
      context: context,
      builder: (ctx) => AddTransactionDialog(defaultIsIncome: defaultIsIncome),
    );
  }

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  late bool _isIncome;
  String _category = 'Market';
  bool _isRecurring = false;
  String _recurringType = 'Aylık';

  final List<String> _incomeCategories = ['Maaş', 'Freelance', 'Yatırım Getirisi', 'Ek Gelir', 'Diğer'];
  final List<String> _expenseCategories = ['Market', 'Kira', 'Faturalar', 'Yeme-İçme', 'Ulaşım', 'Eğlence', 'Diğer'];

  @override
  void initState() {
    super.initState();
    _isIncome = widget.defaultIsIncome;
    _category = _isIncome ? _incomeCategories.first : _expenseCategories.first;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.replaceAll(',', '.').trim());

    if (title.isEmpty || amount == null || amount <= 0) return;

    final newTx = TransactionModel(
      id: const Uuid().v4(),
      title: title,
      amount: amount,
      isIncome: _isIncome,
      category: _category,
      date: DateTime.now(),
      isRecurring: _isRecurring,
      recurringType: _isRecurring ? _recurringType : null,
      createdAt: DateTime.now(),
    );

    context.read<FinanceBloc>().add(AddTransactionEvent(newTx));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = _isIncome ? _incomeCategories : _expenseCategories;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isIncome ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: _isIncome ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(width: 8),
          Text(_isIncome ? 'Gelir Ekle' : 'Gider Ekle',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Income / Expense segmented switch
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Gider')),
                      selected: !_isIncome,
                      selectedColor: AppColors.danger.withOpacity(0.3),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _isIncome = false;
                            _category = _expenseCategories.first;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Center(child: Text('Gelir')),
                      selected: _isIncome,
                      selectedColor: AppColors.success.withOpacity(0.3),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _isIncome = true;
                            _category = _incomeCategories.first;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              TextField(
                controller: _titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Açıklama / Kalem *',
                  hintText: 'Örn: Elektrik Faturası / Proje Avansı',
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Tutar (₺) *',
                  hintText: '0.00',
                  prefixText: '₺ ',
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Kategori'),
                dropdownColor: AppColors.surface,
                items: currentCategories.map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
              const SizedBox(height: 12),

              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: const Text('Planlı / Düzenli Ödeme'),
                subtitle: const Text('Aylık veya haftalık tekrarlayan ödemeler için',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                value: _isRecurring,
                activeColor: AppColors.primary,
                onChanged: (val) => setState(() => _isRecurring = val),
              ),

              if (_isRecurring) ...[
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _recurringType,
                  decoration: const InputDecoration(labelText: 'Periyot'),
                  dropdownColor: AppColors.surface,
                  items: const [
                    DropdownMenuItem(value: 'Haftalık', child: Text('Haftalık')),
                    DropdownMenuItem(value: 'Aylık', child: Text('Aylık')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _recurringType = val);
                  },
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
            backgroundColor: _isIncome ? AppColors.success : AppColors.danger,
            foregroundColor: Colors.white,
          ),
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
}
