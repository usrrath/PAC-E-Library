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
  String get settingBiometrics => 'High Security';

  @override
  String get settingBiometricsSubtitle => 'Use fingerprint or face ID to sign in securely';

  @override
  String get settingDeviceLogs => 'Device Logs';

  @override
  String get settingDeviceLogsSubtitle => 'View recent devices and login activity';

  @override
  String get settingTwoFactorGoogleAuthSubtitle => 'Protect your account using Google Authenticator';

  @override
  String get settingTwoFactorGoogleAuthEnabled => 'Google Authenticator is enabled';

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

  @override
  String get libraryTitle => 'Library';

  @override
  String get libraryListView => 'List view';

  @override
  String get libraryGridView => 'Grid view';

  @override
  String get libraryRefresh => 'Refresh';

  @override
  String get libraryBackToTop => 'Back To Top';

  @override
  String get libraryAllCategories => 'All Categories';

  @override
  String get libraryAllBooks => 'All Books';

  @override
  String get libraryBooks => 'books';

  @override
  String get libraryNoBooksFound => 'No books found.';

  @override
  String get librarySelectCategory => 'Select Category';

  @override
  String get libraryChooseCategory => 'Choose Category';

  @override
  String get libraryRecommendedBooks => 'Recommended Books';

  @override
  String get libraryRecommended => 'Recommended';

  @override
  String get libraryReadNow => 'Read details';

  @override
  String get libraryViewBook => 'View book';

  @override
  String get libraryLoadingMore => 'Loading more...';

  @override
  String get libraryScrollToLoadMore => 'Scroll to load more';

  @override
  String get libraryNoMoreResults => 'No more results';

  @override
  String get libraryUnauthenticated => 'Unauthenticated. Please login again.';

  @override
  String get libraryDetailTitle => 'Book Details';

  @override
  String get libraryDetailRead => 'Read';

  @override
  String get libraryDetailCategory => 'Category';

  @override
  String get libraryDetailTags => 'Tags';

  @override
  String get libraryDetailYear => 'Year';

  @override
  String get libraryDetailDescription => 'Description';

  @override
  String get libraryDetailSimilarTitles => 'Similar titles';

  @override
  String get libraryDetailNoRecommendations => 'No recommendations found.';

  @override
  String get libraryDetailUnknown => 'Unknown';

  @override
  String get libraryDetailUntitled => 'Untitled';

  @override
  String get libraryDetailUnknownAuthor => 'Unknown Author';

  @override
  String get libraryDetailNoDescription => 'No description available.';

  @override
  String get libraryDetailBookIdNotFound => 'Book ID not found.';

  @override
  String get libraryDetailBookNotFound => 'Book not found.';

  @override
  String get libraryDetailFailedLoad => 'Failed to load book details.';

  @override
  String get libraryDetailFailedFavorite => 'Failed to update favorite.';

  @override
  String get libraryDetailAddFavorite => 'Add to favorites';

  @override
  String get libraryDetailRemoveFavorite => 'Remove favorite';

  @override
  String get libraryViewSearchPdf => 'Search ...';

  @override
  String get libraryViewDownloadingPdf => 'Downloading PDF...';

  @override
  String get libraryViewPdfFileNotFound => 'PDF file not found.';

  @override
  String get libraryViewPdfLoadFailed => 'PDF load failed.';

  @override
  String get libraryViewFailedOpenPdf => 'Failed to open PDF.';

  @override
  String get libraryViewTextLayerError => 'This PDF text layer has an error. Text selection was disabled.';

  @override
  String get libraryViewSelectTextFirst => 'Select text first.';

  @override
  String get libraryViewNoteSaved => 'Note saved.';

  @override
  String get libraryViewUnderlineSaved => 'Underline saved.';

  @override
  String get libraryViewStrikethroughSaved => 'Strikethrough saved.';

  @override
  String get libraryViewSquigglySaved => 'Squiggly saved.';

  @override
  String get libraryViewHighlightSaved => 'Highlight saved.';

  @override
  String get libraryViewSavedLocalSyncFailed => 'Saved locally, but failed to sync.';

  @override
  String get libraryViewFailedDelete => 'Failed to delete.';

  @override
  String get libraryViewJumpToPage => 'Jump to page';

  @override
  String get libraryViewCancel => 'Cancel';

  @override
  String get libraryViewGo => 'Go';

  @override
  String get libraryViewInvalidPageNumber => 'Invalid page number';

  @override
  String get libraryViewBookmarks => 'Bookmarks';

  @override
  String get libraryViewNoBookmarks => 'No bookmarks yet.';

  @override
  String get libraryViewPage => 'Page';

  @override
  String get libraryViewPageNotes => 'Page notes';

  @override
  String get libraryViewNotesHighlights => 'Notes / Highlights';

  @override
  String get libraryViewAllNotesHighlights => 'All notes / highlights';

  @override
  String get libraryViewNoNotes => 'No notes yet. Select text in PDF to add one.';

  @override
  String get libraryViewReload => 'Reload';

  @override
  String get libraryViewDelete => 'Delete';

  @override
  String get libraryViewLightReader => 'Light reader';

  @override
  String get libraryViewDarkReader => 'Dark reader';

  @override
  String get libraryViewClearCacheReload => 'Clear cache and reload';

  @override
  String get libraryViewHighlight => 'Highlight';

  @override
  String get libraryViewUnderline => 'Underline';

  @override
  String get libraryViewStrike => 'Strike';

  @override
  String get libraryViewSquiggly => 'Squiggly';

  @override
  String get libraryViewNote => 'Note';

  @override
  String get libraryViewWriteNote => 'Write note...';

  @override
  String get libraryViewSave => 'Save';

  @override
  String get libraryViewNotesHighlightsLower => 'notes / highlights';

  @override
  String get searchTitle => 'Search';

  @override
  String get searchBackToTop => 'Back to top';

  @override
  String get searchListView => 'List view';

  @override
  String get searchGridView => 'Grid view';

  @override
  String get searchRefresh => 'Refresh';

  @override
  String get searchHint => 'Search title, author, category, tags, year';

  @override
  String get searchBestMatch => 'Best Match';

  @override
  String get searchMostPopular => 'Most Popular';

  @override
  String get searchNewest => 'Newest';

  @override
  String get searchTrendingSearches => 'Trending Searches';

  @override
  String searchResultsCount(Object visible, Object total) {
    return 'Search Results: $visible / $total';
  }

  @override
  String searchSuggestedBooksCount(Object count) {
    return 'Suggested Books: $count';
  }

  @override
  String get searchRetry => 'Retry';

  @override
  String get searchNoSuggestedBooksFound => 'No suggested books found';

  @override
  String searchNoResultsFor(Object query) {
    return 'No results for \"$query\"';
  }

  @override
  String get searchTryAnotherKeyword => 'Try another keyword or refresh the page.';

  @override
  String get searchLoadingMore => 'Loading more...';

  @override
  String get searchScrollToLoadMore => 'Scroll to load more';

  @override
  String get searchNoMoreResults => 'No more results';

  @override
  String get searchImageNotAvailable => 'Image\nnot available';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationsDefaultTitle => 'Notification';

  @override
  String get notificationsAllCaughtUp => 'All caught up';

  @override
  String notificationsUnread(Object count) {
    return '$count unread';
  }

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsClearAll => 'Clear all';

  @override
  String get notificationsMarkedAllRead => 'All notifications marked as read';

  @override
  String get notificationsCleared => 'Notifications cleared';

  @override
  String get notificationsActionFailed => 'Action failed. Please try again.';

  @override
  String get notificationsConnectionError => 'Please check your internet connection and try again.';

  @override
  String get notificationsEmptyTitle => 'No notifications';

  @override
  String get notificationsEmptySubtitle => 'New updates and alerts will appear here.';

  @override
  String get notificationsUnableToLoad => 'Unable to load notifications';

  @override
  String get notificationsRetry => 'Retry';

  @override
  String get notificationsJustNow => 'Just now';

  @override
  String notificationsMinAgo(Object count) {
    return '$count min ago';
  }

  @override
  String notificationsHourAgo(Object count) {
    return '$count hour ago';
  }

  @override
  String notificationsDayAgo(Object count) {
    return '$count day ago';
  }

  @override
  String get continueReadingAction => 'Reading';

  @override
  String get favoritesScreenTitle => 'Favorites';

  @override
  String get favoritesScreenNoCategory => 'No category';

  @override
  String get favoritesScreenViews => 'views';

  @override
  String get favoritesScreenViewDetail => 'View details';

  @override
  String get favoritesScreenNoFavoriteBooks => 'No favorite books';

  @override
  String get favoritesScreenRetry => 'Retry';

  @override
  String get favoritesScreenRemoveFromFavorites => 'Remove from favorites?';

  @override
  String get favoritesScreenCancel => 'Cancel';

  @override
  String get favoritesScreenRemove => 'Remove';

  @override
  String get favoritesScreenRemoved => 'removed';

  @override
  String get favoritesScreenFailedToLoadFavorites => 'Failed to load favorites';

  @override
  String get favoritesScreenRemoveFailed => 'Remove failed';

  @override
  String get favoritesScreenUnableLoadData => 'Unable to load data. Please check your internet connection.';

  @override
  String get homeAppTitle => 'PAC E-Library';

  @override
  String get homeSubtitle => 'Read, learn, and continue anywhere';

  @override
  String get homeContinueReading => 'Continue Reading';

  @override
  String get homeReading => 'reading';

  @override
  String get homeFavorites => 'Favorites';

  @override
  String get homeSavedBooks => 'Saved books';

  @override
  String get homeRecommendedBooks => 'Recommended Books';

  @override
  String get homePickedForYou => 'Picked for you';

  @override
  String get homePopularBooks => 'Popular Books';

  @override
  String get homeMostReadBooks => 'Most read books';

  @override
  String get homeNewReleases => 'New Releases';

  @override
  String get homeRecentlyAdded => 'Recently added';

  @override
  String get homeNoCategory => 'No Category';

  @override
  String get homeViews => 'views';

  @override
  String get homeGoodMorning => 'Good morning';

  @override
  String get homeGoodAfternoon => 'Good afternoon';

  @override
  String get homeGoodEvening => 'Good evening';

  @override
  String get homeUnableToLoad => 'Unable to load home';

  @override
  String get homeTryAgain => 'Try again';

  @override
  String get homeStartReading => 'Start reading and continue your learning journey.';

  @override
  String homeBooksInProgress(int count) {
    return '$count books in progress.';
  }

  @override
  String homeFavoriteUpdated(String title) {
    return '$title favorite updated';
  }

  @override
  String get deviceLogsTitle => 'Device Logs';

  @override
  String get deviceLogsRefresh => 'Refresh';

  @override
  String get deviceLogsHeaderSubtitle => 'Review devices that recently accessed your account.';

  @override
  String get deviceLogsUnableToLoad => 'Unable to load device logs';

  @override
  String get deviceLogsInternetError => 'Error Internet';

  @override
  String get deviceLogsTryAgain => 'Try again';

  @override
  String get deviceLogsEmptyTitle => 'No device logs';

  @override
  String get deviceLogsEmptySubtitle => 'Your login devices will appear here.';

  @override
  String get deviceLogsUnknownDevice => 'Unknown Device';

  @override
  String get deviceLogsUnknownApp => 'Unknown app';

  @override
  String get deviceLogsUnknownLocation => 'Unknown location';

  @override
  String get deviceLogsCurrent => 'Current';

  @override
  String get deviceLogsIp => 'IP';
}
