import 'package:equatable/equatable.dart';

import 'account_type.dart';

class BalancePoint extends Equatable {
  const BalancePoint(this.date, this.balance);

  final String date;
  final double balance;

  @override
  List<Object?> get props => [date, balance];
}

class Account extends Equatable {
  const Account({required this.id, required this.type, required this.name, required this.balance, required this.updated, required this.history});

  final String id;
  final AccountType type;
  final String name;
  final double balance;
  final String updated;
  final List<BalancePoint> history;

  List<BalancePoint> get effectiveHistory => history.isEmpty ? [BalancePoint(updated, balance)] : history;

  @override
  List<Object?> get props => [id, type, name, balance, updated, history];
}
