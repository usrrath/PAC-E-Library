import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

class NotificationEmptyView
    extends StatelessWidget {
  const NotificationEmptyView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.notifications_none_rounded,
            size: 70,
          ),
          const SizedBox(height: 16),
          Text(t.notificationsEmptyTitle),
          const SizedBox(height: 8),
          Text(
            t.notificationsEmptySubtitle,
          ),
        ],
      ),
    );
  }
}