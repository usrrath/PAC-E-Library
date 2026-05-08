import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'E-Library'**
  String get appName;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search Books'**
  String get search;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @continueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get continueReading;

  /// No description provided for @menuHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get menuHome;

  /// No description provided for @menuLibrary.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get menuLibrary;

  /// No description provided for @menuSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get menuSearch;

  /// No description provided for @menuProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menuProfile;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @settingTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingTitle;

  /// No description provided for @settingReset.
  ///
  /// In en, this message translates to:
  /// **'Reset settings'**
  String get settingReset;

  /// No description provided for @settingResetDone.
  ///
  /// In en, this message translates to:
  /// **'Reset done'**
  String get settingResetDone;

  /// No description provided for @settingAppTheme.
  ///
  /// In en, this message translates to:
  /// **'App Theme'**
  String get settingAppTheme;

  /// No description provided for @settingSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingSystem;

  /// No description provided for @settingLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingLight;

  /// No description provided for @settingDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingDark;

  /// No description provided for @settingReadingDefaults.
  ///
  /// In en, this message translates to:
  /// **'Reading settings defaults'**
  String get settingReadingDefaults;

  /// No description provided for @settingFontSize.
  ///
  /// In en, this message translates to:
  /// **'Font size'**
  String get settingFontSize;

  /// No description provided for @settingSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get settingSmall;

  /// No description provided for @settingMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get settingMedium;

  /// No description provided for @settingLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get settingLarge;

  /// No description provided for @settingRememberLastPage.
  ///
  /// In en, this message translates to:
  /// **'Remember last page'**
  String get settingRememberLastPage;

  /// No description provided for @settingContinueWhereLeftOff.
  ///
  /// In en, this message translates to:
  /// **'Continue where you left off'**
  String get settingContinueWhereLeftOff;

  /// No description provided for @settingLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language settings'**
  String get settingLanguage;

  /// No description provided for @settingAppLanguage.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get settingAppLanguage;

  /// No description provided for @settingSelectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select language'**
  String get settingSelectLanguage;

  /// No description provided for @settingEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get settingEnglish;

  /// No description provided for @settingKhmer.
  ///
  /// In en, this message translates to:
  /// **'Khmer'**
  String get settingKhmer;

  /// No description provided for @settingLanguageChanged.
  ///
  /// In en, this message translates to:
  /// **'Language changed'**
  String get settingLanguageChanged;

  /// No description provided for @settingNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification controls'**
  String get settingNotifications;

  /// No description provided for @settingNewReleases.
  ///
  /// In en, this message translates to:
  /// **'New releases'**
  String get settingNewReleases;

  /// No description provided for @settingNewReleasesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Get notified when new books arrive'**
  String get settingNewReleasesSubtitle;

  /// No description provided for @settingRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Recommendations'**
  String get settingRecommendations;

  /// No description provided for @settingRecommendationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Personalized suggestions'**
  String get settingRecommendationsSubtitle;

  /// No description provided for @settingAccountSecurity.
  ///
  /// In en, this message translates to:
  /// **'Account security'**
  String get settingAccountSecurity;

  /// No description provided for @settingChangePassword.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get settingChangePassword;

  /// No description provided for @settingChangingPassword.
  ///
  /// In en, this message translates to:
  /// **'Changing password...'**
  String get settingChangingPassword;

  /// No description provided for @settingUpdateLoginPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your login password'**
  String get settingUpdateLoginPassword;

  /// No description provided for @settingOldPassword.
  ///
  /// In en, this message translates to:
  /// **'Old password'**
  String get settingOldPassword;

  /// No description provided for @settingNewPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get settingNewPassword;

  /// No description provided for @settingConfirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get settingConfirmNewPassword;

  /// No description provided for @settingPasswordHelper.
  ///
  /// In en, this message translates to:
  /// **'Password must be 6-10 characters'**
  String get settingPasswordHelper;

  /// No description provided for @settingLogoutAllDevices.
  ///
  /// In en, this message translates to:
  /// **'Logout all devices'**
  String get settingLogoutAllDevices;

  /// No description provided for @settingRecommendedAfterPassword.
  ///
  /// In en, this message translates to:
  /// **'Recommended after changing password'**
  String get settingRecommendedAfterPassword;

  /// No description provided for @settingOldPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Old password is required'**
  String get settingOldPasswordRequired;

  /// No description provided for @settingNewPasswordLength.
  ///
  /// In en, this message translates to:
  /// **'New password must be 6-10 characters'**
  String get settingNewPasswordLength;

  /// No description provided for @settingConfirmPasswordNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Confirm password does not match'**
  String get settingConfirmPasswordNotMatch;

  /// No description provided for @settingPasswordChanged.
  ///
  /// In en, this message translates to:
  /// **'Password changed successfully'**
  String get settingPasswordChanged;

  /// No description provided for @settingLoginTokenNotFound.
  ///
  /// In en, this message translates to:
  /// **'Login token not found'**
  String get settingLoginTokenNotFound;

  /// No description provided for @settingTwoFactor.
  ///
  /// In en, this message translates to:
  /// **'Two-factor authentication (2FA)'**
  String get settingTwoFactor;

  /// No description provided for @settingTwoFactorSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extra protection for your account'**
  String get settingTwoFactorSubtitle;

  /// No description provided for @settingLoginAlerts.
  ///
  /// In en, this message translates to:
  /// **'Login alerts'**
  String get settingLoginAlerts;

  /// No description provided for @settingLoginAlertsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Notify me about new sign-ins'**
  String get settingLoginAlertsSubtitle;

  /// No description provided for @settingLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingLogout;

  /// No description provided for @settingLogoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Do you want to logout?'**
  String get settingLogoutConfirm;

  /// No description provided for @settingLogoutFailed.
  ///
  /// In en, this message translates to:
  /// **'Logout failed'**
  String get settingLogoutFailed;

  /// No description provided for @settingLoggingOut.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get settingLoggingOut;

  /// No description provided for @settingLogoutAccount.
  ///
  /// In en, this message translates to:
  /// **'Log out of this account'**
  String get settingLogoutAccount;

  /// No description provided for @settingCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingCancel;

  /// No description provided for @settingSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get settingSave;

  /// No description provided for @profilesProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profilesProfile;

  /// No description provided for @profilesRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get profilesRefresh;

  /// No description provided for @profilesEditProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profilesEditProfile;

  /// No description provided for @profilesReadingStatistics.
  ///
  /// In en, this message translates to:
  /// **'Reading Statistics'**
  String get profilesReadingStatistics;

  /// No description provided for @profilesFavoriteBooks.
  ///
  /// In en, this message translates to:
  /// **'Favorite Books'**
  String get profilesFavoriteBooks;

  /// No description provided for @profilesReadingProgress.
  ///
  /// In en, this message translates to:
  /// **'Reading Progress'**
  String get profilesReadingProgress;

  /// No description provided for @profilesInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get profilesInProgress;

  /// No description provided for @profilesNoFavoriteBooks.
  ///
  /// In en, this message translates to:
  /// **'No favorite books.'**
  String get profilesNoFavoriteBooks;

  /// No description provided for @profilesNoReadingProgress.
  ///
  /// In en, this message translates to:
  /// **'No reading progress.'**
  String get profilesNoReadingProgress;

  /// No description provided for @profilesNoName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get profilesNoName;

  /// No description provided for @profilesNoEmail.
  ///
  /// In en, this message translates to:
  /// **'No Email'**
  String get profilesNoEmail;

  /// No description provided for @profilesUserId.
  ///
  /// In en, this message translates to:
  /// **'ID: {id}'**
  String profilesUserId(Object id);

  /// No description provided for @profilesName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get profilesName;

  /// No description provided for @profilesEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profilesEmail;

  /// No description provided for @profilesUserLevel.
  ///
  /// In en, this message translates to:
  /// **'User Level'**
  String get profilesUserLevel;

  /// No description provided for @profilesCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get profilesCancel;

  /// No description provided for @profilesSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get profilesSave;

  /// No description provided for @profilesNoChangesToUpdate.
  ///
  /// In en, this message translates to:
  /// **'No changes to update'**
  String get profilesNoChangesToUpdate;

  /// No description provided for @profilesProfileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profilesProfileUpdatedSuccessfully;

  /// No description provided for @profilesTokenNotFound.
  ///
  /// In en, this message translates to:
  /// **'Token not found. Please login again.'**
  String get profilesTokenNotFound;

  /// No description provided for @profilesClickedBook.
  ///
  /// In en, this message translates to:
  /// **'Clicked: {title}'**
  String profilesClickedBook(Object title);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'km': return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
