class LoginUtils {
  const LoginUtils._();

  static String cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Network Error: Exception: ', '')
        .replaceFirst('Login error: Exception: ', '');
  }

  static String? validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) return 'Please enter email';

    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!regex.hasMatch(email)) return 'Invalid email';

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.isEmpty) return 'Please enter password';

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }
}