import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/category_budget.dart';

abstract class BudgetRepository {
  Future<Either<Failure, void>> setBudget(CategoryBudget budget);
  Future<Either<Failure, void>> updateBudget(CategoryBudget budget);
  Future<Either<Failure, void>> deleteBudget(String budgetId);
  Future<Either<Failure, List<CategoryBudget>>> getBudgets(String userId);
  Stream<List<CategoryBudget>> watchBudgets(String userId);
  Future<Either<Failure, CategoryBudget?>> getBudgetByCategory(
      String userId, String category);
}
