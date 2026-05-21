import 'dart:io';
import 'package:flutter/foundation.dart';

class BaseURL {
  BaseURL._();

  // =========================
  // LOCAL DEVELOPMENT
  // =========================

  // Laravel running on same computer
  static const String local = 'http://127.0.0.1:8080';

  // Android Emulator
  static const String androidEmulator = 'http://10.0.2.2:8080';

  // Real Android / iPhone on SAME WiFi
  // Change to your Mac/PC IP address
  // static const String localNetwork = 'http://192.168.1.10:8080';
  static const String localNetwork = 'http://127.0.0.1:8080';

  // =========================
  // PRODUCTION
  // =========================

  static const String production = 'https://code-blue.cloud';

  // =========================
  // MAIN BASE URL
  // =========================

  static String get base {
    if (kIsWeb) {
      return kDebugMode ? local : production;
    }

    if (Platform.isAndroid) {
      return kDebugMode ? androidEmulator : production;
    }

    if (Platform.isIOS) {
      if (!kDebugMode) return production;

      // iOS Simulator can use 127.0.0.1
      if (_isIOSSimulator) {
        return local;
      }

      // Real iPhone/iPad must use your computer WiFi IP
      return localNetwork;
    }

    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return kDebugMode ? local : production;
    }

    return production;
  }

  static bool get _isIOSSimulator {
    if (!Platform.isIOS) return false;

    // Flutter sets this on iOS Simulator
    final simulatorDeviceName = Platform.environment['SIMULATOR_DEVICE_NAME'];
    return simulatorDeviceName != null && simulatorDeviceName.isNotEmpty;
  }

  static String get api => '$base/api';

  static String storage(String path) {
    if (path.isEmpty) return '';

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    final cleanPath = path.startsWith('/') ? path.substring(1) : path;
    return '$base/$cleanPath';
  }
}