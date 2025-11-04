import 'package:equatable/equatable.dart';

class MonthlyBook extends Equatable {
  final String id;
  final String userId;
  final int month; // 1-12
  final int year; // 2024, 2025, etc.
  final String name; // "November 2024"
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final int transactionCount;
  final DateTime createdAt;
  final bool isCurrent;

  const MonthlyBook({
    required this.id,
    required this.userId,
    required this.month,
    required this.year,
    required this.name,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.transactionCount,
    required this.createdAt,
    required this.isCurrent,
  });

  // Helper to get start date of the month
  DateTime get startDate => DateTime(year, month, 1);
  
  // Helper to get end date of the month
  DateTime get endDate => DateTime(year, month + 1, 0, 23, 59, 59);

  // Check if a date belongs to this book
  bool containsDate(DateTime date) {
    return date.year == year && date.month == month;
  }

  MonthlyBook copyWith({
    String? id,
    String? userId,
    int? month,
    int? year,
    String? name,
    double? totalIncome,
    double? totalExpense,
    double? balance,
    int? transactionCount,
    DateTime? createdAt,
    bool? isCurrent,
  }) {
    return MonthlyBook(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      year: year ?? this.year,
      name: name ?? this.name,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      transactionCount: transactionCount ?? this.transactionCount,
      createdAt: createdAt ?? this.createdAt,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        month,
        year,
        name,
        totalIncome,
        totalExpense,
        balance,
        transactionCount,
        createdAt,
        isCurrent,
      ];

  // Create a book from current date
  static MonthlyBook createCurrent(String userId) {
    final now = DateTime.now();
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return MonthlyBook(
      id: '${now.year}_${now.month}',
      userId: userId,
      month: now.month,
      year: now.year,
      name: '${monthNames[now.month - 1]} ${now.year}',
      totalIncome: 0.0,
      totalExpense: 0.0,
      balance: 0.0,
      transactionCount: 0,
      createdAt: now,
      isCurrent: true,
    );
  }

  // Create a book for specific month/year
  static MonthlyBook create(String userId, int month, int year) {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    final now = DateTime.now();
    final isCurrent = now.month == month && now.year == year;
    
    return MonthlyBook(
      id: '${year}_$month',
      userId: userId,
      month: month,
      year: year,
      name: '${monthNames[month - 1]} $year',
      totalIncome: 0.0,
      totalExpense: 0.0,
      balance: 0.0,
      transactionCount: 0,
      createdAt: DateTime.now(),
      isCurrent: isCurrent,
    );
  }
}
