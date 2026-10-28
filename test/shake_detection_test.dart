import 'package:flutter_test/flutter_test.dart';
import 'package:spent_app/layers/technical/Shake/shake_detection.dart';

void main() {
  test('une secousse = plusieurs pics rapprochés', () {
    final d = ShakeDetection();
    expect(d.onSample(20, 1000), isFalse);
    expect(d.onSample(20, 1150), isFalse);
    expect(d.onSample(20, 1300), isTrue);
  });

  test('un seul pic ou un mouvement doux ne déclenche rien', () {
    final d = ShakeDetection();
    expect(d.onSample(25, 0), isFalse);
    for (var t = 100; t < 3000; t += 20) {
      expect(d.onSample(5, t), isFalse);
    }
  });

  test('pics trop espacés : pas de secousse', () {
    final d = ShakeDetection();
    expect(d.onSample(20, 0), isFalse);
    expect(d.onSample(20, 500), isFalse);
    expect(d.onSample(20, 1000), isFalse);
  });

  test('délai de repos après une secousse', () {
    final d = ShakeDetection();
    d.onSample(20, 1000);
    d.onSample(20, 1150);
    expect(d.onSample(20, 1300), isTrue);
    expect(d.onSample(20, 1400), isFalse);
    expect(d.onSample(20, 1500), isFalse);
  });
}
