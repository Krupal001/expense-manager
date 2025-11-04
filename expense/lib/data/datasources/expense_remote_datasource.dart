import 'package:firebase_database/firebase_database.dart';
import '../models/expense_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseModel>> getExpenses(String userId);
  Future<ExpenseModel> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String expenseId);
  Stream<List<ExpenseModel>> watchExpenses(String userId);
}

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final FirebaseDatabase database;

  ExpenseRemoteDataSourceImpl({required this.database});

  @override
  Future<List<ExpenseModel>> getExpenses(String userId) async {
    try {
      final snapshot =
          await database.ref().child('expenses').child(userId).get();

      if (!snapshot.exists) {
        return [];
      }

      final data = Map<String, dynamic>.from(snapshot.value as Map);
      final expenses = <ExpenseModel>[];

      data.forEach((key, value) {
        final expenseData = Map<String, dynamic>.from(value as Map);
        expenses.add(ExpenseModel.fromJson(expenseData));
      });

      return expenses;
    } catch (e) {
      throw Exception('Failed to get expenses: ${e.toString()}');
    }
  }

  @override
  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    try {
      final ref = database
          .ref()
          .child('expenses')
          .child(expense.userId)
          .child(expense.id);

      await ref.set(expense.toJson());
      return expense;
    } catch (e) {
      throw Exception('Failed to add expense: ${e.toString()}');
    }
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await database
          .ref()
          .child('expenses')
          .child(expense.userId)
          .child(expense.id)
          .update(expense.toJson());
    } catch (e) {
      throw Exception('Failed to update expense: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      // Note: We need userId here, but for simplicity, we'll search for it
      // In production, you might want to pass userId as well
      final snapshot = await database.ref().child('expenses').get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        for (var userId in data.keys) {
          final userExpenses = Map<String, dynamic>.from(data[userId] as Map);
          if (userExpenses.containsKey(expenseId)) {
            await database
                .ref()
                .child('expenses')
                .child(userId)
                .child(expenseId)
                .remove();
            return;
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to delete expense: ${e.toString()}');
    }
  }

  @override
  Stream<List<ExpenseModel>> watchExpenses(String userId) {
    return database.ref().child('expenses').child(userId).onValue.map((event) {
      if (!event.snapshot.exists) {
        return <ExpenseModel>[];
      }

      final data = Map<String, dynamic>.from(event.snapshot.value as Map);
      final expenses = <ExpenseModel>[];

      data.forEach((key, value) {
        final expenseData = Map<String, dynamic>.from(value as Map);
        expenses.add(ExpenseModel.fromJson(expenseData));
      });

      return expenses;
    });
  }
}
