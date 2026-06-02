import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:otp/otp.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import '../models/success_user.dart';
import '../services/login_service.dart';
import '../services/user_service.dart';
import '../utils/device_info_helper.dart';
import '../utils/login_utils.dart';
import '../widgets/login_widgets.dart';
import 'main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  static const String _kTwoFactorEnabled = 'two_factor_enabled';
  static const String _kTwoFactorSecret = 'two_factor_secret';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final LocalAuthentication _localAuth = LocalAuthentication();

  late final UserService _userService;
  late final LoginService _loginService;

  bool _obscure = true;
  bool _rememberMe = false;
  bool _loading = false;
  bool _biometricAvailable = false;
  bool _biometricLoading = false;
  bool _checkingSession = true;

  String? _errorMessage;

  bool get _busy => _loading || _biometricLoading || _checkingSession;

  @override
  void initState() {
    super.initState();
    _userService = UserService();
    _loginService = LoginService();

    _loadInitialAuth();
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadInitialAuth() async {
    try {
      final remember = await _loginService.getRememberMe();
      final savedUsername = remember ? await _loginService.getSavedEmail() : '';
      final bioEnabled = await _loginService.isBiometricEnabled();
      final token = await _loginService.getToken();

      if (!mounted) return;

      setState(() {
        _rememberMe = remember;
        _usernameCtrl.text = savedUsername;
        _biometricAvailable = bioEnabled;
      });

      if (bioEnabled) return;

      if (token.trim().isNotEmpty) {
        try {
          await _userService.getVerifyAccount(token.trim());
          if (!mounted) return;
          _goToMain();
          return;
        } catch (_) {
          await _loginService.clearAuthOnly();
        }
      }
    } finally {
      if (mounted) {
        setState(() => _checkingSession = false);
      }
    }
  }

  Future<bool> _hasTwoFactorSetup() async {
    final enabled = await _secureStorage.read(key: _kTwoFactorEnabled);
    final secret = await _secureStorage.read(key: _kTwoFactorSecret);

    return enabled == 'true' && secret != null && secret.trim().isNotEmpty;
  }

  Future<String> _twoFactorSecret() async {
    return await _secureStorage.read(key: _kTwoFactorSecret) ?? '';
  }

  bool _verifyGoogleAuthenticatorCode({
    required String secret,
    required String code,
  }) {
    final cleanSecret = secret.trim().replaceAll(' ', '').toUpperCase();
    final cleanCode = code.trim();

    if (cleanSecret.isEmpty) return false;
    if (!RegExp(r'^\d{6}$').hasMatch(cleanCode)) return false;

    final now = DateTime.now().millisecondsSinceEpoch;

    final current = OTP.generateTOTPCodeString(
      cleanSecret,
      now,
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    final previous = OTP.generateTOTPCodeString(
      cleanSecret,
      now - const Duration(seconds: 30).inMilliseconds,
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    final next = OTP.generateTOTPCodeString(
      cleanSecret,
      now + const Duration(seconds: 30).inMilliseconds,
      interval: 30,
      length: 6,
      algorithm: Algorithm.SHA1,
      isGoogle: true,
    );

    return cleanCode == current || cleanCode == previous || cleanCode == next;
  }

  Future<void> _verifyLocalTwoFactorAfterPassword() async {
    final has2FA = await _hasTwoFactorSetup();
    if (!has2FA) return;

    final secret = await _twoFactorSecret();
    final code = await _showTwoFactorDialog();

    if (code == null || code.trim().isEmpty) {
      throw Exception('Please verify Google Authenticator code.');
    }

    final ok = _verifyGoogleAuthenticatorCode(
      secret: secret,
      code: code.trim(),
    );

    if (!ok) {
      throw Exception('Invalid Google Authenticator code.');
    }
  }

  Future<void> _login() async {
    if (_busy) return;

    if (!(_formKey.currentState?.validate() ?? false)) return;

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final deviceInfo = await DeviceInfoHelper.getLoginDeviceInfo();

      final result = await _userService.login(
        _usernameCtrl.text.trim(),
        _passCtrl.text,
        deviceInfo: deviceInfo,
      );

      SuccessUser? successUser;

      if (result.twoFactorRequired) {
        final code = await _showTwoFactorDialog();

        if (code == null || code.trim().isEmpty) {
          throw Exception('Please verify Google Authenticator code.');
        }

        successUser = await _userService.verifyTwoFactorLogin(
          username: _usernameCtrl.text.trim(),
          password: _passCtrl.text,
          code: code.trim(),
          tempToken: result.tempToken,
          deviceInfo: deviceInfo,
        );
      } else {
        successUser = result.user;
        await _verifyLocalTwoFactorAfterPassword();
      }

      if (successUser == null || successUser.token.trim().isEmpty) {
        throw Exception('Token not found from server.');
      }

      await _loginService.saveLogin(
        data: successUser,
        rememberMe: _rememberMe,
        deviceInfo: deviceInfo,
      );

      await _askEnableBiometricAndPin(successUser);

      if (!mounted) return;
      _goToMain();
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = LoginUtils.cleanError(e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _askEnableBiometricAndPin(SuccessUser user) async {
    final alreadyEnabled = await _loginService.isBiometricEnabled(
      ignoreSignedOut: true,
    );

    if (alreadyEnabled) {
      await _loginService.saveBiometricSession(user);
      return;
    }

    final enable = await _showEnableBiometricDialog();
    if (enable != true) return;

    final ok = await _authenticateBiometric(
      reason: 'Enable Fingerprint / Face ID for PAC E-Library',
    );

    if (!ok) return;

    final pin = await _showCreatePinDialog();
    if (pin == null || pin.trim().isEmpty) return;

    await _loginService.saveBiometricPin(pin.trim());
    await _loginService.saveBiometricSession(user);
  }

  Future<bool?> _showEnableBiometricDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Enable biometric login?',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          content: const Text(
            'Use Fingerprint / Face ID and a 4-digit PIN for faster login next time.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Skip'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enable'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showCreatePinDialog() async {
    final pinCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    String? error;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void save() {
              final pin = pinCtrl.text.trim();
              final confirm = confirmCtrl.text.trim();

              if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
                setDialogState(() => error = 'PIN must be 4 digits');
                return;
              }

              if (pin != confirm) {
                setDialogState(() => error = 'PIN confirmation does not match');
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
                    'Create a 4-digit PIN as fallback when biometric is unavailable.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  PinCodeTextField(
                    appContext: dialogContext,
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
                  ),
                  const SizedBox(height: 10),
                  PinCodeTextField(
                    appContext: dialogContext,
                    controller: confirmCtrl,
                    length: 4,
                    obscureText: true,
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
                  child: const Text('Skip'),
                ),
                FilledButton(
                  onPressed: save,
                  child: const Text('Save PIN'),
                ),
              ],
            );
          },
        );
      },
    );

    pinCtrl.dispose();
    confirmCtrl.dispose();

    return result;
  }

  Future<String?> _showTwoFactorDialog() async {
    final codeCtrl = TextEditingController();
    String? error;

    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void verify() {
              final cleanCode = codeCtrl.text.trim();

              if (!RegExp(r'^\d{6}$').hasMatch(cleanCode)) {
                setDialogState(() => error = '2FA code must be 6 digits');
                return;
              }

              Navigator.of(dialogContext).pop(cleanCode);
            }

            return AlertDialog(
              title: const Text(
                'Google Authenticator',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter the 6-digit code from Google Authenticator.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  PinCodeTextField(
                    appContext: dialogContext,
                    controller: codeCtrl,
                    length: 6,
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
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: verify,
                  child: const Text('Verify'),
                ),
              ],
            );
          },
        );
      },
    );

    codeCtrl.dispose();
    return result;
  }

  Future<bool> _authenticateBiometric({required String reason}) async {
    final supported = await _localAuth.isDeviceSupported();
    final canCheck = await _localAuth.canCheckBiometrics;

    if (!supported || !canCheck) {
      throw Exception('Fingerprint / Face ID not available');
    }

    return _localAuth.authenticate(
      localizedReason: reason,
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );
  }

  Future<void> _loginWithBiometrics() async {
    if (_busy) return;

    setState(() {
      _biometricLoading = true;
      _errorMessage = null;
    });

    try {
      final token = await _loginService.getBiometricToken();

      if (token.trim().isEmpty) {
        throw Exception('Biometric token not found');
      }

      final ok = await _authenticateBiometric(
        reason: 'Use Fingerprint or Face ID to login',
      );

      if (!ok) return;

      await _restoreBiometricSession(token);
    } catch (e) {
      await _loginService.clearAuthOnly();

      if (!mounted) return;

      setState(() {
        _biometricAvailable = false;
        _errorMessage = LoginUtils.cleanError(e);
      });
    } finally {
      if (mounted) {
        setState(() => _biometricLoading = false);
      }
    }
  }

  Future<void> _loginWithPin(String pin) async {
    if (_busy) return;

    setState(() {
      _biometricLoading = true;
      _errorMessage = null;
    });

    try {
      final cleanPin = pin.trim();

      if (!RegExp(r'^\d{4}$').hasMatch(cleanPin)) {
        throw Exception('PIN must be 4 digits');
      }

      final validPin = await _loginService.verifyBiometricPin(cleanPin);
      if (!validPin) {
        throw Exception('Invalid PIN code');
      }

      final token = await _loginService.getBiometricToken();

      if (token.trim().isEmpty) {
        throw Exception('Biometric token not found');
      }

      await _restoreBiometricSession(token);
    } catch (e) {
      await _loginService.clearAuthOnly();

      if (!mounted) return;

      setState(() {
        _biometricAvailable = false;
        _errorMessage = LoginUtils.cleanError(e);
      });
    } finally {
      if (mounted) {
        setState(() => _biometricLoading = false);
      }
    }
  }

  Future<void> _restoreBiometricSession(String token) async {
    await _userService.getVerifyAccount(token);
    await _loginService.restoreBiometricLoginToPrefs();
    await _loginService.updateBiometricLastAuth();

    if (!mounted) return;
    _goToMain();
  }

  void _goToMain() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
          (_) => false,
    );
  }

  void _clearError() {
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final bg = isDark ? cs.surface : const Color(0xFFF7F9FC);

    final fieldFill = isDark
        ? cs.surfaceVariant.withOpacity(0.35)
        : const Color(0xFFF7F9FC);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LoginHeader(colorScheme: cs),
                  const SizedBox(height: 16),
                  if (_errorMessage != null) ...[
                    LoginConnectionErrorCard(
                      message: _errorMessage!,
                      onClose: _clearError,
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (_checkingSession)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(28),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_biometricAvailable)
                    _BiometricOnlyCard(
                      loading: _biometricLoading,
                      onLogin: _loginWithBiometrics,
                      onPinLogin: _loginWithPin,
                    )
                  else
                    LoginCard(
                      formKey: _formKey,
                      usernameCtrl: _usernameCtrl,
                      passCtrl: _passCtrl,
                      loading: _loading,
                      obscure: _obscure,
                      rememberMe: _rememberMe,
                      fieldFill: fieldFill,
                      onLogin: _login,
                      onToggleObscure: () {
                        setState(() => _obscure = !_obscure);
                      },
                      onRememberChanged: (value) {
                        setState(() => _rememberMe = value ?? false);
                      },
                      validateUsername: LoginUtils.validateUsername,
                      validatePassword: LoginUtils.validatePassword,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BiometricOnlyCard extends StatefulWidget {
  final bool loading;
  final VoidCallback onLogin;
  final ValueChanged<String> onPinLogin;

  const _BiometricOnlyCard({
    required this.loading,
    required this.onLogin,
    required this.onPinLogin,
  });

  @override
  State<_BiometricOnlyCard> createState() => _BiometricOnlyCardState();
}

class _BiometricOnlyCardState extends State<_BiometricOnlyCard> {
  final TextEditingController _pinCtrl = TextEditingController();
  String? _pinError;

  @override
  void dispose() {
    _pinCtrl.dispose();
    super.dispose();
  }

  void _submitPin() {
    final error = LoginUtils.validatePin(_pinCtrl.text);

    if (error != null) {
      setState(() => _pinError = error);
      return;
    }

    FocusScope.of(context).unfocus();
    widget.onPinLogin(_pinCtrl.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: cs.primary.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(
              Icons.fingerprint_rounded,
              size: 62,
              color: cs.primary,
            ),
            const SizedBox(height: 12),
            const Text(
              'Login with biometrics',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Use Fingerprint / Face ID or your 4-digit PIN.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: widget.loading ? null : widget.onLogin,
                icon: widget.loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.fingerprint_rounded),
                label: Text(
                  widget.loading
                      ? 'Checking...'
                      : 'Login with Fingerprint / Face ID',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Or login with PIN',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            PinCodeTextField(
              appContext: context,
              controller: _pinCtrl,
              length: 4,
              obscureText: true,
              keyboardType: TextInputType.number,
              animationType: AnimationType.fade,
              autoDisposeControllers: false,
              enabled: !widget.loading,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) {
                if (_pinError != null) {
                  setState(() => _pinError = null);
                }
              },
              onCompleted: (_) => _submitPin(),
            ),
            if (_pinError != null) ...[
              const SizedBox(height: 4),
              Text(
                _pinError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
            const SizedBox(height: 10),
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: widget.loading ? null : _submitPin,
                icon: const Icon(Icons.pin_rounded),
                label: const Text(
                  'Login with PIN',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}