import 'package:flutter/material.dart';
import '../models/search_models.dart';

import 'cached_book_image.dart';

class BookCover extends StatelessWidget {
  final String url;
  final String imageNotAvailableText;
  final double? width;
  final double? height;
  final double radius;

  const BookCover({
    super.key,
    required this.url,
    required this.imageNotAvailableText,
    this.width,
    this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return CachedBookImage(
      url: url,
      width: width,
      height: height,
      radius: radius,
    );
  }
}

class SmallTag extends StatelessWidget {
  final String text;

  const SmallTag({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '#$text',
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class BookRowTile extends StatelessWidget {
  final BookItem book;
  final String imageNotAvailableText;
  final VoidCallback onTap;

  const BookRowTile({
    super.key,
    required this.book,
    required this.imageNotAvailableText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 50,
        child: BookCover(
          url: book.coverUrl,
          imageNotAvailableText: imageNotAvailableText,
        ),
      ),
      title: Text(
        book.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(book.displayAuthor),
          Wrap(
            spacing: 6,
            children: book.tags.take(3).map((tag) {
              return SmallTag(text: tag);
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class BookGridCard extends StatelessWidget {
  final BookItem book;
  final String imageNotAvailableText;
  final VoidCallback onTap;

  const BookGridCard({
    super.key,
    required this.book,
    required this.imageNotAvailableText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.primary.withOpacity(0.12),
          ),
          boxShadow: [
            BoxShadow(
              blurRadius: 14,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 8),
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
                child: BookCover(
                  url: book.coverUrl,
                  imageNotAvailableText:
                  imageNotAvailableText,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                10,
                12,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    book.displayTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.displayAuthor,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color:
                      Theme.of(context).hintColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (book.publishYear > 0) ...[
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 15,
                          color: cs.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${book.publishYear}',
                          style: TextStyle(
                            color: cs.primary,
                            fontWeight:
                            FontWeight.w900,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Icon(
                        Icons.visibility_rounded,
                        size: 15,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${book.viewsCount}',
                        style: TextStyle(
                          color: cs.primary,
                          fontWeight:
                          FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  if (book.tags.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children:
                      book.tags.take(2).map((tag) {
                        return SmallTag(text: tag);
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}