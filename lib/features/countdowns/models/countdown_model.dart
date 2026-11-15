import 'package:equatable/equatable.dart';

class CountdownModel extends Equatable {
  final String id;
  final String title;
  final DateTime targetDate;
  final String category;
  final int? colorValue;
  final DateTime createdAt;

  const CountdownModel({
    required this.id,
    required this.title,
    required this.targetDate,
    this.category = 'Genel',
    this.colorValue,
    required this.createdAt,
  });

  int get daysRemaining {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    return target.difference(today).inDays;
  }

  bool get isExpired => daysRemaining < 0;
  bool get isToday => daysRemaining == 0;

  CountdownModel copyWith({
    String? id,
    String? title,
    DateTime? targetDate,
    String? category,
    int? colorValue,
    DateTime? createdAt,
  }) {
    return CountdownModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      category: category ?? this.category,
      colorValue: colorValue ?? this.colorValue,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetDate': targetDate.toIso8601String(),
      'category': category,
      'colorValue': colorValue,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CountdownModel.fromMap(Map<dynamic, dynamic> map) {
    return CountdownModel(
      id: map['id'] as String,
      title: map['title'] as String,
      targetDate: DateTime.parse(map['targetDate'] as String),
      category: map['category'] as String? ?? 'Genel',
      colorValue: map['colorValue'] as int?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        targetDate,
        category,
        colorValue,
        createdAt,
      ];
}
