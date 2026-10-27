import '../entities/account.dart';

abstract interface class AccountsGateway {
  Future<List<Account>?> load();
  Future<void> save(List<Account> accounts);
}
