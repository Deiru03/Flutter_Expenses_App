import 'package:flutter_test/flutter_test.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/models/expense.dart';
import 'package:monthly_expense_app/services/expense_storage.dart';

void main() {
  testWidgets('shows the main expense tracker navigation', (
    WidgetTester tester,
  ) async {
    final controller = ExpenseController(storage: FakeExpenseStorage());

    await tester.pumpWidget(ExpenseTrackerApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('BudgetBuddy'), findsNWidgets(2));
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Reports'), findsOneWidget);
    expect(find.text('Add Expense'), findsOneWidget);
  });

  testWidgets('loads saved expenses into the dashboard', (
    WidgetTester tester,
  ) async {
    final fakeStorage = FakeExpenseStorage(
      initialExpenses: <Expense>[
        Expense(
          id: '1',
          title: 'Apartment Rent',
          amount: 12500,
          category: ExpenseCategory.rent,
          date: DateTime.now(),
          paymentMethod: PaymentMethod.bankTransfer,
        ),
      ],
    );

    final controller = ExpenseController(storage: fakeStorage);

    await tester.pumpWidget(ExpenseTrackerApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.textContaining('Summary for'), findsOneWidget);
    expect(find.text('Category Breakdown'), findsOneWidget);
    expect(find.text('Rent'), findsOneWidget);
  });
}

class FakeExpenseStorage implements ExpenseStorage {
  FakeExpenseStorage({List<Expense>? initialExpenses})
    : _expenses = List<Expense>.from(initialExpenses ?? const <Expense>[]);

  List<Expense> _expenses;

  @override
  Future<List<Expense>> loadExpenses() async {
    return List<Expense>.from(_expenses);
  }

  @override
  Future<void> saveExpenses(List<Expense> expenses) async {
    _expenses = List<Expense>.from(expenses);
  }
}
