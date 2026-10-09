import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

/// Fingerprint / face unlock with the device PIN as fallback, so a failed
/// scan never locks anyone out of their own log.
abstract final class LockService {
  static final _auth = LocalAuthentication();
  static const _system = MethodChannel('gymtrx/system');

  static Future<bool> isAvailable() async {
    try {
      return await _auth.isDeviceSupported();
    } on Exception {
      return false;
    }
  }

  static Future<bool> authenticate({String reason = 'Unlock GYMTRX'}) async {
    try {
      return await _auth.authenticate(localizedReason: reason, persistAcrossBackgrounding: true);
    } on Exception {
      return false;
    }
  }

  /// Hides app content in the Recents switcher (Android 13+). Screenshots stay allowed.
  static Future<void> setRecentsHidden(bool hidden) async {
    try {
      await _system.invokeMethod('setRecentsHidden', hidden);
    } on PlatformException {
      // Older Android or no host (tests): nothing to hide.
    } on MissingPluginException {
      // Same.
    }
  }
}
