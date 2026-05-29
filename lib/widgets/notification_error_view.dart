import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class NotificationErrorView
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const NotificationErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              t.notificationsUnableToLoad,
            ),
            const SizedBox(height: 8),
            Text(message),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: Text(
                t.notificationsRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}