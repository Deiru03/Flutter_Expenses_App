import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_app/models/expense.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: 'PHP ');

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: expenseColor(
            context,
            expense.category,
          ).withValues(alpha: 0.15),
          child: Icon(
            expenseIcon(expense.category),
            color: expenseColor(context, expense.category),
          ),
        ),
        title: Text(
          expense.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          '${expense.category.label} • ${expense.paymentMethod.label} • '
          '${DateFormat.yMMMd().format(expense.date)}',
        ),
        trailing: Text(
          currency.format(expense.amount),
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

IconData expenseIcon(ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.rent:
      return Icons.home_rounded;
    case ExpenseCategory.bills:
      return Icons.receipt_long_rounded;
    case ExpenseCategory.groceries:
      return Icons.shopping_cart_rounded;
    case ExpenseCategory.creditCard:
      return Icons.credit_card_rounded;
    case ExpenseCategory.transport:
      return Icons.directions_bus_rounded;
    case ExpenseCategory.dining:
      return Icons.restaurant_rounded;
    case ExpenseCategory.other:
      return Icons.more_horiz_rounded;
  }
}

Color expenseColor(BuildContext context, ExpenseCategory category) {
  switch (category) {
    case ExpenseCategory.rent:
      return Colors.indigo;
    case ExpenseCategory.bills:
      return Colors.orange;
    case ExpenseCategory.groceries:
      return Colors.green;
    case ExpenseCategory.creditCard:
      return Colors.redAccent;
    case ExpenseCategory.transport:
      return Colors.blue;
    case ExpenseCategory.dining:
      return Colors.purple;
    case ExpenseCategory.other:
      return Theme.of(context).colorScheme.primary;
  }
}
