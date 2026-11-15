import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../countdowns/screens/add_countdown_dialog.dart';
import '../../finance/screens/add_transaction_dialog.dart';
import '../../penalties/screens/add_penalty_dialog.dart';
import '../../reminders/screens/add_reminder_dialog.dart';
import '../../tasks/screens/add_task_dialog.dart';
import '../../weekly_planner/screens/add_weekly_plan_dialog.dart';

class QuickActionSheet extends StatelessWidget {
  const QuickActionSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const QuickActionSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Hızlı İşlem Ekle',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              _actionItem(
                context,
                icon: Icons.add_task_rounded,
                color: AppColors.primary,
                label: 'Günlük Görev',
                onTap: () {
                  Navigator.pop(context);
                  AddTaskDialog.show(context);
                },
              ),
              _actionItem(
                context,
                icon: Icons.calendar_view_week_rounded,
                color: AppColors.secondary,
                label: 'Haftalık Blok',
                onTap: () {
                  Navigator.pop(context);
                  AddWeeklyPlanDialog.show(context);
                },
              ),
              _actionItem(
                context,
                icon: Icons.alarm_add_rounded,
                color: AppColors.warning,
                label: 'Hatırlatıcı',
                onTap: () {
                  Navigator.pop(context);
                  AddReminderDialog.show(context);
                },
              ),
              _actionItem(
                context,
                icon: Icons.gavel_rounded,
                color: AppColors.danger,
                label: 'Minik Ceza',
                onTap: () {
                  Navigator.pop(context);
                  AddPenaltyDialog.show(context);
                },
              ),
              _actionItem(
                context,
                icon: Icons.hourglass_top_rounded,
                color: AppColors.primaryLight,
                label: 'Geri Sayım',
                onTap: () {
                  Navigator.pop(context);
                  AddCountdownDialog.show(context);
                },
              ),
              _actionItem(
                context,
                icon: Icons.payments_rounded,
                color: AppColors.success,
                label: 'Finans',
                onTap: () {
                  Navigator.pop(context);
                  AddTransactionDialog.show(context);
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _actionItem(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 92,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
