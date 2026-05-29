import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../utils/notification_utils.dart';
import '../widgets/notification_action_bar.dart';
import '../widgets/notification_card.dart';
import '../widgets/notification_empty_view.dart';
import '../widgets/notification_error_view.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({
    super.key,
  });

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final NotificationService _service = NotificationService();

  bool loading = true;
  bool actionLoading = false;
  bool changed = false;
  bool _initialized = false;

  String? error;

  List<AppNotification> notifications = [];

  int get unreadCount => notifications.where((e) => !e.read).length;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _initialized = true;
      loadNotifications();
    }
  }

  void _goBack() {
    Navigator.pop(context, changed);
  }

  Future<void> loadNotifications() async {
    final t = AppLocalizations.of(context)!;

    if (!mounted) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final response = await _service.getNotifications();

      final items = extractNotificationList(response)
          .whereType<Map>()
          .map(
            (e) => AppNotification.fromJson(
          Map<String, dynamic>.from(e),
          t,
        ),
      )
          .where((e) => e.id.isNotEmpty || e.title.isNotEmpty)
          .toList();

      if (!mounted) return;

      setState(() {
        notifications = items;
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        error = t.notificationsConnectionError;
        loading = false;
      });
    }
  }

  Future<void> markAllRead() async {
    final t = AppLocalizations.of(context)!;

    if (notifications.isEmpty || actionLoading || unreadCount == 0) return;

    final old = List<AppNotification>.from(notifications);

    setState(() {
      actionLoading = true;
      changed = true;
      notifications = notifications.map((e) => e.copyWith(read: true)).toList();
    });

    try {
      await _service.request(
        '/api/notifications/read-all',
        method: 'PATCH',
      );

      if (!mounted) return;
      _showMessage(t.notificationsMarkedAllRead);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        notifications = old;
      });

      _showMessage(
        t.notificationsActionFailed,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          actionLoading = false;
        });
      }
    }
  }

  Future<void> clearAll() async {
    final t = AppLocalizations.of(context)!;

    if (notifications.isEmpty || actionLoading) return;

    final old = List<AppNotification>.from(notifications);

    setState(() {
      actionLoading = true;
      changed = true;
      notifications.clear();
    });

    try {
      await _service.request(
        '/api/notifications/clear-all',
        method: 'DELETE',
      );

      if (!mounted) return;
      _showMessage(t.notificationsCleared);
    } catch (_) {
      if (!mounted) return;

      setState(() {
        notifications = old;
      });

      _showMessage(
        t.notificationsActionFailed,
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          actionLoading = false;
        });
      }
    }
  }

  Future<void> markOneRead(AppNotification item) async {
    final t = AppLocalizations.of(context)!;

    if (item.id.isEmpty || item.read || actionLoading) return;

    final index = notifications.indexWhere((e) => e.id == item.id);

    if (index < 0) return;

    final old = List<AppNotification>.from(notifications);

    setState(() {
      changed = true;
      notifications[index] = item.copyWith(read: true);
    });

    try {
      await _service.request(
        '/api/notifications/${item.id}/read',
        method: 'PATCH',
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        notifications = old;
      });

      _showMessage(
        t.notificationsActionFailed,
        isError: true,
      );
    }
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    final cs = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? cs.error : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _goBack();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _goBack,
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t.notifications,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                ),
              ),
              Text(
                unreadCount > 0
                    ? t.notificationsUnread(unreadCount)
                    : t.notificationsAllCaughtUp,
                style: TextStyle(
                  color: unreadCount > 0 ? cs.primary : cs.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            NotificationActionBar(
              loading: actionLoading,
              hasItems: notifications.isNotEmpty,
              unreadCount: unreadCount,
              onReadAll: markAllRead,
              onClear: clearAll,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: loadNotifications,
                child: loading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : error != null
                    ? NotificationErrorView(
                  message: error!,
                  onRetry: loadNotifications,
                )
                    : notifications.isEmpty
                    ? const NotificationEmptyView()
                    : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    8,
                    16,
                    16,
                  ),
                  itemCount: notifications.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = notifications[index];

                    return NotificationCard(
                      notification: item,
                      onTap: () => markOneRead(item),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}