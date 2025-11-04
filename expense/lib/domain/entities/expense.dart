import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String category;
  final ExpenseType type; // debit or credit
  final DateTime date;
  final String? description;
  final String? notes;

  const Expense({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.category,
    required this.type,
    required this.date,
    this.description,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        amount,
        category,
        type,
        date,
        description,
        notes,
      ];
}

enum ExpenseType {
  debit,
  credit,
}
