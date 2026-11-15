import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../constants/app_colors.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/finance/screens/finance_screen.dart';
import '../../features/penalties/bloc/penalty_bloc.dart';
import '../../features/penalties/bloc/penalty_state.dart';
import '../../features/reminders/bloc/reminder_bloc.dart';
import '../../features/reminders/bloc/reminder_state.dart';
import '../../features/reminders/screens/reminders_and_alarms_screen.dart';
import '../../features/weekly_planner/screens/weekly_planner_screen.dart';

/// Uygulamanın tek sayfalık (single-page) yapıdan çoklu sayfa (multi-page)
/// mimarisine geçişini yöneten kök ekran (RootScreen / MainLayout).
/// Sayfa durumlarını korumak için [IndexedStack] ve [BottomNavigationBar] kullanır.
class MainLayoutScreen extends StatefulWidget {
  final int initialIndex;

  const MainLayoutScreen({super.key, this.initialIndex = 0});

  /// Alt widget'lardan sekme değiştirmek için yardımcı metot.
  static bool switchTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainLayoutScreenState>();
    if (state != null) {
      state.setTabIndex(index);
      return true;
    }
    return false;
  }

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    DashboardScreen(), // 0: Ana Pano (Günlük akış, görevler, geri sayımlar & ünlemli hatırlatıcılar)
    WeeklyPlannerScreen(), // 1: Haftalık Program (Pazartesiden Pazara saatlik bloklar)
    RemindersAndAlarmsScreen(), // 2: Hatırlatıcılar, Alarmlar ve Minik Cezalar
    FinanceScreen(), // 3: Finans (Cüzdan, gelir/gider ve aylık planlı ödemeler)
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void setTabIndex(int index) {
    if (index >= 0 && index < _screens.length) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: setTabIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primaryLight,
          unselectedItemColor: AppColors.textMuted,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: 'Ana Pano',
              tooltip: 'Günlük Akış, Görevler ve Geri Sayımlar',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.calendar_view_week_outlined),
              activeIcon: Icon(Icons.calendar_view_week_rounded),
              label: 'Haftalık Plan',
              tooltip: 'Pazartesiden Pazara Saatlik Program',
            ),
            BottomNavigationBarItem(
              icon: _buildAlarmsPenaltyBadgeIcon(isActive: false),
              activeIcon: _buildAlarmsPenaltyBadgeIcon(isActive: true),
              label: 'Hatırlatıcı & Ceza',
              tooltip: 'Hatırlatıcılar ve Minik Cezalar',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet_rounded),
              label: 'Finans',
              tooltip: 'Cüzdan, Gelir/Gider ve Planlı Ödemeler',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlarmsPenaltyBadgeIcon({required bool isActive}) {
    return BlocBuilder<ReminderBloc, ReminderState>(
      builder: (context, reminderState) {
        return BlocBuilder<PenaltyBloc, PenaltyState>(
          builder: (context, penaltyState) {
            final importantReminders = reminderState is ReminderLoadedState
                ? reminderState.importantCount
                : 0;
            final activePenalties = penaltyState is PenaltyLoadedState
                ? penaltyState.unresolvedCount
                : 0;
            final totalBadge = importantReminders + activePenalties;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isActive ? Icons.alarm_rounded : Icons.alarm_outlined,
                ),
                if (totalBadge > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: importantReminders > 0
                            ? AppColors.important
                            : AppColors.danger,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$totalBadge',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }
}
