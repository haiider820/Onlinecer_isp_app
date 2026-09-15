import '../../../models/connection_request.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.link,
    required this.read,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String type;
  final String title;
  final String message;
  final String? link;
  final bool read;
  final String? readAt;
  final String? createdAt;
  final String? updatedAt;

  factory AppNotification.fromJson(Map<String, Object?> json) => AppNotification(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? 'system',
        title: json['title']?.toString() ?? 'Notification',
        message: json['message']?.toString() ?? '',
        link: json['link']?.toString(),
        read: json['read'] == true,
        readAt: json['read_at']?.toString(),
        createdAt: json['created_at']?.toString(),
        updatedAt: json['updated_at']?.toString(),
      );

  AppNotification copyWith({bool? read, String? readAt}) => AppNotification(
        id: id,
        type: type,
        title: title,
        message: message,
        link: link,
        read: read ?? this.read,
        readAt: readAt ?? this.readAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}

class NotificationPage {
  const NotificationPage({required this.data, required this.meta});

  final List<AppNotification> data;
  final PaginationMeta meta;

  factory NotificationPage.fromJson(Map<String, Object?> json) => NotificationPage(
        data: [
          for (final item in (json['data'] as List? ?? const []))
            if (item is Map) AppNotification.fromJson(Map<String, Object?>.from(item)),
        ],
        meta: PaginationMeta.fromJson(
          Map<String, Object?>.from(json['meta'] as Map? ?? const {}),
        ),
      );
}

class RecentNotifications {
  const RecentNotifications({required this.unread, required this.notifications});

  final int unread;
  final List<AppNotification> notifications;

  factory RecentNotifications.fromJson(Map<String, Object?> json) => RecentNotifications(
        unread: _int(json['unread']) ?? 0,
        notifications: [
          for (final item in (json['notifications'] as List? ?? const []))
            if (item is Map) AppNotification.fromJson(Map<String, Object?>.from(item)),
        ],
      );
}

class NotificationOpenResult {
  const NotificationOpenResult({this.message, this.openUrl, this.notification});

  final String? message;
  final String? openUrl;
  final AppNotification? notification;

  factory NotificationOpenResult.fromJson(Map<String, Object?> json) {
    final notification = json['notification'];
    return NotificationOpenResult(
      message: json['message']?.toString(),
      openUrl: json['open_url']?.toString(),
      notification: notification is Map
          ? AppNotification.fromJson(Map<String, Object?>.from(notification))
          : null,
    );
  }
}

int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
