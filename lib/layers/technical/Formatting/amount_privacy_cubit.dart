import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'formatters.dart';

class AmountPrivacyCubit extends Cubit<bool> {
  AmountPrivacyCubit(this._prefs) : super(_prefs.getBool(_key) ?? false);

  static const _key = 'hide_amounts';
  final SharedPreferences _prefs;

  Future<void> toggle() async {
    emit(!state);
    await _prefs.setBool(_key, state);
  }

  String money(double n, {int decimals = 2, bool sign = false}) =>
      state ? '••• €' : formatEuro(n, decimals: decimals, sign: sign);
}

extension MoneyContext on BuildContext {
  String money(double n, {int decimals = 2, bool sign = false}) => watch<AmountPrivacyCubit>().money(n, decimals: decimals, sign: sign);
}
