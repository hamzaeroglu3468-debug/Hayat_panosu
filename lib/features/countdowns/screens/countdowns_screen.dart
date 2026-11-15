import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../bloc/countdown_bloc.dart';
import '../bloc/countdown_event.dart';
import '../bloc/countdown_state.dart';
import 'add_countdown_dialog.dart';

class CountdownsScreen extends StatelessWidget {
  const CountdownsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.hourglass_bottom_rounded, color: AppColors.secondary),
            SizedBox(width: 8),
            Text('Geri Sayım Sayaçları'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Yeni Sayaç', style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () => AddCountdownDialog.show(context),
      ),
      body: BlocBuilder<CountdownBloc, CountdownState>(
        builder: (context, state) {
          if (state is CountdownLoadedState) {
            final list = state.upcomingCountdowns;
            if (list.isEmpty) {
              return const Center(
                child: Text('Henüz eklenmiş geri sayım bulunmuyor.',
                    style: TextStyle(color: AppColors.textMuted)),
              );
            }

            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.88,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final cd = list[index];
                final days = cd.daysRemaining;
                final dateStr = DateFormat('dd.MM.yyyy').format(cd.targetDate);

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.secondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                cd.category,
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                context.read<CountdownBloc>().add(DeleteCountdownEvent(cd.id));
                              },
                              child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Center(
                          child: Column(
                            children: [
                              Text(
                                days < 0 ? '0' : '$days',
                                style: const TextStyle(
                                  color: AppColors.secondary,
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                days < 0 ? 'Süre Doldu' : (days == 0 ? 'Bugün!' : 'GÜN KALDI'),
                                style: TextStyle(
                                  color: days <= 3 ? AppColors.important : AppColors.textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          cd.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateStr,
                          style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
