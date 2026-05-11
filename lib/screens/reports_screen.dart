import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/models/expense.dart';
import 'package:monthly_expense_app/widgets/expense_tile.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key, required this.controller});

  final ExpenseController controller;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonthTotal = controller.totalForMonth(now);

    if (currentMonthTotal == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Reports will appear after you add expenses for this month.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    final previousMonthTotal = controller.totalForPreviousMonth(now);
    final totalsByCategory =
        controller
            .totalsByCategoryForMonth(now)
            .entries
            .where((entry) => entry.value > 0)
            .toList()
          ..sort((left, right) => right.value.compareTo(left.value));
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: 'PHP ');
    final topCategory = controller.topCategoryForMonth(now);
    final delta = currentMonthTotal - previousMonthTotal;
    final isHigherThanPreviousMonth = delta >= 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: <Widget>[
        Text(
          'Report for ${DateFormat.yMMMM().format(now)}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Month-over-month summary',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text('Current month: ${currency.format(currentMonthTotal)}'),
                const SizedBox(height: 6),
                Text('Previous month: ${currency.format(previousMonthTotal)}'),
                const SizedBox(height: 6),
                Text(
                  previousMonthTotal == 0
                      ? 'No previous month data yet.'
                      : '${currency.format(delta.abs())} '
                            '${isHigherThanPreviousMonth ? 'higher' : 'lower'} than last month',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'Insights',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                Text('Top category: ${topCategory?.label ?? 'None'}'),
                const SizedBox(height: 6),
                Text(
                  'Average transaction: ${currency.format(controller.averageForMonth(now))}',
                ),
                const SizedBox(height: 6),
                Text(
                  'Transactions this month: ${controller.expenseCountForMonth(now)}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Category Breakdown',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        ...totalsByCategory.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CategoryBreakdownTile(
              category: entry.key,
              value: entry.value,
              total: currentMonthTotal,
              currency: currency,
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryBreakdownTile extends StatelessWidget {
  const _CategoryBreakdownTile({
    required this.category,
    required this.value,
    required this.total,
    required this.currency,
  });

  final ExpenseCategory category;
  final double value;
  final double total;
  final NumberFormat currency;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : value / total;
    final color = expenseColor(context, category);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(expenseIcon(category), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  currency.format(value),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              borderRadius: BorderRadius.circular(8),
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
            const SizedBox(height: 8),
            Text('${(progress * 100).toStringAsFixed(1)}% of monthly spending'),
          ],
        ),
      ),
    );
  }
}
