import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  List<Map<String, dynamic>> notifications = [
    {
      "title": "New Book Available",
      "message": "A new book has been added to your library.",
      "time": "2 min ago",
      "icon": Icons.menu_book_rounded,
      "read": false,
    },
    {
      "title": "Reading Reminder",
      "message": "Continue reading your last opened book.",
      "time": "10 min ago",
      "icon": Icons.auto_stories_rounded,
      "read": false,
    },
    {
      "title": "Favorite Updated",
      "message": "One of your favorite books has new updates.",
      "time": "1 hour ago",
      "icon": Icons.favorite_rounded,
      "read": true,
    },
    {
      "title": "Trending Book",
      "message": "A popular book is trending this week.",
      "time": "3 hours ago",
      "icon": Icons.local_fire_department_rounded,
      "read": true,
    },
  ];

  void _markAllRead() {
    setState(() {
      notifications = notifications.map((e) {
        return {
          ...e,
          "read": true,
        };
      }).toList();
    });
  }

  void _clearAll() {
    setState(() {
      notifications.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "Notifications",
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          TextButton(
            onPressed: notifications.isEmpty
                ? null
                : _markAllRead,
            child: const Text(
              "Mark read",
            ),
          ),

          TextButton(
            onPressed: notifications.isEmpty
                ? null
                : _clearAll,
            child: const Text(
              "Clear",
            ),
          ),

          const SizedBox(width: 8),
        ],
      ),

      body: notifications.isEmpty
          ? Center(
        child: Text(
          "No notifications",
          style: TextStyle(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      )
          : ListView.separated(
        padding:
        const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: notifications.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = notifications[i];
          final bool isRead =
              item["read"] as bool? ?? false;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isRead
                  ? Theme.of(context).cardColor
                  : cs.primary.withOpacity(0.05),
              borderRadius:
              BorderRadius.circular(18),
              border: Border.all(
                color: cs.primary.withOpacity(0.12),
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 14,
                  color:
                  Colors.black.withOpacity(0.05),
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                  cs.primary.withOpacity(0.12),
                  child: Icon(
                    item["icon"] as IconData,
                    color: cs.primary,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item["title"] as String,
                              style: TextStyle(
                                fontWeight:
                                FontWeight.w900,
                                color: cs.onSurface,
                              ),
                            ),
                          ),

                          if (!isRead)
                            Container(
                              width: 10,
                              height: 10,
                              decoration:
                              BoxDecoration(
                                color: cs.primary,
                                shape:
                                BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 4),

                      Text(
                        item["message"] as String,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style: TextStyle(
                          color:
                          cs.onSurfaceVariant,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        item["time"] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w600,
                          color: cs.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.primary,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}