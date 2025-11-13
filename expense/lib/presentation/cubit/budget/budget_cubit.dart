import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/category_budget.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/repositories/budget_repository.dart';
import 'budget_state.dart';

class BudgetCubit extends Cubit<BudgetState> {
  final BudgetRepository budgetRepository;

  StreamSubscription? _budgetSubscription;
  List<CategoryBudget> _currentBudgets = [];

  BudgetCubit({required this.budgetRepository}) : super(BudgetInitial());

  Future<void> loadBudgets(String userId) async {
    emit(BudgetLoading());
    final result = await budgetRepository.getBudgets(userId);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (budgets) {
        _currentBudgets = budgets;
        emit(BudgetLoaded(budgets));
      },
    );
  }

  void watchBudgets(String userId) {
    _budgetSubscription?.cancel();
    _budgetSubscription = budgetRepository.watchBudgets(userId).listen(
      (budgets) {
        _currentBudgets = budgets;
        emit(BudgetLoaded(budgets));
      },
      onError: (error) {
        emit(BudgetError(error.toString()));
      },
    );
  }

  Future<void> setBudget(CategoryBudget budget) async {
    final result = await budgetRepository.setBudget(budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) {
        emit(const BudgetOperationSuccess('Budget set successfully'));
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(BudgetLoaded(_currentBudgets));
        });
      },
    );
  }

  Future<void> updateBudget(CategoryBudget budget) async {
    final result = await budgetRepository.updateBudget(budget);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) {
        emit(const BudgetOperationSuccess('Budget updated successfully'));
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(BudgetLoaded(_currentBudgets));
        });
      },
    );
  }

  Future<void> deleteBudget(String budgetId) async {
    final result = await budgetRepository.deleteBudget(budgetId);
    result.fold(
      (failure) => emit(BudgetError(failure.message)),
      (_) {
        emit(const BudgetOperationSuccess('Budget deleted successfully'));
        Future.delayed(const Duration(milliseconds: 100), () {
          emit(BudgetLoaded(_currentBudgets));
        });
      },
    );
  }

  Future<void> checkBudgetLimit(String userId, Expense expense) async {
    // Only check for debit expenses
    if (expense.type != ExpenseType.debit) return;

    final result =
        await budgetRepository.getBudgetByCategory(userId, expense.category);
    result.fold(
      (failure) => null,
      (budget) {
        if (budget != null && budget.isActive) {
          // Calculate new spent amount
          final newSpentAmount = budget.spentAmount + expense.amount;
          final updatedBudget = budget.copyWith(spentAmount: newSpentAmount);

          // Update budget in database
          budgetRepository.updateBudget(updatedBudget);

          // Check if limit exceeded
          if (updatedBudget.isExceeded) {
            final exceededAmount = updatedBudget.spentAmount - updatedBudget.limitAmount;
            emit(BudgetLimitExceeded(updatedBudget, exceededAmount));
          } else if (updatedBudget.isNearLimit) {
            emit(BudgetNearLimit(updatedBudget));
          }
        }
      },
    );
  }

  Future<void> recalculateBudgetSpending(
      String userId, List<Expense> expenses) async {
    print('BudgetCubit: Recalculating budget spending for ${expenses.length} expenses');
    final budgets = _currentBudgets.where((b) => b.isActive).toList();
    print('BudgetCubit: Found ${budgets.length} active budgets');

    for (var budget in budgets) {
      // Calculate spent amount for this category
      final categoryExpenses = expenses.where(
        (expense) =>
            expense.category == budget.category &&
            expense.type == ExpenseType.debit &&
            expense.date.isAfter(budget.startDate.subtract(const Duration(days: 1))) &&
            expense.date.isBefore(budget.endDate.add(const Duration(days: 1))),
      );

      final totalSpent = categoryExpenses.fold<double>(
        0.0,
        (sum, expense) => sum + expense.amount,
      );

      print('BudgetCubit: ${budget.category} - Current: ₹${budget.spentAmount}, Calculated: ₹$totalSpent (${categoryExpenses.length} expenses)');

      // Update budget if spent amount changed
      if (budget.spentAmount != totalSpent) {
        print('BudgetCubit: Updating ${budget.category} budget spent amount from ₹${budget.spentAmount} to ₹$totalSpent');
        final updatedBudget = budget.copyWith(spentAmount: totalSpent);
        await budgetRepository.updateBudget(updatedBudget);
        
        // Update local budget list
        final index = _currentBudgets.indexWhere((b) => b.id == budget.id);
        if (index != -1) {
          _currentBudgets[index] = updatedBudget;
        }
      }
    }
    
    // Emit updated budgets
    if (budgets.isNotEmpty) {
      emit(BudgetLoaded(_currentBudgets));
    }
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    return super.close();
  }
}
