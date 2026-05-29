import 'package:flutter/material.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  late final UserService _userService;
  late final LoginService _loginService;

  bool _obscure = true;
  bool _rememberMe = false;
  bool _loading = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    _userService = UserService();
    _loginService = LoginService();

    _loadRememberMe();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRememberMe() async {
    try {
      final remember = await _loginService.getRememberMe();
      final email = remember ? await _loginService.getSavedEmail() : '';

      if (!mounted) return;

      setState(() {
        _rememberMe = remember;
        _emailCtrl.text = email;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _rememberMe = false;
      });
    }
  }

  Future<void> _login() async {
    if (_loading) return;

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final deviceInfo = await DeviceInfoHelper.getLoginDeviceInfo();

      debugPrint('DEVICE INFO => $deviceInfo');

      final result = await _userService.login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
        deviceInfo: deviceInfo,
      );

      if (result.token.trim().isEmpty) {
        throw Exception('Token not found from server.');
      }

      await _loginService.saveLogin(
        data: result,
        rememberMe: _rememberMe,
        deviceInfo: deviceInfo,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const MainShell(),
        ),
            (_) => false,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = LoginUtils.cleanError(e);
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _clearError() {
    if (_errorMessage == null) return;

    setState(() {
      _errorMessage = null;
    });
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
                      onRetry: _loading ? null : _login,
                    ),
                    const SizedBox(height: 14),
                  ],

                  LoginCard(
                    formKey: _formKey,
                    emailCtrl: _emailCtrl,
                    passCtrl: _passCtrl,
                    loading: _loading,
                    obscure: _obscure,
                    rememberMe: _rememberMe,
                    fieldFill: fieldFill,
                    onLogin: _login,
                    onToggleObscure: () {
                      setState(() {
                        _obscure = !_obscure;
                      });
                    },
                    onRememberChanged: (value) {
                      setState(() {
                        _rememberMe = value ?? false;
                      });
                    },
                    validateEmail: LoginUtils.validateEmail,
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

class LoginConnectionErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final VoidCallback? onRetry;

  const LoginConnectionErrorCard({
    super.key,
    required this.message,
    required this.onClose,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? cs.errorContainer.withOpacity(0.35)
            : const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cs.error.withOpacity(0.22),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cs.error.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: cs.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Connection problem',
                  style: TextStyle(
                    color: cs.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: TextStyle(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Try again'),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: onClose,
                      child: const Text('Dismiss'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class LoginFormData {
  final String email;
  final String password;
  final bool rememberMe;

  const LoginFormData({
    required this.email,
    required this.password,
    required this.rememberMe,
  });
}