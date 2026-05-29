import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class NotificationActionBar extends StatelessWidget {
  final bool loading;
  final bool hasItems;
  final int unreadCount;
  final VoidCallback onReadAll;
  final VoidCallback onClear;

  const NotificationActionBar({
    super.key,
    required this.loading,
    required this.hasItems,
    required this.unreadCount,
    required this.onReadAll,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: !hasItems ||
                  unreadCount == 0 ||
                  loading
                  ? null
                  : onReadAll,
              icon: const Icon(Icons.done_all_rounded),
              label: Text(
                t.notificationsMarkAllRead,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed:
              !hasItems || loading
                  ? null
                  : onClear,
              icon: const Icon(
                Icons.delete_outline_rounded,
              ),
              label: Text(
                t.notificationsClearAll,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: cs.error,
              ),
            ),
          ),
        ],
      ),
    );
  }
}