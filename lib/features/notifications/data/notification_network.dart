import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

abstract interface class NotificationNetwork {
  Future<Map<String, dynamic>> fetchPage({
    required int page,
    bool unreadOnly,
  });
  Future<Map<String, dynamic>> fetchUnreadCount();
  Future<Map<String, dynamic>> fetchRecent({int limit = 10});
  Future<Map<String, dynamic>> markRead(String id);
  Future<Map<String, dynamic>> markAllRead();
  Future<Map<String, dynamic>> open(String id);
}

class DioNotificationNetwork implements NotificationNetwork {
  DioNotificationNetwork(this._client);

  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchPage({
    required int page,
    bool unreadOnly = false,
  }) =>
      _client.getMap(
        Endpoints.notifications,
        query: {
          'page': page,
          'per_page': 25,
          if (unreadOnly) 'filter': 'unread',
        },
      );

  @override
  Future<Map<String, dynamic>> fetchUnreadCount() =>
      _client.getMap(Endpoints.notificationUnreadCount);

  @override
  Future<Map<String, dynamic>> fetchRecent({int limit = 10}) => _client.getMap(
        Endpoints.notificationRecent,
        query: {'limit': limit},
      );

  @override
  Future<Map<String, dynamic>> markRead(String id) =>
      _client.postMap(Endpoints.notificationRead(id));

  @override
  Future<Map<String, dynamic>> markAllRead() =>
      _client.postMap(Endpoints.notificationReadAll);

  @override
  Future<Map<String, dynamic>> open(String id) =>
      _client.postMap(Endpoints.notificationOpen(id));
}
