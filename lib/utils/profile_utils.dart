class ProfileUtils {
  const ProfileUtils._();

  static String safeText(
      dynamic value, {
        String fallback = '',
      }) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  static double normalizeProgress(double value) {
    final safe = value > 1 ? value / 100 : value;
    return safe.clamp(0.0, 1.0).toDouble();
  }

  static int safePage(int value) {
    return value <= 0 ? 1 : value;
  }
}