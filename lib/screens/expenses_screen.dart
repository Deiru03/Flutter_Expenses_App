import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/models/expense.dart';
import 'package:monthly_expense_app/screens/add_expense_screen.dart';
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
              onDismissed: (_) async {
                await controller.deleteExpense(expense.id);
                if (!context.mounted) {
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${expense.title} removed')),
                );
              },
              child: ExpenseTile(
                expense: expense,
                onTap: () {
                  _showExpenseActions(context, controller, expense);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}

Future<void> _showExpenseActions(
  BuildContext parentContext,
  ExpenseController controller,
  Expense expense,
) async {
  await showModalBottomSheet<void>(
    context: parentContext,
    showDragHandle: true,
    builder: (sheetContext) {
      final errorColor = Theme.of(sheetContext).colorScheme.error;

      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
          child: Wrap(
            children: <Widget>[
              ListTile(
                title: Text(
                  expense.title,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
                subtitle: const Text(
                  'Choose what you want to do with this expense record.',
                ),
              ),
              ListTile(
                leading: const Icon(Icons.edit_rounded),
                title: const Text('Edit'),
                subtitle: const Text('Open this expense in the form'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await Navigator.of(parentContext).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => AddExpenseScreen(
                        controller: controller,
                        existingExpense: expense,
                      ),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.delete_outline_rounded, color: errorColor),
                title: Text('Delete', style: TextStyle(color: errorColor)),
                subtitle: const Text('Remove this expense permanently'),
                onTap: () async {
                  Navigator.of(sheetContext).pop();
                  await controller.deleteExpense(expense.id);
                  if (!parentContext.mounted) {
                    return;
                  }
                  ScaffoldMessenger.of(parentContext).showSnackBar(
                    SnackBar(content: Text('${expense.title} removed')),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
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
