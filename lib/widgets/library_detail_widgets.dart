import 'package:flutter/material.dart';

import '../models/library_detail_model.dart';
import '../models/library_models.dart';
import '../utils/cached_net_image.dart';

class LibraryDetailHeader extends StatelessWidget {
  final Book book;
  final bool canRead;
  final String readLabel;
  final VoidCallback onRead;

  const LibraryDetailHeader({
    super.key,
    required this.book,
    required this.canRead,
    required this.readLabel,
    required this.onRead,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: CachedNetImage(
            url: book.coverUrl,
            width: 120,
            height: 170,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                book.title,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                book.author,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: cs.onSurface.withOpacity(0.65),
                  height: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: canRead ? onRead : null,
                  icon: const Icon(Icons.menu_book_rounded),
                  label: Text(
                    readLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class LibraryInfoChips extends StatelessWidget {
  final String title;
  final String unknownLabel;
  final List<String> items;

  const LibraryInfoChips({
    super.key,
    required this.title,
    required this.unknownLabel,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cleanItems = items
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => !e.startsWith('{'))
        .where((e) => !e.startsWith('['))
        .toSet()
        .toList();

    if (cleanItems.isEmpty) {
      return Text(
        '$title: $unknownLabel',
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: cs.onSurface.withOpacity(0.65),
          fontWeight: FontWeight.w700,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: cleanItems.map((item) => _ChipLabel(text: item)).toList(),
        ),
      ],
    );
  }
}

class LibraryYearBox extends StatelessWidget {
  final String year;
  final String yearLabel;

  const LibraryYearBox({
    super.key,
    required this.year,
    required this.yearLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.calendar_month_rounded, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '$yearLabel: $year',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class LibraryDescription extends StatelessWidget {
  final String title;
  final String text;
  final String emptyLabel;

  const LibraryDescription({
    super.key,
    required this.title,
    required this.text,
    required this.emptyLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final value = text.trim().isEmpty ? emptyLabel : text.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value.length > 700 ? '${value.substring(0, 700).trim()}...' : value,
          style: TextStyle(
            color: cs.onSurface.withOpacity(0.75),
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class SimilarBooksSection extends StatelessWidget {
  final String title;
  final String emptyLabel;
  final List<LibraryDetailModel> items;
  final Book Function(LibraryDetailModel item) toBook;
  final void Function(LibraryDetailModel item) onTap;

  const SimilarBooksSection({
    super.key,
    required this.title,
    required this.emptyLabel,
    required this.items,
    required this.toBook,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        if (items.isEmpty)
          Text(
            emptyLabel,
            style: TextStyle(
              color: cs.onSurface.withOpacity(0.65),
            ),
          )
        else
          SizedBox(
            height: 286,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, index) {
                final item = items[index];
                final book = toBook(item);

                return SizedBox(
                  width: 135,
                  child: MiniBookCard(
                    book: book,
                    onTap: () => onTap(item),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class MiniBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const MiniBookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final tags = book.tags
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => !e.startsWith('{'))
        .where((e) => !e.startsWith('['))
        .take(2)
        .toList();

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outline.withOpacity(0.10),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 0.72,
              child: CachedNetImage(
                url: book.coverUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        book.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          height: 1.15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (tags.isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: tags.map((tag) {
                          return ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 105),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: cs.primary.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: cs.primary.withOpacity(0.12),
                                ),
                              ),
                              child: Text(
                                tag,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 10,
                                  height: 1.1,
                                  fontWeight: FontWeight.w800,
                                  color: cs.primary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LibraryErrorBox extends StatelessWidget {
  final String message;

  const LibraryErrorBox({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.errorContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: cs.onErrorContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ChipLabel extends StatelessWidget {
  final String text;

  const _ChipLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.18)),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: cs.primary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}