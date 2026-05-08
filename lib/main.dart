import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/app_localizations.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme_font.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final theme = await AppSettings.loadThemeMode();
  final scale = await AppSettings.loadFontScale();
  final locale = await AppSettings.loadLocale();

  MyApp.themeMode.value = theme;
  MyApp.fontScale.value = scale;
  MyApp.locale.value = locale;

  runApp(const MyApp());
}

/// ===============================
/// Secure Storage Helper
/// ===============================
class AppSettings {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static const String _kThemeMode = "app_theme_mode";
  static const String _kFontScale = "app_font_scale";
  static const String _kLocale = "app_locale";

  static Future<void> saveThemeMode(ThemeMode mode) async {
    await _storage.write(key: _kThemeMode, value: mode.name);
  }

  static Future<ThemeMode> loadThemeMode() async {
    final value = await _storage.read(key: _kThemeMode);

    switch (value) {
      case "light":
        return ThemeMode.light;
      case "dark":
        return ThemeMode.dark;
      case "system":
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> saveFontScale(double scale) async {
    final safeScale = scale.clamp(0.80, 1.15).toDouble();
    await _storage.write(key: _kFontScale, value: safeScale.toString());
  }

  static Future<double> loadFontScale() async {
    final value = await _storage.read(key: _kFontScale);
    final parsed = double.tryParse(value ?? "");

    if (parsed == null) return 1.0;

    return parsed.clamp(0.80, 1.15).toDouble();
  }

  static Future<void> saveLocale(Locale locale) async {
    await _storage.write(key: _kLocale, value: locale.languageCode);
  }

  static Future<Locale> loadLocale() async {
    final value = await _storage.read(key: _kLocale);

    switch (value) {
      case "km":
        return const Locale("km");
      case "en":
      default:
        return const Locale("en");
    }
  }

  static Future<void> clearAll() async {
    await _storage.delete(key: _kThemeMode);
    await _storage.delete(key: _kFontScale);
    await _storage.delete(key: _kLocale);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ValueNotifier<ThemeMode> themeMode =
  ValueNotifier<ThemeMode>(ThemeMode.system);

  static final ValueNotifier<double> fontScale = ValueNotifier<double>(1.0);

  static final ValueNotifier<Locale> locale =
  ValueNotifier<Locale>(const Locale("en"));

  static Future<void> changeThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    await AppSettings.saveThemeMode(mode);
  }

  static Future<void> changeFontScale(double scale) async {
    final safeScale = scale.clamp(0.80, 1.15).toDouble();
    fontScale.value = safeScale;
    await AppSettings.saveFontScale(safeScale);
  }

  static Future<void> changeLocale(String languageCode) async {
    final newLocale = Locale(languageCode);
    locale.value = newLocale;
    await AppSettings.saveLocale(newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<double>(
          valueListenable: fontScale,
          builder: (context, scale, __) {
            return ValueListenableBuilder<Locale>(
              valueListenable: locale,
              builder: (context, currentLocale, ___) {
                return MaterialApp(
                  debugShowCheckedModeBanner: false,
                  title: "PAC E-Library",

                  locale: currentLocale,

                  supportedLocales: const [
                    Locale("en"),
                    Locale("km"),
                  ],

                  localizationsDelegates: const [
                    AppLocalizations.delegate,
                    GlobalMaterialLocalizations.delegate,
                    GlobalWidgetsLocalizations.delegate,
                    GlobalCupertinoLocalizations.delegate,
                  ],

                  themeMode: mode,
                  theme: AppThemeFont.lightTheme,
                  darkTheme: AppThemeFont.darkTheme,

                  builder: (context, child) {
                    final mediaQuery = MediaQuery.of(context);

                    return MediaQuery(
                      data: mediaQuery.copyWith(
                        textScaler: TextScaler.linear(scale),
                      ),
                      child: child ?? const SizedBox.shrink(),
                    );
                  },

                  home: const SplashScreen(),
                );
              },
            );
          },
        );
      },
    );
  }
}