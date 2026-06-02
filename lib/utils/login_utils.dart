class LoginUtils {
  const LoginUtils._();

  static String cleanError(Object error) {
    var message = error.toString().trim();

    message = message
        .replaceFirst('Exception: ', '')
        .replaceFirst('Network Error: Exception: ', '')
        .replaceFirst('Login error: Exception: ', '')
        .replaceFirst('ClientException: ', '')
        .replaceFirst('SocketException: ', '');

    if (message.contains('Unauthenticated')) {
      return 'Session expired. Please login again with username and password.';
    }

    if (message.contains('Connection failed') ||
        message.contains('Network is unreachable') ||
        message.contains('Failed host lookup') ||
        message.contains('Connection refused') ||
        message.contains('No route to host') ||
        message.contains('Connection timed out')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (message.contains('XMLHttpRequest error')) {
      return 'Unable to connect to server. Please check your API URL or CORS setting.';
    }

    if (message.contains('Token not found')) {
      return 'Login successful, but token was not returned from server.';
    }

    if (message.isEmpty) {
      return 'Login failed. Please try again.';
    }

    return message;
  }

  static String? validateUsername(String? value) {
    final username = (value ?? '').trim();

    if (username.isEmpty) {
      return 'Please enter username';
    }

    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    final password = value ?? '';

    if (password.trim().isEmpty) {
      return 'Please enter password';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateTwoFactorCode(String? value) {
    final code = (value ?? '').trim();

    if (code.isEmpty) return 'Please enter 2FA code';
    if (!RegExp(r'^\d{6}$').hasMatch(code)) {
      return '2FA code must be 6 digits';
    }

    return null;
  }

  static String? validatePin(String? value) {
    final pin = (value ?? '').trim();

    if (pin.isEmpty) return 'Please enter PIN';
    if (!RegExp(r'^\d{4}$').hasMatch(pin)) {
      return 'PIN must be 4 digits';
    }

    return null;
  }
}
