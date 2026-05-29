import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/search_models.dart';
import '../screens/library_detail_screen.dart';
import '../services/search_service.dart';
import '../widgets/library_widgets.dart';

enum SearchSort {
  bestMatch,
  mostPopular,
  newest,
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService _service = SearchService();
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  static const int pageSize = 12;

  bool _isLoading = true;
  bool _isRefreshing = false;
  bool _isLoadingMore = false;
  bool _showBackToTop = false;
  bool _isGrid = false;

  String? _error;
  int _page = 1;
  SearchSort _sort = SearchSort.bestMatch;

  final List<BookItem> _allBooks = [];
  final List<BookItem> _suggestedBooks = [];
  final List<String> _trendingSearches = [];

  bool get _isSearching => _searchCtrl.text.trim().isNotEmpty;

  List<BookItem> get _displayBooks {
    final list = _isSearching
        ? _filteredBooks
        : List<BookItem>.from(_suggestedBooks);

    list.sort(_sortBooks);
    return list;
  }

  List<BookItem> get _visibleBooks {
    final take = (_page * pageSize).clamp(0, _displayBooks.length);
    return _displayBooks.take(take).toList();
  }

  bool get _hasMore => _visibleBooks.length < _displayBooks.length;

  @override
  void initState() {
    super.initState();
    unawaited(_loadData());

    _searchCtrl.addListener(() {
      if (!mounted) return;
      setState(() => _page = 1);
    });

    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool refresh = false}) async {
    if (!mounted) return;

    setState(() {
      _error = null;
      _isRefreshing = refresh;
      _isLoading = !refresh;
    });

    try {
      final books = await _service.getBooks();
      final suggested = await _service.getSuggestedBooks();
      final trending = await _service.getTrendingSearches();

      final uniqueBooks = _uniqueBooks(books);
      final uniqueSuggested = _uniqueBooks(suggested);

      await Future.wait([
        _service.loadBookViews(uniqueBooks),
        _service.loadBookViews(uniqueSuggested),
      ]);

      uniqueBooks.sort(_sortBooks);
      uniqueSuggested.sort(_sortBooks);

      if (!mounted) return;

      setState(() {
        _allBooks
          ..clear()
          ..addAll(uniqueBooks);

        _suggestedBooks
          ..clear()
          ..addAll(uniqueSuggested);

        _trendingSearches
          ..clear()
          ..addAll(trending);

        _page = 1;
        _isLoading = false;
        _isRefreshing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = _friendlyError(e);
        _isLoading = false;
        _isRefreshing = false;
      });
    }
  }

  String _friendlyError(Object error) {
    if (_isInternetError(error)) {
      return 'Error Internet';
    }

    final msg = error.toString()
        .replaceFirst('Exception: ', '')
        .trim();

    if (msg.isEmpty) {
      return 'Something went wrong';
    }

    return msg;
  }

  bool _isInternetError(Object error) {
    final text = error.toString().toLowerCase();

    return error is SocketException ||
        text.contains('socketexception') ||
        text.contains('clientexception') ||
        text.contains('network is unreachable') ||
        text.contains('failed host lookup') ||
        text.contains('connection failed') ||
        text.contains('connection refused') ||
        text.contains('software caused connection abort') ||
        text.contains('connection aborted') ||
        text.contains('no address associated with hostname') ||
        text.contains('temporary failure in name resolution');
  }

  List<BookItem> _uniqueBooks(List<BookItem> books) {
    final map = <String, BookItem>{};

    for (final book in books) {
      final id = book.id.trim();
      if (id.isNotEmpty) {
        map[id] = book;
      }
    }

    return map.values.toList();
  }

  List<BookItem> get _filteredBooks {
    final q = _searchCtrl.text.trim().toLowerCase();

    if (q.isEmpty) return List<BookItem>.from(_allBooks);

    return _allBooks.where((book) {
      return book.title.toLowerCase().contains(q) ||
          book.author.toLowerCase().contains(q) ||
          book.category.toLowerCase().contains(q) ||
          book.language.toLowerCase().contains(q) ||
          book.publishYear.toString().contains(q) ||
          book.tags.any((tag) => tag.toLowerCase().contains(q));
    }).toList();
  }

  int _sortBooks(BookItem a, BookItem b) {
    switch (_sort) {
      case SearchSort.bestMatch:
        return _bestMatchScore(b).compareTo(_bestMatchScore(a));

      case SearchSort.mostPopular:
        final viewCompare = b.viewsCount.compareTo(a.viewsCount);
        if (viewCompare != 0) return viewCompare;

        final yearCompare = b.publishYear.compareTo(a.publishYear);
        if (yearCompare != 0) return yearCompare;

        return b.dateValue.compareTo(a.dateValue);

      case SearchSort.newest:
        return b.dateValue.compareTo(a.dateValue);
    }
  }

  int _bestMatchScore(BookItem book) {
    final q = _searchCtrl.text.trim().toLowerCase();

    if (q.isEmpty) {
      return book.viewsCount + book.dateValue ~/ 1000000000;
    }

    int score = 0;

    if (book.title.toLowerCase() == q) score += 1000;
    if (book.title.toLowerCase().startsWith(q)) score += 500;
    if (book.title.toLowerCase().contains(q)) score += 250;
    if (book.author.toLowerCase().contains(q)) score += 120;
    if (book.tags.any((tag) => tag.toLowerCase().contains(q))) score += 100;
    if (book.category.toLowerCase().contains(q)) score += 80;
    if (book.language.toLowerCase().contains(q)) score += 60;
    if (book.publishYear.toString().contains(q)) score += 50;

    score += book.viewsCount;
    score += book.publishYear > 0 ? book.publishYear ~/ 10 : 0;

    return score;
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    final show = _scrollCtrl.offset > 500;

    if (show != _showBackToTop && mounted) {
      setState(() => _showBackToTop = show);
    }

    final nearBottom =
        _scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 250;

    if (nearBottom) {
      unawaited(_loadMore());
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading || _isRefreshing) return;

    setState(() => _isLoadingMore = true);

    await Future.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    setState(() {
      _page++;
      _isLoadingMore = false;
    });
  }

  Future<void> _scrollToTop() async {
    if (!_scrollCtrl.hasClients) return;

    await _scrollCtrl.animateTo(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _refresh() async {
    await _scrollToTop();
    await _loadData(refresh: true);
  }

  void _applyTrendingSearch(String keyword) {
    _searchCtrl.text = keyword;
    _searchCtrl.selection = TextSelection.collapsed(offset: keyword.length);
    FocusScope.of(context).unfocus();

    setState(() => _page = 1);
  }

  void _clearSearch() {
    _searchCtrl.clear();
    FocusScope.of(context).unfocus();

    setState(() => _page = 1);
  }

  void _openBook(BookItem item) {
    if (item.id.trim().isEmpty) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LibraryDetailScreen(
          book: item.toBook(),
          allBooks: _allBooks.map((e) => e.toBook()).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
        onPressed: _scrollToTop,
        tooltip: l10n.searchBackToTop,
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
            if (_error == null)
            SliverAppBar(
              floating: true,
              snap: true,
              title: Text(
                l10n.searchTitle,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              actions: [
                IconButton(
                  tooltip: _isGrid ? l10n.searchListView : l10n.searchGridView,
                  icon: Icon(
                    _isGrid
                        ? Icons.view_list_rounded
                        : Icons.grid_view_rounded,
                  ),
                  onPressed: () {
                    setState(() => _isGrid = !_isGrid);
                  },
                ),
                IconButton(
                  tooltip: l10n.searchRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _refresh,
                ),
              ],
            ),

            if (_error == null)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    TextField(
                      controller: _searchCtrl,
                      textInputAction: TextInputAction.search,
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchCtrl.text.trim().isEmpty
                            ? null
                            : IconButton(
                          onPressed: _clearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _SortChips(
                      selected: _sort,
                      bestMatch: l10n.searchBestMatch,
                      mostPopular: l10n.searchMostPopular,
                      newest: l10n.searchNewest,
                      onChanged: (value) {
                        setState(() {
                          _sort = value;
                          _page = 1;
                        });
                      },
                    ),

                    if (!_isSearching && _trendingSearches.isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Text(
                        l10n.searchTrendingSearches,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _trendingSearches.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, index) {
                            final item = _trendingSearches[index];

                            return ActionChip(
                              avatar: const Icon(Icons.search_rounded, size: 18),
                              label: Text(item),
                              onPressed: () => _applyTrendingSearch(item),
                            );
                          },
                        ),
                      ),
                    ],

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _isSearching
                                ? l10n.searchResultsCount(
                              _visibleBooks.length,
                              _displayBooks.length,
                            )
                                : l10n.searchSuggestedBooksCount(
                              _visibleBooks.length,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (_isRefreshing)
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ]),
                ),
              ),

            if (_isLoading)
              const SliverToBoxAdapter(
                child: LibraryLoader(),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: connectionErrorView(
                  context: context,
                  title: 'Unable to load search',
                  message: _error!,
                  onRetry: () => _loadData(refresh: true),
                ),
              )
            else if (_displayBooks.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        _isSearching
                            ? l10n.searchNoResultsFor(_searchCtrl.text.trim())
                            : l10n.searchNoSuggestedBooksFound,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: cs.onSurface.withOpacity(0.65),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
              else if (_isGrid)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.62,
                      ),
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >= _visibleBooks.length) {
                            return BottomLoader(
                              isLoading: _isLoadingMore,
                              hasMore: _hasMore,
                            );
                          }

                          final item = _visibleBooks[index];
                          final book = item.toBook();

                          return InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openBook(item),
                            child: BookGridCard(book: book),
                          );
                        },
                        childCount: _visibleBooks.length + (_hasMore ? 1 : 0),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >= _visibleBooks.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: BottomLoader(
                                isLoading: _isLoadingMore,
                                hasMore: _hasMore,
                              ),
                            );
                          }

                          final item = _visibleBooks[index];
                          final book = item.toBook();

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: () => _openBook(item),
                              child: BookListTileCard(book: book),
                            ),
                          );
                        },
                        childCount: _visibleBooks.length + (_hasMore ? 1 : 0),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

