import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../technical/Formatting/formatters.dart';
import '../../domain/account_math.dart';
import '../../domain/entities/account.dart';
import '../../domain/entities/account_type.dart';
import '../../domain/gateways/accounts_gateway.dart';

class AccountsCubit extends Cubit<List<Account>> {
  AccountsCubit(this._gateway) : super(const []);

  final AccountsGateway _gateway;

  Future<void> load() async => emit(await _gateway.load() ?? const []);

  Future<void> _commit(List<Account> next) {
    emit(next);
    return _gateway.save(next);
  }

  Future<void> save({String? id, required AccountType type, required String name, required double balance}) {
    final account = upsertAccount(state, id: id, type: type, name: name, balance: balance, today: todayIso());
    return _commit(id == null ? [...state, account] : [for (final a in state) a.id == id ? account : a]);
  }

  Future<void> remove(String id) => _commit(state.where((a) => a.id != id).toList());
}
