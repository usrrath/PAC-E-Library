// lib/screens/search_screen.dart

import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/search_models.dart';
import '../screens/library_detail_screen.dart';
import '../services/search_service.dart';
import '../widgets/search_widgets.dart';

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
    _loadData();

    _searchCtrl.addListener(() {
      setState(() => _page = 1);
    });

    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool refresh = false}) async {
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
        _error = e.toString().replaceFirst('Exception: ', '').trim();
        _isLoading = false;
        _isRefreshing = false;
      });
    }
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

    if (q.isEmpty) {
      return List<BookItem>.from(_allBooks);
    }

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
    if (show != _showBackToTop) {
      setState(() => _showBackToTop = show);
    }

    final nearBottom =
        _scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 300;

    if (nearBottom) {
      _loadMore();
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
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  void _applyTrendingSearch(String keyword) {
    _searchCtrl.text = keyword;
    _searchCtrl.selection = TextSelection.collapsed(
      offset: keyword.length,
    );
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

    return Scaffold(
      floatingActionButton: AnimatedScale(
        scale: _showBackToTop ? 1 : 0,
        duration: const Duration(milliseconds: 180),
        child: FloatingActionButton.small(
          onPressed: _scrollToTop,
          tooltip: l10n.searchBackToTop,
          child: const Icon(Icons.keyboard_arrow_up_rounded),
        ),
      ),
      appBar: AppBar(
        title: Text(
          l10n.searchTitle,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: _isGrid ? l10n.searchListView : l10n.searchGridView,
            onPressed: () => setState(() => _isGrid = !_isGrid),
            icon: Icon(
              _isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded,
            ),
          ),
          IconButton(
            tooltip: l10n.searchRefresh,
            onPressed: () => _loadData(refresh: true),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(refresh: true),
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
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
                          style: const TextStyle(fontWeight: FontWeight.w900),
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
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded, size: 44),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 12),
                        FilledButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh_rounded),
                          label: Text(l10n.searchRetry),
                        ),
                      ],
                    ),
                  ),
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
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                )
              else if (_isGrid)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >= _visibleBooks.length) {
                            return _BottomLoader(
                              isLoading: _isLoadingMore,
                              hasMore: _hasMore,
                              loadingMoreText: l10n.searchLoadingMore,
                              scrollToLoadMoreText: l10n.searchScrollToLoadMore,
                              noMoreResultsText: l10n.searchNoMoreResults,
                            );
                          }

                          final book = _visibleBooks[index];

                          return BookGridCard(
                            book: book,
                            imageNotAvailableText: l10n.searchImageNotAvailable,
                            onTap: () => _openBook(book),
                          );
                        },
                        childCount: _visibleBooks.length + (_hasMore ? 1 : 0),
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.58,
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          if (index >= _visibleBooks.length) {
                            return _BottomLoader(
                              isLoading: _isLoadingMore,
                              hasMore: _hasMore,
                              loadingMoreText: l10n.searchLoadingMore,
                              scrollToLoadMoreText: l10n.searchScrollToLoadMore,
                              noMoreResultsText: l10n.searchNoMoreResults,
                            );
                          }

                          final book = _visibleBooks[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: BookRowTile(
                              book: book,
                              imageNotAvailableText: l10n.searchImageNotAvailable,
                              onTap: () => _openBook(book),
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
        _chip(context, bestMatch, SearchSort.bestMatch),
        _chip(context, mostPopular, SearchSort.mostPopular),
        _chip(context, newest, SearchSort.newest),
      ],
    );
  }

  Widget _chip(BuildContext context, String label, SearchSort value) {
    final active = selected == value;

    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onChanged(value),
    );
  }
}

class _BottomLoader extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  final String loadingMoreText;
  final String scrollToLoadMoreText;
  final String noMoreResultsText;

  const _BottomLoader({
    required this.isLoading,
    required this.hasMore,
    required this.loadingMoreText,
    required this.scrollToLoadMoreText,
    required this.noMoreResultsText,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasMore) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(noMoreResultsText),
        ),
      );
    }

    if (!isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Text(scrollToLoadMoreText),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Text(loadingMoreText),
          ],
        ),
      ),
    );
  }
}