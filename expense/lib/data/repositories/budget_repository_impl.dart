import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../domain/entities/category_budget.dart';
import '../../domain/repositories/budget_repository.dart';
import '../datasources/budget_remote_datasource.dart';
import '../models/category_budget_model.dart';

class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetRemoteDataSource remoteDataSource;

  BudgetRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> setBudget(CategoryBudget budget) async {
    try {
      final budgetModel = CategoryBudgetModel.fromEntity(budget);
      await remoteDataSource.setBudget(budgetModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBudget(CategoryBudget budget) async {
    try {
      final budgetModel = CategoryBudgetModel.fromEntity(budget);
      await remoteDataSource.updateBudget(budgetModel);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBudget(String budgetId) async {
    try {
      await remoteDataSource.deleteBudget(budgetId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CategoryBudget>>> getBudgets(
      String userId) async {
    try {
      final budgets = await remoteDataSource.getBudgets(userId);
      return Right(budgets);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<CategoryBudget>> watchBudgets(String userId) {
    return remoteDataSource.watchBudgets(userId);
  }

  @override
  Future<Either<Failure, CategoryBudget?>> getBudgetByCategory(
      String userId, String category) async {
    try {
      final budget = await remoteDataSource.getBudgetByCategory(userId, category);
      return Right(budget);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
