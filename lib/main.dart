import 'package:flutter/material.dart';
import 'package:pac_e_library_new/screens/splash_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Load saved settings BEFORE runApp
  final theme = await AppSettings.loadThemeMode();
  final scale = await AppSettings.loadFontScale();

  MyApp.themeMode.value = theme;
  MyApp.fontScale.value = scale;

  runApp(const MyApp());
}

/// ===============================
/// Secure Storage Helper
/// ===============================
class AppSettings {
  static const _storage = FlutterSecureStorage();

  static const _kThemeMode = "app_theme_mode"; // system/light/dark
  static const _kFontScale = "app_font_scale"; // 0.90 / 1.0 / 1.15

  /// -------- ThemeMode ----------
  static Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.write(key: _kThemeMode, value: mode.name); // "system" | "light" | "dark"
  }

  static Future<ThemeMode> loadThemeMode() async {
    final v = await _storage.read(key: _kThemeMode);
    switch (v) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "system":
      default:
        return ThemeMode.system;
    }
  }

  /// -------- FontScale ----------
  static Future<void> saveFontScale(double scale) async {
    await _storage.write(key: _kFontScale, value: scale.toString());
  }

  static Future<double> loadFontScale() async {
    final v = await _storage.read(key: _kFontScale);
    final parsed = double.tryParse(v ?? "");
    // default = 1.0
    if (parsed == null) return 1.0;

    // clamp (safety)
    if (parsed < 0.80) return 0.80;
    if (parsed > 1.15) return 1.15;
    return parsed;
  }

  /// Optional: clear
  static Future<void> clearAll() async {
    await _storage.delete(key: _kThemeMode);
    await _storage.delete(key: _kFontScale);
  }
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});

  // ✅ Global ThemeMode
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(ThemeMode.system);

  // ✅ Global Font Scale (Small/Medium/Large)
  static final ValueNotifier<double> fontScale = ValueNotifier(1.15);


  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (_, mode, __) {
        return ValueListenableBuilder<double>(
          valueListenable: fontScale,
          builder: (_, scale, __) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "PAC E-Library",
              themeMode: mode,
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
                scaffoldBackgroundColor: const Color(0xFFF7F9FC),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
              ),

              // ✅ Apply font scale to ALL text
              builder: (context, child) {
                final mq = MediaQuery.of(context);
                return MediaQuery(
                  data: mq.copyWith(textScaler: TextScaler.linear(scale)),
                  child: child ?? const SizedBox.shrink(),
                );
              },

              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }

}
