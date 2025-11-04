import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../entities/expense.dart';
import '../../repositories/expense_repository.dart';

class AddExpense implements UseCase<Expense, Expense> {
  final ExpenseRepository repository;

  AddExpense(this.repository);

  @override
  Future<Either<Failure, Expense>> call(Expense params) async {
    return await repository.addExpense(params);
  }
}
