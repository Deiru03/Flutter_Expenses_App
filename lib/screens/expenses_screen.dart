import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/widgets/expense_tile.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key, required this.controller});

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    final expenses = controller.expenses;
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: 'PHP ');
    final currentMonth = DateTime.now();

    if (expenses.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Your expense list is empty. Tap "Add Expense" to record your first monthly cost.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _SummaryStat(
                    label: 'This Month',
                    value: currency.format(
                      controller.totalForMonth(currentMonth),
                    ),
                  ),
                ),
                Expanded(
                  child: _SummaryStat(
                    label: 'All Records',
                    value: '${expenses.length}',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ...expenses.map(
          (expense) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Dismissible(
              key: ValueKey<String>(expense.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.delete_outline_rounded,
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
              onDismissed: (_) {
                controller.deleteExpense(expense.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${expense.title} removed')),
                );
              },
              child: ExpenseTile(expense: expense),
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
