import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedNetImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final IconData fallbackIcon;
  final BoxFit fit;

  const CachedNetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fallbackIcon = Icons.menu_book_rounded,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeUrl = url.trim();

    if (safeUrl.isEmpty) {
      return _fallback(cs);
    }

    return CachedNetworkImage(
      imageUrl: safeUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: width == null ? null : (width! * 2).round(),
      memCacheHeight: height == null ? null : (height! * 2).round(),
      placeholder: (_, __) {
        return Container(
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
        );
      },
      errorWidget: (_, __, ___) => _fallback(cs),
    );
  }

  Widget _fallback(ColorScheme cs) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: cs.primary.withOpacity(0.10),
      child: Icon(
        fallbackIcon,
        color: cs.primary,
      ),
    );
  }
}