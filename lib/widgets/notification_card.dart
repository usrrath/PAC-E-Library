import 'package:flutter/material.dart';

import '../models/notification_model.dart';

class NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  IconData _icon() {
    switch (notification.type) {
      case 'book_created':
        return Icons.menu_book_rounded;

      case 'favorite':
        return Icons.favorite_rounded;

      default:
        return Icons.notifications_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          child: Icon(_icon()),
        ),
        title: Text(notification.title),
        subtitle: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(notification.message),
            const SizedBox(height: 4),
            Text(notification.time),
          ],
        ),
        trailing: !notification.read
            ? Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: cs.primary,
            shape: BoxShape.circle,
          ),
        )
            : null,
      ),
    );
  }
}