import 'dart:convert';

import 'package:monthly_expense_app/models/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class ExpenseStorage {
  Future<List<Expense>> loadExpenses();

  Future<void> saveExpenses(List<Expense> expenses);
}

class SharedPreferencesExpenseStorage implements ExpenseStorage {
  static const String _storageKey = 'saved_expenses';

  @override
  Future<List<Expense>> loadExpenses() async {
    final preferences = await SharedPreferences.getInstance();
    final rawExpenses = preferences.getString(_storageKey);

    if (rawExpenses == null || rawExpenses.isEmpty) {
      return <Expense>[];
    }

    final decoded = jsonDecode(rawExpenses);
    if (decoded is! List) {
      return <Expense>[];
    }

    return decoded
        .whereType<Map<dynamic, dynamic>>()
        .map(
          (item) => Expense.fromJson(
            item.map((key, value) => MapEntry(key.toString(), value)),
          ),
        )
        .toList();
  }

  @override
  Future<void> saveExpenses(List<Expense> expenses) async {
    final preferences = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      expenses.map((expense) => expense.toJson()).toList(),
    );

    await preferences.setString(_storageKey, encoded);
  }
}
