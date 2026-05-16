import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/models/expense.dart';
import 'package:monthly_expense_app/screens/add_expense_screen.dart';
import 'package:monthly_expense_app/widgets/expense_tile.dart';

Future<void> showExpenseDetailsSheet({
  required BuildContext parentContext,
  required ExpenseController controller,
  required Expense expense,
}) async {
  await showModalBottomSheet<void>(
    context: parentContext,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final currency = NumberFormat.currency(locale: 'en_PH', symbol: 'PHP ');
      final categoryColor = expenseColor(sheetContext, expense.category);
      final errorColor = Theme.of(sheetContext).colorScheme.error;
      
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 52,
                    height: 52,
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
                          style: Theme.of(sheetContext)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          expense.category.label,
                          style: Theme.of(sheetContext)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: Theme.of(sheetContext)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                currency.format(expense.amount),
                style: Theme.of(sheetContext).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(sheetContext).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 20),
              _DetailRow(
                icon: Icons.category_rounded,
                label: 'Category',
                value: expense.category.label,
              ),
              _DetailRow(
                icon: Icons.payments_rounded,
                label: 'Payment Method',
                value: expense.paymentMethod.label,
              ),
              _DetailRow(
                icon: Icons.calendar_month_rounded,
                label: 'Date',
                value: DateFormat.yMMMMd().format(expense.date),
              ),
              _DetailRow(
                icon: Icons.notes_rounded,
                label: 'Notes',
                value: expense.note == null || expense.note!.isEmpty
                    ? 'No notes added'
                    : expense.note!,
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
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
                      icon: const Icon(Icons.edit_rounded),
                      label: const Text('Edit'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: errorColor,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        Navigator.of(sheetContext).pop();
                        await controller.deleteExpense(expense.id);
                        if (!parentContext.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            content: Text('${expense.title} removed'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}