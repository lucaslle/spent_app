import '../entities/category_rule.dart';
import '../entities/spend_category.dart';
import '../entities/transaction_entry.dart';

class SpendingSnapshot {
  const SpendingSnapshot({required this.entries, required this.budgets, required this.lastImport, this.rules});

  final List<TransactionEntry> entries;
  final Map<SpendCategory, double> budgets;
  final String lastImport;
  final List<CategoryRule>? rules;
}

abstract interface class SpendingGateway {
  Future<SpendingSnapshot?> load();
  Future<void> save(SpendingSnapshot snapshot);
}
