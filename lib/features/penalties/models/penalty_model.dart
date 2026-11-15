import 'package:equatable/equatable.dart';

class PenaltyModel extends Equatable {
  final String id;
  final String title;
  final String penaltyAction;
  final String? relatedTaskId;
  final bool isResolved;
  final DateTime createdAt;
  final DateTime? resolvedAt;

  const PenaltyModel({
    required this.id,
    required this.title,
    required this.penaltyAction,
    this.relatedTaskId,
    this.isResolved = false,
    required this.createdAt,
    this.resolvedAt,
  });

  PenaltyModel copyWith({
    String? id,
    String? title,
    String? penaltyAction,
    String? relatedTaskId,
    bool? isResolved,
    DateTime? createdAt,
    DateTime? resolvedAt,
  }) {
    return PenaltyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      penaltyAction: penaltyAction ?? this.penaltyAction,
      relatedTaskId: relatedTaskId ?? this.relatedTaskId,
      isResolved: isResolved ?? this.isResolved,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'penaltyAction': penaltyAction,
      'relatedTaskId': relatedTaskId,
      'isResolved': isResolved,
      'createdAt': createdAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  factory PenaltyModel.fromMap(Map<dynamic, dynamic> map) {
    return PenaltyModel(
      id: map['id'] as String,
      title: map['title'] as String,
      penaltyAction: map['penaltyAction'] as String,
      relatedTaskId: map['relatedTaskId'] as String?,
      isResolved: map['isResolved'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      resolvedAt: map['resolvedAt'] != null
          ? DateTime.parse(map['resolvedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        penaltyAction,
        relatedTaskId,
        isResolved,
        createdAt,
        resolvedAt,
      ];
}
