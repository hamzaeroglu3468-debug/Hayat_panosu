import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/constants/app_theme.dart';
import 'core/database/hive_service.dart';
import 'core/navigation/main_layout_screen.dart';
import 'features/countdowns/bloc/countdown_bloc.dart';
import 'features/countdowns/bloc/countdown_event.dart';
import 'features/finance/bloc/finance_bloc.dart';
import 'features/finance/bloc/finance_event.dart';
import 'features/penalties/bloc/penalty_bloc.dart';
import 'features/penalties/bloc/penalty_event.dart';
import 'features/reminders/bloc/reminder_bloc.dart';
import 'features/reminders/bloc/reminder_event.dart';
import 'features/tasks/bloc/task_bloc.dart';
import 'features/tasks/bloc/task_event.dart';
import 'features/weekly_planner/bloc/weekly_planner_bloc.dart';
import 'features/weekly_planner/bloc/weekly_planner_event.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Türkçe tarih/saat formatlamasını başlat
  await initializeDateFormatting('tr_TR', null);

  // 2. Hive yerel veritabanını başlat
  await HiveService.init();

  runApp(const HayatPanosuApp());
}

class HayatPanosuApp extends StatelessWidget {
  const HayatPanosuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TaskBloc>(
          create: (context) => TaskBloc()..add(LoadTasksEvent()),
        ),
        BlocProvider<WeeklyPlannerBloc>(
          create: (context) =>
              WeeklyPlannerBloc()..add(LoadWeeklyPlansEvent()),
        ),
        BlocProvider<ReminderBloc>(
          create: (context) => ReminderBloc()..add(LoadRemindersEvent()),
        ),
        BlocProvider<PenaltyBloc>(
          create: (context) => PenaltyBloc()..add(LoadPenaltiesEvent()),
        ),
        BlocProvider<CountdownBloc>(
          create: (context) => CountdownBloc()..add(LoadCountdownsEvent()),
        ),
        BlocProvider<FinanceBloc>(
          create: (context) => FinanceBloc()..add(LoadFinanceEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Hayat Panosu',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        // Uygulama genelinde tüm saat seçicilerde ve bileşenlerde 24 saat (HH:mm) formatını zorunlu kıl
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: true,
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        home: const MainLayoutScreen(),
      ),
    );
  }
}
