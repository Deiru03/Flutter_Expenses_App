import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_app/models/expense.dart';

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense, this.onTap});

  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: 'PHP ');
    final categoryColor = expenseColor(context, expense.category);
    final amountText = currency.format(expense.amount);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  expenseIcon(expense.category),
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      expense.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${expense.category.label} • ${expense.paymentMethod.label}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormat.yMMMd().format(expense.date),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      amountText,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (onTap != null) ...<Widget>[
                    const SizedBox(height: 10),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ],
          ),
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
