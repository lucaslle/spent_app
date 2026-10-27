import '../entities/spend_category.dart';
import '../entities/transaction_entry.dart';

class SpendingSnapshot {
  const SpendingSnapshot({required this.entries, required this.budgets, required this.lastImport});

  final List<TransactionEntry> entries;
  final Map<SpendCategory, double> budgets;
  final String lastImport;
}

abstract interface class SpendingGateway {
  Future<SpendingSnapshot?> load();
  Future<void> save(SpendingSnapshot snapshot);
}
