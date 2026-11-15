import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../penalties/bloc/penalty_bloc.dart';
import '../../penalties/bloc/penalty_event.dart';
import '../../penalties/bloc/penalty_state.dart';
import '../../penalties/screens/add_penalty_dialog.dart';
import '../../penalties/screens/penalties_screen.dart';

class PenaltiesSection extends StatelessWidget {
  const PenaltiesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PenaltyBloc, PenaltyState>(
      builder: (context, state) {
        if (state is PenaltyLoadedState) {
          final count = state.unresolvedCount;
          final activeList = state.activePenalties;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: count > 0 ? AppColors.danger.withOpacity(0.4) : AppColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.gavel_rounded,
                              color: AppColors.danger, size: 18),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Minik Cezalar Modülü',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PenaltiesScreen()),
                        );
                      },
                      child: Row(
                        children: [
                          if (count > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              margin: const EdgeInsets.only(right: 6),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '$count Aktif',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (activeList.isEmpty)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Şu anda bekleyen aktif bir cezanız yok.',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      TextButton.icon(
                        onPressed: () => AddPenaltyDialog.show(context),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Ekle'),
                        style: TextButton.styleFrom(foregroundColor: AppColors.danger),
                      ),
                    ],
                  )
                else ...[
                  // Show the most pressing active penalty
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.danger.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeList.first.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Ceza: ${activeList.first.penaltyAction}',
                                style: const TextStyle(
                                  color: AppColors.danger,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Cezayı Öde',
                          icon: const Icon(Icons.check_circle_outline_rounded,
                              color: AppColors.success),
                          onPressed: () {
                            context
                                .read<PenaltyBloc>()
                                .add(ResolvePenaltyEvent(activeList.first.id));
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
