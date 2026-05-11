import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'library_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  static const int pageSize = 6;

  final ScrollController _scrollCtrl = ScrollController();

  bool isGrid = true;
  bool isRefreshing = false;
  bool isLoadingMore = false;
  bool isFirstLoading = true;

  int page = 1;
  String selectedCategory = 'All';

  late final List<String> allCategories;

  final List<Book> books = demoBooks;

  List<Book> get filteredBooks {
    if (selectedCategory == 'All') return books;
    return books.where((b) => b.categories.contains(selectedCategory)).toList();
  }

  List<Book> get visibleBooks {
    final total = filteredBooks;
    final take = min(page * pageSize, total.length);
    return total.take(take).toList();
  }

  bool get hasMore => visibleBooks.length < filteredBooks.length;

  @override
  void initState() {
    super.initState();

    final categories = <String>{};
    for (final book in books) {
      categories.addAll(book.categories);
    }

    allCategories = ['All', ...categories.toList()..sort()];

    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      setState(() => isFirstLoading = false);
    });

    _scrollCtrl.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollCtrl.hasClients) return;

    final position = _scrollCtrl.position;

    if (position.pixels >= position.maxScrollExtent - 250) {
      _loadMore();
    }
  }

  @override
  void dispose() {
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (isRefreshing) return;

    setState(() => isRefreshing = true);

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    setState(() {
      books.shuffle();
      page = 1;
      isRefreshing = false;
    });
  }

  Future<void> _loadMore() async {
    if (!hasMore || isLoadingMore || isRefreshing || isFirstLoading) return;

    setState(() => isLoadingMore = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    setState(() {
      page++;
      isLoadingMore = false;
    });
  }

  void _setCategory(String category) {
    setState(() {
      selectedCategory = category;
      page = 1;
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
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
              title: const Text(
                'Library',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              actions: [
                IconButton(
                  tooltip: isGrid ? 'List view' : 'Grid view',
                  icon: Icon(isGrid ? Icons.view_list : Icons.grid_view),
                  onPressed: () => setState(() => isGrid = !isGrid),
                ),
                IconButton(
                  tooltip: 'Refresh',
                  icon: const Icon(Icons.refresh),
                  onPressed: _refresh,
                ),
              ],
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 42,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: allCategories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (_, index) {
                          final category = allCategories[index];
                          final selected = category == selectedCategory;

                          return ChoiceChip(
                            label: Text(category),
                            selected: selected,
                            onSelected: (_) => _setCategory(category),
                            selectedColor: cs.primary.withOpacity(0.15),
                            side: BorderSide(
                              color: cs.primary.withOpacity(0.25),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: selected ? cs.primary : cs.onSurface,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Showing ${visibleBooks.length} / ${filteredBooks.length}',
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.65),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isFirstLoading)
              const SliverToBoxAdapter(child: LibraryShimmer())
            else if (filteredBooks.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Text(
                    'No books found.',
                    style: TextStyle(
                      color: cs.onSurface.withOpacity(0.65),
                    ),
                  ),
                ),
              )
            else if (isGrid)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.70,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        if (index >= visibleBooks.length) {
                          return BottomLoader(
                            isLoading: isLoadingMore,
                            hasMore: hasMore,
                          );
                        }

                        final book = visibleBooks[index];

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _openDetails(book),
                          child: BookGridCard(book: book),
                        );
                      },
                      childCount: visibleBooks.length + (hasMore ? 1 : 0),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        if (index >= visibleBooks.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: BottomLoader(
                              isLoading: isLoadingMore,
                              hasMore: hasMore,
                            ),
                          );
                        }

                        final book = visibleBooks[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openDetails(book),
                            child: BookListTileCard(book: book),
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
}

class BookGridCard extends StatelessWidget {
  final Book book;

  const BookGridCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(18),
              ),
              child: CachedNetImage(
                url: book.coverUrl,
                width: double.infinity,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      book.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
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

class BookListTileCard extends StatelessWidget {
  final Book book;

  const BookListTileCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outline.withOpacity(0.10)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CachedNetImage(
              url: book.coverUrl,
              width: 60,
              height: 84,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.65),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 18,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      book.rating.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right_rounded, color: cs.primary),
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

class BottomLoader extends StatelessWidget {
  final bool isLoading;
  final bool hasMore;

  const BottomLoader({
    super.key,
    required this.isLoading,
    required this.hasMore,
  });

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
            ? isLoading
            ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: cs.primary,
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              'Loading more...',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        )
            : Text(
          'Scroll to load more',
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w800,
          ),
        )
            : Text(
          'No more results',
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class LibraryShimmer extends StatelessWidget {
  const LibraryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}

class CachedNetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const CachedNetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeUrl = url.trim();

    if (safeUrl.isEmpty) {
      return _noImage(cs);
    }

    return CachedNetworkImage(
      imageUrl: safeUrl,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Container(
        width: width,
        height: height,
        alignment: Alignment.center,
        color: cs.primary.withOpacity(0.10),
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: cs.primary,
          ),
        ),
      ),
      errorWidget: (_, __, ___) => _noImage(cs),
    );
  }

  Widget _noImage(ColorScheme cs) {
    return Container(
      width: width,
      height: height,
      color: cs.primary.withOpacity(0.10),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_rounded,
            color: cs.primary,
            size: 26,
          ),
          const SizedBox(height: 6),
          Text(
            'Image\nnot available',
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

class Book {
  final String id;
  final String title;
  final String author;
  final String publisher;
  final double rating;
  final List<String> categories;
  final List<String> tags;
  final String description;
  final String coverUrl;
  final String fileUrl;
  final String publishYear;
  final List<BookReview> reviews;
  final bool isFavorite;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.publisher,
    required this.rating,
    required this.categories,
    required this.tags,
    required this.description,
    required this.coverUrl,
    this.fileUrl = '',
    this.publishYear = '',
    required this.reviews,
    this.isFavorite = false,
  });
}

