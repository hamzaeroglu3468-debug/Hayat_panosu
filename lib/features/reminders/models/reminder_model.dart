import 'package:equatable/equatable.dart';

class ReminderModel extends Equatable {
  final String id;
  final String title;
  final String? note;
  final DateTime dueDate;
  final bool isImportant;
  final bool isDone;
  final DateTime createdAt;

  const ReminderModel({
    required this.id,
    required this.title,
    this.note,
    required this.dueDate,
    this.isImportant = false,
    this.isDone = false,
    required this.createdAt,
  });

  ReminderModel copyWith({
    String? id,
    String? title,
    String? note,
    DateTime? dueDate,
    bool? isImportant,
    bool? isDone,
    DateTime? createdAt,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      note: note ?? this.note,
      dueDate: dueDate ?? this.dueDate,
      isImportant: isImportant ?? this.isImportant,
      isDone: isDone ?? this.isDone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'note': note,
      'dueDate': dueDate.toIso8601String(),
      'isImportant': isImportant,
      'isDone': isDone,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReminderModel.fromMap(Map<dynamic, dynamic> map) {
    return ReminderModel(
      id: map['id'] as String,
      title: map['title'] as String,
      note: map['note'] as String?,
      dueDate: DateTime.parse(map['dueDate'] as String),
      isImportant: map['isImportant'] as bool? ?? false,
      isDone: map['isDone'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        note,
        dueDate,
        isImportant,
        isDone,
        createdAt,
      ];
}
