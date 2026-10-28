import 'package:equatable/equatable.dart';

import '../../../../technical/Formatting/formatters.dart';
import '../../domain/entities/category_rule.dart';
import '../../domain/entities/spend_category.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/spending_stats.dart';

class SpendingState extends Equatable {
  SpendingState({
    required this.entries,
    required this.budgets,
    required this.lastImport,
    this.rules = defaultRules,
    this.selectedMonth,
    this.loaded = false,
  })  : stats = computeSpendingStats(entries, budgets, todayIso(), month: selectedMonth),
        months = availableMonths(entries, todayIso());

  final List<TransactionEntry> entries;
  final Map<SpendCategory, double> budgets;
  final String lastImport;
  final List<CategoryRule> rules;
  final String? selectedMonth;
  final bool loaded;
  final SpendingStats? stats;
  final List<String> months;

  String? get displayedMonth => stats == null ? null : '${stats!.year}-${pad2(stats!.month)}';

  int get toReviewCount => entries.where((t) => t.category == SpendCategory.autre).length;

  SpendingState copyWith({
    List<TransactionEntry>? entries,
    Map<SpendCategory, double>? budgets,
    String? lastImport,
    List<CategoryRule>? rules,
    String? selectedMonth,
    bool clearMonth = false,
    bool? loaded,
  }) =>
      SpendingState(
        entries: entries ?? this.entries,
        budgets: budgets ?? this.budgets,
        lastImport: lastImport ?? this.lastImport,
        rules: rules ?? this.rules,
        selectedMonth: clearMonth ? null : (selectedMonth ?? this.selectedMonth),
        loaded: loaded ?? this.loaded,
      );

  @override
  List<Object?> get props => [entries, budgets, lastImport, rules, selectedMonth, loaded];
}
