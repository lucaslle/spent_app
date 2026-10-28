class ShakeDetection {
  ShakeDetection({this.threshold = 14, this.windowMs = 700, this.cooldownMs = 1200, this.peaksNeeded = 3});

  final double threshold;
  final int windowMs;
  final int cooldownMs;
  final int peaksNeeded;

  final List<int> _peaks = [];
  int _lastShake = -1 << 40;

  /// [magnitude] est l'accélération en m/s² sans la gravité ; renvoie true quand une secousse est détectée.
  bool onSample(double magnitude, int nowMs) {
    if (nowMs - _lastShake < cooldownMs) return false;
    if (magnitude >= threshold && (_peaks.isEmpty || nowMs - _peaks.last > 80)) _peaks.add(nowMs);
    _peaks.removeWhere((t) => nowMs - t > windowMs);
    if (_peaks.length < peaksNeeded) return false;
    _peaks.clear();
    _lastShake = nowMs;
    return true;
  }
}
