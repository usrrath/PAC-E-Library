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
    // return 'Suggested Books: $count';
    return 'Suggested Books';
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
}
