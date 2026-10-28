import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spent_app/layers/technical/Security/app_lock_cubit.dart';
import 'package:spent_app/layers/technical/Security/device_authenticator.dart';

class _Auth implements DeviceAuthenticator {
  _Auth({this.available = true, this.results = const []});

  final bool available;
  final List<bool> results;
  int prompts = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<bool> authenticate(String reason) async {
    final i = prompts++;
    return results.isEmpty ? true : results[i % results.length];
  }
}

Future<AppLockCubit> _cubit(_Auth auth, {Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final cubit = AppLockCubit(await SharedPreferences.getInstance(), auth);
  await cubit.init();
  return cubit;
}

void main() {
  test('déverrouille au démarrage si la biométrie réussit', () async {
    final c = await _cubit(_Auth());
    expect(c.state.locked, isFalse);
  });

  test('reste verrouillé si la biométrie échoue, puis déverrouille au nouvel essai', () async {
    final auth = _Auth(results: [false, true]);
    final c = await _cubit(auth);
    expect(c.state.locked, isTrue);
    await c.unlock();
    expect(c.state.locked, isFalse);
    expect(auth.prompts, 2);
  });

  test('se reverrouille en arrière-plan et redemande au retour', () async {
    final auth = _Auth();
    final c = await _cubit(auth);
    c.onBackgrounded();
    expect(c.state.locked, isTrue);
    await c.onResumed();
    expect(c.state.locked, isFalse);
    expect(auth.prompts, 2);
  });

  test('sans verrouillage d’écran sur l’appareil, aucune protection ni blocage', () async {
    final c = await _cubit(_Auth(available: false));
    expect(c.state.locked, isFalse);
    c.onBackgrounded();
    expect(c.state.locked, isFalse);
  });

  test('désactiver la protection exige une authentification', () async {
    final denied = await _cubit(_Auth(results: [true, false]));
    await denied.setEnabled(false);
    expect(denied.state.enabled, isTrue);

    final granted = await _cubit(_Auth());
    await granted.setEnabled(false);
    expect(granted.state.enabled, isFalse);
    granted.onBackgrounded();
    expect(granted.state.locked, isFalse);
  });

  test('le réglage désactivé est conservé au prochain démarrage', () async {
    final c = await _cubit(_Auth(), prefs: {'app_lock_enabled': false});
    expect(c.state.enabled, isFalse);
    expect(c.state.locked, isFalse);
  });
}
