import 'package:flutter/material.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/screens/add_expense_screen.dart';
import 'package:monthly_expense_app/screens/dashboard_screen.dart';
import 'package:monthly_expense_app/screens/expenses_screen.dart';
import 'package:monthly_expense_app/screens/reports_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});

  final ExpenseController controller;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _currentIndex = 0;

  Future<void> _openAddExpenseScreen() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AddExpenseScreen(controller: widget.controller),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final screens = <Widget>[
          DashboardScreen(controller: widget.controller),
          ExpensesScreen(controller: widget.controller),
          ReportsScreen(controller: widget.controller),
        ];

        if (widget.controller.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(_titleForIndex(_currentIndex))),
          body: IndexedStack(index: _currentIndex, children: screens),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openAddExpenseScreen,
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const <NavigationDestination>[
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.list_alt_outlined),
                selectedIcon: Icon(Icons.list_alt_rounded),
                label: 'Expenses',
              ),
              NavigationDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics_rounded),
                label: 'Reports',
              ),
            ],
          ),
        );
      },
    );
  }

  String _titleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Monthly Overview';
      case 1:
        return 'Expenses';
      case 2:
        return 'Reports';
      default:
        return 'Monthly Expense Tracker';
    }
  }
}
