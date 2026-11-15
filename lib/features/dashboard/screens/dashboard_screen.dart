import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/live_clock_widget.dart';
import '../../reminders/bloc/reminder_bloc.dart';
import '../../reminders/bloc/reminder_state.dart';
import '../../reminders/screens/important_items_screen.dart';
import '../widgets/countdown_section.dart';
import '../widgets/daily_flow_section.dart';
import '../widgets/important_alert_banner.dart';
import '../widgets/quick_action_sheet.dart';

/// Ana Pano (Sayfa 1):
/// Cihaz saatiyle tam senkronize canlı saat (`LiveClockWidget`), ünlemli hatırlatıcılar,
/// o günün görevleri ve öne çıkan geri sayımları barındırır.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dayStr = DateFormat('EEEE, d MMMM', 'tr_TR').format(now);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hayat Panosu',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              dayStr,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Cihaz saatiyle saniye bazında senkronize canlı 24s saat rozeti
          const LiveClockWidget(compact: true, showSeconds: true),
          const SizedBox(width: 4),

          // Ünlemli (!) Önemli Maddeler Sayfası Kısayolu
          BlocBuilder<ReminderBloc, ReminderState>(
            builder: (context, state) {
              final hasImportant =
                  state is ReminderLoadedState && state.hasActiveImportant;
              final count =
                  state is ReminderLoadedState ? state.importantCount : 0;

              return IconButton(
                tooltip: 'Önemli Sayfası (!)',
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(
                      Icons.priority_high_rounded,
                      color: hasImportant
                          ? AppColors.important
                          : AppColors.textSecondary,
                      size: 24,
                    ),
                    if (hasImportant)
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.important,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ImportantItemsScreen(),
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Hızlı Ekle',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () => QuickActionSheet.show(context),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: const [
            // 0. Gerçek Zamanlı Cihaz Saati Kartı (HH:mm:ss - 24 Saat Formatı)
            LiveClockWidget(showSeconds: true),
            SizedBox(height: 16),

            // 1. Ünlemli (!) Önemli ve Öncelikli Hatırlatıcılar Bandı
            ImportantAlertBanner(),

            // 2. Günlük Akış & O Günün Görevleri (24 Saat HH:mm Formatında)
            DailyFlowSection(),
            SizedBox(height: 24),

            // 3. Öne Çıkan Geri Sayımlar (Countdowns)
            CountdownSection(),
            SizedBox(height: 80), // FAB boşluğu
          ],
        ),
      ),
    );
  }
}
