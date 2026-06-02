import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/continue_reading_book.dart';

class ContinueReadingCard extends StatelessWidget {
  final ContinueReadingBook book;
  final String continueReadingActionText;
  final VoidCallback onTap;

  const ContinueReadingCard({
    super.key,
    required this.book,
    required this.continueReadingActionText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;

    final cardColor = dark ? const Color(0xFF13283B) : const Color(0xFFEAF4FF);
    final borderColor = dark ? const Color(0xFF284766) : const Color(0xFFC9DDF4);
    final titleColor = dark ? Colors.white : const Color(0xFF17212B);
    final subColor = dark ? const Color(0xFF9FAFC0) : const Color(0xFF68737F);
    final pillTextColor = dark ? const Color(0xFFD9EAFF) : const Color(0xFF315F8A);
    final arrowColor = dark ? const Color(0xFFA8D4FF) : const Color(0xFF2F6899);

    final progressValue = (book.percent / 100).clamp(0.0, 1.0);
    final percentText = '${book.percent.toStringAsFixed(2)}%';

    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: dark
                  ? Colors.black.withOpacity(0.18)
                  : Colors.black.withOpacity(0.035),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ContinueReadingBookImage(
              url: book.coverUrl,
              width: 116,
              height: 164,
              radius: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: SizedBox(
                height: 164,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          book.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 20,
                            height: 1.15,
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
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: progressValue,
                                  minHeight: 7,
                                  backgroundColor: dark
                                      ? Colors.white.withOpacity(0.10)
                                      : Colors.black.withOpacity(0.08),
                                  color: cs.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              percentText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: cs.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Page ${book.lastPage}/${book.totalPages}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: pillTextColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.menu_book_rounded,
                          size: 21,
                          color: titleColor,
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            continueReadingActionText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: titleColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 30,
                          color: arrowColor,
                        ),
                      ],
                    ),
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

class ContinueReadingBookImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final double radius;
  final BoxFit fit;

  const ContinueReadingBookImage({
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
    final cleanUrl = url.trim();

    final child = cleanUrl.isEmpty
        ? _fallback(cs)
        : CachedNetworkImage(
      imageUrl: cleanUrl,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: const Duration(milliseconds: 120),
      fadeOutDuration: const Duration(milliseconds: 80),
      memCacheWidth: 240,
      placeholder: (_, __) => _fallback(cs, loading: true),
      errorWidget: (_, __, ___) => _fallback(cs),
    );

    if (radius <= 0) return child;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: child,
    );
  }

  Widget _fallback(ColorScheme cs, {bool loading = false}) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      alignment: Alignment.center,
      color: cs.primary.withOpacity(0.10),
      child: loading
          ? SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: cs.primary,
        ),
      )
          : Icon(Icons.menu_book_rounded, color: cs.primary),
    );
  }
}

class ContinueReadingLoadingList extends StatelessWidget {
  const ContinueReadingLoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: 6,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) {
        return Container(
          height: 192,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.primary.withOpacity(0.07),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              Container(
                width: 116,
                height: 164,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: SizedBox(
                  height: 164,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(5, (i) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Container(
                          height: i == 1 ? 20 : 16,
                          width: i == 1 ? double.infinity : 150,
                          decoration: BoxDecoration(
                            color: cs.primary.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ContinueReadingEmptyView extends StatelessWidget {
  final ColorScheme colorScheme;

  const ContinueReadingEmptyView({
    super.key,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(
          Icons.auto_stories_outlined,
          size: 64,
          color: colorScheme.primary,
        ),
        const SizedBox(height: 14),
        Text(
          'No reading progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Books you start reading will appear here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

class ContinueReadingErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ContinueReadingErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 120),
        Icon(Icons.wifi_off_rounded, size: 54, color: cs.error),
        const SizedBox(height: 14),
        Text(
          'Unable to load progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: cs.onSurface,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: cs.onSurfaceVariant),
        ),
        const SizedBox(height: 18),
        FilledButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('Try again'),
        ),
      ],
    );
  }
}