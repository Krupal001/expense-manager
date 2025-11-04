import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.amount,
    required super.category,
    required super.type,
    required super.date,
    super.description,
    super.notes,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      type: ExpenseType.values.firstWhere(
        (e) => e.toString() == 'ExpenseType.${json['type']}',
      ),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'category': category,
      'type': type.toString().split('.').last,
      'date': date.toIso8601String(),
      'description': description,
      'notes': notes,
    };
  }
}
