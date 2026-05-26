import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'continue_reading_screen.dart';
import 'favorites_screen.dart';
import 'notifications_screen.dart';

class BookViewItem {
  final String title;
  final String author;
  final String imageUrl;
  final String category;
  final bool isNew;
  final bool isFree;
  final bool isTrending;
  final bool isPdf;

  const BookViewItem({
    required this.title,
    required this.author,
    required this.imageUrl,
    required this.category,
    this.isNew = false,
    this.isFree = false,
    this.isTrending = false,
    this.isPdf = false,
  });
}

const List<BookViewItem> allBooks = [
  BookViewItem(
    title: "Clean Code",
    author: "Robert C. Martin",
    category: "Technology",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg",
    isNew: true,
    isTrending: true,
    isPdf: true,
  ),
  BookViewItem(
    title: "Clean Architecture",
    author: "Robert C. Martin",
    category: "Technology",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780134494166-M.jpg",
    isTrending: true,
    isPdf: true,
  ),
  BookViewItem(
    title: "The Pragmatic Programmer",
    author: "Andrew Hunt",
    category: "Technology",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780201616224-L.jpg",
    isNew: true,
    isPdf: true,
  ),
  BookViewItem(
    title: "Atomic Habits",
    author: "James Clear",
    category: "Business",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780735211292-L.jpg",
    isNew: true,
    isTrending: true,
  ),
  BookViewItem(
    title: "Clean Code",
    author: "Robert C. Martin",
    category: "Technology",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780132350884-L.jpg",
    isNew: true,
    isTrending: true,
    isPdf: true,
  ),
  BookViewItem(
    title: "Clean Architecture",
    author: "Robert C. Martin",
    category: "Technology",
    imageUrl: "https://covers.openlibrary.org/b/isbn/9780134494166-M.jpg",
    isTrending: true,
    isPdf: true,
  ),
];

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recommended = allBooks;
    final popular = allBooks.where((e) => e.isTrending).toList();
    final newBooks = allBooks.where((e) => e.isNew).toList();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            _TopBar(
              onNotificationTap: () {
                _open(context, const NotificationsScreen());
              },
            ),
            const SizedBox(height: 18),

            const _HeroCard(),
            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: "Continue",
                    subtitle: "Last reading",
                    icon: Icons.play_circle_outline_rounded,
                    onTap: () {
                      _open(context, const ContinueReadingScreen());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickActionCard(
                    title: "Favorites",
                    subtitle: "Saved books",
                    icon: Icons.favorite_border_rounded,
                    onTap: () {
                      _open(context, const FavoritesScreen());
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            _BookHorizontalSection(
              title: "Recommended Books",
              subtitle: "Picked for you",
              books: recommended,
            ),

            const SizedBox(height: 22),

            _BookHorizontalSection(
              title: "Popular Books",
              subtitle: "Most read this week",
              books: popular,
            ),

            const SizedBox(height: 22),

            _BookHorizontalSection(
              title: "New Releases",
              subtitle: "Recently added",
              books: newBooks,
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const _TopBar({
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "PAC E-Library",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Read, learn, and continue anywhere",
                style: TextStyle(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Stack(
          children: [
            IconButton.filledTonal(
              onPressed: onNotificationTap,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                width: 9,
                height: 9,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  String _greeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final titleColor = isDark ? cs.onSurface : cs.onPrimary;
    final subtitleColor = isDark
        ? cs.onSurfaceVariant
        : cs.onPrimary.withOpacity(0.88);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: isDark
              ? [
            cs.surfaceContainerHighest.withOpacity(0.95),
            cs.surface.withOpacity(0.98),
          ]
              : [
            cs.primary.withOpacity(0.95),
            cs.primary.withOpacity(0.68),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isDark
              ? cs.outlineVariant.withOpacity(0.35)
              : cs.primary.withOpacity(0.10),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            color: isDark
                ? Colors.black.withOpacity(0.24)
                : cs.primary.withOpacity(0.20),
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${_greeting()}, Ung Sereyrath",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18,
                    height: 1.15,
                    fontWeight: FontWeight.w900,
                    color: titleColor,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Continue your learning journey with your latest books.",
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? cs.surfaceContainerHighest : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: cs.primary.withOpacity(0.12)),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              color: isDark
                  ? Colors.black.withOpacity(0.18)
                  : Colors.black.withOpacity(0.045),
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookHorizontalSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<BookViewItem> books;

  const _BookHorizontalSection({
    required this.title,
    required this.subtitle,
    required this.books,
  });

  @override
  Widget build(BuildContext context) {
    if (books.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, subtitle: subtitle),
        const SizedBox(height: 12),
        SizedBox(
          height: 245,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: books.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              return _BookCard(book: books[i]);
            },
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 4,
          height: 36,
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookCard extends StatelessWidget {
  final BookViewItem book;

  const _BookCard({
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final badge = book.isNew ? "NEW" : (book.isFree ? "FREE" : null);

    return SizedBox(
      width: 145,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Open ${book.title}"),
              duration: const Duration(milliseconds: 900),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? cs.surfaceContainerHighest : theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cs.primary.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                color: isDark
                    ? Colors.black.withOpacity(0.18)
                    : Colors.black.withOpacity(0.045),
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: SafeNetImage(
                        url: book.imageUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (badge != null)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: cs.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              color: cs.onPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 9, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: cs.onSurface,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        Icon(
                          Icons.category_rounded,
                          size: 14,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            book.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cs.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SafeNetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  const SafeNetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.radius = 0,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Widget img = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, __) => Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        alignment: Alignment.center,
        color: cs.primary.withOpacity(0.10),
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: cs.primary,
        ),
      ),
      errorWidget: (_, __, ___) => Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        alignment: Alignment.center,
        color: cs.primary.withOpacity(0.10),
        child: Icon(
          Icons.menu_book_rounded,
          color: cs.primary,
        ),
      ),
    );

    if (radius > 0) {
      img = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: img,
      );
    }

    return img;
  }
}