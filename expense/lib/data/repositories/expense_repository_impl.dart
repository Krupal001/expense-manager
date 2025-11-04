import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_remote_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Expense>>> getExpenses(String userId) async {
    try {
      final expenses = await remoteDataSource.getExpenses(userId);
      return Right(expenses);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Expense>> addExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel(
        id: expense.id,
        userId: expense.userId,
        title: expense.title,
        amount: expense.amount,
        category: expense.category,
        type: expense.type,
        date: expense.date,
        description: expense.description,
        notes: expense.notes,
      );
      final result = await remoteDataSource.addExpense(expenseModel);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateExpense(Expense expense) async {
    try {
      final expenseModel = ExpenseModel(
        id: expense.id,
        userId: expense.userId,
        title: expense.title,
        amount: expense.amount,
        category: expense.category,
        type: expense.type,
        date: expense.date,
        description: expense.description,
        notes: expense.notes,
      );
      await remoteDataSource.updateExpense(expenseModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteExpense(String expenseId) async {
    try {
      await remoteDataSource.deleteExpense(expenseId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<Expense>> watchExpenses(String userId) {
    return remoteDataSource.watchExpenses(userId);
  }
}
