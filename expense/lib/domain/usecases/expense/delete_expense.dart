import 'package:dartz/dartz.dart';
import '../../../core/error/failures.dart';
import '../../../core/usecases/usecase.dart';
import '../../repositories/expense_repository.dart';

class DeleteExpense implements UseCase<void, String> {
  final ExpenseRepository repository;

  DeleteExpense(this.repository);

  @override
  Future<Either<Failure, void>> call(String expenseId) async {
    return await repository.deleteExpense(expenseId);
  }
}
