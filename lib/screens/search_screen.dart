import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// =======================================================
/// SEARCH SCREEN (StatefulWidget)
/// ✅ Search (title/author/isbn)
/// ✅ Refresh page (pull-to-refresh + refresh icon)
/// ✅ Auto scroll pagination by 6
/// ✅ Grid/List toggle
/// ✅ Safe image + "Image not available"
/// ✅ CustomScrollView + Slivers (no nested scroll bugs)
/// =======================================================
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool isGrid = false;

  // pagination
  static const int pageSize = 6;
  int page = 1;
  bool isRefreshing = false;
  bool isLoadingMore = false;

  // filters
  String selectedCategory = "All";
  String selectedFileType = "All";

  // ✅ FIX: ONLY ONE allBooks (remove late + remove _sampleBooks())
  final List<BookItem> allBooks = [
    BookItem(
      title: "Clean Code",
      author: "Robert C. Martin",
      isbn: "9780132350884",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 95,
      rating: 4.7,
      publishDate: DateTime(2008, 8, 1),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg",
    ),
    BookItem(
      title: "Clean Architecture",
      author: "Robert C. Martin",
      isbn: "9780134494166",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 92,
      rating: 4.6,
      publishDate: DateTime(2017, 9, 20),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780134494166-M.jpg",
    ),
    BookItem(
      title: "The Pragmatic Programmer",
      author: "Andrew Hunt",
      isbn: "9780201616224",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 97,
      rating: 4.8,
      publishDate: DateTime(1999, 10, 20),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780201616224-L.jpg",
    ),
    BookItem(
      title: "Refactoring",
      author: "Martin Fowler",
      isbn: "9780201485677",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 90,
      rating: 4.5,
      publishDate: DateTime(1999, 7, 8),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780201485677-L.jpg",
    ),
    BookItem(
      title: "Design Patterns",
      author: "Erich Gamma",
      isbn: "9780201633610",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 89,
      rating: 4.4,
      publishDate: DateTime(1994, 10, 31),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780201633610-L.jpg",
    ),
    BookItem(
      title: "Effective Java",
      author: "Joshua Bloch",
      isbn: "9780134685991",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 93,
      rating: 4.7,
      publishDate: DateTime(2018, 1, 6),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780134685991-L.jpg",
    ),
    BookItem(
      title: "Flutter in Action",
      author: "Eric Windmill",
      isbn: "9781617296147",
      category: "Mobile",
      language: "English",
      fileType: "PDF",
      popularity: 88,
      rating: 4.4,
      publishDate: DateTime(2020, 1, 1),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9781617296147-L.jpg",
    ),
    BookItem(
      title: "You Don't Know JS",
      author: "Kyle Simpson",
      isbn: "9781491904244",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 91,
      rating: 4.6,
      publishDate: DateTime(2015, 12, 27),
      coverUrl:
      "https://books.google.com/books/content?id=ISBN:9781491904244&printsec=frontcover&img=1&zoom=1",
    ),
    BookItem(
      title: "JavaScript: The Good Parts",
      author: "Douglas Crockford",
      isbn: "9780596517748",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 85,
      rating: 4.3,
      publishDate: DateTime(2008, 5, 15),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780596517748-L.jpg",
    ),
    BookItem(
      title: "Introduction to Algorithms",
      author: "Thomas H. Cormen",
      isbn: "9780262033848",
      category: "Education",
      language: "English",
      fileType: "PDF",
      popularity: 94,
      rating: 4.5,
      publishDate: DateTime(2009, 7, 31),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780262033848-L.jpg",
    ),
    BookItem(
      title: "Atomic Habits",
      author: "James Clear",
      isbn: "9780735211292",
      category: "Self-Help",
      language: "English",
      fileType: "PDF",
      popularity: 99,
      rating: 4.8,
      publishDate: DateTime(2018, 10, 16),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg",
    ),
    BookItem(
      title: "1984",
      author: "George Orwell",
      isbn: "9780451524935",
      category: "Novel",
      language: "English",
      fileType: "EPUB",
      popularity: 98,
      rating: 4.6,
      publishDate: DateTime(1949, 6, 8),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg",
    ),
    BookItem(
      title: "Clean Code",
      author: "Robert C. Martin",
      isbn: "9780132350884",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 95,
      rating: 4.7,
      publishDate: DateTime(2008, 8, 1),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg",
    ),
    BookItem(
      title: "Clean Architecture",
      author: "Robert C. Martin",
      isbn: "9780134494166",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 92,
      rating: 4.6,
      publishDate: DateTime(2017, 9, 20),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780134494166-M.jpg",
    ),
    BookItem(
      title: "The Pragmatic Programmer",
      author: "Andrew Hunt",
      isbn: "9780201616224",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 97,
      rating: 4.8,
      publishDate: DateTime(1999, 10, 20),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780201616224-L.jpg",
    ),
    BookItem(
      title: "Refactoring",
      author: "Martin Fowler",
      isbn: "9780201485677",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 90,
      rating: 4.5,
      publishDate: DateTime(1999, 7, 8),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780201485677-L.jpg",
    ),
    BookItem(
      title: "Design Patterns",
      author: "Erich Gamma",
      isbn: "9780201633610",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 89,
      rating: 4.4,
      publishDate: DateTime(1994, 10, 31),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780201633610-L.jpg",
    ),
    BookItem(
      title: "Effective Java",
      author: "Joshua Bloch",
      isbn: "9780134685991",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 93,
      rating: 4.7,
      publishDate: DateTime(2018, 1, 6),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780134685991-L.jpg",
    ),
    BookItem(
      title: "Flutter in Action",
      author: "Eric Windmill",
      isbn: "9781617296147",
      category: "Mobile",
      language: "English",
      fileType: "PDF",
      popularity: 88,
      rating: 4.4,
      publishDate: DateTime(2020, 1, 1),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9781617296147-L.jpg",
    ),
    BookItem(
      title: "You Don't Know JS",
      author: "Kyle Simpson",
      isbn: "9781491904244",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 91,
      rating: 4.6,
      publishDate: DateTime(2015, 12, 27),
      coverUrl:
      "https://books.google.com/books/content?id=ISBN:9781491904244&printsec=frontcover&img=1&zoom=1",
    ),
    BookItem(
      title: "JavaScript: The Good Parts",
      author: "Douglas Crockford",
      isbn: "9780596517748",
      category: "Technology",
      language: "English",
      fileType: "PDF",
      popularity: 85,
      rating: 4.3,
      publishDate: DateTime(2008, 5, 15),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780596517748-L.jpg",
    ),
    BookItem(
      title: "Introduction to Algorithms",
      author: "Thomas H. Cormen",
      isbn: "9780262033848",
      category: "Education",
      language: "English",
      fileType: "PDF",
      popularity: 94,
      rating: 4.5,
      publishDate: DateTime(2009, 7, 31),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780262033848-L.jpg",
    ),
    BookItem(
      title: "Atomic Habits",
      author: "James Clear",
      isbn: "9780735211292",
      category: "Self-Help",
      language: "English",
      fileType: "PDF",
      popularity: 99,
      rating: 4.8,
      publishDate: DateTime(2018, 10, 16),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg",
    ),
    BookItem(
      title: "1984",
      author: "George Orwell",
      isbn: "9780451524935",
      category: "Novel",
      language: "English",
      fileType: "EPUB",
      popularity: 98,
      rating: 4.6,
      publishDate: DateTime(1949, 6, 8),
      coverUrl: "https://covers.openlibrary.org/b/isbn/9780451524935-L.jpg",
    ),
    // ✅ add more...
  ];

  List<BookItem> get _filteredAll {
    final q = _searchCtrl.text.trim().toLowerCase();
    Iterable<BookItem> list = allBooks;

    if (selectedCategory != "All") {
      list = list.where((b) => b.category == selectedCategory);
    }
    if (selectedFileType != "All") {
      list = list.where((b) => b.fileType == selectedFileType);
    }

    if (q.isNotEmpty) {
      list = list.where((b) =>
      b.title.toLowerCase().contains(q) ||
          b.author.toLowerCase().contains(q) ||
          b.isbn.toLowerCase().contains(q));
    }

    return list.toList();
  }

  List<BookItem> get visibleBooks {
    final full = _filteredAll;
    final take = (page * pageSize).clamp(0, full.length);
    return full.take(take).toList();
  }

  bool get hasMore => visibleBooks.length < _filteredAll.length;

  @override
  void initState() {
    super.initState();

    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 260) {
        _loadMore();
      }
    });

    _searchCtrl.addListener(() => setState(() => page = 1));
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (isRefreshing) return;
    setState(() => isRefreshing = true);

    await Future.delayed(const Duration(milliseconds: 650));
    allBooks.shuffle();

    if (!mounted) return;
    setState(() {
      page = 1;
      isRefreshing = false;
    });
  }

  Future<void> _loadMore() async {
    if (!hasMore || isLoadingMore || isRefreshing) return;
    setState(() => isLoadingMore = true);

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() {
      page += 1;
      isLoadingMore = false;
    });
  }

  void _resetAll() {
    setState(() {
      selectedCategory = "All";
      selectedFileType = "All";
      page = 1;
    });
    _searchCtrl.clear();
    FocusScope.of(context).unfocus();
  }

  void toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(milliseconds: 900)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final categories = const ["All", "Technology", "Business", "Novel", "Mobile", "Education", "Self-Help"];
    final fileTypes = const ["All", "PDF", "EPUB"];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: cs.primary,
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverAppBar(
              title: const Text("Search", style: TextStyle(fontWeight: FontWeight.w800)),
              floating: true,
              snap: true,
              actions: [
                IconButton(
                  tooltip: isGrid ? "List view" : "Grid view",
                  onPressed: () => setState(() => isGrid = !isGrid),
                  icon: Icon(isGrid ? Icons.view_list_rounded : Icons.grid_view_rounded),
                ),
                IconButton(
                  tooltip: "Refresh",
                  onPressed: _refresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate(
                  [
                    TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: "Search title, author",
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: _searchCtrl.text.trim().isEmpty
                            ? null
                            : IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            FocusScope.of(context).unfocus();
                            setState(() => page = 1);
                          },
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                    const SizedBox(height: 12),

                    _sectionHeader("Filters", onReset: _resetAll),
                    const SizedBox(height: 8),

                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final c = categories[i];
                          final selected = selectedCategory == c;
                          return ChoiceChip(
                            label: Text(c),
                            selected: selected,
                            onSelected: (_) => setState(() {
                              selectedCategory = c;
                              page = 1;
                            }),
                            selectedColor: cs.primary.withOpacity(0.15),
                            side: BorderSide(color: cs.primary.withOpacity(0.25)),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: selected ? cs.primary : cs.onSurface,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 10),

                    // SizedBox(
                    //   height: 42,
                    //   child: ListView.separated(
                    //     scrollDirection: Axis.horizontal,
                    //     itemCount: fileTypes.length,
                    //     separatorBuilder: (_, __) => const SizedBox(width: 10),
                    //     itemBuilder: (_, i) {
                    //       final f = fileTypes[i];
                    //       final selected = selectedFileType == f;
                    //       return FilterChip(
                    //         label: Text(f),
                    //         selected: selected,
                    //         onSelected: (_) => setState(() {
                    //           selectedFileType = f;
                    //           page = 1;
                    //         }),
                    //         selectedColor: cs.primary.withOpacity(0.15),
                    //         checkmarkColor: cs.primary,
                    //         side: BorderSide(color: cs.primary.withOpacity(0.25)),
                    //         labelStyle: TextStyle(
                    //           fontWeight: FontWeight.w800,
                    //           color: selected ? cs.primary : cs.onSurface,
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "Results: ${visibleBooks.length} / ${_filteredAll.length}",
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                        if (_filteredAll.isNotEmpty)
                          Text(
                            "(+$pageSize auto)",
                            style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w800),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            if (_filteredAll.isEmpty)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                sliver: SliverToBoxAdapter(child: _EmptyState(query: _searchCtrl.text.trim())),
              )
            else if (isGrid)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      if (i >= visibleBooks.length) {
                        return _BottomLoader(isLoading: isLoadingMore, hasMore: hasMore);
                      }
                      final b = visibleBooks[i];
                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () => toast("Open ${b.title}"),
                        child: _BookCard(
                          title: b.title,
                          author: b.author,
                          imageUrl: b.coverUrl,
                          badge: b.fileType,
                        ),
                      );
                    },
                    childCount: visibleBooks.length + (hasMore ? 1 : 0),
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, i) {
                      if (i >= visibleBooks.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: _BottomLoader(isLoading: isLoadingMore, hasMore: hasMore),
                        );
                      }
                      final b = visibleBooks[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => toast("Open ${b.title}"),
                          child: _BookRowTile(item: b),
                        ),
                      );
                    },
                    childCount: visibleBooks.length + (hasMore ? 1 : 0),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, {required VoidCallback onReset}) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
        TextButton(
          onPressed: onReset,
          child: Text("Reset", style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }
}

