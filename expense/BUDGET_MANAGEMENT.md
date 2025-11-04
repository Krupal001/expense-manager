# Budget Management System

## Overview
The expense tracker now includes a comprehensive budget management system that allows users to set spending limits by category and receive real-time notifications when approaching or exceeding those limits.

## Features

### 1. **Budget Settings Screen**
Access via the settings icon (⚙️) on the home screen budget card.

#### Create Budget
- **Category Selection**: Choose from predefined categories (Food, Transport, Shopping, Bills, Entertainment, Health, Education, Other)
- **Limit Amount**: Set the maximum amount you want to spend in that category
- **Date Range**: Define start and end dates for the budget period (default: 30 days)
- **Auto-tracking**: Spent amount is automatically calculated from your expenses

#### Edit Budget
- Update limit amount
- Modify date range
- Changes apply immediately

#### Delete Budget
- Remove budget limits you no longer need
- Confirmation dialog prevents accidental deletion

### 2. **Budget Card on Home Screen**
Located at the top of the home screen, showing:
- **Total Budget**: Sum of all active budget limits
- **Total Spent**: Sum of all expenses (debit transactions only)
- **Remaining**: Budget - Spent
- **Progress Bar**: Visual indicator of spending (changes color based on status)
- **Quick Actions**:
  - ⚙️ Settings icon → Navigate to Budget Settings
  - "Analytics" button → View detailed analytics
  - Tap anywhere → View analytics

### 3. **Real-time Budget Monitoring**

#### Status Indicators
- **Green**: Healthy spending (< 80% of limit)
- **Orange**: Near limit warning (80-100% of limit)
- **Red**: Budget exceeded (> 100% of limit)

#### Automatic Notifications
When you add an expense, the system automatically:
1. Checks if there's a budget for that category
2. Updates the spent amount
3. Shows notifications based on status:

**Budget Exceeded (Red Alert)**
```
⚠️ Food budget exceeded by ₹500.00!
[View] button → Navigate to Budget Settings
```
- Duration: 5 seconds
- Action button to view and manage budgets

**Near Limit Warning (Orange Alert)**
```
⚡ Transport budget near limit! ₹200.00 remaining
```
- Duration: 4 seconds
- Triggers at 80% of budget limit

### 4. **Budget Card Details**

Each budget card in the settings screen shows:
- **Category Icon**: Visual representation
- **Category Name**: e.g., "Food", "Transport"
- **Date Range**: "Nov 01 - Nov 30"
- **Progress Bar**: Color-coded based on status
- **Spent Amount**: Current spending in the category
- **Limit Amount**: Maximum allowed spending
- **Warning Messages**:
  - Exceeded: "Exceeded by ₹X.XX"
  - Near Limit: "Near limit! ₹X.XX remaining"
- **Actions**: Edit or Delete via menu (⋮)

## How It Works

### Budget Calculation
```dart
// Entity properties
double limitAmount;      // Set by user
double spentAmount;      // Auto-calculated from expenses
double remainingAmount;  // limitAmount - spentAmount
double percentageUsed;   // (spentAmount / limitAmount) * 100

// Status checks
bool isExceeded;         // spentAmount > limitAmount
bool isNearLimit;        // percentageUsed >= 80% && !isExceeded
```

### Expense Integration
When you add an expense (debit):
1. Expense is saved to Firebase
2. System checks for active budget in that category
3. Updates `spentAmount` in the budget
4. Evaluates budget status
5. Shows notification if exceeded or near limit

### Firebase Structure
```
budgets/
  └── {userId}/
      └── {budgetId}/
          ├── category: "Food"
          ├── limitAmount: 5000
          ├── spentAmount: 4500
          ├── startDate: "2024-11-01"
          ├── endDate: "2024-11-30"
          ├── isActive: true
          └── createdAt: "2024-11-01T10:00:00Z"
```

## User Journey

### Setting Up First Budget
1. Open app → Home screen
2. Tap ⚙️ icon on budget card
3. Tap "+ Add Budget" button
4. Select category (e.g., "Food")
5. Enter limit amount (e.g., ₹5000)
6. Set date range (default: today + 30 days)
7. Tap "Add"
8. Budget is now active and monitoring

