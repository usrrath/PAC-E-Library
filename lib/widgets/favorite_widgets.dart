import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/library_models.dart';

class FavoriteBookCard extends StatelessWidget {
  final Book book;
  final List<String> categories;
  final List<String> tags;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const FavoriteBookCard({
    super.key,
    required this.book,
    required this.categories,
    required this.tags,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;

    final category =
    categories.isNotEmpty ? categories.first : t.favoritesScreenNoCategory;

    final cardColor = dark ? const Color(0xFF13283B) : const Color(0xFFEAF4FF);
    final borderColor = dark ? const Color(0xFF284766) : const Color(0xFFC9DDF4);
    final titleColor = dark ? Colors.white : const Color(0xFF17212B);
    final subColor = dark ? const Color(0xFF9FAFC0) : const Color(0xFF68737F);
    final pillColor = dark ? const Color(0xFF263E59) : const Color(0xFFDDEEFF);
    final pillTextColor = dark ? const Color(0xFFD9EAFF) : const Color(0xFF315F8A);
    final arrowColor = dark ? const Color(0xFFA8D4FF) : const Color(0xFF2F6899);

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FavoriteBookImage(url: book.coverUrl, width: 116, height: 184),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FavoritePill(
                    icon: Icons.category_outlined,
                    text: category,
                    background: pillColor,
                    foreground: pillTextColor,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    book.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    book.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: subColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FavoritePill(
                    icon: Icons.visibility_rounded,
                    text: '${book.viewCount} ${t.favoritesScreenViews}',
                    background: pillColor,
                    foreground: pillTextColor,
                  ),
                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: tags.take(2).map((tag) {
                        return FavoritePill(
                          icon: Icons.sell_rounded,
                          text: tag,
                          background: pillColor,
                          foreground: pillTextColor,
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 21, color: titleColor),
                      const SizedBox(width: 7),
                      Expanded(
                        child: Text(
                          t.favoritesScreenViewDetail,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_forward_rounded, size: 30, color: arrowColor),
                    ],
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

class FavoriteBookImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;

  const FavoriteBookImage({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: CachedNetworkImage(
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: cs.primary.withOpacity(0.10),
          alignment: Alignment.center,
          child: CircularProgressIndicator(strokeWidth: 2, color: cs.primary),
        ),
        errorWidget: (_, __, ___) => Container(
          width: width,
          height: height,
          color: cs.primary.withOpacity(0.10),
          alignment: Alignment.center,
          child: Icon(Icons.menu_book_rounded, color: cs.primary),
        ),
      ),
    );
  }
}

class FavoritePill extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color background;
  final Color foreground;

  const FavoritePill({
    super.key,
    required this.icon,
    required this.text,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foreground),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: foreground,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoriteEmptyView extends StatelessWidget {
  final ColorScheme colorScheme;

  const FavoriteEmptyView({
    super.key,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.favorite_border_rounded, size: 64, color: colorScheme.primary),
        const SizedBox(height: 14),
        Text(
          t.favoritesScreenNoFavoriteBooks,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class FavoriteErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const FavoriteErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.wifi_off_rounded, size: 54, color: cs.error),
        const SizedBox(height: 14),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: Text(t.favoritesScreenRetry),
        ),
      ],
    );
  }
}