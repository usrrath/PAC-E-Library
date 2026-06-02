import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  final ColorScheme colorScheme;

  const LoginHeader({
    super.key,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 126,
          height: 126,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/icons/app_icon.png',
              fit: BoxFit.fill,
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'PAC E-Library',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Police Academy of Cambodia',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class LoginCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController usernameCtrl;
  final TextEditingController passCtrl;
  final bool loading;
  final bool obscure;
  final bool rememberMe;
  final Color fieldFill;
  final VoidCallback onLogin;
  final VoidCallback onToggleObscure;
  final ValueChanged<bool?> onRememberChanged;
  final String? Function(String?) validateUsername;
  final String? Function(String?) validatePassword;

  const LoginCard({
    super.key,
    required this.formKey,
    required this.usernameCtrl,
    required this.passCtrl,
    required this.loading,
    required this.obscure,
    required this.rememberMe,
    required this.fieldFill,
    required this.onLogin,
    required this.onToggleObscure,
    required this.onRememberChanged,
    required this.validateUsername,
    required this.validatePassword,
  });

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
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Sign in',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'To continue reading',
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 22),
              TextFormField(
                controller: usernameCtrl,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: validateUsername,
                decoration: InputDecoration(
                  labelText: 'Username',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  filled: true,
                  fillColor: fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: passCtrl,
                obscureText: obscure,
                textInputAction: TextInputAction.done,
                validator: validatePassword,
                onFieldSubmitted: (_) {
                  if (!loading) onLogin();
                },
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    onPressed: onToggleObscure,
                    icon: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                  filled: true,
                  fillColor: fieldFill,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                value: rememberMe,
                onChanged: loading ? null : onRememberChanged,
                dense: true,
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text(
                  'Remember me',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: loading ? null : onLogin,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: loading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.4),
                  )
                      : const Text(
                    'Sign In',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LoginConnectionErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const LoginConnectionErrorCard({
    super.key,
    required this.message,
    required this.onClose,
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
        border: Border.all(color: cs.error.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: cs.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: cs.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}