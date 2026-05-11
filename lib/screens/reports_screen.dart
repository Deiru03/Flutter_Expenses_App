import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/models/expense.dart';
import 'package:monthly_expense_app/widgets/expense_tile.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, required this.controller});

  final ExpenseController controller;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  late DateTime _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  Future<void> _pickReportMonth() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedMonth,
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
      helpText: 'Select report month',
    );

    if (pickedDate == null) {
      return;
    }

    setState(() {
      _selectedMonth = DateTime(pickedDate.year, pickedDate.month);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthTotal = widget.controller.totalForMonth(_selectedMonth);
    final previousMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month - 1,
    );
    final previousMonthTotal = widget.controller.totalForMonth(previousMonth);
    final totalsByCategory =
        widget.controller
            .totalsByCategoryForMonth(_selectedMonth)
            .entries
            .where((entry) => entry.value > 0)
            .toList()
          ..sort((left, right) => right.value.compareTo(left.value));
    final currency = NumberFormat.currency(locale: 'en_PH', symbol: 'PHP ');
    final topCategory = widget.controller.topCategoryForMonth(_selectedMonth);
    final delta = monthTotal - previousMonthTotal;
    final isHigherThanPreviousMonth = delta >= 0;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      children: <Widget>[
        _ReportsHeader(selectedMonth: _selectedMonth),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Selected Month',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        DateFormat.yMMMM().format(_selectedMonth),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton.tonal(
                  onPressed: _pickReportMonth,
                  child: const Text('Change'),
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
                  'Month-over-month summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Selected month: ${currency.format(monthTotal)}'),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Top category: ${topCategory?.label ?? 'None'}'),
                const SizedBox(height: 6),
                Text(
                  'Average transaction: ${currency.format(widget.controller.averageForMonth(_selectedMonth))}',
                ),
                const SizedBox(height: 6),
                Text(
                  'Transactions this month: ${widget.controller.expenseCountForMonth(_selectedMonth)}',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (monthTotal == 0)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'No expenses found for ${DateFormat.yMMMM().format(_selectedMonth)}. '
                'Choose another month or add more records.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
          )
        else ...<Widget>[
          Text(
            'Category Breakdown',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...totalsByCategory.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _CategoryBreakdownTile(
                category: entry.key,
                value: entry.value,
                total: monthTotal,
                currency: currency,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ReportsHeader extends StatelessWidget {
  const _ReportsHeader({required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(
            Icons.analytics_rounded,
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Monthly Analysis',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Analysis for ${DateFormat.yMMMM().format(selectedMonth)}',
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  currency.format(value),
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
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
