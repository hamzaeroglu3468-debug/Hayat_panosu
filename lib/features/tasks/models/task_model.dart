import 'package:equatable/equatable.dart';

class TaskModel extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String time; // Başlangıç saati, örn: "09:00"
  final String? endTime; // Bitiş saati, örn: "10:30"
  final String? timeBlock; // "Sabah Bloğu", "Öğleden Sonra", "Akşam Bloğu"
  final String category; // "İş / Yazılım", "Kişisel", "Sağlık", "Eğitim"
  final bool isCompleted;
  final bool isImportant;
  final bool hasPenalty;
  final String? penaltyNote; // Örn: "Yapılmazsa 20 şınav"
  final bool hasReminder;
  final String? reminderNote;
  final String? sourceWeeklyPlanId; // Haftalık programdan aktarıldıysa ID'si
  final int? dayOfWeek; // 1 = Pazartesi ... 7 = Pazar
  final DateTime createdAt;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.time,
    this.endTime,
    this.timeBlock,
    this.category = 'Genel',
    this.isCompleted = false,
    this.isImportant = false,
    this.hasPenalty = false,
    this.penaltyNote,
    this.hasReminder = false,
    this.reminderNote,
    this.sourceWeeklyPlanId,
    this.dayOfWeek,
    required this.createdAt,
  });

  bool get isFromWeeklyPlan => sourceWeeklyPlanId != null;

  String get formattedTimeRange =>
      (endTime != null && endTime!.isNotEmpty) ? '$time - $endTime' : time;

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? time,
    String? endTime,
    String? timeBlock,
    String? category,
    bool? isCompleted,
    bool? isImportant,
    bool? hasPenalty,
    String? penaltyNote,
    bool? hasReminder,
    String? reminderNote,
    String? sourceWeeklyPlanId,
    int? dayOfWeek,
    DateTime? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      time: time ?? this.time,
      endTime: endTime ?? this.endTime,
      timeBlock: timeBlock ?? this.timeBlock,
      category: category ?? this.category,
      isCompleted: isCompleted ?? this.isCompleted,
      isImportant: isImportant ?? this.isImportant,
      hasPenalty: hasPenalty ?? this.hasPenalty,
      penaltyNote: penaltyNote ?? this.penaltyNote,
      hasReminder: hasReminder ?? this.hasReminder,
      reminderNote: reminderNote ?? this.reminderNote,
      sourceWeeklyPlanId: sourceWeeklyPlanId ?? this.sourceWeeklyPlanId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'endTime': endTime,
      'timeBlock': timeBlock,
      'category': category,
      'isCompleted': isCompleted,
      'isImportant': isImportant,
      'hasPenalty': hasPenalty,
      'penaltyNote': penaltyNote,
      'hasReminder': hasReminder,
      'reminderNote': reminderNote,
      'sourceWeeklyPlanId': sourceWeeklyPlanId,
      'dayOfWeek': dayOfWeek,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskModel.fromMap(Map<dynamic, dynamic> map) {
    return TaskModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String?,
      time: map['time'] as String? ?? '12:00',
      endTime: map['endTime'] as String?,
      timeBlock: map['timeBlock'] as String?,
      category: map['category'] as String? ?? 'Genel',
      isCompleted: map['isCompleted'] as bool? ?? false,
      isImportant: map['isImportant'] as bool? ?? false,
      hasPenalty: map['hasPenalty'] as bool? ?? false,
      penaltyNote: map['penaltyNote'] as String?,
      hasReminder: map['hasReminder'] as bool? ?? false,
      reminderNote: map['reminderNote'] as String?,
      sourceWeeklyPlanId: map['sourceWeeklyPlanId'] as String?,
      dayOfWeek: map['dayOfWeek'] as int?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        time,
        endTime,
        timeBlock,
        category,
        isCompleted,
        isImportant,
        hasPenalty,
        penaltyNote,
        hasReminder,
        reminderNote,
        sourceWeeklyPlanId,
        dayOfWeek,
        createdAt,
      ];
}
