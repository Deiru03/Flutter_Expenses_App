import 'package:flutter/foundation.dart';
import 'package:monthly_expense_app/models/expense.dart';
import 'package:monthly_expense_app/services/expense_storage.dart';

class ExpenseController extends ChangeNotifier {
  ExpenseController({required ExpenseStorage storage}) : _storage = storage;

  final ExpenseStorage _storage;

  List<Expense> _expenses = <Expense>[];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  List<Expense> get expenses => List<Expense>.unmodifiable(_expenses);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadExpenses() async {
    if (_hasLoaded) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _expenses = await _storage.loadExpenses();
      _sortExpenses();
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Unable to load saved expenses.';
    } finally {
      _hasLoaded = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    _expenses = <Expense>[expense, ..._expenses];
    _sortExpenses();
    notifyListeners();
    await _persist();
  }

  Future<void> updateExpense(Expense updatedExpense) async {
    _expenses = _expenses.map((expense) {
      if (expense.id == updatedExpense.id) {
        return updatedExpense;
      }
      return expense;
    }).toList();
    _sortExpenses();
    notifyListeners();
    await _persist();
  }

  Future<void> deleteExpense(String expenseId) async {
    _expenses = _expenses.where((expense) => expense.id != expenseId).toList();
    notifyListeners();
    await _persist();
  }

  List<Expense> recentExpenses({int count = 5}) {
    final end = count.clamp(0, _expenses.length);
    return _expenses.take(end).toList();
  }

  List<Expense> expensesForMonth(DateTime month) {
    return _expenses.where((expense) {
      return expense.date.year == month.year &&
          expense.date.month == month.month;
    }).toList();
  }

  double totalForMonth(DateTime month) {
    return expensesForMonth(
      month,
    ).fold<double>(0, (sum, expense) => sum + expense.amount);
  }

  int expenseCountForMonth(DateTime month) {
    return expensesForMonth(month).length;
  }

  double averageForMonth(DateTime month) {
    final monthExpenses = expensesForMonth(month);
    if (monthExpenses.isEmpty) {
      return 0;
    }

    final total = monthExpenses.fold<double>(
      0,
      (sum, expense) => sum + expense.amount,
    );
    return total / monthExpenses.length;
  }

  Map<ExpenseCategory, double> totalsByCategoryForMonth(DateTime month) {
    final totals = <ExpenseCategory, double>{
      for (final category in ExpenseCategory.values) category: 0,
    };

    for (final expense in expensesForMonth(month)) {
      totals.update(
        expense.category,
        (current) => current + expense.amount,
        ifAbsent: () => expense.amount,
      );
    }

    return totals;
  }

  ExpenseCategory? topCategoryForMonth(DateTime month) {
    final totals = totalsByCategoryForMonth(month);
    final nonZeroTotals = totals.entries
        .where((entry) => entry.value > 0)
        .toList(growable: false);

    if (nonZeroTotals.isEmpty) {
      return null;
    }

    nonZeroTotals.sort((left, right) => right.value.compareTo(left.value));
    return nonZeroTotals.first.key;
  }

  double totalForPreviousMonth(DateTime month) {
    final previousMonth = DateTime(month.year, month.month - 1);
    return totalForMonth(previousMonth);
  }

  Future<void> _persist() async {
    try {
      await _storage.saveExpenses(_expenses);
      _errorMessage = null;
    } catch (_) {
      _errorMessage = 'Unable to save your latest expense changes.';
    } finally {
      notifyListeners();
    }
  }

  void _sortExpenses() {
    _expenses.sort((left, right) => right.date.compareTo(left.date));
  }
}
