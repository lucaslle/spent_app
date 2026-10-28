import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'device_authenticator.dart';

class AppLockState extends Equatable {
  const AppLockState({this.ready = false, this.available = false, this.enabled = true, this.locked = true, this.busy = false});

  final bool ready;
  final bool available;
  final bool enabled;
  final bool locked;
  final bool busy;

  bool get protectionActive => available && enabled;

  AppLockState copyWith({bool? ready, bool? available, bool? enabled, bool? locked, bool? busy}) => AppLockState(
        ready: ready ?? this.ready,
        available: available ?? this.available,
        enabled: enabled ?? this.enabled,
        locked: locked ?? this.locked,
        busy: busy ?? this.busy,
      );

  @override
  List<Object?> get props => [ready, available, enabled, locked, busy];
}

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit(this._prefs, this._authenticator) : super(const AppLockState());

  static const _key = 'app_lock_enabled';
  static const _reason = 'Déverrouillez écu pour accéder à vos données';

  final SharedPreferences _prefs;
  final DeviceAuthenticator _authenticator;

  Future<void> init() async {
    final available = await _authenticator.isAvailable();
    final enabled = _prefs.getBool(_key) ?? true;
    emit(AppLockState(ready: true, available: available, enabled: enabled, locked: available && enabled));
    if (state.locked) await unlock();
  }

  Future<void> unlock() async {
    if (state.busy || !state.locked) return;
    emit(state.copyWith(busy: true));
    final ok = await _authenticator.authenticate(_reason);
    emit(state.copyWith(busy: false, locked: !ok));
  }

  void onBackgrounded() {
    if (state.busy || !state.protectionActive) return;
    emit(state.copyWith(locked: true));
  }

  Future<void> onResumed() => unlock();

  Future<void> setEnabled(bool value) async {
    if (!state.available || value == state.enabled) return;
    if (!value) {
      emit(state.copyWith(busy: true));
      final ok = await _authenticator.authenticate(_reason);
      emit(state.copyWith(busy: false));
      if (!ok) return;
    }
    await _prefs.setBool(_key, value);
    emit(state.copyWith(enabled: value));
  }
}
