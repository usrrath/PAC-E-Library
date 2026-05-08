// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'E-Library';

  @override
  String get login => 'Login';

  @override
  String get logout => 'Logout';

  @override
  String get welcome => 'Welcome';

  @override
  String get search => 'Search Books';

  @override
  String get favorites => 'Favorites';

  @override
  String get continueReading => 'Continue Reading';

  @override
  String get menuHome => 'Home';

  @override
  String get menuLibrary => 'Library';

  @override
  String get menuSearch => 'Search';

  @override
  String get menuProfile => 'Profile';

  @override
  String get menuSettings => 'Settings';

  @override
  String get settingTitle => 'Settings';

  @override
  String get settingReset => 'Reset settings';

  @override
  String get settingResetDone => 'Reset done';

  @override
  String get settingAppTheme => 'App Theme';

  @override
  String get settingSystem => 'System';

  @override
  String get settingLight => 'Light';

  @override
  String get settingDark => 'Dark';

  @override
  String get settingReadingDefaults => 'Reading settings defaults';

  @override
  String get settingFontSize => 'Font size';

  @override
  String get settingSmall => 'Small';

  @override
  String get settingMedium => 'Medium';

  @override
  String get settingLarge => 'Large';

  @override
  String get settingRememberLastPage => 'Remember last page';

  @override
  String get settingContinueWhereLeftOff => 'Continue where you left off';

  @override
  String get settingLanguage => 'Language settings';

  @override
  String get settingAppLanguage => 'App language';

  @override
  String get settingSelectLanguage => 'Select language';

  @override
  String get settingEnglish => 'English';

  @override
  String get settingKhmer => 'Khmer';

  @override
  String get settingLanguageChanged => 'Language changed';

  @override
  String get settingNotifications => 'Notification controls';

  @override
  String get settingNewReleases => 'New releases';

  @override
  String get settingNewReleasesSubtitle => 'Get notified when new books arrive';

  @override
  String get settingRecommendations => 'Recommendations';

  @override
  String get settingRecommendationsSubtitle => 'Personalized suggestions';

  @override
  String get settingAccountSecurity => 'Account security';

  @override
  String get settingChangePassword => 'Change password';

  @override
  String get settingChangingPassword => 'Changing password...';

  @override
  String get settingUpdateLoginPassword => 'Update your login password';

  @override
  String get settingOldPassword => 'Old password';

  @override
  String get settingNewPassword => 'New password';

  @override
  String get settingConfirmNewPassword => 'Confirm new password';

  @override
  String get settingPasswordHelper => 'Password must be 6-10 characters';

  @override
  String get settingLogoutAllDevices => 'Logout all devices';

  @override
  String get settingRecommendedAfterPassword => 'Recommended after changing password';

  @override
  String get settingOldPasswordRequired => 'Old password is required';

  @override
  String get settingNewPasswordLength => 'New password must be 6-10 characters';

  @override
  String get settingConfirmPasswordNotMatch => 'Confirm password does not match';

  @override
  String get settingPasswordChanged => 'Password changed successfully';

  @override
  String get settingLoginTokenNotFound => 'Login token not found';

  @override
  String get settingTwoFactor => 'Two-factor authentication (2FA)';

  @override
  String get settingTwoFactorSubtitle => 'Extra protection for your account';

  @override
  String get settingLoginAlerts => 'Login alerts';

  @override
  String get settingLoginAlertsSubtitle => 'Notify me about new sign-ins';

  @override
  String get settingLogout => 'Logout';

  @override
  String get settingLogoutConfirm => 'Do you want to logout?';

  @override
  String get settingLogoutFailed => 'Logout failed';

  @override
  String get settingLoggingOut => 'Logging out...';

  @override
  String get settingLogoutAccount => 'Log out of this account';

  @override
  String get settingCancel => 'Cancel';

  @override
  String get settingSave => 'Save';

  @override
  String get profilesProfile => 'Profile';

  @override
  String get profilesRefresh => 'Refresh';

  @override
  String get profilesEditProfile => 'Edit Profile';

  @override
  String get profilesReadingStatistics => 'Reading Statistics';

  @override
  String get profilesFavoriteBooks => 'Favorite Books';

  @override
  String get profilesReadingProgress => 'Reading Progress';

  @override
  String get profilesInProgress => 'In Progress';

  @override
  String get profilesNoFavoriteBooks => 'No favorite books.';

  @override
  String get profilesNoReadingProgress => 'No reading progress.';

  @override
  String get profilesNoName => 'No Name';

  @override
  String get profilesNoEmail => 'No Email';

  @override
  String profilesUserId(Object id) {
    return 'ID: $id';
  }

  @override
  String get profilesName => 'Name';

  @override
  String get profilesEmail => 'Email';

  @override
  String get profilesUserLevel => 'User Level';

  @override
  String get profilesCancel => 'Cancel';

  @override
  String get profilesSave => 'Save';

  @override
  String get profilesNoChangesToUpdate => 'No changes to update';

  @override
  String get profilesProfileUpdatedSuccessfully => 'Profile updated successfully';

  @override
  String get profilesTokenNotFound => 'Token not found. Please login again.';

  @override
  String profilesClickedBook(Object title) {
    return 'Clicked: $title';
  }
}
