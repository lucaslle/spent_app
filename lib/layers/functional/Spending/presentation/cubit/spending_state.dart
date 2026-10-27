import 'package:equatable/equatable.dart';

import '../../../../technical/Formatting/formatters.dart';
import '../../domain/entities/spend_category.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/spending_stats.dart';

class SpendingState extends Equatable {
  SpendingState({required this.entries, required this.budgets, required this.lastImport, this.loaded = false})
      : stats = computeSpendingStats(entries, budgets, todayIso());

  final List<TransactionEntry> entries;
  final Map<SpendCategory, double> budgets;
  final String lastImport;
  final bool loaded;
  final SpendingStats? stats;

  int get toReviewCount => entries.where((t) => t.category == SpendCategory.autre).length;

  SpendingState copyWith({List<TransactionEntry>? entries, Map<SpendCategory, double>? budgets, String? lastImport, bool? loaded}) => SpendingState(
        entries: entries ?? this.entries,
        budgets: budgets ?? this.budgets,
        lastImport: lastImport ?? this.lastImport,
        loaded: loaded ?? this.loaded,
      );

  @override
  List<Object?> get props => [entries, budgets, lastImport, loaded];
}
