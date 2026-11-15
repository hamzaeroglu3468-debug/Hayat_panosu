import 'package:equatable/equatable.dart';
import '../../tasks/models/task_model.dart';

class WeeklyPlanItemModel extends Equatable {
  final String id;
  final int dayOfWeek; // 1 = Pazartesi ... 7 = Pazar
  final String startTime; // Örn: "09:00"
  final String endTime; // Örn: "10:30"
  final String timeBlock; // "Sabah Bloğu", "Öğle Bloğu", "Öğleden Sonra", "Akşam Bloğu"
  final String title;
  final String? description;
  final String category;
  final bool isImportant;
  final bool hasPenalty;
  final String? penaltyNote;
  final bool hasReminder;
  final String? reminderNote;
  final bool isSyncedToDaily;
  final bool isCompletedToday;
  final DateTime createdAt;

  const WeeklyPlanItemModel({
    required this.id,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.timeBlock = 'Sabah Bloğu',
    required this.title,
    this.description,
    this.category = 'Ders / Eğitim',
    this.isImportant = false,
    this.hasPenalty = false,
    this.penaltyNote,
    this.hasReminder = false,
    this.reminderNote,
    this.isSyncedToDaily = true,
    this.isCompletedToday = false,
    required this.createdAt,
  });

  static const List<String> dayNames = [
    'Pazartesi',
    'Salı',
    'Çarşamba',
    'Perşembe',
    'Cuma',
    'Cumartesi',
    'Pazar',
  ];

  static const List<String> shortDayNames = [
    'Pzt',
    'Sal',
    'Çar',
    'Per',
    'Cum',
    'Cmt',
    'Paz',
  ];

  String get dayName => dayNames[(dayOfWeek - 1).clamp(0, 6)];
  String get shortDayName => shortDayNames[(dayOfWeek - 1).clamp(0, 6)];
  String get formattedTimeRange => '$startTime - $endTime';

  TaskModel toTaskModel({String? taskId}) {
    return TaskModel(
      id: taskId ?? 'weekly_${id}_task',
      title: title,
      description: description,
      time: startTime,
      endTime: endTime,
      timeBlock: timeBlock,
      category: category,
      isCompleted: isCompletedToday,
      isImportant: isImportant,
      hasPenalty: hasPenalty,
      penaltyNote: penaltyNote,
      hasReminder: hasReminder,
      reminderNote: reminderNote,
      sourceWeeklyPlanId: id,
      dayOfWeek: dayOfWeek,
      createdAt: createdAt,
    );
  }

  WeeklyPlanItemModel copyWith({
    String? id,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? timeBlock,
    String? title,
    String? description,
    String? category,
    bool? isImportant,
    bool? hasPenalty,
    String? penaltyNote,
    bool? hasReminder,
    String? reminderNote,
    bool? isSyncedToDaily,
    bool? isCompletedToday,
    DateTime? createdAt,
  }) {
    return WeeklyPlanItemModel(
      id: id ?? this.id,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      timeBlock: timeBlock ?? this.timeBlock,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isImportant: isImportant ?? this.isImportant,
      hasPenalty: hasPenalty ?? this.hasPenalty,
      penaltyNote: penaltyNote ?? this.penaltyNote,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderNote: reminderNote ?? this.reminderNote,
      isSyncedToDaily: isSyncedToDaily ?? this.isSyncedToDaily,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'timeBlock': timeBlock,
      'title': title,
      'description': description,
      'category': category,
      'isImportant': isImportant,
      'hasPenalty': hasPenalty,
      'penaltyNote': penaltyNote,
      'hasReminder': hasReminder,
      'reminderNote': reminderNote,
      'isSyncedToDaily': isSyncedToDaily,
      'isCompletedToday': isCompletedToday,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory WeeklyPlanItemModel.fromMap(Map<dynamic, dynamic> map) {
    return WeeklyPlanItemModel(
      id: map['id'] as String,
      dayOfWeek: map['dayOfWeek'] as int? ?? 1,
      startTime: map['startTime'] as String? ?? '09:00',
      endTime: map['endTime'] as String? ?? '10:00',
      timeBlock: map['timeBlock'] as String? ?? 'Sabah Bloğu',
      title: map['title'] as String,
      description: map['description'] as String?,
      category: map['category'] as String? ?? 'Ders / Eğitim',
      isImportant: map['isImportant'] as bool? ?? false,
      hasPenalty: map['hasPenalty'] as bool? ?? false,
      penaltyNote: map['penaltyNote'] as String?,
      hasReminder: map['hasReminder'] as bool? ?? false,
      reminderNote: map['reminderNote'] as String?,
      isSyncedToDaily: map['isSyncedToDaily'] as bool? ?? true,
      isCompletedToday: map['isCompletedToday'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        dayOfWeek,
        startTime,
        endTime,
        timeBlock,
        title,
        description,
        category,
        isImportant,
        hasPenalty,
        penaltyNote,
        hasReminder,
        reminderNote,
        isSyncedToDaily,
        isCompletedToday,
        createdAt,
      ];
}
