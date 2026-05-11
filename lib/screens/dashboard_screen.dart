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
    final previousMonth = DateTime(now.year, now.month - 1);
    final previousMonthTotal = controller.totalForMonth(previousMonth);
    final currentMonthTotal = controller.totalForMonth(now);
    final monthDifference = currentMonthTotal - previousMonthTotal;

    if (currentMonthExpenses.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
        children: <Widget>[
          _SectionIntro(
            icon: Icons.spa_rounded,
            title: 'Monthly Snapshot',
            subtitle:
                'Track your rent, bills, groceries, and card payments in one calm space.',
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      Icons.auto_graph_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No expenses yet for ${DateFormat.yMMMM().format(now)}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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
          const SizedBox(height: 16),
          _PreviousMonthSummaryCard(
            monthLabel: DateFormat.yMMMM().format(previousMonth),
            value: currency.format(previousMonthTotal),
            differenceLabel: previousMonthTotal == 0
                ? 'No expenses recorded for the previous month yet.'
                : 'This month is ${currency.format(monthDifference.abs())} '
                      '${monthDifference >= 0 ? 'higher' : 'lower'} than last month.',
          ),
        ],
      );
    }

    final recentExpenses = controller.recentExpenses();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: <Widget>[
        _SectionIntro(
          icon: Icons.spa_rounded,
          title: 'Monthly Snapshot',
          subtitle: 'Overview for ${DateFormat.yMMMM().format(now)}',
        ),
        const SizedBox(height: 20),
        _MonthlyHeroCard(
          monthLabel: DateFormat.yMMMM().format(now),
          total: currency.format(currentMonthTotal),
          transactionCount: controller.expenseCountForMonth(now),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _MetricCard(
              title: 'Total Spent',
              value: currency.format(currentMonthTotal),
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
        const SizedBox(height: 20),
        _PreviousMonthSummaryCard(
          monthLabel: DateFormat.yMMMM().format(previousMonth),
          value: currency.format(previousMonthTotal),
          differenceLabel: previousMonthTotal == 0
              ? 'No expenses recorded for the previous month yet.'
              : 'Compared with ${DateFormat.yMMMM().format(now)}, your spending is '
                    '${currency.format(monthDifference.abs())} '
                    '${monthDifference >= 0 ? 'higher' : 'lower'}.',
        ),
        const SizedBox(height: 24),
        Text(
          'Category Breakdown',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
        Text(
          'Recent Expenses',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
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

class _SectionIntro extends StatelessWidget {
  const _SectionIntro({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MonthlyHeroCard extends StatelessWidget {
  const _MonthlyHeroCard({
    required this.monthLabel,
    required this.total,
    required this.transactionCount,
  });

  final String monthLabel;
  final String total;
  final int transactionCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: <Color>[
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.82),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.wallet_rounded, color: Colors.white),
                ),
                const Spacer(),
                Text(
                  monthLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Total Spent',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.82),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              total,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '$transactionCount recorded transactions',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PreviousMonthSummaryCard extends StatelessWidget {
  const _PreviousMonthSummaryCard({
    required this.monthLabel,
    required this.value,
    required this.differenceLabel,
  });

  final String monthLabel;
  final String value;
  final String differenceLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.history_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Previous Month',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              monthLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              differenceLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
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
      width: 168,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        trailing: Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
