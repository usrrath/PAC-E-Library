import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/library_models.dart';

class CategorySection extends StatelessWidget {
  final List<CategoryModel> categories;
  final int selectedCategoryId;
  final ValueChanged<CategoryModel> onSelected;

  const CategorySection({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onSelected,
  });

  String _name(BuildContext context, CategoryModel category) {
    final l10n = AppLocalizations.of(context)!;
    return category.id == 0 ? l10n.libraryAllCategories : category.name;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    if (categories.isEmpty) return const SizedBox.shrink();

    final selectedCategory = categories.firstWhere(
          (e) => e.id == selectedCategoryId,
      orElse: () => const CategoryModel(id: 0, name: ''),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _showCategorySheet(context, selectedCategory),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: cs.outline.withOpacity(0.18)),
            boxShadow: [
              BoxShadow(
                blurRadius: 14,
                offset: const Offset(0, 8),
                color: Colors.black.withOpacity(0.04),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: cs.primary.withOpacity(0.12),
                child: Icon(
                  selectedCategory.id == 0
                      ? Icons.apps_rounded
                      : Icons.folder_rounded,
                  color: cs.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.librarySelectCategory,
                      style: TextStyle(
                        color: cs.onSurface.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _name(context, selectedCategory),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded, color: cs.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _showCategorySheet(
      BuildContext context,
      CategoryModel selectedCategory,
      ) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.88,
          builder: (context, controller) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: cs.outline.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.libraryChooseCategory,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: controller,
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, index) {
                      final category = categories[index];
                      final selected = category.id == selectedCategory.id;
                      final isAll = category.id == 0;

                      return Material(
                        color: selected
                            ? cs.primary.withOpacity(0.12)
                            : cs.surfaceContainerHighest.withOpacity(0.45),
                        borderRadius: BorderRadius.circular(16),
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: selected
                                ? cs.primary
                                : cs.primary.withOpacity(0.10),
                            child: Icon(
                              isAll
                                  ? Icons.apps_rounded
                                  : Icons.folder_rounded,
                              color: selected ? cs.onPrimary : cs.primary,
                            ),
                          ),
                          title: Text(
                            _name(context, category),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w900),
                          ),
                          trailing: selected
                              ? Icon(
                            Icons.check_circle_rounded,
                            color: cs.primary,
                          )
                              : const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            onSelected(category);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class RecommendedSection extends StatelessWidget {
  final bool isLoading;
  final List<Book> books;
  final ValueChanged<Book> onTap;

  const RecommendedSection({
    super.key,
    required this.isLoading,
    required this.books,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SizedBox(
          height: 185,
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (books.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 0, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.libraryRecommendedBooks,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 185,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.88),
              padEnds: false,
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(22),
                    onTap: () => onTap(book),
                    child: RecommendedBookCard(book: book),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendedBookCard extends StatelessWidget {
  final Book book;

  const RecommendedBookCard({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: CachedNetImage(
              url: book.coverUrl,
              width: 105,
              height: double.infinity,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SmallBadge(
                  icon: Icons.auto_awesome_rounded,
                  text: l10n.libraryRecommended,
                ),
                const SizedBox(height: 10),
                Text(
                  book.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: cs.onSurface.withOpacity(0.65),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Recommended book: only view count.
                BookMetaChips(
                  book: book,
                  showCategoryAndTags: false,
                ),

                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        book.publishYear.isEmpty
                            ? l10n.libraryReadNow
                            : book.publishYear,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, color: cs.primary),
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
                  style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
                ),
                const SizedBox(height: 8),

                // All books: category + tags + view count.
                BookMetaChips(
                  book: book,
                  showCategoryAndTags: true,
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
    final l10n = AppLocalizations.of(context)!;
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
              width: 80,
              height: 122,
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
                  style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
                ),
                const SizedBox(height: 8),

                // All books: category + tags + view count.
                BookMetaChips(
                  book: book,
                  showCategoryAndTags: true,
                ),

                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      book.publishYear.isEmpty
                          ? l10n.libraryViewBook
                          : book.publishYear,
                      style: const TextStyle(fontWeight: FontWeight.w800),
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

class BookMetaChips extends StatelessWidget {
  final Book book;
  final bool showCategoryAndTags;
  final bool showYear;

  const BookMetaChips({
    super.key,
    required this.book,
    required this.showCategoryAndTags,
    this.showYear = false,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _SmallBadge(
        icon: Icons.visibility_rounded,
        text: '${book.viewCount} views',
      ),
    ];

    if (showYear && book.publishYear.trim().isNotEmpty) {
      chips.add(
        _SmallBadge(
          icon: Icons.calendar_month_rounded,
          text: book.publishYear,
        ),
      );
    }

    if (showCategoryAndTags) {
      // for (final category in book.categories.take(1)) {
      //   chips.add(_SmallBadge(icon: Icons.folder_rounded, text: category));
      // }

      for (final tag in book.tags.take(2)) {
        chips.add(_SmallBadge(icon: Icons.sell_rounded, text: tag));
      }
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: chips,
    );
  }
}

class _SmallBadge extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallBadge({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeText = text.trim();

    if (safeText.isEmpty) return const SizedBox.shrink();

    return Container(
      constraints: const BoxConstraints(maxWidth: 150),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.primary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              safeText,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: cs.primary,
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
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
    final l10n = AppLocalizations.of(context)!;
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
            Text(
              l10n.libraryLoadingMore,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        )
            : Text(
          l10n.libraryScrollToLoadMore,
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w800,
          ),
        )
            : Text(
          l10n.libraryNoMoreResults,
          style: TextStyle(
            color: Theme.of(context).hintColor,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class LibraryLoader extends StatelessWidget {
  const LibraryLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(24),
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

    if (safeUrl.isEmpty) return _noImage(cs);

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
      child: Icon(
        Icons.image_not_supported_rounded,
        color: cs.primary,
        size: 28,
      ),
    );
  }
}