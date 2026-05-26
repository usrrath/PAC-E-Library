import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/library_models.dart';
import '../models/success_user.dart';
import '../services/library_detail_service.dart';
import '../services/library_service.dart';
import '../services/profile_service.dart';
import '../services/user_service.dart';
import '../utils/library_utils.dart';
import '../widgets/library_widgets.dart';
import 'library_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final SuccessUser? successUser;

  const LibraryScreen({
    super.key,
    this.successUser,
  });

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const int allCategoryId = 0;
  static const int perPage = 12;

  final UserService _userService = UserService();
  final LibraryDetailService _detailService = LibraryDetailService();
  final ScrollController _scrollCtrl = ScrollController();

  final List<CategoryModel> categories = [];
  final List<Book> books = [];
  final List<Book> recommendedBooks = [];

  bool showScrollTop = false;
  bool isGrid = false;
  bool isFirstLoading = true;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isLoadingRecommended = true;

  int page = 1;
  int selectedCategoryId = allCategoryId;
  bool hasMore = true;

  String search = '';
  String? errorMessage;
  String _token = '';

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    unawaited(_loadInitial());
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadToken() async {
    final widgetToken = widget.successUser?.token.trim() ?? '';
    final savedToken = (await ProfileService.getToken())?.trim() ?? '';

    _token = widgetToken.isNotEmpty ? widgetToken : savedToken;
  }

  Future<void> _loadInitial() async {
    if (!mounted) return;

    setState(() {
      isFirstLoading = true;
      errorMessage = null;
    });

    try {
      await _loadToken();

      if (_token.isEmpty) {
        throw Exception('Unauthenticated. Please login again.');
      }

      await Future.wait([
        _fetchCategories(),
        _fetchRecommendedBooks(),
        _fetchBooks(reset: true),
      ]);
    } catch (e) {
      errorMessage = cleanError(e);
    }

    if (!mounted) return;

    setState(() {
      isFirstLoading = false;
    });
  }

  Future<void> _refresh() async {
    if (isRefreshing) return;

    await _scrollToTop();

    if (!mounted) return;

    setState(() {
      isRefreshing = true;
      errorMessage = null;
    });

    try {
      await _loadToken();

      if (_token.isEmpty) {
        throw Exception('Unauthenticated. Please login again.');
      }

      await Future.wait([
        _fetchCategories(),
        _fetchRecommendedBooks(),
        _fetchBooks(reset: true),
      ]);
    } catch (e) {
      errorMessage = cleanError(e);
    }

    if (!mounted) return;

    setState(() {
      isRefreshing = false;
    });
  }

  Future<void> _fetchCategories() async {
    final response = await _userService.getCategories(token: _token);

    final loaded = extractList(response)
        .whereType<Map>()
        .map((e) => CategoryModel.fromJson(Map<String, dynamic>.from(e)))
        .where((e) => e.id > 0)
        .toList();

    if (!mounted) return;

    setState(() {
      categories
        ..clear()
        ..add(const CategoryModel(id: allCategoryId, name: ''))
        ..addAll(loaded);
    });
  }

  Future<void> _fetchBooks({required bool reset}) async {
    if (reset) {
      page = 1;
      hasMore = true;
      books.clear();
    }

    final response = await _userService.getItems(
      token: _token,
      page: page,
      perPage: perPage,
      categoryId: selectedCategoryId,
      search: search,
      filter: 'all',
    );

    final parsed = extractList(response)
        .whereType<Map>()
        .map((e) {
      return Book.fromJson(
        Map<String, dynamic>.from(e),
        _detailService,
      );
    })
        .where((e) => e.id.isNotEmpty)
        .toList();

    final loaded = await _withViewCounts(parsed);

    loaded.sort(_sortByViewsAndYearDesc);

    final meta = extractMeta(response);
    final currentPage = intValue(meta['current_page']) ?? page;
    final lastPage = intValue(meta['last_page']);

    if (!mounted) return;

    setState(() {
      books.addAll(loaded);

      books.sort(_sortByViewsAndYearDesc);

      hasMore = lastPage != null
          ? currentPage < lastPage
          : loaded.length >= perPage;
    });
  }

  Future<void> _fetchRecommendedBooks() async {
    if (mounted) {
      setState(() {
        isLoadingRecommended = true;
      });
    }

    try {
      final response = await _userService.getRecommendedBooks(
        token: _token,
        limit: 8,
      );

      final parsed = extractList(response)
          .whereType<Map>()
          .map((e) {
        return Book.fromJson(
          Map<String, dynamic>.from(e),
          _detailService,
        );
      })
          .where((e) => e.id.isNotEmpty)
          .toList();

      final loaded = await _withViewCounts(parsed);

      loaded.sort(_sortByViewsAndYearDesc);

      if (!mounted) return;

      setState(() {
        recommendedBooks
          ..clear()
          ..addAll(loaded);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        recommendedBooks.clear();
      });
    }

    if (!mounted) return;

    setState(() {
      isLoadingRecommended = false;
    });
  }

  int _sortByViewsAndYearDesc(Book a, Book b) {
    final viewCompare = b.viewCount.compareTo(a.viewCount);
    if (viewCompare != 0) return viewCompare;

    final yearA = _yearValue(a.publishYear);
    final yearB = _yearValue(b.publishYear);

    return yearB.compareTo(yearA);
  }

  int _yearValue(String value) {
    final text = value.trim();

    if (text.isEmpty) return 0;

    final match = RegExp(r'\d{4}').firstMatch(text);

    if (match == null) return 0;

    return int.tryParse(match.group(0) ?? '') ?? 0;
  }

  Future<List<Book>> _withViewCounts(List<Book> items) async {
    final result = <Book>[];

    for (final book in items) {
      try {
        final response = await _userService.getBookViewsCount(
          token: _token,
          bookId: book.id,
        );

        final count = _readViewCountResponse(response);

        result.add(
          book.copyWith(
            viewCount: count > 0 ? count : book.viewCount,
          ),
        );
      } catch (_) {
        result.add(book);
      }
    }

    return result;
  }

  int _readViewCountResponse(Map<String, dynamic> response) {
    final direct = viewCountValue(response);
    if (direct > 0) return direct;

    final data = response['data'];

    if (data is Map) {
      return viewCountValue(Map<String, dynamic>.from(data));
    }

    return 0;
  }

  Future<void> _loadMore() async {
    if (!hasMore || isLoadingMore || isRefreshing || isFirstLoading) return;

    setState(() {
      isLoadingMore = true;
    });

    try {
      page++;
      await _fetchBooks(reset: false);
    } catch (_) {
      page = math.max(1, page - 1);
    }

    if (!mounted) return;

    setState(() {
      isLoadingMore = false;
    });
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    final shouldShow = _scrollCtrl.offset > 500;

    if (showScrollTop != shouldShow && mounted) {
      setState(() {
        showScrollTop = shouldShow;
      });
    }

    final position = _scrollCtrl.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      unawaited(_loadMore());
    }
  }

  Future<void> _scrollToTop() async {
    if (!_scrollCtrl.hasClients) return;

    await _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _setCategory(CategoryModel category) async {
    if (selectedCategoryId == category.id) return;

    await _scrollToTop();

    if (!mounted) return;

    setState(() {
      selectedCategoryId = category.id;
      isFirstLoading = true;
      errorMessage = null;
    });

    try {
      await _fetchBooks(reset: true);
    } catch (e) {
      errorMessage = cleanError(e);
    }

    if (!mounted) return;

    setState(() {
      isFirstLoading = false;
    });
  }

  void _openDetails(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LibraryDetailScreen(
          book: book,
          allBooks: books,
        ),
      ),
    );
  }

  String _selectedCategoryName(AppLocalizations l10n) {
    for (final category in categories) {
      if (category.id == selectedCategoryId) {
        return category.id == allCategoryId
            ? l10n.libraryAllCategories
            : category.name;
      }
    }

    return l10n.libraryAllCategories;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: showScrollTop
          ? FloatingActionButton.small(
        onPressed: _scrollToTop,
        tooltip: l10n.libraryBackToTop,
        child: const Icon(Icons.keyboard_arrow_up_rounded),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: cs.primary,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(
                l10n.libraryTitle,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              actions: [
                IconButton(
                  tooltip: isGrid
                      ? l10n.libraryListView
                      : l10n.libraryGridView,
                  icon: Icon(
                    isGrid
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                  ),
                  onPressed: () {
                    setState(() {
                      isGrid = !isGrid;
                    });
                  },
                ),
                IconButton(
                  tooltip: l10n.libraryRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _refresh,
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: RecommendedSection(
                isLoading: isLoadingRecommended,
                books: recommendedBooks,
                onTap: _openDetails,
              ),
            ),
            SliverToBoxAdapter(
              child: CategorySection(
                categories: categories,
                selectedCategoryId: selectedCategoryId,
                onSelected: _setCategory,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedCategoryId == allCategoryId
                            ? l10n.libraryAllBooks
                            : _selectedCategoryName(l10n),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (errorMessage != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      errorMessage!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: cs.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            else if (isFirstLoading)
              const SliverToBoxAdapter(
                child: LibraryLoader(),
              )
            else if (books.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      l10n.libraryNoBooksFound,
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.65),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              else if (isGrid)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >= books.length) {
                            return BottomLoader(
                              isLoading: isLoadingMore,
                              hasMore: hasMore,
                            );
                          }

                          final book = books[index];

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openDetails(book),
                            child: BookGridCard(book: book),
                          );
                        },
                        childCount: books.length + (hasMore ? 1 : 0),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >= books.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: BottomLoader(
                                isLoading: isLoadingMore,
                                hasMore: hasMore,
                              ),
                            );
                          }

                          final book = books[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _openDetails(book),
                              child: BookListTileCard(book: book),
                            ),
                          );
                        },
                        childCount: books.length + (hasMore ? 1 : 0),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}