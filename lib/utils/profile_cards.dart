import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ProfileImageCache {
  const ProfileImageCache._();

  static CacheManager manager = CacheManager(
    Config(
      'profileImageCache',
      stalePeriod: const Duration(days: 14),
      maxNrOfCacheObjects: 120,
    ),
  );
}

class CachedProfileImage extends StatelessWidget {
  final String url;
  final double width;
  final double height;
  final double radius;
  final IconData fallbackIcon;
  final BoxFit fit;

  const CachedProfileImage({
    super.key,
    required this.url,
    this.width = 56,
    this.height = 56,
    this.radius = 14,
    this.fallbackIcon = Icons.person_rounded,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final cleanUrl = ProfileUtils.safeText(url);

    Widget fallback() {
      return Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: cs.primary.withOpacity(0.12),
          borderRadius: BorderRadius.circular(radius),
        ),
        alignment: Alignment.center,
        child: Icon(
          fallbackIcon,
          color: cs.primary,
          size: width * 0.46,
        ),
      );
    }

    if (cleanUrl.isEmpty) return fallback();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CachedNetworkImage(
        imageUrl: cleanUrl,
        cacheManager: ProfileImageCache.manager,
        width: width,
        height: height,
        fit: fit,
        fadeInDuration: const Duration(milliseconds: 180),
        fadeOutDuration: const Duration(milliseconds: 120),
        placeholder: (_, __) => Container(
          width: width,
          height: height,
          color: cs.surfaceContainerHighest.withOpacity(0.45),
          alignment: Alignment.center,
          child: SizedBox(
            width: width * 0.28,
            height: width * 0.28,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => fallback(),
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final Widget child;

  const ProfileCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.primary.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            blurRadius: 14,
            color: Colors.black.withOpacity(isDark ? 0.18 : 0.04),
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class ProfileBadge extends StatelessWidget {
  final String text;

  const ProfileBadge({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: cs.primary,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class EmptyProfileCard extends StatelessWidget {
  final String text;

  const EmptyProfileCard({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ProfileCard(
      child: Text(
        text,
        style: TextStyle(color: cs.onSurfaceVariant),
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ProfileStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ProfileCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: cs.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileUtils {
  const ProfileUtils._();

  static String safeText(
      dynamic value, {
        String fallback = '',
      }) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  static double normalizeProgress(double value) {
    final safe = value > 1 ? value / 100 : value;
    return safe.clamp(0.0, 1.0).toDouble();
  }

  static int safePage(int value) {
    return value <= 0 ? 1 : value;
  }
}