### Adding Expense with Budget Check
1. Tap + button on home screen
2. Select "Expense"
3. Fill in details:
   - Title: "Lunch"
   - Amount: ₹500
   - Category: "Food" (has budget)
   - Date: Today
4. Tap "Add"
5. System checks Food budget:
   - If near limit (80%+): Orange warning
   - If exceeded: Red alert with "View" button
6. Expense is saved and budget updated

### Managing Budgets
1. Go to Budget Settings (⚙️ icon)
2. View all active budgets with status
3. Edit budget:
   - Tap ⋮ menu → "Edit"
   - Update limit or dates
   - Tap "Update"
4. Delete budget:
   - Tap ⋮ menu → "Delete"
   - Confirm deletion
   - Budget removed

## Best Practices

### Setting Realistic Budgets
- Review past spending in Analytics screen
- Set budgets 10-15% higher than average spending
- Start with major categories (Food, Transport, Bills)
- Adjust based on actual usage

### Budget Periods
- **Monthly**: Most common, aligns with salary
- **Weekly**: For tighter control
- **Custom**: For specific goals (e.g., vacation budget)

### Responding to Alerts
- **Near Limit**: Review recent expenses, cut unnecessary spending
- **Exceeded**: Analyze why, adjust budget or spending habits
- **Use "View" button**: Quick access to budget details

### Category Strategy
- Create budgets for variable expenses (Food, Entertainment)
- Fixed expenses (Rent, Bills) may not need strict limits
- Use "Other" for miscellaneous spending

## Technical Details

### State Management
- **BudgetCubit**: Manages budget CRUD operations
- **States**:
  - `BudgetLoaded`: Active budgets displayed
  - `BudgetLimitExceeded`: Triggers red alert
  - `BudgetNearLimit`: Triggers orange warning
  - `BudgetOperationSuccess`: Confirmation messages

### Real-time Updates
- Uses Firebase Realtime Database streams
- `watchBudgets()` keeps budgets in sync
- Automatic recalculation when expenses change

### Budget Checking Logic
```dart
// Triggered after adding expense
checkBudgetLimit(userId, expense) {
  if (expense.type == ExpenseType.debit) {
    // Get budget for category
    budget = getBudgetByCategory(userId, expense.category);
    
    if (budget.isActive) {
      // Update spent amount
      newSpentAmount = budget.spentAmount + expense.amount;
      
      // Check status
      if (newSpentAmount > budget.limitAmount) {
        emit(BudgetLimitExceeded);  // Red alert
      } else if (percentageUsed >= 80%) {
        emit(BudgetNearLimit);      // Orange warning
      }
    }
  }
}
```

## Troubleshooting

### Budget Not Updating
- Ensure expense category matches budget category exactly
- Check if budget is active (`isActive: true`)
- Verify expense type is "debit" (not "credit")
- Check date range - expense must be within budget period

### No Notifications
- Verify budget exists for the expense category
- Check if you've already seen the notification (won't repeat)
- Ensure expense amount pushes total over threshold

### Incorrect Spent Amount
- Use "Recalculate" feature (if implemented)
- Delete and recreate budget
- Check for duplicate expenses

## Future Enhancements
- [ ] Budget templates (e.g., "Conservative", "Moderate", "Flexible")
- [ ] Recurring budgets (auto-create monthly)
- [ ] Budget rollover (unused amount to next period)
- [ ] Multi-currency support
- [ ] Budget sharing (family/group budgets)
- [ ] AI-powered budget suggestions
- [ ] Budget vs. actual reports
- [ ] Export budget data
- [ ] Budget goals and milestones
- [ ] Push notifications (when app is closed)

## Summary
The budget management system provides:
✅ Easy budget creation by category
✅ Real-time spending tracking
✅ Automatic limit notifications
✅ Visual progress indicators
✅ Quick access from home screen
✅ Firebase-backed persistence
✅ Seamless integration with expenses

This helps users stay on track with their financial goals and avoid overspending!
