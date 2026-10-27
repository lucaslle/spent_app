import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/spend_category.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/gateways/spending_gateway.dart';
import '../../domain/sample_data.dart';
import '../../domain/categorizer.dart';
import 'spending_state.dart';

enum ImportMode { replace, append }

class SpendingCubit extends Cubit<SpendingState> {
  SpendingCubit(this._gateway) : super(SpendingState(entries: const [], budgets: defaultBudgets(), lastImport: 'Aucun import'));

  final SpendingGateway _gateway;

  Future<void> load() async {
    final saved = await _gateway.load();
    if (saved != null) {
      emit(SpendingState(entries: saved.entries, budgets: saved.budgets, lastImport: saved.lastImport, loaded: true));
      return;
    }
    final sample = sampleTransactions();
    emit(SpendingState(entries: sample, budgets: defaultBudgets(), lastImport: _sampleLabel(sample.length), loaded: true));
  }

  String _sampleLabel(int n) => 'Exemple intégré · $n opérations';

  Future<void> _commit(SpendingState next) {
    emit(next);
    return _gateway.save(SpendingSnapshot(entries: next.entries, budgets: next.budgets, lastImport: next.lastImport));
  }

  Future<void> importEntries(List<TransactionEntry> incoming, String fileName, ImportMode mode) {
    var next = incoming;
    if (mode == ImportMode.append) {
      String key(TransactionEntry t) => '${t.date}|${t.raw}|${t.amount}';
      final seen = state.entries.map(key).toSet();
      next = [...state.entries, ...incoming.where((t) => !seen.contains(key(t)))]..sort(compareByDateDesc);
    }
    return _commit(state.copyWith(entries: next, lastImport: '$fileName · ${incoming.length} opérations'));
  }

  Future<int> classify(String id, SpendCategory category, {required bool applyToSimilar}) async {
    final target = state.entries.firstWhere((t) => t.id == id);
    final name = merchantName(target.raw);
    final ids = applyToSimilar ? state.entries.where((t) => merchantName(t.raw) == name).map((t) => t.id).toSet() : {id};
    await _commit(state.copyWith(entries: [for (final t in state.entries) ids.contains(t.id) ? t.copyWith(category: category, manual: true) : t]));
    return ids.length;
  }

  Future<void> toggleExcluded(String id) =>
      _commit(state.copyWith(entries: [for (final t in state.entries) t.id == id ? t.copyWith(excluded: !t.excluded) : t]));

  Future<void> setBudget(SpendCategory category, double value) =>
      _commit(state.copyWith(budgets: {...state.budgets, category: value < 0 ? 0 : value}));

  Future<void> resetBudgets() => _commit(state.copyWith(budgets: defaultBudgets()));

  Future<void> reloadSample() {
    final sample = sampleTransactions();
    return _commit(state.copyWith(entries: sample, lastImport: _sampleLabel(sample.length)));
  }

  Future<void> clearAll() => _commit(state.copyWith(entries: const [], lastImport: 'Aucun import'));
}
