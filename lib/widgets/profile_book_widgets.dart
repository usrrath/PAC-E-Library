import 'package:flutter/material.dart';

import '../models/book_mini_model.dart';
import '../utils/cached_net_image.dart';
import '../utils/profile_cards.dart';

class ProfileBookInfo extends StatelessWidget {
  final BookMini book;
  final bool showProgress;

  const ProfileBookInfo({
    super.key,
    required this.book,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final title = book.title.trim().isNotEmpty ? book.title.trim() : 'Untitled';

    final author = book.author.trim().isNotEmpty
        ? book.author.trim()
        : 'Unknown Author';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          author,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
        if (showProgress) ...[
          const SizedBox(height: 6),
          Text(
            book.safeTotalPages > 0
                ? 'Page ${book.safeLastPage} / ${book.safeTotalPages}'
                : 'Page ${book.safeLastPage}',
            style: TextStyle(
              color: cs.primary,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          ProfileProgressRow(progress: book.normalizedProgress),
        ],
      ],
    );
  }
}

class ProfileProgressRow extends StatelessWidget {
  final double progress;

  const ProfileProgressRow({
    super.key,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final safeProgress = progress.clamp(0.0, 1.0).toDouble();
    final percent = safeProgress * 100;

    return Row(
      children: [
        Expanded(
          child: LinearProgressIndicator(
            value: safeProgress,
            minHeight: 7,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${percent.toStringAsFixed(2)}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class FavoriteBookCard extends StatelessWidget {
  final BookMini book;
  final VoidCallback onTap;

  const FavoriteBookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: cs.primary.withOpacity(0.12)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18),
                    ),
                    child: CachedNetImage(
                      url: book.coverUrl,
                      width: 120,
                      height: 140,
                    ),
                  ),
                  const Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.favorite_rounded,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: ProfileBookInfo(
                book: book,
                showProgress: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ReadingBookTile extends StatelessWidget {
  final BookMini book;
  final VoidCallback onTap;

  const ReadingBookTile({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: ProfileCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
            Expanded(child: ProfileBookInfo(book: book)),
            Icon(Icons.play_arrow_rounded, color: cs.primary),
          ],
        ),
      ),
    );
  }
}