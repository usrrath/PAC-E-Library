import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class DeviceInfoHelper {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  static Future<Map<String, String>> getLoginDeviceInfo() async {
    try {

      if (kIsWeb) {
        final info = await _deviceInfo.webBrowserInfo;

        final userAgent = info.userAgent ?? '';

        debugPrint('WEB USER AGENT => $userAgent');

        String browserName = info.browserName.name;
        String browserVersion = '';

        final patterns = [
          RegExp(r'Edg/([\d\.]+)', caseSensitive: false),
          RegExp(r'Chrome/([\d\.]+)', caseSensitive: false),
          RegExp(r'Firefox/([\d\.]+)', caseSensitive: false),
          RegExp(r'Version/([\d\.]+)', caseSensitive: false),
        ];

        for (final pattern in patterns) {
          final match = pattern.firstMatch(userAgent);

          if (match != null) {
            browserVersion = match.group(1) ?? '';
            break;
          }
        }

        return {
          'device_type': _webDeviceType(info.platform ?? ''),

          // MacIntel / Win32 / Linux x86_64
          'device_name': _clean(info.platform, 'Web Device'),

          // Chrome 138.0.7204.169
          'browser': browserVersion.isEmpty
              ? browserName
              : '$browserName $browserVersion',

          // MacIntel
          'platform': _clean(info.platform, 'Web'),

          'user_agent': userAgent,
        };
      }

      // if (Platform.isAndroid) {
      //   final info = await _deviceInfo.androidInfo;
      //
      //   final modelCode = _clean(info.model, 'Android Device').toUpperCase();
      //   final deviceName = _androidDeviceName(info);
      //   final platform = 'Android ${_clean(info.version.release, '')}'.trim();
      //
      //   return {
      //     'device_type': _isAndroidTablet(info) ? 'Tablet' : 'Mobile',
      //     'device_name': deviceName,
      //     'browser': modelCode,
      //     'platform': platform,
      //     'user_agent': '$deviceName $modelCode $platform',
      //   };
      // }
      if (Platform.isAndroid) {
        final info = await _deviceInfo.androidInfo;

        final modelCode = _clean(info.model, 'Android Device').toUpperCase();
        final deviceName = _androidDeviceName(info);

        return {
          'device_type': _isAndroidTablet(info) ? 'Tablet' : 'Mobile',
          'device_name': deviceName,
          'browser': modelCode,
          'platform': 'Android ${info.version.release}',
          'user_agent': 'Flutter Android App ($deviceName)',
        };
      }

      // if (Platform.isIOS) {
      //   final info = await _deviceInfo.iosInfo;
      //
      //   final machine = _clean(info.utsname.machine, info.model);
      //   final deviceName = _iosDeviceName(machine);
      //   final platform = _clean(
      //     '${info.systemName} ${info.systemVersion}',
      //     'iOS',
      //   );
      //
      //   return {
      //     'device_type': deviceName.toLowerCase().contains('ipad')
      //         ? 'Tablet'
      //         : 'Mobile',
      //     'device_name': deviceName,
      //     'browser': machine,
      //     'platform': platform,
      //     'user_agent': '$deviceName $machine $platform',
      //   };
      // }
      if (Platform.isIOS) {
        final info = await _deviceInfo.iosInfo;

        final deviceName = _iosDeviceName(info);

        final platform = _clean(
          '${info.systemName} ${info.systemVersion}',
          'iOS',
        );

        return {
          'device_type': deviceName.toLowerCase().contains('ipad')
              ? 'Tablet'
              : 'Mobile',
          'device_name': deviceName,
          'browser': 'Flutter App',
          'platform': platform,
          'user_agent': 'Flutter iOS App ($deviceName)',
        };
      }

      if (Platform.isMacOS) {
        final info = await _deviceInfo.macOsInfo;

        final deviceName =
        _clean(info.computerName, 'Mac');

        return {
          'device_type': 'Desktop',
          'device_name': deviceName,

          // show computer name instead of macOS version
          'browser': deviceName,

          'platform': 'macOS ${info.osRelease}',
          'user_agent':
          '$deviceName macOS ${info.osRelease}',
        };
      }

      if (Platform.isWindows) {
        final info = await _deviceInfo.windowsInfo;

        final deviceName =
        _clean(info.computerName, 'Windows PC');

        return {
          'device_type': 'Desktop',
          'device_name': deviceName,

          // show computer name
          'browser': deviceName,

          'platform': 'Windows',
          'user_agent': '$deviceName Windows',
        };
      }

      if (Platform.isLinux) {
        final info = await _deviceInfo.linuxInfo;

        final deviceName =
        _clean(info.prettyName, 'Linux PC');

        return {
          'device_type': 'Desktop',
          'device_name': deviceName,

          // show machine name
          'browser': deviceName,

          'platform': 'Linux',
          'user_agent': '$deviceName Linux',
        };
      }
    } catch (e) {
      debugPrint('DEVICE INFO ERROR: $e');
    }

    return {
      'device_type': kIsWeb ? 'Desktop' : 'Mobile',
      'device_name': 'Unknown Device',
      'browser': 'Unknown',
      'platform': kIsWeb ? 'Web' : Platform.operatingSystem,
      'user_agent': '',
    };
  }

  // static String _androidDeviceName(AndroidDeviceInfo info) {
  //   final manufacturer = _title(_clean(info.manufacturer, 'Android'));
  //   final model = _clean(info.model, 'Android Device').toUpperCase();
  //
  //   const modelNames = {
  //     'SM-S918B': 'Samsung Galaxy S23 Ultra',
  //     'SM-S918U': 'Samsung Galaxy S23 Ultra',
  //     'SM-S918U1': 'Samsung Galaxy S23 Ultra',
  //     'SM-S918N': 'Samsung Galaxy S23 Ultra',
  //     'SM-S928B': 'Samsung Galaxy S24 Ultra',
  //     'SM-S928U': 'Samsung Galaxy S24 Ultra',
  //     'SM-S928U1': 'Samsung Galaxy S24 Ultra',
  //     'SM-S938B': 'Samsung Galaxy S25 Ultra',
  //     'SM-S938U': 'Samsung Galaxy S25 Ultra',
  //     'SM-G998B': 'Samsung Galaxy S21 Ultra',
  //     'SM-G998U': 'Samsung Galaxy S21 Ultra',
  //     'SM-S908B': 'Samsung Galaxy S22 Ultra',
  //     'SM-S908U': 'Samsung Galaxy S22 Ultra',
  //   };
  //
  //   if (modelNames.containsKey(model)) {
  //     return modelNames[model]!;
  //   }
  //
  //   if (model.toLowerCase().startsWith(manufacturer.toLowerCase())) {
  //     return model;
  //   }
  //
  //   return '$manufacturer $model'.trim();
  // }
  // static String _androidDeviceName(AndroidDeviceInfo info) {
  //   final manufacturer = _clean(info.manufacturer, '');
  //   final brand = _clean(info.brand, '');
  //   final model = _clean(info.model, '');
  //   final device = _clean(info.device, '');
  //   final product = _clean(info.product, '');
  //
  //   final emulatorText =
  //   '$model $device $product ${info.hardware}'.toLowerCase();
  //
  //   if (!info.isPhysicalDevice ||
  //       emulatorText.contains('sdk') ||
  //       emulatorText.contains('emulator') ||
  //       emulatorText.contains('goldfish') ||
  //       emulatorText.contains('ranchu') ||
  //       emulatorText.contains('vbox')) {
  //     return 'Android Emulator';
  //   }
  //
  //   if (manufacturer.isNotEmpty && model.isNotEmpty) {
  //     if (model.toLowerCase().startsWith(manufacturer.toLowerCase())) {
  //       return model;
  //     }
  //
  //     return '${_title(manufacturer)} $model';
  //   }
  //
  //   if (brand.isNotEmpty && model.isNotEmpty) {
  //     return '${_title(brand)} $model';
  //   }
  //
  //   return model.isNotEmpty ? model : 'Android Device';
  // }
  static String _androidDeviceName(AndroidDeviceInfo info) {
    final manufacturer = _clean(info.manufacturer, '');
    final brand = _clean(info.brand, '');

    if (!info.isPhysicalDevice) {
      return 'Android Emulator';
    }

    if (manufacturer.isNotEmpty) {
      return _title(manufacturer);
    }

    if (brand.isNotEmpty) {
      return _title(brand);
    }

    return 'Android';
  }

  // static String _iosDeviceName(String machine) {
  //   const names = {
  //     'iPhone16,1': 'iPhone 15 Pro',
  //     'iPhone16,2': 'iPhone 15 Pro Max',
  //     'iPhone17,1': 'iPhone 16 Pro',
  //     'iPhone17,2': 'iPhone 16 Pro Max',
  //     'iPhone18,1': 'iPhone 17 Pro',
  //     'iPhone18,2': 'iPhone 17 Pro Max',
  //     'A3257': 'iPhone 17 Pro Max',
  //   };
  //
  //   return names[machine] ?? machine;
  // }
  // static String _iosDeviceName(IosDeviceInfo info) {
  //   final model = _clean(info.model, '');
  //   final machine = _clean(info.utsname.machine, '');
  //
  //   // Simulator
  //   if (!info.isPhysicalDevice) {
  //     return 'iOS Simulator';
  //   }
  //
  //   // Prefer Apple-provided model if available
  //   if (model.isNotEmpty &&
  //       model.toLowerCase() != 'iphone' &&
  //       model.toLowerCase() != 'ipad' &&
  //       model.toLowerCase() != 'ipod') {
  //     return model;
  //   }
  //
  //   // Fallback to machine identifier
  //   if (machine.isNotEmpty) {
  //     return machine;
  //   }
  //
  //   return 'iPhone';
  // }
  static String _iosDeviceName(IosDeviceInfo info) {
    if (!info.isPhysicalDevice) {
      return 'iOS Simulator';
    }

    return 'Apple';
  }

  static bool _isAndroidTablet(AndroidDeviceInfo info) {
    final text = '${info.manufacturer} ${info.model}'.toLowerCase();

    return text.contains('tablet') ||
        text.contains('tab') ||
        text.contains('pad');
  }

  static String _webDeviceType(String platform) {
    final text = platform.toLowerCase();

    if (text.contains('android') || text.contains('iphone')) {
      return 'Mobile';
    }

    if (text.contains('ipad')) {
      return 'Tablet';
    }

    return 'Desktop';
  }

  static String _browserVersion(String userAgent) {
    final patterns = [
      RegExp(r'Chrome\/([\d.]+)', caseSensitive: false),
      RegExp(r'Edg\/([\d.]+)', caseSensitive: false),
      RegExp(r'Firefox\/([\d.]+)', caseSensitive: false),
      RegExp(r'Version\/([\d.]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(userAgent);
      if (match != null) {
        return match.group(1) ?? '';
      }
    }

    return '';
  }

  static String _clean(String? value, String fallback) {
    final text = (value ?? '').trim();

    if (text.isEmpty ||
        text == '0' ||
        text.toLowerCase() == 'null' ||
        text.toLowerCase() == 'unknown') {
      return fallback;
    }

    return text;
  }

  static String _title(String value) {
    if (value.trim().isEmpty) return '';

    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    })
        .join(' ');
  }
}