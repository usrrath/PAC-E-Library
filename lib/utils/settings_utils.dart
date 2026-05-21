class SettingsUtils {
  const SettingsUtils._();

  static String cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '')
        .replaceFirst('Change password error: ', '');
  }
}