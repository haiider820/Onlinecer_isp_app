import '../presentation/notification_model.dart';
import 'notification_network.dart';

class NotificationRepository {
  NotificationRepository({required this.network});

  final NotificationNetwork network;

  Future<NotificationPage> fetchPage({required int page, bool unreadOnly = false}) async =>
      NotificationPage.fromJson(await network.fetchPage(page: page, unreadOnly: unreadOnly));

  Future<int> fetchUnreadCount() async {
    final map = await network.fetchUnreadCount();
    final value = map['count'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<RecentNotifications> fetchRecent({int limit = 10}) async =>
      RecentNotifications.fromJson(await network.fetchRecent(limit: limit));

  Future<AppNotification?> markRead(String id) async {
    final map = await network.markRead(id);
    final notification = map['notification'];
    return notification is Map
        ? AppNotification.fromJson(Map<String, Object?>.from(notification))
        : null;
  }

  Future<int> markAllRead() async {
    final map = await network.markAllRead();
    final value = map['updated'];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<NotificationOpenResult> open(String id) async =>
      NotificationOpenResult.fromJson(await network.open(id));
}
