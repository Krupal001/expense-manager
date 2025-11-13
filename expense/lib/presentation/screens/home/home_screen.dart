import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_categories.dart';
import '../../../domain/entities/expense.dart';
import '../../cubit/auth/auth_cubit.dart';
import '../../cubit/auth/auth_state.dart';
import '../../cubit/expense/expense_cubit.dart';
import '../../cubit/expense/expense_state.dart';
import '../../cubit/budget/budget_cubit.dart';
import '../../cubit/budget/budget_state.dart';
import '../analytics/analytics_screen.dart';
import '../budget/budget_settings_screen.dart';
import '../expense/all_transactions_screen.dart';
import '../expense/edit_expense_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Selected month and year for the book
  late int _selectedMonth;
  late int _selectedYear;
  late String _selectedBookName;

  @override
  void initState() {
    super.initState();
    // Initialize with current month
    final now = DateTime.now();
    _selectedMonth = now.month;
    _selectedYear = now.year;
    _updateBookName();
    
    final authState = context.read<AuthCubit>().state;
    if (authState is AuthAuthenticated) {
      context.read<ExpenseCubit>().watchExpenses(authState.user.id);
      context.read<BudgetCubit>().watchBudgets(authState.user.id);
    }
  }

  void _updateBookName() {
    final monthNames = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    _selectedBookName = '${monthNames[_selectedMonth - 1]} $_selectedYear';
  }

  // Filter expenses by selected month
  List<Expense> _filterExpensesByMonth(List<Expense> expenses) {
    return expenses.where((expense) {
      return expense.date.year == _selectedYear &&
          expense.date.month == _selectedMonth;
    }).toList();
  }

  // Check if selected month is current month
  bool get _isCurrentMonth {
    final now = DateTime.now();
    return _selectedMonth == now.month && _selectedYear == now.year;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.book, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: GestureDetector(
                onTap: () => _showMonthPicker(context),
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        _selectedBookName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_drop_down, size: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          if (!_isCurrentMonth)
            IconButton(
              icon: const Icon(Icons.today),
              tooltip: 'Current Month',
              onPressed: () {
                setState(() {
                  final now = DateTime.now();
                  _selectedMonth = now.month;
                  _selectedYear = now.year;
                  _updateBookName();
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthCubit>().signOut();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ExpenseCubit, ExpenseState>(
            listener: (context, state) {
              if (state is ExpenseOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is ExpenseError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              } else if (state is ExpenseLoaded) {
                // Recalculate budget spending when expenses are loaded
                final authState = context.read<AuthCubit>().state;
                if (authState is AuthAuthenticated) {
                  context.read<BudgetCubit>().recalculateBudgetSpending(
                    authState.user.id, 
                    state.expenses,
                  );
                }
              }
            },
          ),
          BlocListener<BudgetCubit, BudgetState>(
            listener: (context, state) {
              if (state is BudgetLimitExceeded) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '⚠️ ${state.budget.category} budget exceeded by ₹${state.exceededAmount.toStringAsFixed(2)}!',
                    ),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 5),
                    action: SnackBarAction(
                      label: 'View',
                      textColor: Colors.white,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BudgetSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else if (state is BudgetNearLimit) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '⚡ ${state.budget.category} budget near limit! ₹${state.budget.remainingAmount.toStringAsFixed(2)} remaining',
                    ),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    duration: const Duration(seconds: 4),
                  ),
                );
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () async {
            final authState = context.read<AuthCubit>().state;
            if (authState is AuthAuthenticated) {
              context.read<ExpenseCubit>().loadExpenses(authState.user.id);
              context.read<BudgetCubit>().loadBudgets(authState.user.id);
              
              // Recalculate budget spending after loading expenses
              final expenseState = context.read<ExpenseCubit>().state;
              if (expenseState is ExpenseLoaded) {
                context.read<BudgetCubit>().recalculateBudgetSpending(
                  authState.user.id, 
                  expenseState.expenses,
                );
              }
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Month Book Info Banner
                  if (!_isCurrentMonth)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Viewing $_selectedBookName book (Read-only)',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                final now = DateTime.now();
                                _selectedMonth = now.month;
                                _selectedYear = now.year;
                                _updateBookName();
                              });
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('Current', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),
                  _buildBudgetCard(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recent Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AllTransactionsScreen(
                                selectedMonth: _selectedMonth,
                                selectedYear: _selectedYear,
                              ),
                            ),
                          );
                        },
                        child: const Text('See All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildExpensesList(),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: _isCurrentMonth
          ? FloatingActionButton(
              onPressed: () => _showAddTransactionOptions(context),
              child: const Icon(Icons.add),
              tooltip: 'Add Transaction',
            )
          : FloatingActionButton.extended(
              onPressed: () {
                setState(() {
                  final now = DateTime.now();
                  _selectedMonth = now.month;
                  _selectedYear = now.year;
                  _updateBookName();
                });
              },
              icon: const Icon(Icons.today),
              label: const Text('Go to Current Month'),
              backgroundColor: Colors.blue,
            ),
    );
  }

  Widget _buildBudgetCard() {
    return BlocBuilder<BudgetCubit, BudgetState>(
      builder: (context, budgetState) {
        return BlocBuilder<ExpenseCubit, ExpenseState>(
          builder: (context, expenseState) {
            double totalBudget = 0;
            double totalSpent = 0;

            if (budgetState is BudgetLoaded) {
              totalBudget = budgetState.budgets.fold(
                0.0,
                (sum, budget) => sum + budget.limitAmount,
              );
            }

            if (expenseState is ExpenseLoaded) {
              // Filter expenses by selected month FIRST
              final monthExpenses = _filterExpensesByMonth(expenseState.expenses);
              
              // Calculate spent only from current month's expenses
              totalSpent = monthExpenses
                  .where((e) => e.type == ExpenseType.debit)
                  .fold(0.0, (sum, expense) => sum + expense.amount);
            }

            double remaining = totalBudget - totalSpent;
            double percentage =
                totalBudget > 0 ? (totalSpent / totalBudget) : 0;

            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(context).colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isCurrentMonth ? 'Monthly Budget' : '$_selectedBookName Budget',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const BudgetSettingsScreen(),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.settings,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Text(
                                    'Analytics',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${totalBudget.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: percentage.clamp(0.0, 1.0),
                        backgroundColor: Colors.white24,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          percentage > 0.9 ? Colors.red : Colors.white,
                        ),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Spent',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹${totalSpent.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Remaining',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              '₹${remaining.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQuickStats() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoaded) {
          // Filter expenses by selected month
          final monthExpenses = _filterExpensesByMonth(state.expenses);

          final totalIncome = monthExpenses
              .where((e) => e.type == ExpenseType.credit)
              .fold(0.0, (sum, e) => sum + e.amount);

          final totalExpense = monthExpenses
              .where((e) => e.type == ExpenseType.debit)
              .fold(0.0, (sum, e) => sum + e.amount);

          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total Income',
                  totalIncome,
                  Icons.arrow_upward,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Total Expense',
                  totalExpense,
                  Icons.arrow_downward,
                  Colors.red,
                ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard(
      String title, double amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '₹${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesList() {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        if (state is ExpenseLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          );
        } else if (state is ExpenseLoaded) {
          // Filter expenses by selected month
          final monthExpenses = _filterExpensesByMonth(state.expenses);
          
          if (monthExpenses.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No transactions in $_selectedBookName',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isCurrentMonth
                          ? 'Tap the + button to add your first transaction'
                          : 'Switch to current month to add transactions',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final recentExpenses = monthExpenses.take(5).toList();
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentExpenses.length,
            itemBuilder: (context, index) {
              final expense = recentExpenses[index];
              return _buildExpenseItem(expense);
            },
          );
        } else if (state is ExpenseError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildExpenseItem(Expense expense) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getCategoryColor(expense.category).withOpacity(0.2),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: _getCategoryColor(expense.category),
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${expense.category} • ${DateFormat('MMM dd, yyyy').format(expense.date)}',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Text(
          '${expense.type == ExpenseType.credit ? '+' : '-'}₹${expense.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color:
                expense.type == ExpenseType.credit ? Colors.green : Colors.red,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditExpenseScreen(expense: expense),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    return AppCategories.getCategoryIcon(category);
  }

  Color _getCategoryColor(String category) {
    return AppCategories.getCategoryColor(category);
  }

  void _showAddTransactionOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildTransactionTypeCard(
                    context,
                    'Expense',
                    Icons.arrow_downward,
                    Colors.red,
                    ExpenseType.debit,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTransactionTypeCard(
                    context,
                    'Income',
                    Icons.arrow_upward,
                    Colors.green,
                    ExpenseType.credit,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    ExpenseType type,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _showAddTransactionDialog(context, type);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddTransactionDialog(BuildContext context, ExpenseType type) {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();
    String selectedCategory = type == ExpenseType.debit 
        ? AppCategories.expenseCategories.first 
        : AppCategories.incomeCategories.first;
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: (type == ExpenseType.debit
                                  ? Colors.red
                                  : Colors.green)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          type == ExpenseType.debit
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: type == ExpenseType.debit
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Add ${type == ExpenseType.debit ? 'Expense' : 'Income'}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: type == ExpenseType.debit
                          ? 'e.g., Lunch at restaurant'
                          : 'e.g., Salary',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.title),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: amountController,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: '₹',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.currency_rupee),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.category),
                    ),
                    items: AppCategories.getCategoriesForType(
                            type == ExpenseType.debit ? 'debit' : 'credit')
                        .map((cat) => DropdownMenuItem(
                              value: cat,
                              child: Row(
                                children: [
                                  Icon(
                                    _getCategoryIcon(cat),
                                    size: 20,
                                    color: _getCategoryColor(cat),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(cat),
                                ],
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText: 'Add notes...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      prefixIcon: const Icon(Icons.notes),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          selectedDate = date;
                        });
                      }
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Colors.grey),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                DateFormat('MMM dd, yyyy').format(selectedDate),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.isNotEmpty &&
                                amountController.text.isNotEmpty) {
                              final authState = context.read<AuthCubit>().state;
                              if (authState is AuthAuthenticated) {
                                final expense = Expense(
                                  id: DateTime.now()
                                      .millisecondsSinceEpoch
                                      .toString(),
                                  title: titleController.text,
                                  amount: double.parse(amountController.text),
                                  category: selectedCategory,
                                  date: selectedDate,
                                  userId: authState.user.id,
                                  type: type,
                                  description:
                                      descriptionController.text.isEmpty
                                          ? null
                                          : descriptionController.text,
                                );

                                context
                                    .read<ExpenseCubit>()
                                    .addExpense(expense);
                                
                                // Check budget limit for debit expenses
                                if (type == ExpenseType.debit) {
                                  context
                                      .read<BudgetCubit>()
                                      .checkBudgetLimit(authState.user.id, expense);
                                }
                                
                                Navigator.pop(dialogContext);

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '${type == ExpenseType.debit ? 'Expense' : 'Income'} added successfully!',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Add'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Month Picker Dialog
  void _showMonthPicker(BuildContext context) {
    final now = DateTime.now();
    final currentYear = now.year;
    
    // Generate list of months (last 12 months + next 3 months)
    final List<Map<String, dynamic>> monthOptions = [];
    
    for (int i = 12; i >= -3; i--) {
      final date = DateTime(currentYear, now.month - i, 1);
      final monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ];
      
      monthOptions.add({
        'month': date.month,
        'year': date.year,
        'name': '${monthNames[date.month - 1]} ${date.year}',
        'isCurrent': date.month == now.month && date.year == now.year,
      });
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.book, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Select Month Book',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Month List
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: monthOptions.length,
                itemBuilder: (context, index) {
                  final option = monthOptions[index];
                  final isSelected = option['month'] == _selectedMonth &&
                      option['year'] == _selectedYear;
                  
                  return ListTile(
                    leading: Icon(
                      option['isCurrent'] ? Icons.today : Icons.calendar_month,
                      color: isSelected
                          ? const Color(0xFF7C3AED)
                          : (option['isCurrent'] ? Colors.green : Colors.grey),
                    ),
                    title: Text(
                      option['name'],
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? const Color(0xFF7C3AED) : Colors.black87,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF7C3AED))
                        : (option['isCurrent']
                            ? Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.green),
                                ),
                                child: const Text(
                                  'Current',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.green,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : null),
                    onTap: () {
                      setState(() {
                        _selectedMonth = option['month'];
                        _selectedYear = option['year'];
                        _updateBookName();
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
