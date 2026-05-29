import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/cached_net_image.dart';

class ProfileAvatar extends StatelessWidget {
  final String photoUrl;
  final File? selectedPhoto;
  final double size;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    required this.selectedPhoto,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (selectedPhoto != null) {
      return ClipOval(
        child: Image.file(
          selectedPhoto!,
          key: ValueKey(selectedPhoto!.path),
          width: size,
          height: size,
          fit: BoxFit.cover,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) {
            return AvatarFallback(size: size);
          },
        ),
      );
    }

    if (photoUrl.trim().isEmpty) {
      return AvatarFallback(size: size);
    }

    return ClipOval(
      child: CachedNetImage(
        url: photoUrl,
        width: size,
        height: size,
        fallbackIcon: Icons.person_rounded,
      ),
    );
  }
}

class AvatarFallback extends StatelessWidget {
  final double size;
  final bool loading;

  const AvatarFallback({
    super.key,
    required this.size,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: cs.primary.withOpacity(0.10),
      ),
      child: loading
          ? SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: cs.primary,
        ),
      )
          : Icon(
        Icons.person_rounded,
        color: cs.primary,
        size: size * 0.48,
      ),
    );
  }
}