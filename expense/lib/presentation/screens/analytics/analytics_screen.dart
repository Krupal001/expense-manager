import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../cubit/expense/expense_cubit.dart';
import '../../cubit/expense/expense_state.dart';
import '../../../domain/entities/expense.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'This Month';
  String _selectedCategory = 'All';
  ExpenseType? _selectedType;

  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'Last Month',
    'This Year',
    'All Time'
  ];

  final List<String> _categories = [
    'All',
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Bills',
    'Health',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Analytics',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: BlocBuilder<ExpenseCubit, ExpenseState>(
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ExpenseLoaded) {
            final filteredExpenses = _filterExpenses(state.expenses);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFilters(),
                  const SizedBox(height: 24),
                  _buildSummaryCards(filteredExpenses),
                  const SizedBox(height: 24),
                  _buildCategoryChart(filteredExpenses),
                  const SizedBox(height: 24),
                  _buildTrendChart(filteredExpenses),
                  const SizedBox(height: 24),
                  _buildTopExpenses(filteredExpenses),
                ],
              ),
            );
          } else if (state is ExpenseError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildFilters() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filters',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedPeriod,
                    decoration: const InputDecoration(
                      labelText: 'Period',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    ),
                    items: _periods
                        .map((period) => DropdownMenuItem(
                              value: period,
                              child: Text(period),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPeriod = value!;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    ),
                    items: _categories
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(cat),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedType == null,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Expenses'),
                  selected: _selectedType == ExpenseType.debit,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? ExpenseType.debit : null;
                    });
                  },
                ),
                FilterChip(
                  label: const Text('Income'),
                  selected: _selectedType == ExpenseType.credit,
                  onSelected: (selected) {
                    setState(() {
                      _selectedType = selected ? ExpenseType.credit : null;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(List<Expense> expenses) {
    final totalIncome = expenses
        .where((e) => e.type == ExpenseType.credit)
        .fold(0.0, (sum, e) => sum + e.amount);
    final totalExpense = expenses
        .where((e) => e.type == ExpenseType.debit)
        .fold(0.0, (sum, e) => sum + e.amount);
    final balance = totalIncome - totalExpense;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            'Income',
            totalIncome,
            Icons.arrow_upward,
            Colors.green,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Expense',
            totalExpense,
            Icons.arrow_downward,
            Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryCard(
            'Balance',
            balance,
            Icons.account_balance_wallet,
            balance >= 0 ? Colors.blue : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String title, double amount, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 6),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '₹${amount.toStringAsFixed(0)}',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChart(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('No data available'),
          ),
        ),
      );
    }

    final categoryData = <String, double>{};
    for (var expense in expenses) {
      if (_selectedType == null || expense.type == _selectedType) {
        categoryData[expense.category] =
            (categoryData[expense.category] ?? 0) + expense.amount;
      }
    }

    if (categoryData.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Center(
            child: Text('No data available'),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spending by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: categoryData.entries.map((entry) {
                    final color = _getCategoryColor(entry.key);
                    final percentage = (entry.value /
                            categoryData.values.fold(0.0, (a, b) => a + b)) *
                        100;
                    return PieChartSectionData(
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(0)}%',
                      color: color,
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: categoryData.entries.map((entry) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${entry.key}: ₹${entry.value.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group expenses by date
    final Map<DateTime, double> dailyExpenses = {};
    final Map<DateTime, double> dailyIncome = {};

    for (var expense in expenses) {
      final date =
          DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (expense.type == ExpenseType.debit) {
        dailyExpenses[date] = (dailyExpenses[date] ?? 0) + expense.amount;
      } else {
        dailyIncome[date] = (dailyIncome[date] ?? 0) + expense.amount;
      }
    }

    if (dailyExpenses.isEmpty && dailyIncome.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedDates = {...dailyExpenses.keys, ...dailyIncome.keys}.toList()
      ..sort();

    if (sortedDates.length < 2) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend Analysis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '₹${value.toInt()}',
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < sortedDates.length) {
                            final date = sortedDates[value.toInt()];
                            return Text(
                              DateFormat('MM/dd').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    if (dailyExpenses.isNotEmpty)
                      LineChartBarData(
                        spots: sortedDates.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            dailyExpenses[entry.value] ?? 0,
                          );
                        }).toList(),
                        isCurved: true,
                        color: Colors.red,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                    if (dailyIncome.isNotEmpty)
                      LineChartBarData(
                        spots: sortedDates.asMap().entries.map((entry) {
                          return FlSpot(
                            entry.key.toDouble(),
                            dailyIncome[entry.value] ?? 0,
                          );
                        }).toList(),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Expenses', Colors.red),
                const SizedBox(width: 24),
                _buildLegendItem('Income', Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 3,
          color: color,
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildTopExpenses(List<Expense> expenses) {
    if (expenses.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedExpenses = List<Expense>.from(expenses)
      ..sort((a, b) => b.amount.compareTo(a.amount));
    final topExpenses = sortedExpenses.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Transactions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...topExpenses.map((expense) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: _getCategoryColor(expense.category)
                            .withOpacity(0.2),
                        child: Icon(
                          _getCategoryIcon(expense.category),
                          color: _getCategoryColor(expense.category),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              DateFormat('MMM dd, yyyy').format(expense.date),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${expense.type == ExpenseType.credit ? '+' : '-'}₹${expense.amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: expense.type == ExpenseType.credit
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  List<Expense> _filterExpenses(List<Expense> expenses) {
    var filtered = expenses;

    // Filter by period
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'Today':
        filtered = filtered
            .where((e) =>
                e.date.year == now.year &&
                e.date.month == now.month &&
                e.date.day == now.day)
            .toList();
        break;
      case 'This Week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        filtered = filtered.where((e) => e.date.isAfter(weekStart)).toList();
        break;
      case 'This Month':
        filtered = filtered
            .where((e) => e.date.year == now.year && e.date.month == now.month)
            .toList();
        break;
      case 'Last Month':
        final lastMonth = DateTime(now.year, now.month - 1);
        filtered = filtered
            .where((e) =>
                e.date.year == lastMonth.year &&
                e.date.month == lastMonth.month)
            .toList();
        break;
      case 'This Year':
        filtered = filtered.where((e) => e.date.year == now.year).toList();
        break;
    }

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((e) => e.category == _selectedCategory).toList();
    }

    // Filter by type
    if (_selectedType != null) {
      filtered = filtered.where((e) => e.type == _selectedType).toList();
    }

    return filtered;
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant;
      case 'transport':
        return Icons.directions_car;
      case 'shopping':
        return Icons.shopping_bag;
      case 'entertainment':
        return Icons.movie;
      case 'bills':
        return Icons.receipt;
      case 'health':
        return Icons.local_hospital;
      default:
        return Icons.attach_money;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Colors.orange;
      case 'transport':
        return Colors.blue;
      case 'shopping':
        return Colors.purple;
      case 'entertainment':
        return Colors.pink;
      case 'bills':
        return Colors.red;
      case 'health':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
