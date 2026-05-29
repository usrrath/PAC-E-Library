import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/home_models.dart';
import '../models/library_models.dart';
import '../models/success_user.dart';
import '../services/home_service.dart';
import '../services/library_detail_service.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';
import '../widgets/home_widgets.dart';
import 'continue_reading_screen.dart';
import 'favorites_screen.dart';
import 'library_detail_screen.dart';
import 'notifications_screen.dart';


class HomeScreen extends StatefulWidget {
  final SuccessUser? successUser;

  const HomeScreen({
    super.key,
    this.successUser,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeService _homeService = HomeService();
  final UserService _userService = UserService();
  final LibraryDetailService _detailService = LibraryDetailService();

  bool loading = true;
  String? error;

  List<HomeBook> recommended = [];
  List<HomeBook> popular = [];
  List<HomeBook> newReleases = [];
  List<HomeNotification> notifications = [];
  List<Map<String, dynamic>> progress = [];
  List<Book> detailBooks = [];

  String userName = 'Reader';

  @override
  void initState() {
    super.initState();
    _loadUserName();
    loadHome();
  }

  Future<void> _loadUserName() async {
    final localName = _extractUserName(widget.successUser);

    if (localName.isNotEmpty) {
      if (mounted) setState(() => userName = localName);
      return;
    }

    try {
      final token = await _token();
      if (token.isEmpty) return;

      final verify = await _userService.getVerifyAccount(token);
      final verifyName = _extractNameFromAny(verify);

      if (verifyName.isNotEmpty) {
        if (mounted) setState(() => userName = verifyName);
        return;
      }

      final profile = await _userService.getProfile(token);
      final profileName = _extractNameFromAny(profile);

      if (profileName.isNotEmpty && mounted) {
        setState(() => userName = profileName);
      }
    } catch (_) {}
  }

  Future<String> _token() async {
    final token = widget.successUser?.token.trim() ?? '';
    if (token.isNotEmpty) return token;

    return (await ProfileService.getToken())?.trim() ?? '';
  }

  Future<void> loadHome() async {
    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final data = await _homeService.loadHome();

      final rec = data.recommended;
      final pop = data.popular;
      final news = data.newReleases;

      pop.sort((a, b) => b.viewsCount.compareTo(a.viewsCount));

      if (!mounted) return;

      setState(() {
        recommended = rec;
        popular = pop;
        newReleases = news;
        notifications = data.notifications;
        progress = data.progress;
        detailBooks = _buildDetailBooks([
          ...rec,
          ...pop,
          ...news,
        ]);
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        error = _friendlyError(e);
        loading = false;
      });
    }
  }

  List<Book> _buildDetailBooks(List<HomeBook> books) {
    final map = <String, Book>{};

    for (final book in books) {
      if (book.id.trim().isEmpty) continue;
      map[book.id] = book.toDetailBook(_detailService);
    }

    return map.values.toList();
  }

  Future<void> _toggleFavorite(HomeBook book) async {
    if (book.id.trim().isEmpty) return;

    try {
      await _homeService.toggleFavorite(book.id);
      await loadHome();

      if (!mounted) return;

      final t = AppLocalizations.of(context)!;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.homeFavoriteUpdated(book.title)),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    }
  }

  void _openBook(HomeBook homeBook) {
    final book = detailBooks.firstWhere(
          (e) => e.id == homeBook.id,
      orElse: () => homeBook.toDetailBook(_detailService),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LibraryDetailScreen(
          book: book,
          allBooks: detailBooks,
        ),
      ),
    );
  }

  Future<void> _openNotifications() async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const NotificationsScreen(),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await loadHome();
    }
  }

  void _open(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  int get unreadCount => notifications.where((e) => !e.read).length;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: loadHome,
          child: loading
              ? const Center(child: CircularProgressIndicator())
              : error != null
              ? HomeError(
            message: error!,
            onRetry: loadHome,
          )
              : ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              HomeTopBar(
                unreadCount: unreadCount,
                onNotifications: _openNotifications,
              ),
              const SizedBox(height: 18),

              HomeHeroCard(
                userName: userName,
                progressCount: progress.length,
              ),
              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: HomeQuickCard(
                      title: t.homeContinueReading,
                      subtitle: '${progress.length} ${t.homeReading}',
                      icon: Icons.play_circle_outline_rounded,
                      onTap: () => _open(
                        const ContinueReadingScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: HomeQuickCard(
                      title: t.homeFavorites,
                      subtitle: t.homeSavedBooks,
                      icon: Icons.favorite_border_rounded,
                      onTap: () => _open(
                        const FavoritesScreen(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              HomeBookSection(
                title: t.homeRecommendedBooks,
                subtitle: t.homePickedForYou,
                books: recommended,
                onTap: _openBook,
                onFavorite: _toggleFavorite,
              ),
              const SizedBox(height: 22),

              HomeBookSection(
                title: t.homePopularBooks,
                subtitle: t.homeMostReadBooks,
                books: popular,
                onTap: _openBook,
                onFavorite: _toggleFavorite,
              ),
              const SizedBox(height: 22),

              HomeBookSection(
                title: t.homeNewReleases,
                subtitle: t.homeRecentlyAdded,
                books: newReleases,
                onTap: _openBook,
                onFavorite: _toggleFavorite,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractUserName(SuccessUser? successUser) {
    if (successUser == null) return '';
    return _extractNameFromAny(successUser.user.toJson());
  }

  String _extractNameFromAny(dynamic value) {
    if (value == null) return '';

    if (value is Map) {
      final map = Map<String, dynamic>.from(value);

      for (final key in [
        'name',
        'username',
        'full_name',
        'display_name',
      ]) {
        final text = map[key]?.toString().trim() ?? '';
        if (text.isNotEmpty) return text;
      }

      for (final key in [
        'user',
        'data',
        'account',
        'profile',
      ]) {
        final nestedName = _extractNameFromAny(map[key]);
        if (nestedName.isNotEmpty) return nestedName;
      }
    }

    return '';
  }

  String _friendlyError(Object error) {
    final text = error.toString().toLowerCase();

    if (text.contains('socketexception') ||
        text.contains('clientexception') ||
        text.contains('network is unreachable') ||
        text.contains('failed host lookup') ||
        text.contains('connection failed') ||
        text.contains('connection refused')) {
      return 'Error Internet';
    }

    return error.toString().replaceFirst('Exception: ', '');
  }
}