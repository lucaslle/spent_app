import 'package:equatable/equatable.dart';

import 'spend_category.dart';

class TransactionEntry extends Equatable {
  const TransactionEntry({
    required this.id,
    required this.date,
    required this.raw,
    required this.amount,
    required this.category,
    this.excluded = false,
    this.manual = false,
  });

  final String id;
  final String date;
  final String raw;
  final double amount;
  final SpendCategory category;
  final bool excluded;
  final bool manual;

  bool get isSpend => !excluded && SpendCategory.spending.contains(category) && (amount < 0 || category != SpendCategory.autre);
  bool get isVariableSpend => isSpend && !category.isFixed;
  bool get isIncome => amount > 0 && !excluded && category == SpendCategory.revenus;

  TransactionEntry copyWith({SpendCategory? category, bool? excluded, bool? manual}) => TransactionEntry(
        id: id,
        date: date,
        raw: raw,
        amount: amount,
        category: category ?? this.category,
        excluded: excluded ?? this.excluded,
        manual: manual ?? this.manual,
      );

  @override
  List<Object?> get props => [id, date, raw, amount, category, excluded, manual];
}

int compareByDateDesc(TransactionEntry a, TransactionEntry b) => b.date.compareTo(a.date);
