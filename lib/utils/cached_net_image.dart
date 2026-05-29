import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class AppCacheManager {
  AppCacheManager._();

  static final CacheManager imageCache = CacheManager(
    Config(
      'app_image_cache',
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 300,
    ),
  );
}

class CachedNetImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final IconData fallbackIcon;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const CachedNetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fallbackIcon = Icons.menu_book_rounded,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  double? _safeSize(double? value) {
    if (value == null || value.isNaN || value.isInfinite || value <= 0) {
      return null;
    }
    return value;
  }

  int? _cacheSize(double? value) {
    final safe = _safeSize(value);
    if (safe == null) return null;
    return (safe * 2).round();
  }

  bool _isValidUrl(String value) {
    final text = value.trim();
    if (text.isEmpty || text == 'null') return false;
    return text.startsWith('http://') || text.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final safeWidth = _safeSize(width);
    final safeHeight = _safeSize(height);
    final safeUrl = (url ?? '').trim();

    final image = !_isValidUrl(safeUrl)
        ? _fallback(cs, safeWidth, safeHeight)
        : CachedNetworkImage(
      imageUrl: safeUrl,
      cacheManager: AppCacheManager.imageCache,
      width: safeWidth,
      height: safeHeight,
      fit: fit,
      memCacheWidth: _cacheSize(safeWidth),
      memCacheHeight: _cacheSize(safeHeight),
      fadeInDuration: const Duration(milliseconds: 180),
      fadeOutDuration: const Duration(milliseconds: 100),
      placeholder: (_, __) => _loading(cs, safeWidth, safeHeight),
      errorWidget: (_, __, ___) => _fallback(cs, safeWidth, safeHeight),
    );

    if (borderRadius == null) return image;

    return ClipRRect(
      borderRadius: borderRadius!,
      child: image,
    );
  }

  Widget _loading(ColorScheme cs, double? width, double? height) {
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
  }

  Widget _fallback(ColorScheme cs, double? width, double? height) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.center,
      color: cs.primary.withOpacity(0.10),
      child: Icon(
        fallbackIcon,
        color: cs.primary,
        size: 28,
      ),
    );
  }
}