import 'package:equatable/equatable.dart';

class CategoryBudget extends Equatable {
  final String id;
  final String userId;
  final String category;
  final double limitAmount;
  final double spentAmount;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
  final DateTime createdAt;

  const CategoryBudget({
    required this.id,
    required this.userId,
    required this.category,
    required this.limitAmount,
    required this.spentAmount,
    required this.startDate,
    required this.endDate,
    required this.isActive,
    required this.createdAt,
  });

  double get remainingAmount => limitAmount - spentAmount;
  double get percentageUsed => (spentAmount / limitAmount * 100).clamp(0, 100);
  bool get isExceeded => spentAmount > limitAmount;
  bool get isNearLimit => percentageUsed >= 80 && !isExceeded;

  CategoryBudget copyWith({
    String? id,
    String? userId,
    String? category,
    double? limitAmount,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CategoryBudget(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      category: category ?? this.category,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        limitAmount,
        spentAmount,
        startDate,
        endDate,
        isActive,
        createdAt,
      ];
}
