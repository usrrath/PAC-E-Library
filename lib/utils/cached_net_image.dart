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

  double? _safeSize(double? value) {
    if (value == null) return null;

    if (value.isNaN || value.isInfinite || value <= 0) {
      return null;
    }

    return value;
  }

  int? _cacheSize(double? value) {
    final safe = _safeSize(value);

    if (safe == null) return null;

    return (safe * 2).round();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeUrl = url.trim();

    final safeWidth = _safeSize(width);
    final safeHeight = _safeSize(height);

    if (safeUrl.isEmpty) {
      return _fallback(cs, safeWidth, safeHeight);
    }

    return CachedNetworkImage(
      imageUrl: safeUrl,
      width: safeWidth,
      height: safeHeight,
      fit: fit,

      memCacheWidth: _cacheSize(safeWidth),
      memCacheHeight: _cacheSize(safeHeight),

      placeholder: (_, __) {
        return Container(
          width: safeWidth,
          height: safeHeight,
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

      errorWidget: (_, __, ___) {
        return _fallback(cs, safeWidth, safeHeight);
      },
    );
  }

  Widget _fallback(
      ColorScheme cs,
      double? width,
      double? height,
      ) {
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