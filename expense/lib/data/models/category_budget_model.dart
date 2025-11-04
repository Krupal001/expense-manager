import '../../domain/entities/category_budget.dart';

class CategoryBudgetModel extends CategoryBudget {
  const CategoryBudgetModel({
    required super.id,
    required super.userId,
    required super.category,
    required super.limitAmount,
    required super.spentAmount,
    required super.startDate,
    required super.endDate,
    required super.isActive,
    required super.createdAt,
  });

  factory CategoryBudgetModel.fromJson(Map<String, dynamic> json) {
    return CategoryBudgetModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: json['category'] as String,
      limitAmount: (json['limitAmount'] as num).toDouble(),
      spentAmount: (json['spentAmount'] as num).toDouble(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      isActive: json['isActive'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'category': category,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory CategoryBudgetModel.fromEntity(CategoryBudget budget) {
    return CategoryBudgetModel(
      id: budget.id,
      userId: budget.userId,
      category: budget.category,
      limitAmount: budget.limitAmount,
      spentAmount: budget.spentAmount,
      startDate: budget.startDate,
      endDate: budget.endDate,
      isActive: budget.isActive,
      createdAt: budget.createdAt,
    );
  }
}
