import 'dart:convert';

enum ExpenseCategory {
  rent,
  bills,
  groceries,
  creditCard,
  transport,
  dining,
  other,
}

enum PaymentMethod { cash, bankTransfer, debitCard, creditCard, eWallet }

extension ExpenseCategoryLabel on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.rent:
        return 'Rent';
      case ExpenseCategory.bills:
        return 'Bills';
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.creditCard:
        return 'Credit Card';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.dining:
        return 'Dining';
      case ExpenseCategory.other:
        return 'Other';
    }
  }
}

extension PaymentMethodLabel on PaymentMethod {
  String get label {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.eWallet:
        return 'E-Wallet';
    }
  }
}

class Expense {
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.paymentMethod,
    this.note,
  });

  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final String? note;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      category: _expenseCategoryFromName(json['category'] as String?),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      paymentMethod: _paymentMethodFromName(json['paymentMethod'] as String?),
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod.name,
      'note': note,
    };
  }

  String toEncodedJson() => jsonEncode(toJson());
}

ExpenseCategory _expenseCategoryFromName(String? value) {
  return ExpenseCategory.values.firstWhere(
    (category) => category.name == value,
    orElse: () => ExpenseCategory.other,
  );
}

PaymentMethod _paymentMethodFromName(String? value) {
  return PaymentMethod.values.firstWhere(
    (method) => method.name == value,
    orElse: () => PaymentMethod.cash,
  );
}
