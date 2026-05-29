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

    if (message.trim().isEmpty) {
      return 'Login failed. Please try again.';
    }

    return message;
  }

  static String? validateEmail(String? value) {
    final email = (value ?? '').trim();

    if (email.isEmpty) {
      return 'Please enter email';
    }

    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (!regex.hasMatch(email)) {
      return 'Invalid email address';
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
}