class BookReview {
  final String user;
  final double rating;
  final String comment;

  const BookReview({
    required this.user,
    required this.rating,
    required this.comment,
  });
}

final List<Book> demoBooks = [
  Book(
    id: '1',
    title: 'Clean Code',
    author: 'Robert C. Martin',
    publisher: 'Prentice Hall',
    rating: 4.7,
    categories: ['Technology', 'Programming'],
    tags: ['Best Practices', 'Code Quality'],
    description: 'A handbook of agile software craftsmanship.',
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg',
    reviews: [
      BookReview(user: 'Dara', rating: 5, comment: 'Excellent'),
    ],
  ),
  Book(
    id: '2',
    title: 'Clean Architecture',
    author: 'Robert C. Martin',
    publisher: 'Pearson',
    rating: 4.6,
    categories: ['Technology', 'Architecture'],
    tags: ['Design', 'SOLID'],
    description: 'Software architecture principles.',
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780134494166-L.jpg',
    reviews: [
      BookReview(user: 'Rath', rating: 5, comment: 'Very clear'),
    ],
  ),
  Book(
    id: '3',
    title: 'Refactoring',
    author: 'Martin Fowler',
    publisher: 'Addison-Wesley',
    rating: 4.5,
    categories: ['Technology', 'Programming'],
    tags: ['Refactor'],
    description: 'Improving existing code.',
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780201485677-L.jpg',
    reviews: [],
  ),
  Book(
    id: '4',
    title: 'Design Patterns',
    author: 'Erich Gamma',
    publisher: 'Addison-Wesley',
    rating: 4.4,
    categories: ['Technology', 'Architecture'],
    tags: ['Patterns'],
    description: 'Classic GoF patterns.',
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780201633610-L.jpg',
    reviews: [],
  ),
  Book(
    id: '5',
    title: 'The Pragmatic Programmer',
    author: 'Andrew Hunt',
    publisher: 'Addison-Wesley',
    rating: 4.8,
    categories: ['Technology', 'Programming'],
    tags: ['Career'],
    description: 'Timeless programming advice.',
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780201616224-L.jpg',
    reviews: [],
  ),
  Book(
    id: '6',
    title: 'Effective Java',
    author: 'Joshua Bloch',
    publisher: 'Addison-Wesley',
    rating: 4.7,
    categories: ['Technology', 'Programming'],
    tags: ['Java'],
    description: 'Best practices for Java.',
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780134685991-L.jpg',
    reviews: [],
  ),
  Book(
    id: '7',
    title: 'The Art of War',
    author: 'Sun Tzu',
    publisher: 'Oxford',
    rating: 4.4,
    categories: ['History', 'Philosophy'],
    tags: ['Strategy'],
    description: 'Ancient military strategy.',
    coverUrl: 'https://covers.openlibrary.org/b/isbn/9780195014761-L.jpg',
    reviews: [],
  ),
  Book(
    id: '8',
    title: 'No Image Demo',
    author: 'Unknown',
    publisher: 'Unknown',
    rating: 4.0,
    categories: ['Technology'],
    tags: ['Demo'],
    description: 'This item has no image URL.',
    coverUrl: '',
    reviews: [],
  ),
];