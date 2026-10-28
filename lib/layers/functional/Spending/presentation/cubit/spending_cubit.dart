import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/categorizer.dart';
import '../../domain/entities/category_rule.dart';
import '../../domain/entities/spend_category.dart';
import '../../domain/entities/transaction_entry.dart';
import '../../domain/gateways/spending_gateway.dart';
import 'spending_state.dart';

enum ImportMode { replace, append }

class SpendingCubit extends Cubit<SpendingState> {
  SpendingCubit(this._gateway) : super(SpendingState(entries: const [], budgets: const {}, lastImport: 'Aucun import'));

  final SpendingGateway _gateway;

  Future<void> load() async {
    final saved = await _gateway.load();
    emit(SpendingState(
      entries: saved?.entries ?? const [],
      budgets: saved?.budgets ?? const {},
      lastImport: saved?.lastImport ?? 'Aucun import',
      rules: saved?.rules ?? defaultRules,
      loaded: true,
    ));
  }

  Future<void> _commit(SpendingState next) {
    emit(next);
    return _gateway.save(SpendingSnapshot(entries: next.entries, budgets: next.budgets, lastImport: next.lastImport, rules: next.rules));
  }

  Future<int> importEntries(List<TransactionEntry> incoming, String fileName, ImportMode mode) async {
    final before = state.entries.length;
    var next = incoming;
    if (mode == ImportMode.append) {
      final existing = state.entries;
      final references = {for (final t in existing) ?t.reference};
      final looseKeys = {for (final t in existing.where((t) => t.reference == null)) _looseKey(t)};
      final fresh = incoming.where((t) {
        final ref = t.reference;
        if (ref != null && references.contains(ref)) return false;
        return !looseKeys.contains(_looseKey(t));
      }).toList();
      next = [...existing, ...fresh]..sort(compareByDateDesc);
    }
    await _commit(state.copyWith(entries: next, lastImport: '$fileName · ${incoming.length} opérations'));
    return mode == ImportMode.append ? next.length - before : next.length;
  }

  String _looseKey(TransactionEntry t) => '${t.date}|${t.raw}|${t.amount}';

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

  Future<void> resetBudgets() => _commit(state.copyWith(budgets: const {}));

  Future<void> clearAll() => _commit(state.copyWith(entries: const [], lastImport: 'Aucun import', clearMonth: true));

  /// Ajoute (ou remplace) une règle et l'applique aux opérations existantes non classées à la main.
  Future<int> addRule(String keyword, SpendCategory? category) async {
    final k = keyword.trim().toLowerCase();
    if (k.isEmpty) return 0;
    final rule = CategoryRule(keyword: k, category: category);
    var changed = 0;
    final entries = [
      for (final t in state.entries)
        if (!t.manual && rule.matches(t.raw))
          () {
            changed++;
            return category == null ? t.copyWith(excluded: true) : t.copyWith(category: category);
          }()
        else
          t,
    ];
    await _commit(state.copyWith(entries: entries, rules: [...state.rules.where((r) => r.keyword != k), rule]));
    return changed;
  }

  Future<void> removeRule(String keyword) => _commit(state.copyWith(rules: state.rules.where((r) => r.keyword != keyword).toList()));

  void selectMonth(String month) => emit(state.copyWith(selectedMonth: month));
}
