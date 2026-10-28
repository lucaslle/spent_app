import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensors_plus/sensors_plus.dart';

import 'shake_detection.dart';

class ShakeListener extends StatefulWidget {
  const ShakeListener({super.key, required this.onShake, required this.child});

  final VoidCallback onShake;
  final Widget child;

  @override
  State<ShakeListener> createState() => _ShakeListenerState();
}

class _ShakeListenerState extends State<ShakeListener> {
  final _detection = ShakeDetection();
  StreamSubscription<UserAccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = userAccelerometerEventStream(samplingPeriod: SensorInterval.gameInterval).listen(
      (e) {
        final magnitude = math.sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
        if (_detection.onSample(magnitude, DateTime.now().millisecondsSinceEpoch)) {
          HapticFeedback.mediumImpact();
          widget.onShake();
        }
      },
      onError: (_) {},
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
