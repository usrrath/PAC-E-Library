// import 'package:flutter/material.dart';
// import 'package:pac_e_library_new/screens/forgetpassword_screen.dart';
// import 'package:pac_e_library_new/screens/home_screen.dart';
//
// import '../services/user_service.dart';
//
//
// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});
//
//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }
//
// class _LoginScreenState extends State<LoginScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final _emailCtrl = TextEditingController();
//   final _passCtrl = TextEditingController();
//
//   bool _obscure = true;
//   bool _rememberMe = true;
//   bool _loading = false;
//
//   @override
//   void dispose() {
//     _emailCtrl.dispose();
//     _passCtrl.dispose();
//     super.dispose();
//   }
//
//   void _toast(String msg) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
//     );
//   }
//
//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     setState(() => _loading = true);
//     await Future.delayed(const Duration(milliseconds: 900));
//     if (!mounted) return;
//     setState(() => _loading = false);
//
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const MainShell()),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final cs = theme.colorScheme;
//
//     // A nice "page background" that works in both modes
//     final bg = theme.brightness == Brightness.dark
//         ? cs.surface
//         : const Color(0xFFF7F9FC);
//
//     final fieldFill = theme.brightness == Brightness.dark
//         ? cs.surfaceContainerHighest.withOpacity(0.35)
//         : const Color(0xFFF7F9FC);
//
//     return Scaffold(
//       backgroundColor: bg,
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 520),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   _header(cs),
//                   const SizedBox(height: 16),
//                   _loginCard(cs, fieldFill),
//                   const SizedBox(height: 14),
//                   // _footerLinks(cs),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _header(ColorScheme cs) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [
//             Container(
//               width: 44,
//               height: 44,
//               decoration: BoxDecoration(
//                 color: cs.primary.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(color: cs.primary.withOpacity(0.18)),
//               ),
//               child: Icon(Icons.local_library_rounded, color: cs.primary),
//             ),
//             const SizedBox(width: 10),
//             Text(
//               "PAC E-Library",
//               style: TextStyle(
//                 fontSize: 42,
//                 fontWeight: FontWeight.w900,
//                 color: cs.onSurface,
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 14),
//         Text(
//           "Welcome Reading Online",
//           style: TextStyle(
//             fontSize: 26,
//             fontWeight: FontWeight.w900,
//             color: cs.onSurface,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Text(
//           "Login to continue reading and manage your library.",
//           style: TextStyle(color: cs.onSurfaceVariant, height: 1.35),
//         ),
//       ],
//     );
//   }
//
//   Widget _loginCard(ColorScheme cs, Color fieldFill) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: cs.primary.withOpacity(0.12)),
//         boxShadow: [
//           BoxShadow(
//             blurRadius: 18,
//             color: Colors.black.withOpacity(0.06),
//             offset: const Offset(0, 12),
//           ),
//         ],
//       ),
//       child: Form(
//         key: _formKey,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Text("Login", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: cs.onSurface)),
//             const SizedBox(height: 14),
//
//             // Email
//             TextFormField(
//               controller: _emailCtrl,
//               keyboardType: TextInputType.emailAddress,
//               textInputAction: TextInputAction.next,
//               decoration: InputDecoration(
//                 labelText: "Email",
//                 hintText: "name@example.com",
//                 prefixIcon: const Icon(Icons.email_outlined),
//                 filled: true,
//                 fillColor: fieldFill,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               validator: (v) {
//                 final s = (v ?? "").trim();
//                 if (s.isEmpty) return "Please enter email";
//                 if (!s.contains("@") || !s.contains(".")) return "Invalid email";
//                 return null;
//               },
//             ),
//             const SizedBox(height: 12),
//
//             // Password
//             TextFormField(
//               controller: _passCtrl,
//               obscureText: _obscure,
//               textInputAction: TextInputAction.done,
//               onFieldSubmitted: (_) => _login(),
//               decoration: InputDecoration(
//                 labelText: "Password",
//                 hintText: "••••••••",
//                 prefixIcon: const Icon(Icons.lock_outline_rounded),
//                 suffixIcon: IconButton(
//                   onPressed: () => setState(() => _obscure = !_obscure),
//                   icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined),
//                 ),
//                 filled: true,
//                 fillColor: fieldFill,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(16),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//               validator: (v) {
//                 final s = (v ?? "");
//                 if (s.isEmpty) return "Please enter password";
//                 if (s.length < 6) return "Password must be at least 6 characters";
//                 return null;
//               },
//             ),
//             const SizedBox(height: 10),
//
//             // Remember + Forgot
//             Row(
//               children: [
//                 Checkbox(
//                   value: _rememberMe,
//                   onChanged: (v) => setState(() => _rememberMe = v ?? true),
//                   activeColor: cs.primary,
//                 ),
//                 Text("Remember me", style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface)),
//                 const Spacer(),
//                 TextButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(builder: (_) => const ForgetPasswordScreen()),
//                     );
//                   },
//                   child: Text(
//                     "Forgot password?",
//                     style: TextStyle(fontWeight: FontWeight.w800, color: cs.primary),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 6),
//
//             // Login button
//             SizedBox(
//               height: 50,
//               child: ElevatedButton(
//                 onPressed: _loading ? null : _login,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: cs.primary,
//                   foregroundColor: cs.onPrimary,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 ),
//                 child: _loading
//                     ? SizedBox(
//                   width: 18,
//                   height: 18,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: cs.onPrimary),
//                 )
//                     : const Text("Login", style: TextStyle(fontWeight: FontWeight.w900)),
//               ),
//             ),
//             const SizedBox(height: 14),
//
//           ],
//         ),
//       ),
//     );
//   }
//
//   final _service = UserService();
//
//   Widget _buildLoginButton() {
//     return SizedBox(
//       width: double.maxFinite,
//       child: FilledButton(
//         onPressed: () {
//           if (_formKey.currentState!.validate()) {
//             _service
//                 .login(_emailCtrl.text.trim(), _passCtrl.text)
//                 .then((successUser) async{
//               await context.read<UserLogic>().saveUser(successUser);
//               await context.read<StudentLogic>().readStudents(context);
//               Navigator.of(context).push(MaterialPageRoute(builder: (context) => MainScreen()));
//             })
//                 .onError((e, s) {
//               debugPrint(e.toString());
//               // MyMessage(context, "Login Failed");
//             });
//           }
//         },
//         child: Text("LOGIN"),
//       ),
//     );
//   }
//
//
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/user_service.dart';
import 'forgetpassword_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  final UserService _service = UserService();

  bool _obscure = true;
  bool _rememberMe = true;
  bool _loading = false;

  // get SharedPreferences => null;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
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

  Future<void> _saveAuthData({
    required String token,
    required String userId,
    required String name,
    required String email,
    String? level,
    String? photo,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('auth_token', token);
    await prefs.setString('user_id', userId);
    await prefs.setString('user_name', name);
    await prefs.setString('user_email', email);

    if (level != null) {
      await prefs.setString('user_level', level);
    }

    if (photo != null) {
      await prefs.setString('user_photo', photo);
    }

    await prefs.setBool('remember_me', _rememberMe);
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final result = await _service.login(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (result.token.isEmpty) {
        throw Exception('Token not found from server.');
      }

      await _saveAuthData(
        token: result.token,
        userId: result.user.id,
        name: result.user.name,
        email: result.user.email,
        level: result.user.level,
        photo: result.user.photo,
      );

      if (!mounted) return;

      _toast('Login success');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MainShell()),
      );
    } catch (e) {
      _toast(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String? _validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Please enter email';
    }

    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!regex.hasMatch(email)) {
      return 'Invalid email';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) {
      return 'Please enter password';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final bg = theme.brightness == Brightness.dark
        ? cs.surface
        : const Color(0xFFF7F9FC);

    final fieldFill = theme.brightness == Brightness.dark
        ? cs.surfaceContainerHighest.withOpacity(0.35)
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
                  _header(cs),
                  const SizedBox(height: 16),
                  _loginCard(cs, fieldFill),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.primary.withOpacity(0.18)),
              ),
              child: Icon(
                Icons.local_library_rounded,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'PAC E-Library',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Welcome Reading Online',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: cs.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Login to continue reading and manage your library.',
          style: TextStyle(
            color: cs.onSurfaceVariant,
            height: 1.35,
          ),
        ),
      ],
    );
  }

  Widget _loginCard(ColorScheme cs, Color fieldFill) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: Colors.black.withOpacity(0.06),
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Login',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 14),

            TextFormField(
              controller: _emailCtrl,
              enabled: !_loading,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'name@example.com',
                prefixIcon: const Icon(Icons.email_outlined),
                filled: true,
                fillColor: fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: _validateEmail,
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _passCtrl,
              enabled: !_loading,
              obscureText: _obscure,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _login(),
              decoration: InputDecoration(
                labelText: 'Password',
                hintText: '••••••••',
                prefixIcon: const Icon(Icons.lock_outline_rounded),
                suffixIcon: IconButton(
                  onPressed: _loading
                      ? null
                      : () {
                    setState(() => _obscure = !_obscure);
                  },
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                filled: true,
                fillColor: fieldFill,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: _validatePassword,
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  onChanged: _loading
                      ? null
                      : (value) {
                    setState(() => _rememberMe = value ?? true);
                  },
                  activeColor: cs.primary,
                ),
                Text(
                  'Remember me',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ForgetPasswordScreen(),
                      ),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: cs.primary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: cs.primary,
                  foregroundColor: cs.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _loading
                    ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onPrimary,
                  ),
                )
                    : const Text(
                  'Login',
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
