// import 'package:flutter/foundation.dart';
//
// class BaseURL {
//   static String get base {
//
//     // Web (Chrome, Edge, etc.)
//     if (kIsWeb) {
//       return 'http://127.0.0.1:8080';
//     }
//
//     // Mobile / Desktop
//     switch (defaultTargetPlatform) {
//       case TargetPlatform.android:
//         return 'http://10.0.2.2:8080'; // Android Emulator
//       case TargetPlatform.iOS:
//         return 'http://127.0.0.1:8080'; // iOS Simulator
//       case TargetPlatform.macOS:
//       case TargetPlatform.windows:
//       case TargetPlatform.linux:
//         return 'http://127.0.0.1:8080';
//       default:
//         return 'http://127.0.0.1:8080';
//     }
//   }
// }

import 'package:flutter/foundation.dart';

class BaseURL {
  static String get base {
    const local = 'http://127.0.0.1:8080';
    const emulator = 'http://10.0.2.2:8080';

    // 👉 CHANGE THIS to your Laravel server IP (VERY IMPORTANT)
    // const realDevice = 'http://127.0.0.1:8080';
    const realDevice = 'https://code-blue.cloud';

    if (kIsWeb) {
      return local;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return kDebugMode ? emulator : realDevice;

      case TargetPlatform.iOS:
        return local;

      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return local;

      default:
        return local;
    }
  }
}