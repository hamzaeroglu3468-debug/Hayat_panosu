import 'package:equatable/equatable.dart';

class TransactionModel extends Equatable {
  final String id;
  final String title;
  final double amount;
  final bool isIncome;
  final String category;
  final DateTime date;
  final bool isRecurring;
  final String? recurringType; // "Haftalık", "Aylık"
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.category,
    required this.date,
    this.isRecurring = false,
    this.recurringType,
    required this.createdAt,
  });

  TransactionModel copyWith({
    String? id,
    String? title,
    double? amount,
    bool? isIncome,
    String? category,
    DateTime? date,
    bool? isRecurring,
    String? recurringType,
    DateTime? createdAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      isIncome: isIncome ?? this.isIncome,
      category: category ?? this.category,
      date: date ?? this.date,
      isRecurring: isRecurring ?? this.isRecurring,
      recurringType: recurringType ?? this.recurringType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'isIncome': isIncome,
      'category': category,
      'date': date.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringType': recurringType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      isIncome: map['isIncome'] as bool? ?? false,
      category: map['category'] as String? ?? 'Genel',
      date: DateTime.parse(map['date'] as String),
      isRecurring: map['isRecurring'] as bool? ?? false,
      recurringType: map['recurringType'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        isIncome,
        category,
        date,
        isRecurring,
        recurringType,
        createdAt,
      ];
}
