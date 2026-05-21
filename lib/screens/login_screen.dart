import 'package:flutter/material.dart';

import '../services/login_service.dart';
import '../services/user_service.dart';
import '../utils/login_utils.dart';
import '../widgets/login_widgets.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();

  final UserService _userService = UserService();
  final LoginService _loginService = LoginService();

  bool _obscure = true;
  bool _rememberMe = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
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

      if (!mounted) return;

      if (!remember) {
        setState(() => _rememberMe = false);
        return;
      }

      final email = await _loginService.getSavedEmail();

      if (!mounted) return;

      setState(() {
        _rememberMe = true;
        _emailCtrl.text = email;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _rememberMe = false);
    }
  }

  void _toast(String msg) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _login() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    setState(() => _loading = true);

    try {
      final result = await _userService.login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );

      if (result.token.trim().isEmpty) {
        throw Exception('Token not found from server.');
      }

      await _loginService.saveLogin(
        data: result,
        rememberMe: _rememberMe,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (e) {
      _toast(LoginUtils.cleanError(e));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color bg = isDark ? cs.surface : const Color(0xFFF7F9FC);
    final Color fieldFill = isDark
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
                      setState(() => _obscure = !_obscure);
                    },
                    onRememberChanged: (value) {
                      setState(() => _rememberMe = value ?? false);
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