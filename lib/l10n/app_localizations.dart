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

  /// No description provided for @settingBiometrics.
  ///
  /// In en, this message translates to:
  /// **'High Security'**
  String get settingBiometrics;

  /// No description provided for @settingBiometricsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use fingerprint or face ID to sign in securely'**
  String get settingBiometricsSubtitle;

  /// No description provided for @settingDeviceLogs.
  ///
  /// In en, this message translates to:
  /// **'Device Logs'**
  String get settingDeviceLogs;

  /// No description provided for @settingDeviceLogsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View recent devices and login activity'**
  String get settingDeviceLogsSubtitle;

  /// No description provided for @settingTwoFactorGoogleAuthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Protect your account using Google Authenticator'**
  String get settingTwoFactorGoogleAuthSubtitle;

  /// No description provided for @settingTwoFactorGoogleAuthEnabled.
  ///
  /// In en, this message translates to:
  /// **'Google Authenticator is enabled'**
  String get settingTwoFactorGoogleAuthEnabled;

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

  /// No description provided for @libraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Library'**
  String get libraryTitle;

  /// No description provided for @libraryListView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get libraryListView;

  /// No description provided for @libraryGridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get libraryGridView;

  /// No description provided for @libraryRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get libraryRefresh;

  /// No description provided for @libraryBackToTop.
  ///
  /// In en, this message translates to:
  /// **'Back To Top'**
  String get libraryBackToTop;

  /// No description provided for @libraryAllCategories.
  ///
  /// In en, this message translates to:
  /// **'All Categories'**
  String get libraryAllCategories;

  /// No description provided for @libraryAllBooks.
  ///
  /// In en, this message translates to:
  /// **'All Books'**
  String get libraryAllBooks;

  /// No description provided for @libraryBooks.
  ///
  /// In en, this message translates to:
  /// **'books'**
  String get libraryBooks;

  /// No description provided for @libraryNoBooksFound.
  ///
  /// In en, this message translates to:
  /// **'No books found.'**
  String get libraryNoBooksFound;

  /// No description provided for @librarySelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select Category'**
  String get librarySelectCategory;

  /// No description provided for @libraryChooseCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose Category'**
  String get libraryChooseCategory;

  /// No description provided for @libraryRecommendedBooks.
  ///
  /// In en, this message translates to:
  /// **'Recommended Books'**
  String get libraryRecommendedBooks;

  /// No description provided for @libraryRecommended.
  ///
  /// In en, this message translates to:
  /// **'Recommended'**
  String get libraryRecommended;

  /// No description provided for @libraryReadNow.
  ///
  /// In en, this message translates to:
  /// **'Read details'**
  String get libraryReadNow;

  /// No description provided for @libraryViewBook.
  ///
  /// In en, this message translates to:
  /// **'View book'**
  String get libraryViewBook;

  /// No description provided for @libraryLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get libraryLoadingMore;

  /// No description provided for @libraryScrollToLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll to load more'**
  String get libraryScrollToLoadMore;

  /// No description provided for @libraryNoMoreResults.
  ///
  /// In en, this message translates to:
  /// **'No more results'**
  String get libraryNoMoreResults;

  /// No description provided for @libraryUnauthenticated.
  ///
  /// In en, this message translates to:
  /// **'Unauthenticated. Please login again.'**
  String get libraryUnauthenticated;

  /// No description provided for @libraryDetailTitle.
  ///
  /// In en, this message translates to:
  /// **'Book Details'**
  String get libraryDetailTitle;

  /// No description provided for @libraryDetailRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get libraryDetailRead;

  /// No description provided for @libraryDetailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get libraryDetailCategory;

  /// No description provided for @libraryDetailTags.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get libraryDetailTags;

  /// No description provided for @libraryDetailYear.
  ///
  /// In en, this message translates to:
  /// **'Year'**
  String get libraryDetailYear;

  /// No description provided for @libraryDetailDescription.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get libraryDetailDescription;

  /// No description provided for @libraryDetailSimilarTitles.
  ///
  /// In en, this message translates to:
  /// **'Similar titles'**
  String get libraryDetailSimilarTitles;

  /// No description provided for @libraryDetailNoRecommendations.
  ///
  /// In en, this message translates to:
  /// **'No recommendations found.'**
  String get libraryDetailNoRecommendations;

  /// No description provided for @libraryDetailUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get libraryDetailUnknown;

  /// No description provided for @libraryDetailUntitled.
  ///
  /// In en, this message translates to:
  /// **'Untitled'**
  String get libraryDetailUntitled;

  /// No description provided for @libraryDetailUnknownAuthor.
  ///
  /// In en, this message translates to:
  /// **'Unknown Author'**
  String get libraryDetailUnknownAuthor;

  /// No description provided for @libraryDetailNoDescription.
  ///
  /// In en, this message translates to:
  /// **'No description available.'**
  String get libraryDetailNoDescription;

  /// No description provided for @libraryDetailBookIdNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book ID not found.'**
  String get libraryDetailBookIdNotFound;

  /// No description provided for @libraryDetailBookNotFound.
  ///
  /// In en, this message translates to:
  /// **'Book not found.'**
  String get libraryDetailBookNotFound;

  /// No description provided for @libraryDetailFailedLoad.
  ///
  /// In en, this message translates to:
  /// **'Failed to load book details.'**
  String get libraryDetailFailedLoad;

  /// No description provided for @libraryDetailFailedFavorite.
  ///
  /// In en, this message translates to:
  /// **'Failed to update favorite.'**
  String get libraryDetailFailedFavorite;

  /// No description provided for @libraryDetailAddFavorite.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get libraryDetailAddFavorite;

  /// No description provided for @libraryDetailRemoveFavorite.
  ///
  /// In en, this message translates to:
  /// **'Remove favorite'**
  String get libraryDetailRemoveFavorite;

  /// No description provided for @libraryViewSearchPdf.
  ///
  /// In en, this message translates to:
  /// **'Search ...'**
  String get libraryViewSearchPdf;

  /// No description provided for @libraryViewDownloadingPdf.
  ///
  /// In en, this message translates to:
  /// **'Downloading PDF...'**
  String get libraryViewDownloadingPdf;

  /// No description provided for @libraryViewPdfFileNotFound.
  ///
  /// In en, this message translates to:
  /// **'PDF file not found.'**
  String get libraryViewPdfFileNotFound;

  /// No description provided for @libraryViewPdfLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'PDF load failed.'**
  String get libraryViewPdfLoadFailed;

  /// No description provided for @libraryViewFailedOpenPdf.
  ///
  /// In en, this message translates to:
  /// **'Failed to open PDF.'**
  String get libraryViewFailedOpenPdf;

  /// No description provided for @libraryViewTextLayerError.
  ///
  /// In en, this message translates to:
  /// **'This PDF text layer has an error. Text selection was disabled.'**
  String get libraryViewTextLayerError;

  /// No description provided for @libraryViewSelectTextFirst.
  ///
  /// In en, this message translates to:
  /// **'Select text first.'**
  String get libraryViewSelectTextFirst;

  /// No description provided for @libraryViewNoteSaved.
  ///
  /// In en, this message translates to:
  /// **'Note saved.'**
  String get libraryViewNoteSaved;

  /// No description provided for @libraryViewUnderlineSaved.
  ///
  /// In en, this message translates to:
  /// **'Underline saved.'**
  String get libraryViewUnderlineSaved;

  /// No description provided for @libraryViewStrikethroughSaved.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough saved.'**
  String get libraryViewStrikethroughSaved;

  /// No description provided for @libraryViewSquigglySaved.
  ///
  /// In en, this message translates to:
  /// **'Squiggly saved.'**
  String get libraryViewSquigglySaved;

  /// No description provided for @libraryViewHighlightSaved.
  ///
  /// In en, this message translates to:
  /// **'Highlight saved.'**
  String get libraryViewHighlightSaved;

  /// No description provided for @libraryViewSavedLocalSyncFailed.
  ///
  /// In en, this message translates to:
  /// **'Saved locally, but failed to sync.'**
  String get libraryViewSavedLocalSyncFailed;

  /// No description provided for @libraryViewFailedDelete.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete.'**
  String get libraryViewFailedDelete;

  /// No description provided for @libraryViewJumpToPage.
  ///
  /// In en, this message translates to:
  /// **'Jump to page'**
  String get libraryViewJumpToPage;

  /// No description provided for @libraryViewCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get libraryViewCancel;

  /// No description provided for @libraryViewGo.
  ///
  /// In en, this message translates to:
  /// **'Go'**
  String get libraryViewGo;

  /// No description provided for @libraryViewInvalidPageNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid page number'**
  String get libraryViewInvalidPageNumber;

  /// No description provided for @libraryViewBookmarks.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get libraryViewBookmarks;

  /// No description provided for @libraryViewNoBookmarks.
  ///
  /// In en, this message translates to:
  /// **'No bookmarks yet.'**
  String get libraryViewNoBookmarks;

  /// No description provided for @libraryViewPage.
  ///
  /// In en, this message translates to:
  /// **'Page'**
  String get libraryViewPage;

  /// No description provided for @libraryViewPageNotes.
  ///
  /// In en, this message translates to:
  /// **'Page notes'**
  String get libraryViewPageNotes;

  /// No description provided for @libraryViewNotesHighlights.
  ///
  /// In en, this message translates to:
  /// **'Notes / Highlights'**
  String get libraryViewNotesHighlights;

  /// No description provided for @libraryViewAllNotesHighlights.
  ///
  /// In en, this message translates to:
  /// **'All notes / highlights'**
  String get libraryViewAllNotesHighlights;

  /// No description provided for @libraryViewNoNotes.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Select text in PDF to add one.'**
  String get libraryViewNoNotes;

  /// No description provided for @libraryViewReload.
  ///
  /// In en, this message translates to:
  /// **'Reload'**
  String get libraryViewReload;

  /// No description provided for @libraryViewDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get libraryViewDelete;

  /// No description provided for @libraryViewLightReader.
  ///
  /// In en, this message translates to:
  /// **'Light reader'**
  String get libraryViewLightReader;

  /// No description provided for @libraryViewDarkReader.
  ///
  /// In en, this message translates to:
  /// **'Dark reader'**
  String get libraryViewDarkReader;

  /// No description provided for @libraryViewClearCacheReload.
  ///
  /// In en, this message translates to:
  /// **'Clear cache and reload'**
  String get libraryViewClearCacheReload;

  /// No description provided for @libraryViewHighlight.
  ///
  /// In en, this message translates to:
  /// **'Highlight'**
  String get libraryViewHighlight;

  /// No description provided for @libraryViewUnderline.
  ///
  /// In en, this message translates to:
  /// **'Underline'**
  String get libraryViewUnderline;

  /// No description provided for @libraryViewStrike.
  ///
  /// In en, this message translates to:
  /// **'Strike'**
  String get libraryViewStrike;

  /// No description provided for @libraryViewSquiggly.
  ///
  /// In en, this message translates to:
  /// **'Squiggly'**
  String get libraryViewSquiggly;

  /// No description provided for @libraryViewNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get libraryViewNote;

  /// No description provided for @libraryViewWriteNote.
  ///
  /// In en, this message translates to:
  /// **'Write note...'**
  String get libraryViewWriteNote;

  /// No description provided for @libraryViewSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get libraryViewSave;

  /// No description provided for @libraryViewNotesHighlightsLower.
  ///
  /// In en, this message translates to:
  /// **'notes / highlights'**
  String get libraryViewNotesHighlightsLower;

  /// No description provided for @searchTitle.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get searchTitle;

  /// No description provided for @searchBackToTop.
  ///
  /// In en, this message translates to:
  /// **'Back to top'**
  String get searchBackToTop;

  /// No description provided for @searchListView.
  ///
  /// In en, this message translates to:
  /// **'List view'**
  String get searchListView;

  /// No description provided for @searchGridView.
  ///
  /// In en, this message translates to:
  /// **'Grid view'**
  String get searchGridView;

  /// No description provided for @searchRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get searchRefresh;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search title, author, category, tags, year'**
  String get searchHint;

  /// No description provided for @searchBestMatch.
  ///
  /// In en, this message translates to:
  /// **'Best Match'**
  String get searchBestMatch;

  /// No description provided for @searchMostPopular.
  ///
  /// In en, this message translates to:
  /// **'Most Popular'**
  String get searchMostPopular;

  /// No description provided for @searchNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get searchNewest;

  /// No description provided for @searchTrendingSearches.
  ///
  /// In en, this message translates to:
  /// **'Trending Searches'**
  String get searchTrendingSearches;

  /// No description provided for @searchResultsCount.
  ///
  /// In en, this message translates to:
  /// **'Search Results: {visible} / {total}'**
  String searchResultsCount(Object visible, Object total);

  /// No description provided for @searchSuggestedBooksCount.
  ///
  /// In en, this message translates to:
  /// **'Suggested Books: {count}'**
  String searchSuggestedBooksCount(Object count);

  /// No description provided for @searchRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get searchRetry;

  /// No description provided for @searchNoSuggestedBooksFound.
  ///
  /// In en, this message translates to:
  /// **'No suggested books found'**
  String get searchNoSuggestedBooksFound;

  /// No description provided for @searchNoResultsFor.
  ///
  /// In en, this message translates to:
  /// **'No results for \"{query}\"'**
  String searchNoResultsFor(Object query);

  /// No description provided for @searchTryAnotherKeyword.
  ///
  /// In en, this message translates to:
  /// **'Try another keyword or refresh the page.'**
  String get searchTryAnotherKeyword;

  /// No description provided for @searchLoadingMore.
  ///
  /// In en, this message translates to:
  /// **'Loading more...'**
  String get searchLoadingMore;

  /// No description provided for @searchScrollToLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Scroll to load more'**
  String get searchScrollToLoadMore;

  /// No description provided for @searchNoMoreResults.
  ///
  /// In en, this message translates to:
  /// **'No more results'**
  String get searchNoMoreResults;

  /// No description provided for @searchImageNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'Image\nnot available'**
  String get searchImageNotAvailable;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationsDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Notification'**
  String get notificationsDefaultTitle;

  /// No description provided for @notificationsAllCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get notificationsAllCaughtUp;

  /// No description provided for @notificationsUnread.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String notificationsUnread(Object count);

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get notificationsClearAll;

  /// No description provided for @notificationsMarkedAllRead.
  ///
  /// In en, this message translates to:
  /// **'All notifications marked as read'**
  String get notificationsMarkedAllRead;

  /// No description provided for @notificationsCleared.
  ///
  /// In en, this message translates to:
  /// **'Notifications cleared'**
  String get notificationsCleared;

  /// No description provided for @notificationsActionFailed.
  ///
  /// In en, this message translates to:
  /// **'Action failed. Please try again.'**
  String get notificationsActionFailed;

  /// No description provided for @notificationsConnectionError.
  ///
  /// In en, this message translates to:
  /// **'Please check your internet connection and try again.'**
  String get notificationsConnectionError;

  /// No description provided for @notificationsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmptyTitle;

  /// No description provided for @notificationsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'New updates and alerts will appear here.'**
  String get notificationsEmptySubtitle;

  /// No description provided for @notificationsUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load notifications'**
  String get notificationsUnableToLoad;

  /// No description provided for @notificationsRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get notificationsRetry;

  /// No description provided for @notificationsJustNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notificationsJustNow;

  /// No description provided for @notificationsMinAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String notificationsMinAgo(Object count);

  /// No description provided for @notificationsHourAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} hour ago'**
  String notificationsHourAgo(Object count);

  /// No description provided for @notificationsDayAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} day ago'**
  String notificationsDayAgo(Object count);

  /// No description provided for @continueReadingAction.
  ///
  /// In en, this message translates to:
  /// **'Reading'**
  String get continueReadingAction;

  /// No description provided for @favoritesScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesScreenTitle;

  /// No description provided for @favoritesScreenNoCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get favoritesScreenNoCategory;

  /// No description provided for @favoritesScreenViews.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get favoritesScreenViews;

  /// No description provided for @favoritesScreenViewDetail.
  ///
  /// In en, this message translates to:
  /// **'View details'**
  String get favoritesScreenViewDetail;

  /// No description provided for @favoritesScreenNoFavoriteBooks.
  ///
  /// In en, this message translates to:
  /// **'No favorite books'**
  String get favoritesScreenNoFavoriteBooks;

  /// No description provided for @favoritesScreenRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get favoritesScreenRetry;

  /// No description provided for @favoritesScreenRemoveFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites?'**
  String get favoritesScreenRemoveFromFavorites;

  /// No description provided for @favoritesScreenCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get favoritesScreenCancel;

  /// No description provided for @favoritesScreenRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get favoritesScreenRemove;

  /// No description provided for @favoritesScreenRemoved.
  ///
  /// In en, this message translates to:
  /// **'removed'**
  String get favoritesScreenRemoved;

  /// No description provided for @favoritesScreenFailedToLoadFavorites.
  ///
  /// In en, this message translates to:
  /// **'Failed to load favorites'**
  String get favoritesScreenFailedToLoadFavorites;

  /// No description provided for @favoritesScreenRemoveFailed.
  ///
  /// In en, this message translates to:
  /// **'Remove failed'**
  String get favoritesScreenRemoveFailed;

  /// No description provided for @favoritesScreenUnableLoadData.
  ///
  /// In en, this message translates to:
  /// **'Unable to load data. Please check your internet connection.'**
  String get favoritesScreenUnableLoadData;

  /// No description provided for @homeAppTitle.
  ///
  /// In en, this message translates to:
  /// **'PAC E-Library'**
  String get homeAppTitle;

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read, learn, and continue anywhere'**
  String get homeSubtitle;

  /// No description provided for @homeContinueReading.
  ///
  /// In en, this message translates to:
  /// **'Continue Reading'**
  String get homeContinueReading;

  /// No description provided for @homeReading.
  ///
  /// In en, this message translates to:
  /// **'reading'**
  String get homeReading;

  /// No description provided for @homeFavorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get homeFavorites;

  /// No description provided for @homeSavedBooks.
  ///
  /// In en, this message translates to:
  /// **'Saved books'**
  String get homeSavedBooks;

  /// No description provided for @homeRecommendedBooks.
  ///
  /// In en, this message translates to:
  /// **'Recommended Books'**
  String get homeRecommendedBooks;

  /// No description provided for @homePickedForYou.
  ///
  /// In en, this message translates to:
  /// **'Picked for you'**
  String get homePickedForYou;

  /// No description provided for @homePopularBooks.
  ///
  /// In en, this message translates to:
  /// **'Popular Books'**
  String get homePopularBooks;

  /// No description provided for @homeMostReadBooks.
  ///
  /// In en, this message translates to:
  /// **'Most read books'**
  String get homeMostReadBooks;

  /// No description provided for @homeNewReleases.
  ///
  /// In en, this message translates to:
  /// **'New Releases'**
  String get homeNewReleases;

  /// No description provided for @homeRecentlyAdded.
  ///
  /// In en, this message translates to:
  /// **'Recently added'**
  String get homeRecentlyAdded;

  /// No description provided for @homeNoCategory.
  ///
  /// In en, this message translates to:
  /// **'No Category'**
  String get homeNoCategory;

  /// No description provided for @homeViews.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get homeViews;

  /// No description provided for @homeGoodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get homeGoodMorning;

  /// No description provided for @homeGoodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get homeGoodAfternoon;

  /// No description provided for @homeGoodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get homeGoodEvening;

  /// No description provided for @homeUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load home'**
  String get homeUnableToLoad;

  /// No description provided for @homeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get homeTryAgain;

  /// No description provided for @homeStartReading.
  ///
  /// In en, this message translates to:
  /// **'Start reading and continue your learning journey.'**
  String get homeStartReading;

  /// No description provided for @homeBooksInProgress.
  ///
  /// In en, this message translates to:
  /// **'{count} books in progress.'**
  String homeBooksInProgress(int count);

  /// No description provided for @homeFavoriteUpdated.
  ///
  /// In en, this message translates to:
  /// **'{title} favorite updated'**
  String homeFavoriteUpdated(String title);

  /// No description provided for @deviceLogsTitle.
  ///
  /// In en, this message translates to:
  /// **'Device Logs'**
  String get deviceLogsTitle;

  /// No description provided for @deviceLogsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get deviceLogsRefresh;

  /// No description provided for @deviceLogsHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review devices that recently accessed your account.'**
  String get deviceLogsHeaderSubtitle;

  /// No description provided for @deviceLogsUnableToLoad.
  ///
  /// In en, this message translates to:
  /// **'Unable to load device logs'**
  String get deviceLogsUnableToLoad;

  /// No description provided for @deviceLogsInternetError.
  ///
  /// In en, this message translates to:
  /// **'Error Internet'**
  String get deviceLogsInternetError;

  /// No description provided for @deviceLogsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get deviceLogsTryAgain;

  /// No description provided for @deviceLogsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No device logs'**
  String get deviceLogsEmptyTitle;

  /// No description provided for @deviceLogsEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your login devices will appear here.'**
  String get deviceLogsEmptySubtitle;

  /// No description provided for @deviceLogsUnknownDevice.
  ///
  /// In en, this message translates to:
  /// **'Unknown Device'**
  String get deviceLogsUnknownDevice;

  /// No description provided for @deviceLogsUnknownApp.
  ///
  /// In en, this message translates to:
  /// **'Unknown app'**
  String get deviceLogsUnknownApp;

  /// No description provided for @deviceLogsUnknownLocation.
  ///
  /// In en, this message translates to:
  /// **'Unknown location'**
  String get deviceLogsUnknownLocation;

  /// No description provided for @deviceLogsCurrent.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get deviceLogsCurrent;

  /// No description provided for @deviceLogsIp.
  ///
  /// In en, this message translates to:
  /// **'IP'**
  String get deviceLogsIp;
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
