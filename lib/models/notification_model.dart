import '../l10n/app_localizations.dart';
import '../utils/notification_utils.dart';

class AppNotification {
  final String id;
  final String title;
  final String message;
  final String time;
  final String type;
  final bool read;

  const AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.type,
    required this.read,
  });

  factory AppNotification.fromJson(
      Map<String, dynamic> json,
      AppLocalizations t,
      ) {
    return AppNotification(
      id: strValue(json, const ['id']),
      title: strValue(
        json,
        const ['title', 'type'],
        fallback: t.notificationsDefaultTitle,
      ),
      message: strValue(
        json,
        const ['message', 'body', 'description'],
      ),
      time: formatNotificationTime(
        strValue(
          json,
          const ['created_at', 'updated_at', 'time'],
        ),
        t,
      ),
      type: strValue(json, const ['type']),
      read:
      json['read_at'] != null ||
          boolValue(json, const ['read', 'is_read']),
    );
  }

  AppNotification copyWith({
    bool? read,
  }) {
    return AppNotification(
      id: id,
      title: title,
      message: message,
      time: time,
      type: type,
      read: read ?? this.read,
    );
  }
}