/// ===============================
/// Models
/// ===============================
class BookItem {
  final String title;
  final String author;
  final String isbn;
  final String category;
  final String language;
  final String fileType;
  final int popularity;
  final double rating;
  final DateTime publishDate;
  final String coverUrl;

  BookItem({
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.language,
    required this.fileType,
    required this.popularity,
    required this.rating,
    required this.publishDate,
    required this.coverUrl,
  });
}

/// ===============================
/// UI Widgets
/// ===============================
class _BottomLoader extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;
  const _BottomLoader({required this.isLoading, required this.hasMore});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.primary.withOpacity(0.10)),
      ),
      child: Center(
        child: hasMore
            ? (isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
            ),
            const SizedBox(width: 10),
            const Text("Loading more...", style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        )
            : Text("Scroll to load more",
            style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w800)))
            : Text("No more results",
            style: TextStyle(color: Theme.of(context).hintColor, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String query;
  const _EmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, color: cs.primary, size: 34),
          const SizedBox(height: 10),
          Text(
            query.isEmpty ? "Start searching books..." : "No results for \"$query\"",
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 6),
          Text(
            "Try another keyword or adjust filters.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).hintColor),
          ),
        ],
      ),
    );
  }
}

class BookCover extends StatelessWidget {
  final String url;
  final BoxFit fit;

