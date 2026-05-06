import 'dart:io';
import 'package:flutter/foundation.dart';

class BaseURL {
  // =========================
  // LOCAL DEVELOPMENT
  // =========================

  // Web / Desktop
  static const String local = 'http://127.0.0.1:8080';

  // Android Emulator
  static const String emulator = 'http://10.0.2.2:8080';

  // Real Android/iPhone device on SAME WiFi network
  // 👉 CHANGE THIS to your computer local IP
  // Example: http://192.168.1.10:8080
  static const String localNetwork = 'http://192.168.1.10:8080';

  // =========================
  // PRODUCTION HOSTING
  // =========================

  static const String production = 'https://code-blue.cloud';

  // =========================
  // MAIN BASE URL
  // =========================

  static String get base {
    // Web
    if (kIsWeb) {
      return kDebugMode ? local : production;
    }

    // Android
    if (Platform.isAndroid) {
      if (kDebugMode) {
        // Emulator
        return emulator;

        // Real device testing on WiFi:
        // return localNetwork;
      }

      return production;
    }

    // iPhone / iPad
    if (Platform.isIOS) {
      return kDebugMode ? localNetwork : production;
    }

    // macOS / Windows / Linux
    if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
      return kDebugMode ? local : production;
    }

    return production;
  }
}