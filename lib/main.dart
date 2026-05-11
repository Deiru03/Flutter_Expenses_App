import 'package:flutter/material.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/screens/home_shell.dart';
import 'package:monthly_expense_app/services/expense_storage.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatefulWidget {
  ExpenseTrackerApp({super.key, ExpenseController? controller})
    : controller =
          controller ??
          ExpenseController(storage: SharedPreferencesExpenseStorage());

  final ExpenseController controller;

  @override
  State<ExpenseTrackerApp> createState() => _ExpenseTrackerAppState();
}

class _ExpenseTrackerAppState extends State<ExpenseTrackerApp> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadExpenses();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monthly Expense Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        useMaterial3: true,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      home: HomeShell(controller: widget.controller),
    );
  }
}