  const BookCover({super.key, required this.url, this.fit = BoxFit.cover});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeUrl = url.trim();

    if (safeUrl.isEmpty) return _noImage(cs);

    return CachedNetworkImage(
      imageUrl: safeUrl,
      fit: fit,
      placeholder: (_, __) => Container(
        color: cs.primary.withOpacity(0.08),
        alignment: Alignment.center,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
        ),
      ),
      errorWidget: (_, __, ___) => _noImage(cs),
    );
  }

  Widget _noImage(ColorScheme cs) {
    return Container(
      color: cs.primary.withOpacity(0.08),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported_rounded, color: cs.primary, size: 28),
          const SizedBox(height: 6),
          Text(
            "Image\nnot available",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 11,
              height: 1.1,
              color: cs.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  final String title;
  final String author;
  final String imageUrl;
  final String? badge;

  const _BookCard({
    required this.title,
    required this.author,
    required this.imageUrl,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(blurRadius: 14, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                  child: BookCover(url: imageUrl),
                ),
                if (badge != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: cs.primary, borderRadius: BorderRadius.circular(14)),
                      child: Text(
                        badge!,
                        style: TextStyle(color: cs.onPrimary, fontWeight: FontWeight.w900, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).hintColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BookRowTile extends StatelessWidget {
  final BookItem item;
  const _BookRowTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(blurRadius: 14, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 84,
              child: BookCover(url: item.coverUrl),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text(item.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: cs.primary.withOpacity(0.18)),
                      ),
                      child: Text(item.category,
                          style: TextStyle(color: cs.primary, fontWeight: FontWeight.w800, fontSize: 12)),
                    ),
                    const Spacer(),
                    Text(item.fileType, style: TextStyle(color: cs.primary, fontWeight: FontWeight.w900)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
