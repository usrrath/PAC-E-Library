import 'package:flutter/material.dart';
import 'package:pac_e_library_new/screens/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _goToLogin();
  }

  Future<void> _goToLogin() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      // ✅ Use theme primary as background so Dark/Light looks good
      backgroundColor: cs.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Container(
              //   width: 92,
              //   height: 92,
              //   decoration: BoxDecoration(
              //     color: cs.onPrimary.withOpacity(0.18),
              //     borderRadius: BorderRadius.circular(26),
              //     border: Border.all(color: cs.onPrimary.withOpacity(0.30)),
              //   ),
              //   child: Icon(Icons.local_library_rounded, size: 46, color: cs.onPrimary),
              // ),
              const SizedBox(height: 18),
              Text(
                "PAC E-Library",
                style: TextStyle(
                  fontSize: 44,
                  fontWeight: FontWeight.w900,
                  color: cs.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Read • Save • Learn",
                style: TextStyle(
                  color: cs.onPrimary.withOpacity(0.85),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: cs.onPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
