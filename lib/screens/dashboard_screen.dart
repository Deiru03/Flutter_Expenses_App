import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/models/expense.dart';
import 'package:monthly_expense_app/widgets/expense_tile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.controller});

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonthExpenses = controller.expensesForMonth(now);
    final totalsByCategory = controller.totalsByCategoryForMonth(now);
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: 'PHP ');

    if (currentMonthExpenses.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          Text(
            'Monthly Expense Tracker',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Track your rent, bills, groceries, and card payments in one place.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'No expenses yet for ${DateFormat.yMMMM().format(now)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Start by adding your first expense entry. '
                    'The dashboard will automatically calculate your monthly summary and reports.',
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    final recentExpenses = controller.recentExpenses();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          'Monthly Expense Tracker',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Summary for ${DateFormat.yMMMM().format(now)}',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _MetricCard(
              title: 'Total Spent',
              value: currency.format(controller.totalForMonth(now)),
              icon: Icons.payments_rounded,
            ),
            _MetricCard(
              title: 'Transactions',
              value: '${controller.expenseCountForMonth(now)}',
              icon: Icons.receipt_rounded,
            ),
            _MetricCard(
              title: 'Average',
              value: currency.format(controller.averageForMonth(now)),
              icon: Icons.insights_rounded,
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Category Breakdown',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...totalsByCategory.entries
            .where((entry) => entry.value > 0)
            .map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CategorySummaryRow(
                  label: entry.key.label,
                  value: currency.format(entry.value),
                  icon: expenseIcon(entry.key),
                  color: expenseColor(context, entry.key),
                ),
              ),
            ),
        const SizedBox(height: 24),
        Text('Recent Expenses', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...recentExpenses.map(
          (expense) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ExpenseTile(expense: expense),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 12),
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategorySummaryRow extends StatelessWidget {
  const _CategorySummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(label),
        trailing: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
