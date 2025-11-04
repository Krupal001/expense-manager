import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/expense.dart';
import '../../../domain/repositories/expense_repository.dart';
import '../../../domain/usecases/expense/add_expense.dart';
import '../../../domain/usecases/expense/delete_expense.dart';
import '../../../domain/usecases/expense/get_expenses.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final GetExpenses getExpensesUseCase;
  final AddExpense addExpenseUseCase;
  final DeleteExpense deleteExpenseUseCase;
  final ExpenseRepository expenseRepository;

  StreamSubscription? _expenseSubscription;
  List<Expense> _currentExpenses = [];

  ExpenseCubit({
    required this.getExpensesUseCase,
    required this.addExpenseUseCase,
    required this.deleteExpenseUseCase,
    required this.expenseRepository,
  }) : super(ExpenseInitial());

  Future<void> loadExpenses(String userId) async {
    emit(ExpenseLoading());
    final result = await getExpensesUseCase(userId);
    result.fold(
      (failure) => emit(ExpenseError(failure.message)),
      (expenses) => emit(ExpenseLoaded(expenses)),
    );
  }

  void watchExpenses(String userId) {
    _expenseSubscription?.cancel();
    _expenseSubscription = expenseRepository
        .watchExpenses(userId)
        .listen(
          (expenses) {
            _currentExpenses = expenses;
            emit(ExpenseLoaded(expenses));
          },
          onError: (error) {
            emit(ExpenseError(error.toString()));
          },
        );
  }

  Future<void> addExpense(Expense expense) async {
    final result = await addExpenseUseCase(expense);
    result.fold((failure) => emit(ExpenseError(failure.message)), (_) {
      emit(const ExpenseOperationSuccess('Expense added successfully'));
      // Restore loaded state with current expenses
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_currentExpenses.isNotEmpty || state is ExpenseLoaded) {
          emit(ExpenseLoaded(_currentExpenses));
        }
      });
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    final result = await deleteExpenseUseCase(expenseId);
    result.fold((failure) => emit(ExpenseError(failure.message)), (_) {
      emit(const ExpenseOperationSuccess('Expense deleted successfully'));
      // Restore loaded state with current expenses
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_currentExpenses.isNotEmpty || state is ExpenseLoaded) {
          emit(ExpenseLoaded(_currentExpenses));
        }
      });
    });
  }

  Future<void> updateExpense(Expense expense) async {
    // Delete old and add new (since we don't have update use case yet)
    await deleteExpenseUseCase(expense.id);
    final result = await addExpenseUseCase(expense);
    result.fold((failure) => emit(ExpenseError(failure.message)), (_) {
      emit(const ExpenseOperationSuccess('Expense updated successfully'));
      // Restore loaded state with current expenses
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_currentExpenses.isNotEmpty || state is ExpenseLoaded) {
          emit(ExpenseLoaded(_currentExpenses));
        }
      });
    });
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}
