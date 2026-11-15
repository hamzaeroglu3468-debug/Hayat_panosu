import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../features/tasks/models/task_model.dart';
import '../../features/reminders/models/reminder_model.dart';
import '../../features/penalties/models/penalty_model.dart';
import '../../features/countdowns/models/countdown_model.dart';
import '../../features/finance/models/transaction_model.dart';
import '../../features/weekly_planner/models/weekly_plan_item_model.dart';

class HiveService {
  static const String tasksBoxName = 'tasks_box';
  static const String remindersBoxName = 'reminders_box';
  static const String penaltiesBoxName = 'penalties_box';
  static const String countdownsBoxName = 'countdowns_box';
  static const String transactionsBoxName = 'transactions_box';
  static const String weeklyPlansBoxName = 'weekly_plans_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(tasksBoxName);
    await Hive.openBox(remindersBoxName);
    await Hive.openBox(penaltiesBoxName);
    await Hive.openBox(countdownsBoxName);
    await Hive.openBox(transactionsBoxName);
    await Hive.openBox(weeklyPlansBoxName);

    await _seedInitialDataIfEmpty();
  }

  static Box get _tasksBox => Hive.box(tasksBoxName);
  static Box get _remindersBox => Hive.box(remindersBoxName);
  static Box get _penaltiesBox => Hive.box(penaltiesBoxName);
  static Box get _countdownsBox => Hive.box(countdownsBoxName);
  static Box get _transactionsBox => Hive.box(transactionsBoxName);
  static Box get _weeklyPlansBox => Hive.box(weeklyPlansBoxName);

  // --- Seed Data ---
  static Future<void> _seedInitialDataIfEmpty() async {
    const uuid = Uuid();
    final now = DateTime.now();
    final todayWeekday = now.weekday; // 1 = Pazartesi ... 7 = Pazar

    // 1. Weekly Plans Seed (Pazartesi - Pazar + Bugünün Rutinleri)
    if (_weeklyPlansBox.isEmpty) {
      final defaultWeeklyPlans = [
        // Bugünün haftalık plan maddeleri (kesinlikle bugünün akışında da görünmesi için)
        WeeklyPlanItemModel(
          id: 'wp_today_1',
          dayOfWeek: todayWeekday,
          startTime: '09:30',
          endTime: '11:00',
          timeBlock: 'Sabah Bloğu',
          title: 'Algoritma & Veri Yapıları Çalışma Bloğu',
          description: 'Haftalık ders programından aktarılan derin odaklanma (Deep Work) seansı.',
          category: 'Ders / Eğitim',
          isImportant: true,
          hasPenalty: true,
          penaltyNote: 'Kaçırılırsa: +1 saat ekstra problem çözümü ve 20 şınav',
          hasReminder: true,
          reminderNote: 'Ders başlamadan 15 dk önce masada ol',
          isSyncedToDaily: true,
          isCompletedToday: false,
          createdAt: now,
        ),
        WeeklyPlanItemModel(
          id: 'wp_today_2',
          dayOfWeek: todayWeekday,
          startTime: '14:00',
          endTime: '16:00',
          timeBlock: 'Öğleden Sonra',
          title: 'Flutter Hayat Panosu Sprint Geliştirmesi',
          description: 'Haftalık çalışma planı kapsamında modül testleri ve UI iyileştirmeleri.',
          category: 'İş / Yazılım',
          isImportant: false,
          hasPenalty: true,
          penaltyNote: 'Tamamlanmazsa: Akşam dizi/oyun süresi iptal',
          hasReminder: true,
          reminderNote: 'Kahveni hazırla ve bildirimleri sessize al',
          isSyncedToDaily: true,
          isCompletedToday: false,
          createdAt: now,
        ),
        WeeklyPlanItemModel(
          id: 'wp_today_3',
          dayOfWeek: todayWeekday,
          startTime: '18:30',
          endTime: '19:30',
          timeBlock: 'Akşam Bloğu',
          title: 'Fonksiyonel Antrenman & Kardiyo',
          description: 'Haftalık spor rutini: 45 dk antrenman + 15 dk esneme.',
          category: 'Spor / Sağlık',
          isImportant: false,
          hasPenalty: true,
          penaltyNote: 'Aksatılırsa: 40 Şınav + 50 TL Ceza Kumbarasına',
          hasReminder: false,
          isSyncedToDaily: false, // Tek tıkla aktarmayı göstermek için hazır
          isCompletedToday: false,
          createdAt: now,
        ),

        // Diğer günler için örnek haftalık program maddeleri
        WeeklyPlanItemModel(
          id: uuid.v4(),
          dayOfWeek: 1, // Pazartesi
          startTime: '08:30',
          endTime: '09:30',
          timeBlock: 'Sabah Bloğu',
          title: 'Haftalık Hedef & Bütçe Planlama Toplantısı',
          description: 'Tüm haftanın görevlerini ve finansal hedeflerini gözden geçir.',
          category: 'Kişisel Rutin',
          isImportant: true,
          hasPenalty: false,
          hasReminder: true,
          reminderNote: 'Pazartesi sabah 08:15 alarmı',
          isSyncedToDaily: true,
          createdAt: now,
        ),
        WeeklyPlanItemModel(
          id: uuid.v4(),
          dayOfWeek: 2, // Salı
          startTime: '10:00',
          endTime: '12:00',
          timeBlock: 'Sabah Bloğu',
          title: 'Mobil Mimari & State Management Ders Bloğu',
          description: 'BLoC, Clean Architecture ve performans optimizasyonu.',
          category: 'Ders / Eğitim',
          isImportant: true,
          hasPenalty: true,
          penaltyNote: 'Özet çıkarılmazsa: 25 sayfa teknik makale okuma cezası',
          isSyncedToDaily: true,
          createdAt: now,
        ),
        WeeklyPlanItemModel(
          id: uuid.v4(),
          dayOfWeek: 3, // Çarşamba
          startTime: '15:00',
          endTime: '17:00',
          timeBlock: 'Öğleden Sonra',
          title: 'İngilizce Konuşma & Kelime Pratiği',
          description: '30 dk speaking club + 50 yeni akademik kelime tekrarı.',
          category: 'Ders / Eğitim',
          isImportant: false,
          hasPenalty: true,
          penaltyNote: 'Yapılmazsa: 30 dk İngilizce podcast dinleme',
          isSyncedToDaily: true,
          createdAt: now,
        ),
        WeeklyPlanItemModel(
          id: uuid.v4(),
          dayOfWeek: 4, // Perşembe
          startTime: '19:00',
          endTime: '20:30',
          timeBlock: 'Akşam Bloğu',
          title: 'Yüzme veya Açık Hava Koşusu',
          description: 'En az 5 km tempolu koşu veya 1 saat yüzme.',
          category: 'Spor / Sağlık',
          isImportant: false,
          hasPenalty: true,
          penaltyNote: 'Aksatılırsa: 35 Burpee egzersizi',
          isSyncedToDaily: true,
          createdAt: now,
        ),
        WeeklyPlanItemModel(
          id: uuid.v4(),
          dayOfWeek: 5, // Cuma
          startTime: '16:00',
          endTime: '17:30',
          timeBlock: 'Öğleden Sonra',
          title: 'Haftalık Değerlendirme & Finans Kontrolü',
          description: 'Gelir-gider tablosunu güncelle, haftanın tamamlanan görevlerini incele.',
          category: 'Finans',
          isImportant: true,
          hasPenalty: false,
          isSyncedToDaily: true,
          createdAt: now,
        ),
      ];

      for (var item in defaultWeeklyPlans) {
        await _weeklyPlansBox.put(item.id, item.toMap());
      }
    }

    // 2. Tasks Seed (Bugünün özel görevleri + Haftalık plandan senkronize olanlar)
    if (_tasksBox.isEmpty) {
      final defaultTasks = [
        TaskModel(
          id: uuid.v4(),
          title: 'Sabah Rutini & Günlük Planlama',
          description: 'Günün önceliklerini belirle, 2 bardak su iç ve esneme yap.',
          time: '08:30',
          endTime: '09:00',
          timeBlock: 'Sabah Bloğu',
          category: 'Kişisel',
          isCompleted: true,
          isImportant: false,
          hasPenalty: false,
          createdAt: now,
        ),
        TaskModel(
          id: uuid.v4(),
          title: 'Kitap Okuma (30 Sayfa)',
          description: 'Atomik Alışkanlıklar kitabından 30 sayfa oku ve not çıkar.',
          time: '21:30',
          endTime: '22:15',
          timeBlock: 'Akşam Bloğu',
          category: 'Eğitim',
          isCompleted: false,
          isImportant: false,
          hasPenalty: true,
          penaltyNote: 'Aksatılırsa: Ertesi gün sosyal medya yok!',
          createdAt: now,
        ),
      ];

      for (var task in defaultTasks) {
        await _tasksBox.put(task.id, task.toMap());
      }
    }

    // Bugünün haftalık planlarından isSyncedToDaily == true olanları günlük görev listesiyle senkronize et
    await syncTodayWeeklyPlansToTasks();

    // 3. Reminders Seed
    if (_remindersBox.isEmpty) {
      final defaultReminders = [
        ReminderModel(
          id: uuid.v4(),
          title: 'Kira ve Aidat Ödemesi',
          note: 'Ev sahibinin IBAN numarasına gönderilecek, dekont arşivlenecek.',
          dueDate: now.add(const Duration(days: 1)),
          isImportant: true,
          isDone: false,
          createdAt: now,
        ),
        ReminderModel(
          id: uuid.v4(),
          title: 'Haftalık Proje Değerlendirmesi',
          note: 'Eksik maddeler çıkarılıp haftalık program güncellenecek.',
          dueDate: now.add(const Duration(days: 3)),
          isImportant: false,
          isDone: false,
          createdAt: now,
        ),
      ];

      for (var reminder in defaultReminders) {
        await _remindersBox.put(reminder.id, reminder.toMap());
      }
    }

    // 4. Penalties Seed
    if (_penaltiesBox.isEmpty) {
      final defaultPenalties = [
        PenaltyModel(
          id: uuid.v4(),
          title: 'Akşam Sporunu Atlama',
          penaltyAction: '30 Şınav + 20 Mekik Çek',
          isResolved: false,
          createdAt: now.subtract(const Duration(hours: 12)),
        ),
      ];

      for (var penalty in defaultPenalties) {
        await _penaltiesBox.put(penalty.id, penalty.toMap());
      }
    }

    // 5. Countdowns Seed
    if (_countdownsBox.isEmpty) {
      final defaultCountdowns = [
        CountdownModel(
          id: uuid.v4(),
          title: 'Hayat Panosu v1.0 Lansmanı',
          targetDate: now.add(const Duration(days: 12)),
          category: 'Hedef',
          createdAt: now,
        ),
        CountdownModel(
          id: uuid.v4(),
          title: 'Yılbaşı Hedefleri & Yeni Yıl',
          targetDate: DateTime(now.year + 1, 1, 1),
          category: 'Özel Gün',
          createdAt: now,
        ),
      ];

      for (var countdown in defaultCountdowns) {
        await _countdownsBox.put(countdown.id, countdown.toMap());
      }
    }

    // 6. Transactions Seed
    if (_transactionsBox.isEmpty) {
      final defaultTransactions = [
        TransactionModel(
          id: uuid.v4(),
          title: 'Aylık Yazılım Geliri / Maaş',
          amount: 45000.0,
          isIncome: true,
          category: 'Maaş',
          date: now.subtract(const Duration(days: 4)),
          isRecurring: true,
          recurringType: 'Aylık',
          createdAt: now,
        ),
        TransactionModel(
          id: uuid.v4(),
          title: 'Ofis / Ev Kirası',
          amount: 14500.0,
          isIncome: false,
          category: 'Kira',
          date: now.add(const Duration(days: 1)),
          isRecurring: true,
          recurringType: 'Aylık',
          createdAt: now,
        ),
        TransactionModel(
          id: uuid.v4(),
          title: 'Market ve Mutfak Harcaması',
          amount: 2450.0,
          isIncome: false,
          category: 'Market',
          date: now.subtract(const Duration(days: 1)),
          isRecurring: false,
          createdAt: now,
        ),
      ];

      for (var t in defaultTransactions) {
        await _transactionsBox.put(t.id, t.toMap());
      }
    }
  }

  // --- Weekly Planner Operations & Synchronization ---
  static List<WeeklyPlanItemModel> getWeeklyPlans() {
    final list = _weeklyPlansBox.values
        .map((e) => WeeklyPlanItemModel.fromMap(e as Map))
        .toList();
    list.sort((a, b) {
      final dayCmp = a.dayOfWeek.compareTo(b.dayOfWeek);
      if (dayCmp != 0) return dayCmp;
      return a.startTime.compareTo(b.startTime);
    });
    return list;
  }

  static Future<void> saveWeeklyPlan(WeeklyPlanItemModel item) async {
    await _weeklyPlansBox.put(item.id, item.toMap());
    if (item.isSyncedToDaily) {
      final task = item.toTaskModel();
      await _tasksBox.put(task.id, task.toMap());
    } else {
      final taskId = 'weekly_${item.id}_task';
      if (_tasksBox.containsKey(taskId)) {
        await _tasksBox.delete(taskId);
      }
    }
  }

  static Future<void> deleteWeeklyPlan(String id) async {
    await _weeklyPlansBox.delete(id);
    final linkedTaskId = 'weekly_${id}_task';
    if (_tasksBox.containsKey(linkedTaskId)) {
      await _tasksBox.delete(linkedTaskId);
    }
  }

  static Future<void> syncTodayWeeklyPlansToTasks() async {
    final todayWeekday = DateTime.now().weekday;
    final plans = getWeeklyPlans();
    for (final plan in plans) {
      if (plan.dayOfWeek == todayWeekday && plan.isSyncedToDaily) {
        final taskId = 'weekly_${plan.id}_task';
        if (!_tasksBox.containsKey(taskId)) {
          final task = plan.toTaskModel(taskId: taskId);
          await _tasksBox.put(taskId, task.toMap());
        }
      }
    }
  }

  // --- Task Operations ---
  static List<TaskModel> getTasks() {
    final list = _tasksBox.values.map((e) => TaskModel.fromMap(e as Map)).toList();
    list.sort((a, b) => a.time.compareTo(b.time));
    return list;
  }

  static Future<void> saveTask(TaskModel task) async {
    await _tasksBox.put(task.id, task.toMap());
    // Eğer bu görev bir haftalık plan kaleminden senkronize edildiyse, haftalık planı da güncel tut
    if (task.sourceWeeklyPlanId != null) {
      final raw = _weeklyPlansBox.get(task.sourceWeeklyPlanId);
      if (raw != null) {
        final plan = WeeklyPlanItemModel.fromMap(raw as Map);
        final updatedPlan = plan.copyWith(
          isCompletedToday: task.isCompleted,
          isImportant: task.isImportant,
          hasPenalty: task.hasPenalty,
          penaltyNote: task.penaltyNote,
          hasReminder: task.hasReminder,
          reminderNote: task.reminderNote,
        );
        await _weeklyPlansBox.put(updatedPlan.id, updatedPlan.toMap());
      }
    }
  }

  static Future<void> deleteTask(String id) async {
    final raw = _tasksBox.get(id);
    if (raw != null) {
      final task = TaskModel.fromMap(raw as Map);
      if (task.sourceWeeklyPlanId != null) {
        final wpRaw = _weeklyPlansBox.get(task.sourceWeeklyPlanId);
        if (wpRaw != null) {
          final plan = WeeklyPlanItemModel.fromMap(wpRaw as Map);
          await _weeklyPlansBox.put(
            plan.id,
            plan.copyWith(isSyncedToDaily: false).toMap(),
          );
        }
      }
    }
    await _tasksBox.delete(id);
  }

  // --- Reminder Operations ---
  static List<ReminderModel> getReminders() {
    return _remindersBox.values.map((e) => ReminderModel.fromMap(e as Map)).toList();
  }

  static Future<void> saveReminder(ReminderModel reminder) async {
    await _remindersBox.put(reminder.id, reminder.toMap());
  }

  static Future<void> deleteReminder(String id) async {
    await _remindersBox.delete(id);
  }

  // --- Penalty Operations ---
  static List<PenaltyModel> getPenalties() {
    return _penaltiesBox.values.map((e) => PenaltyModel.fromMap(e as Map)).toList();
  }

  static Future<void> savePenalty(PenaltyModel penalty) async {
    await _penaltiesBox.put(penalty.id, penalty.toMap());
  }

  static Future<void> deletePenalty(String id) async {
    await _penaltiesBox.delete(id);
  }

  // --- Countdown Operations ---
  static List<CountdownModel> getCountdowns() {
    return _countdownsBox.values.map((e) => CountdownModel.fromMap(e as Map)).toList();
  }

  static Future<void> saveCountdown(CountdownModel countdown) async {
    await _countdownsBox.put(countdown.id, countdown.toMap());
  }

  static Future<void> deleteCountdown(String id) async {
    await _countdownsBox.delete(id);
  }

  // --- Transaction Operations ---
  static List<TransactionModel> getTransactions() {
    return _transactionsBox.values.map((e) => TransactionModel.fromMap(e as Map)).toList();
  }

  static Future<void> saveTransaction(TransactionModel transaction) async {
    await _transactionsBox.put(transaction.id, transaction.toMap());
  }

  static Future<void> deleteTransaction(String id) async {
    await _transactionsBox.delete(id);
  }
}
