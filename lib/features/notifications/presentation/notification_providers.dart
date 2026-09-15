import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/providers.dart';
import '../data/notification_network.dart';
import '../data/notification_repository.dart';
import 'notification_model.dart';

final notificationNetworkProvider = Provider<NotificationNetwork>(
  (ref) => DioNotificationNetwork(ref.watch(apiClientProvider)),
);

final notificationRepositoryProvider = Provider<NotificationRepository>(
  (ref) => NotificationRepository(network: ref.watch(notificationNetworkProvider)),
);

final notificationPageProvider =
    FutureProvider.family<NotificationPage, ({bool unreadOnly, int page})>((ref, arg) {
  return ref
      .watch(notificationRepositoryProvider)
      .fetchPage(page: arg.page, unreadOnly: arg.unreadOnly);
});

final notificationUnreadCountProvider = FutureProvider<int>((ref) {
  return ref.watch(notificationRepositoryProvider).fetchUnreadCount();
});

final recentNotificationsProvider = FutureProvider.family<RecentNotifications, int>((ref, limit) {
  return ref.watch(notificationRepositoryProvider).fetchRecent(limit: limit);
});

final notificationRefreshProvider = StateProvider<int>((ref) => 0);
