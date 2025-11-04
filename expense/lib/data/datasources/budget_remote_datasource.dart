import 'package:firebase_database/firebase_database.dart';
import '../models/category_budget_model.dart';

abstract class BudgetRemoteDataSource {
  Future<void> setBudget(CategoryBudgetModel budget);
  Future<void> updateBudget(CategoryBudgetModel budget);
  Future<void> deleteBudget(String budgetId);
  Future<List<CategoryBudgetModel>> getBudgets(String userId);
  Stream<List<CategoryBudgetModel>> watchBudgets(String userId);
  Future<CategoryBudgetModel?> getBudgetByCategory(
      String userId, String category);
}

class BudgetRemoteDataSourceImpl implements BudgetRemoteDataSource {
  final FirebaseDatabase database;

  BudgetRemoteDataSourceImpl({required this.database});

  DatabaseReference get _budgetsRef => database.ref('budgets');

  @override
  Future<void> setBudget(CategoryBudgetModel budget) async {
    await _budgetsRef.child(budget.id).set(budget.toJson());
  }

  @override
  Future<void> updateBudget(CategoryBudgetModel budget) async {
    await _budgetsRef.child(budget.id).update(budget.toJson());
  }

  @override
  Future<void> deleteBudget(String budgetId) async {
    await _budgetsRef.child(budgetId).remove();
  }

  @override
  Future<List<CategoryBudgetModel>> getBudgets(String userId) async {
    final snapshot = await _budgetsRef
        .orderByChild('userId')
        .equalTo(userId)
        .once();

    if (snapshot.snapshot.value == null) {
      return [];
    }

    final budgetsMap = snapshot.snapshot.value as Map<dynamic, dynamic>;
    return budgetsMap.entries
        .map((entry) => CategoryBudgetModel.fromJson(
              Map<String, dynamic>.from(entry.value as Map),
            ))
        .toList();
  }

  @override
  Stream<List<CategoryBudgetModel>> watchBudgets(String userId) {
    return _budgetsRef
        .orderByChild('userId')
        .equalTo(userId)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) {
        return <CategoryBudgetModel>[];
      }

      final budgetsMap = event.snapshot.value as Map<dynamic, dynamic>;
      return budgetsMap.entries
          .map((entry) => CategoryBudgetModel.fromJson(
                Map<String, dynamic>.from(entry.value as Map),
              ))
          .toList();
    });
  }

  @override
  Future<CategoryBudgetModel?> getBudgetByCategory(
      String userId, String category) async {
    final budgets = await getBudgets(userId);
    try {
      return budgets.firstWhere(
        (budget) => budget.category == category && budget.isActive,
      );
    } catch (e) {
      return null;
    }
  }
}
