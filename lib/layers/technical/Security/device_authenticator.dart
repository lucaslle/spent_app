import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

abstract interface class DeviceAuthenticator {
  Future<bool> isAvailable();
  Future<bool> authenticate(String reason);
}

class LocalAuthDeviceAuthenticator implements DeviceAuthenticator {
  LocalAuthDeviceAuthenticator() : _auth = LocalAuthentication();

  final LocalAuthentication _auth;

  @override
  Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } on PlatformException {
      return false;
    }
  }
}