Widget connectionErrorView({
  required BuildContext context,
  required String title,
  required String message,
  required VoidCallback onRetry,
}) {
  final cs = Theme.of(context).colorScheme;
  final isDark = Theme.of(context).brightness == Brightness.dark;

  return Center(
    child: Padding(

      padding: const EdgeInsets.symmetric(horizontal: 34),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.wifi_off_rounded,
            size: 72,
            color: isDark
                ? const Color(0xFFD89A91)
                : cs.error.withOpacity(0.75),
          ),

          const SizedBox(height: 28),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurface,
              fontSize: 28,
              height: 1.15,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 22),

          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.72),
              fontSize: 22,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 40),

          SizedBox(
            width: double.infinity,
            height: 78,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try again'),
              style: FilledButton.styleFrom(
                backgroundColor: isDark
                    ? const Color(0xFF9DCAFA)
                    : cs.primaryContainer,
                foregroundColor: isDark
                    ? const Color(0xFF073A58)
                    : cs.onPrimaryContainer,
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _SortChips extends StatelessWidget {
  final SearchSort selected;
  final ValueChanged<SearchSort> onChanged;
  final String bestMatch;
  final String mostPopular;
  final String newest;

  const _SortChips({
    required this.selected,
    required this.onChanged,
    required this.bestMatch,
    required this.mostPopular,
    required this.newest,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      children: [
        _chip(bestMatch, SearchSort.bestMatch),
        _chip(mostPopular, SearchSort.mostPopular),
        _chip(newest, SearchSort.newest),
      ],
    );
  }

  Widget _chip(String label, SearchSort value) {
    return ChoiceChip(
      label: Text(label),
      selected: selected == value,
      onSelected: (_) => onChanged(value),
    );
  }
}