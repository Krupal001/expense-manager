import 'package:equatable/equatable.dart';
import '../../../domain/entities/category_budget.dart';

abstract class BudgetState extends Equatable {
  const BudgetState();

  @override
  List<Object?> get props => [];
}

class BudgetInitial extends BudgetState {}

class BudgetLoading extends BudgetState {}

class BudgetLoaded extends BudgetState {
  final List<CategoryBudget> budgets;

  const BudgetLoaded(this.budgets);

  @override
  List<Object?> get props => [budgets];
}

class BudgetError extends BudgetState {
  final String message;

  const BudgetError(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetOperationSuccess extends BudgetState {
  final String message;

  const BudgetOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class BudgetLimitExceeded extends BudgetState {
  final CategoryBudget budget;
  final double exceededAmount;

  const BudgetLimitExceeded(this.budget, this.exceededAmount);

  @override
  List<Object?> get props => [budget, exceededAmount];
}

class BudgetNearLimit extends BudgetState {
  final CategoryBudget budget;

  const BudgetNearLimit(this.budget);

  @override
  List<Object?> get props => [budget];
}
