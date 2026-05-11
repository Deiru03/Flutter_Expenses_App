import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_app/controllers/expense_controller.dart';
import 'package:monthly_expense_app/main.dart';
import 'package:monthly_expense_app/models/expense.dart';
import 'package:monthly_expense_app/services/expense_storage.dart';

void main() {
  test('updateExpense replaces the matching record', () async {
    final originalExpense = Expense(
      id: '1',
      title: 'Apartment Rent',
      amount: 12500,
      category: ExpenseCategory.rent,
      date: DateTime(2026, 5, 1),
      paymentMethod: PaymentMethod.bankTransfer,
    );
    final controller = ExpenseController(
      storage: FakeExpenseStorage(initialExpenses: <Expense>[originalExpense]),
    );

    await controller.loadExpenses();
    await controller.updateExpense(
      Expense(
        id: '1',
        title: 'Updated Apartment Rent',
        amount: 12800,
        category: ExpenseCategory.rent,
        date: DateTime(2026, 5, 1),
        paymentMethod: PaymentMethod.bankTransfer,
      ),
    );

    expect(controller.expenses, hasLength(1));
    expect(controller.expenses.single.title, 'Updated Apartment Rent');
    expect(controller.expenses.single.amount, 12800);
  });

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
    expect(find.text('Total Spent'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
  });

  testWidgets('shows previous month summary on the dashboard', (
    WidgetTester tester,
  ) async {
    final now = DateTime.now();
    final previousMonthDate = DateTime(now.year, now.month - 1, 15);
    final controller = ExpenseController(
      storage: FakeExpenseStorage(
        initialExpenses: <Expense>[
          Expense(
            id: '1',
            title: 'Current Month Rent',
            amount: 10000,
            category: ExpenseCategory.rent,
            date: now,
            paymentMethod: PaymentMethod.bankTransfer,
          ),
          Expense(
            id: '2',
            title: 'Previous Month Groceries',
            amount: 4200,
            category: ExpenseCategory.groceries,
            date: previousMonthDate,
            paymentMethod: PaymentMethod.cash,
          ),
        ],
      ),
    );

    await tester.pumpWidget(ExpenseTrackerApp(controller: controller));
    await tester.pumpAndSettle();

    expect(find.text('Previous Month'), findsOneWidget);
    expect(
      find.text(DateFormat.yMMMM().format(previousMonthDate)),
      findsOneWidget,
    );
  });

  testWidgets('shows a month picker on the reports tab', (
    WidgetTester tester,
  ) async {
    final controller = ExpenseController(
      storage: FakeExpenseStorage(
        initialExpenses: <Expense>[
          Expense(
            id: '1',
            title: 'Report Seed Expense',
            amount: 1000,
            category: ExpenseCategory.other,
            date: DateTime.now(),
            paymentMethod: PaymentMethod.cash,
          ),
        ],
      ),
    );

    await tester.pumpWidget(ExpenseTrackerApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();

    expect(find.text('Selected Month'), findsOneWidget);
    expect(find.text('Change'), findsOneWidget);
  });

  testWidgets('opens expense actions and deletes the selected record', (
    WidgetTester tester,
  ) async {
    final controller = ExpenseController(
      storage: FakeExpenseStorage(
        initialExpenses: <Expense>[
          Expense(
            id: '1',
            title: 'Electricity Bill',
            amount: 725,
            category: ExpenseCategory.bills,
            date: DateTime.now(),
            paymentMethod: PaymentMethod.eWallet,
          ),
        ],
      ),
    );

    await tester.pumpWidget(ExpenseTrackerApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Electricity Bill'));
    await tester.pumpAndSettle();

    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(find.text('Electricity Bill'), findsNothing);
  });

  testWidgets('opens the edit form with the selected expense data', (
    WidgetTester tester,
  ) async {
    final controller = ExpenseController(
      storage: FakeExpenseStorage(
        initialExpenses: <Expense>[
          Expense(
            id: '1',
            title: 'Groceries',
            amount: 5000,
            category: ExpenseCategory.groceries,
            date: DateTime.now(),
            paymentMethod: PaymentMethod.creditCard,
            note: 'Weekly market',
          ),
        ],
      ),
    );

    await tester.pumpWidget(ExpenseTrackerApp(controller: controller));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Expenses'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Expense'), findsOneWidget);
    expect(find.text('Groceries'), findsWidgets);
    expect(find.text('Save Changes'), findsOneWidget);
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
