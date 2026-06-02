import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:otp/otp.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../apps/app_provider.dart';
import '../l10n/app_localizations.dart';
import '../models/settings_model.dart';
import '../screens/login_screen.dart';
import '../services/settings_service.dart';
import '../services/user_service.dart';
import '../utils/settings_utils.dart';
import '../widgets/settings_widgets.dart';
import 'Device_Logs_Screen.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _kBiometricEnabled = 'biometric_enabled';
  static const String _kBiometricToken = 'biometric_server_token';
  static const String _kBiometricLastAuth = 'biometric_last_auth';
  static const String _kBiometricPinCode = 'biometric_pin_code';

  static const String _kTwoFactorEnabled = 'two_factor_enabled';
  static const String _kTwoFactorSecret = 'two_factor_secret';

  static const int _sessionTimeoutMinutes = 15;

  ThemeMode mode = AppProvider.themeMode.value;
  FontSizePref fontSize = FontSizePref.medium;

  String languageCode =
  AppProvider.locale.value.languageCode == 'km' ? 'km' : 'en';

  bool notifNewReleases = true;
  bool enable2FA = false;
  bool loginAlerts = true;

  bool enableBiometrics = false;
  bool biometricLoading = false;
  bool twoFactorLoading = false;

  bool logoutLoading = false;
  bool passwordLoading = false;

  String? errorMessage;

  bool get _busy =>
      logoutLoading || passwordLoading || biometricLoading || twoFactorLoading;

  AppLocalizations get t => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();

    fontSize = SettingsService.fontFromScale(AppProvider.fontScale.value);
    languageCode =
    AppProvider.locale.value.languageCode == 'km' ? 'km' : 'en';

    _loadBiometricSetting();
    _loadTwoFactorSetting();
  }

  Future<void> _loadBiometricSetting() async {
    final enabled = await _secureStorage.read(key: _kBiometricEnabled);

    if (!mounted) return;

    setState(() {
      enableBiometrics = enabled == 'true';
    });
  }

  Future<void> _loadTwoFactorSetting() async {
    final enabled = await _secureStorage.read(key: _kTwoFactorEnabled);

    if (!mounted) return;

    setState(() {
      enable2FA = enabled == 'true';
    });
  }

  Future<bool> _authenticateBiometric() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;

      if (!supported || !canCheck) {
        _toast('Fingerprint / Face ID not available');
        return false;
      }

      return _localAuth.authenticate(
        localizedReason: 'Use Fingerprint or Face ID to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (e) {
      _toast(SettingsUtils.cleanError(e));
      return false;
    }
  }

  Future<void> _setEnableBiometrics(bool value) async {
    if (_busy) return;

    setState(() {
      biometricLoading = true;
      errorMessage = null;
    });

    try {
      if (value) {
        final ok = await _authenticateBiometric();
        if (!ok) return;

        final token = await SettingsService.token();

        if (token == null || token.isEmpty) {
          _toast(t.settingLoginTokenNotFound);
          return;
        }

        final pin = await _showSetupBiometricPinDialog();
        if (pin == null || pin.trim().isEmpty) return;

        await _secureStorage.write(key: _kBiometricPinCode, value: pin.trim());
        await _secureStorage.write(key: _kBiometricEnabled, value: 'true');
        await _secureStorage.write(key: _kBiometricToken, value: token);
        await _secureStorage.write(
          key: _kBiometricLastAuth,
          value: DateTime.now().millisecondsSinceEpoch.toString(),
        );

        if (!mounted) return;

        setState(() => enableBiometrics = true);
        _toast('Biometric fast re-login enabled');
      } else {
        await _clearBiometricStorage();

        if (!mounted) return;

        setState(() => enableBiometrics = false);
        _toast('Biometric fast re-login disabled');
      }
    } catch (e) {
      if (_isInternetError(e)) {
        _showInternetError(e);
      } else {
        _toast(SettingsUtils.cleanError(e));
      }
    } finally {
      if (mounted) {
        setState(() => biometricLoading = false);
      }
    }
  }

  Future<void> _clearBiometricStorage() async {
    await _secureStorage.delete(key: _kBiometricEnabled);
    await _secureStorage.delete(key: _kBiometricToken);
    await _secureStorage.delete(key: _kBiometricLastAuth);
    await _secureStorage.delete(key: _kBiometricPinCode);
  }

  Future<String?> _showSetupBiometricPinDialog() async {
    final pinCtrl = TextEditingController();
    String? error;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void save() {
              final pin = pinCtrl.text.trim();

              if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
                setDialogState(() {
                  error = 'PIN must be 4 digits';
                });
                return;
              }

              Navigator.of(dialogContext).pop(pin);
            }

            return AlertDialog(
              title: const Text(
                'Create PIN',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Create a 4-digit PIN for backup biometric login.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  PinCodeTextField(
                    appContext: context,
                    controller: pinCtrl,
                    length: 4,
                    obscureText: true,
                    autoFocus: true,
                    keyboardType: TextInputType.number,
                    animationType: AnimationType.fade,
                    autoDisposeControllers: false,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: (_) {
                      if (error != null) {
                        setDialogState(() => error = null);
                      }
                    },
                    onCompleted: (_) => save(),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(t.settingCancel),
                ),
                FilledButton(
                  onPressed: save,
                  child: Text(t.settingSave),
                ),
              ],
            );
          },
        );
      },
    );

    pinCtrl.dispose();
    return result;
  }

  Future<void> _clearTwoFactorStorage() async {
    await _secureStorage.delete(key: _kTwoFactorEnabled);
    await _secureStorage.delete(key: _kTwoFactorSecret);
  }

  Future<String?> biometricFastReloginToken() async {
    final enabled = await _secureStorage.read(key: _kBiometricEnabled);

    if (enabled != 'true') return null;

    final token = await _secureStorage.read(key: _kBiometricToken);

    if (token == null || token.isEmpty) return null;

    final lastAuthRaw = await _secureStorage.read(key: _kBiometricLastAuth);
    final lastAuthMillis = int.tryParse(lastAuthRaw ?? '') ?? 0;

    final lastAuthTime = DateTime.fromMillisecondsSinceEpoch(lastAuthMillis);
    final expired =
        DateTime.now().difference(lastAuthTime).inMinutes >=
            _sessionTimeoutMinutes;

    if (expired) {
      final ok = await _authenticateBiometric();

      if (!ok) return null;

      await _secureStorage.write(
        key: _kBiometricLastAuth,
        value: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    }

    return token;
  }

  bool _isInternetError(Object error) {
    final msg = error.toString();

    return msg.contains('SocketException') ||
        msg.contains('ClientException') ||
        msg.contains('Network is unreachable') ||
        msg.contains('Connection failed') ||
        msg.contains('Failed host lookup') ||
        msg.contains('No address associated with hostname') ||
        msg.contains('Connection refused') ||
        msg.contains('timed out') ||
        msg.contains('timeout');
  }

  String _friendlyError(Object error) {
    if (_isInternetError(error)) return 'Error Internet';

    final msg = error.toString().replaceFirst('Exception: ', '').trim();

    if (msg.isEmpty) return 'Something went wrong';

    return msg;
  }

  void _showInternetError(Object error) {
    setState(() {
      errorMessage = _friendlyError(error);
    });
  }

  Future<void> _setMode(ThemeMode value) async {
    setState(() => mode = value);
    await SettingsService.changeThemeMode(value);
  }

  Future<void> _setFontSize(FontSizePref value) async {
    setState(() => fontSize = value);
    await SettingsService.changeFontSize(value);
  }

  Future<void> _setLanguage(String code) async {
    setState(() => languageCode = code);
    await SettingsService.changeLanguage(code);

    if (!mounted) return;
    _toast(t.settingLanguageChanged);
  }

  String _fontLabel(FontSizePref value) {
    switch (value) {
      case FontSizePref.small:
        return t.settingSmall;
      case FontSizePref.medium:
        return t.settingMedium;
      case FontSizePref.large:
        return t.settingLarge;
    }
  }

  String _languageLabel() {
    return languageCode == 'km' ? t.settingKhmer : t.settingEnglish;
  }

  void _toast(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _openGoogleAuthSetupDialog() async {
    if (_busy) return;

    setState(() {
      twoFactorLoading = true;
      errorMessage = null;
    });

    try {
      final secret = _generateGoogleAuthSecret();
      final otpUrl = _buildOtpAuthUrl(secret);

      final ok = await _showGoogleAuthSetupDialog(
        secret: secret,
        otpUrl: otpUrl,
      );

      if (ok != true || !mounted) return;

      await _secureStorage.write(key: _kTwoFactorEnabled, value: 'true');
      await _secureStorage.write(key: _kTwoFactorSecret, value: secret);

      if (!mounted) return;

      setState(() => enable2FA = true);
      _toast('2FA Google Authenticator enabled');
    } catch (e) {
      _toast(SettingsUtils.cleanError(e));
    } finally {
      if (mounted) {
        setState(() => twoFactorLoading = false);
      }
    }
  }

  Future<void> _openGoogleAuthDisableDialog() async {
    if (_busy) return;

    final secret = await _secureStorage.read(key: _kTwoFactorSecret);

    if (secret == null || secret.isEmpty) {
      await _clearTwoFactorStorage();
      if (!mounted) return;
      setState(() => enable2FA = false);
      return;
    }

    final ok = await _showGoogleAuthDisableDialog(secret: secret);

    if (ok != true || !mounted) return;

    await _clearTwoFactorStorage();

    if (!mounted) return;

    setState(() => enable2FA = false);
    _toast('2FA Google Authenticator disabled');
  }

  String _generateGoogleAuthSecret() {
    return OTP.randomSecret().replaceAll('=', '').toUpperCase();
  }

  String _buildOtpAuthUrl(String secret) {
    final issuer = Uri.encodeComponent('PAC E-Library');
    final account = Uri.encodeComponent('PAC E-Library');
    final cleanSecret = secret.replaceAll(' ', '').toUpperCase();

    return 'otpauth://totp/$issuer:$account'
        '?secret=$cleanSecret'
        '&issuer=$issuer'
        '&algorithm=SHA1'
        '&digits=6'
        '&period=30';
  }

  bool _verifyOtpCode({
    required String secret,
    required String code,
  }) {
    final cleanCode = code.trim();

    if (cleanCode.length != 6) return false;

    final now = DateTime.now().millisecondsSinceEpoch;

    final current = OTP.generateTOTPCodeString(
      secret,
      now,
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    final previous = OTP.generateTOTPCodeString(
      secret,
      now - const Duration(seconds: 30).inMilliseconds,
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    final next = OTP.generateTOTPCodeString(
      secret,
      now + const Duration(seconds: 30).inMilliseconds,
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    return cleanCode == current || cleanCode == previous || cleanCode == next;
  }




  Future<bool?> _showGoogleAuthSetupDialog({
    required String secret,
    required String otpUrl,
  }) async {
    final codeCtrl = TextEditingController();
    String? error;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void verify() {
              final ok = _verifyOtpCode(
                secret: secret,
                code: codeCtrl.text,
              );

              if (!ok) {
                setDialogState(() {
                  error = 'Invalid Google Authenticator code';
                });
                return;
              }

              Navigator.of(dialogContext).pop(true);
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  maxHeight: 700,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Google Authenticator',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 18),

                      SizedBox(
                        width: 220,
                        height: 220,
                        child: QrImageView(
                          data: otpUrl,
                          version: QrVersions.auto,
                          gapless: true,
                        ),
                      ),

                      const SizedBox(height: 14),
                      const Text(
                        'Scan this QR code with Google Authenticator, then enter the 6-digit code.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),

                      InkWell(
                        onTap: () async {
                          await Clipboard.setData(
                            ClipboardData(text: secret),
                          );
                          _toast('Secret copied');
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .outline
                                  .withOpacity(0.25),
                            ),
                          ),
                          child: SelectableText(
                            secret,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      PinCodeTextField(
                        appContext: context,
                        controller: codeCtrl,
                        length: 6,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        autoDisposeControllers: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) {
                          if (error != null) {
                            setDialogState(() => error = null);
                          }
                        },
                        onCompleted: (_) => verify(),
                      ),

                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            child: Text(t.settingCancel),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: verify,
                            child: Text(t.settingSave),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    codeCtrl.dispose();
    return result;
  }


  Future<bool?> _showGoogleAuthDisableDialog({
    required String secret,
  }) async {
    final codeCtrl = TextEditingController();
    String? error;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void verify() {
              final ok = _verifyOtpCode(
                secret: secret,
                code: codeCtrl.text,
              );

              if (!ok) {
                setDialogState(() {
                  error = 'Invalid Google Authenticator code';
                });
                return;
              }

              Navigator.of(dialogContext).pop(true);
            }

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  maxHeight: 430,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Disable 2FA',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Enter your 6-digit Google Authenticator code to disable 2FA.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),

                      PinCodeTextField(
                        appContext: context,
                        controller: codeCtrl,
                        length: 6,
                        keyboardType: TextInputType.number,
                        animationType: AnimationType.fade,
                        autoDisposeControllers: false,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (_) {
                          if (error != null) {
                            setDialogState(() => error = null);
                          }
                        },
                        onCompleted: (_) => verify(),
                      ),

                      if (error != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(false);
                            },
                            child: Text(t.settingCancel),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: verify,
                            child: const Text('Disable'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    codeCtrl.dispose();
    return result;
  }












  Future<void> _resetSettings() async {
    if (_busy) return;

    await SettingsService.resetSettings();

    if (!mounted) return;

    setState(() {
      mode = ThemeMode.system;
      fontSize = FontSizePref.medium;
      languageCode = 'en';
      errorMessage = null;
    });

    _toast(t.settingResetDone);
  }

  Future<void> _goToLogin() async {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  Future<void> _confirmLogout() async {
    if (_busy) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t.settingLogout),
          content: Text(t.settingLogoutConfirm),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(t.settingCancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(t.settingLogout),
            ),
          ],
        );
      },
    );

    if (ok != true || !mounted) return;

    setState(() {
      logoutLoading = true;
      errorMessage = null;
    });

    try {
      final token = await SettingsService.token();

      if (token != null && token.isNotEmpty) {
        try {
          await UserService().logout(token).timeout(
            const Duration(seconds: 20),
          );
        } catch (_) {}
      }

      await _clearBiometricStorage();
      await SettingsService.clearAuthKeepRememberMe();

      if (!mounted) return;
      await _goToLogin();
    } on TimeoutException catch (e) {
      _showInternetError(e);
    } on SocketException catch (e) {
      _showInternetError(e);
    } catch (e) {
      if (_isInternetError(e)) {
        _showInternetError(e);
      } else {
        _toast('${t.settingLogoutFailed}: ${SettingsUtils.cleanError(e)}');
      }
    } finally {
      if (mounted) setState(() => logoutLoading = false);
    }
  }

  Future<void> _openChangePasswordDialog() async {
    if (_busy) return;

    final oldCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    bool terminateSessions = true;
    bool obscureOld = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(t.settingChangePassword),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: oldCtrl,
                      obscureText: obscureOld,
                      decoration: InputDecoration(
                        labelText: t.settingOldPassword,
                        prefixIcon: const Icon(Icons.lock_outline_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() => obscureOld = !obscureOld);
                          },
                          icon: Icon(
                            obscureOld
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: newCtrl,
                      obscureText: obscureNew,
                      decoration: InputDecoration(
                        labelText: t.settingNewPassword,
                        helperText: t.settingPasswordHelper,
                        prefixIcon: const Icon(Icons.password_rounded),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() => obscureNew = !obscureNew);
                          },
                          icon: Icon(
                            obscureNew
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: confirmCtrl,
                      obscureText: obscureConfirm,
                      decoration: InputDecoration(
                        labelText: t.settingConfirmNewPassword,
                        prefixIcon: const Icon(
                          Icons.check_circle_outline_rounded,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setDialogState(() {
                              obscureConfirm = !obscureConfirm;
                            });
                          },
                          icon: Icon(
                            obscureConfirm
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      value: terminateSessions,
                      title: Text(
                        t.settingLogoutAllDevices,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(t.settingRecommendedAfterPassword),
                      onChanged: (value) {
                        setDialogState(() => terminateSessions = value);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(t.settingCancel),
                ),
                ElevatedButton(
                  onPressed: () {
                    final oldPassword = oldCtrl.text.trim();
                    final newPassword = newCtrl.text.trim();
                    final confirmPassword = confirmCtrl.text.trim();

                    if (oldPassword.isEmpty) {
                      _toast(t.settingOldPasswordRequired);
                      return;
                    }

                    if (newPassword.length < 6 || newPassword.length > 10) {
                      _toast(t.settingNewPasswordLength);
                      return;
                    }

                    if (newPassword != confirmPassword) {
                      _toast(t.settingConfirmPasswordNotMatch);
                      return;
                    }

                    Navigator.of(dialogContext).pop(true);
                  },
                  child: Text(t.settingSave),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) {
      oldCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();
      return;
    }

    setState(() {
      passwordLoading = true;
      errorMessage = null;
    });

    try {
      final token = await SettingsService.token();

      if (token == null || token.isEmpty) {
        throw Exception(t.settingLoginTokenNotFound);
      }

      await UserService()
          .changePassword(
        token: token,
        oldPassword: oldCtrl.text.trim(),
        newPassword: newCtrl.text.trim(),
        newPasswordConfirmation: confirmCtrl.text.trim(),
        terminateSessions: terminateSessions,
      )
          .timeout(const Duration(seconds: 20));

      _toast(t.settingPasswordChanged);

      await _clearBiometricStorage();
      await SettingsService.clearAuthKeepRememberMe();

      if (!mounted) return;
      await _goToLogin();
    } on TimeoutException catch (e) {
      _showInternetError(e);
    } on SocketException catch (e) {
      _showInternetError(e);
    } catch (e) {
      if (_isInternetError(e)) {
        _showInternetError(e);
      } else {
        _toast(SettingsUtils.cleanError(e));
      }
    } finally {
      oldCtrl.dispose();
      newCtrl.dispose();
      confirmCtrl.dispose();

      if (mounted) setState(() => passwordLoading = false);
    }
  }

  Future<void> _pickLanguage() async {
    final value = await _pickFromList(
      title: t.settingSelectLanguage,
      items: [
        PickItem(label: t.settingEnglish, value: 'en'),
        PickItem(label: t.settingKhmer, value: 'km'),
      ],
      current: languageCode,
    );

    if (!mounted || value == null) return;

    await _setLanguage(value);
  }

  Future<void> _pickFontSize() async {
    final value = await _pickFromList(
      title: t.settingFontSize,
      items: [
        PickItem(label: t.settingSmall, value: FontSizePref.small.name),
        PickItem(label: t.settingMedium, value: FontSizePref.medium.name),
        PickItem(label: t.settingLarge, value: FontSizePref.large.name),
      ],
      current: fontSize.name,
    );

    if (!mounted || value == null) return;

    switch (value) {
      case 'small':
        await _setFontSize(FontSizePref.small);
        break;
      case 'large':
        await _setFontSize(FontSizePref.large);
        break;
      default:
        await _setFontSize(FontSizePref.medium);
    }
  }

  Future<String?> _pickFromList({
    required String title,
    required List<PickItem> items,
    required String current,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        final cs = Theme.of(sheetContext).colorScheme;

        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: cs.onSurface,
                  ),
                ),
              ),
              ...items.map((item) {
                final selected = item.value == current;

                return ListTile(
                  title: Text(
                    item.label,
                    style: TextStyle(
                      fontWeight:
                      selected ? FontWeight.w900 : FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  trailing: selected
                      ? Icon(Icons.check_rounded, color: cs.primary)
                      : null,
                  onTap: () => Navigator.of(sheetContext).pop(item.value),
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _themeRadio(String title, ThemeMode value) {
    final cs = Theme.of(context).colorScheme;

    return RadioListTile<ThemeMode>(
      value: value,
      groupValue: mode,
      onChanged: _busy
          ? null
          : (v) {
        if (v != null) _setMode(v);
      },
      activeColor: cs.primary,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: cs.onSurface,
        ),
      ),
    );
  }

  Widget _internetErrorView(String message) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(28, 70, 28, 28),
      children: [
        const SizedBox(height: 30),
        Icon(
          Icons.wifi_off_rounded,
          size: 72,
          color: cs.error.withOpacity(0.65),
        ),
        const SizedBox(height: 38),
        Text(
          'Unable to load settings',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 19,
            fontWeight: FontWeight.w800,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 42),
        SizedBox(
          width: double.infinity,
          height: 76,
          child: FilledButton.icon(
            onPressed: () {
              setState(() => errorMessage = null);
            },
            icon: const Icon(Icons.refresh_rounded, size: 24),
            label: const Text(
              'Try again',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
              ),
            ),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _settingsBody() {
    final cs = Theme.of(context).colorScheme;

    void openDeviceLogsScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const DeviceLogsScreen()),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        SettingsSectionTitle(text: t.settingAppTheme),
        SettingsCard(
          child: Column(
            children: [
              _themeRadio(t.settingSystem, ThemeMode.system),
              const SettingsDivider(),
              _themeRadio(t.settingLight, ThemeMode.light),
              const SettingsDivider(),
              _themeRadio(t.settingDark, ThemeMode.dark),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SettingsSectionTitle(text: t.settingReadingDefaults),
        SettingsCard(
          child: SettingsDropdownRow(
            title: t.settingFontSize,
            value: _fontLabel(fontSize),
            onTap: _busy ? null : _pickFontSize,
          ),
        ),
        const SizedBox(height: 18),
        SettingsSectionTitle(text: t.settingLanguage),
        SettingsCard(
          child: SettingsDropdownRow(
            title: t.settingAppLanguage,
            value: _languageLabel(),
            onTap: _busy ? null : _pickLanguage,
          ),
        ),
        const SizedBox(height: 18),
        SettingsSectionTitle(text: t.settingNotifications),
        SettingsCard(
          child: Column(
            children: [
              SettingsSwitchRow(
                title: t.settingNewReleases,
                subtitle: t.settingNewReleasesSubtitle,
                value: notifNewReleases,
                onChanged: _busy
                    ? null
                    : (v) {
                  setState(() => notifNewReleases = v);
                },
              ),
              const SettingsDivider(),
              SettingsSwitchRow(
                title: t.settingLoginAlerts,
                subtitle: t.settingLoginAlertsSubtitle,
                value: loginAlerts,
                onChanged: _busy
                    ? null
                    : (v) {
                  setState(() => loginAlerts = v);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SettingsSectionTitle(text: t.settingAccountSecurity),
        SettingsCard(
          child: Column(
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: passwordLoading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Icon(
                  Icons.lock_reset_rounded,
                  color: cs.primary,
                ),
                title: Text(
                  t.settingChangePassword,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: Text(
                  passwordLoading
                      ? t.settingChangingPassword
                      : t.settingUpdateLoginPassword,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                ),
                onTap: _busy ? null : _openChangePasswordDialog,
              ),
              const SettingsDivider(),
              SettingsSwitchRow(
                title: t.settingTwoFactor,
                subtitle: twoFactorLoading
                    ? 'Setting up Google Authenticator...'
                    : enable2FA
                    ? t.settingTwoFactorGoogleAuthEnabled
                    : t.settingTwoFactorGoogleAuthSubtitle,
                value: enable2FA,
                onChanged: _busy
                    ? null
                    : (v) {
                  if (v) {
                    _openGoogleAuthSetupDialog();
                  } else {
                    _openGoogleAuthDisableDialog();
                  }
                },
              ),
              const SettingsDivider(),
              SettingsSwitchRow(
                title: t.settingBiometrics,
                subtitle: enableBiometrics
                    ? 'Fingerprint / Face ID and PIN enabled for fast re-login'
                    : 'Use Fingerprint / Face ID with 4-digit PIN backup',
                value: enableBiometrics,
                onChanged: _busy ? null : _setEnableBiometrics,
              ),
              const SettingsDivider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.devices_rounded,
                  color: cs.primary,
                ),
                title: Text(
                  t.settingDeviceLogs,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: cs.onSurface,
                  ),
                ),
                subtitle: Text(
                  t.settingDeviceLogsSubtitle,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                trailing: Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                ),
                onTap: _busy ? null : openDeviceLogsScreen,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SettingsSectionTitle(text: t.settingLogout),
        SettingsCard(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: logoutLoading
                ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Icon(Icons.logout_rounded, color: Colors.red),
            title: Text(
              t.settingLogout,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: Colors.red,
              ),
            ),
            subtitle: Text(
              logoutLoading ? t.settingLoggingOut : t.settingLogoutAccount,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            onTap: _busy ? null : _confirmLogout,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: errorMessage == null
          ? AppBar(
        title: Text(
          t.settingTitle,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: t.settingReset,
            onPressed: _busy ? null : _resetSettings,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      )
          : null,
      body: errorMessage != null
          ? _internetErrorView(errorMessage!)
          : _settingsBody(),
    );
  }
}