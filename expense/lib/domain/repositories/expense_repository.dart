import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<Either<Failure, List<Expense>>> getExpenses(String userId);
  Future<Either<Failure, Expense>> addExpense(Expense expense);
  Future<Either<Failure, void>> updateExpense(Expense expense);
  Future<Either<Failure, void>> deleteExpense(String expenseId);
  Stream<List<Expense>> watchExpenses(String userId);
}
