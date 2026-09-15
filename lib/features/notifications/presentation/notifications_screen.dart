import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../shared/widgets/branded_header.dart';
import 'notification_model.dart';
import 'notification_providers.dart';

/// Notifications queue matching the stitch screen 10 mockup: branded header
/// with unread count badge + "Mark all as read", pill filter chips, and
/// card-based notification tiles with an unread indicator strip.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _scroll = ScrollController();
  final List<AppNotification> _notifications = [];
  bool _unreadOnly = false;
  bool _loadingMore = false;
  int _page = 1;
  int _lastPage = 1;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadFirst();
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadFirst() async {
    ref.invalidate(notificationPageProvider((unreadOnly: _unreadOnly, page: 1)));
    final page = await ref.read(notificationPageProvider((unreadOnly: _unreadOnly, page: 1)).future);
    if (!mounted) return;
    setState(() {
      _page = page.meta.currentPage ?? 1;
      _lastPage = page.meta.lastPage ?? 1;
      _notifications
        ..clear()
        ..addAll(page.data);
    });
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 250) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore || _page >= _lastPage) return;
    setState(() => _loadingMore = true);
    try {
      final nextPage = _page + 1;
      final page = await ref.read(
        notificationPageProvider((unreadOnly: _unreadOnly, page: nextPage)).future,
      );
      if (!mounted) return;
      setState(() {
        _page = page.meta.currentPage ?? nextPage;
        _lastPage = page.meta.lastPage ?? _lastPage;
        _notifications.addAll(page.data);
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  void _setFilter(bool unreadOnly) {
    if (_unreadOnly == unreadOnly) return;
    setState(() => _unreadOnly = unreadOnly);
    _loadFirst();
  }

  Future<void> _markAllRead() async {
    try {
      await ref.read(notificationRepositoryProvider).markAllRead();
      ref.invalidate(notificationUnreadCountProvider);
      ref.invalidate(recentNotificationsProvider(5));
      await _loadFirst();
    } on ApiException catch (error) {
      _snack(error.message);
    } catch (_) {
      _snack('Could not mark notifications as read.');
    }
  }

  Future<void> _openNotification(AppNotification notification) async {
    try {
      final result = await ref.read(notificationRepositoryProvider).open(notification.id);
      ref.invalidate(notificationUnreadCountProvider);
      ref.invalidate(recentNotificationsProvider(5));
      await _loadFirst();
      final url = result.openUrl ?? notification.link;
      if (url != null && url.isNotEmpty) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      }
    } on ApiException catch (error) {
      _snack(error.message);
    } catch (_) {
      _snack('Could not open notification.');
    }
  }

  Future<void> _markRead(AppNotification notification) async {
    try {
      await ref.read(notificationRepositoryProvider).markRead(notification.id);
      ref.invalidate(notificationUnreadCountProvider);
      ref.invalidate(recentNotificationsProvider(5));
      await _loadFirst();
    } on ApiException catch (error) {
      _snack(error.message);
    } catch (_) {
      _snack('Could not mark notification as read.');
    }
  }

  void _snack(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(notificationPageProvider((unreadOnly: _unreadOnly, page: _page)));
    final unread = ref.watch(notificationUnreadCountProvider).valueOrNull ?? 0;

    return Scaffold(
      appBar: BrandedHeader(
        title: 'Notifications',
        onBack: () => Navigator.of(context).pop(),
        actions: [
          if (unread > 0) _unreadBadge(unread),
          TextButton(
            onPressed: unread == 0 ? null : _markAllRead,
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Filter pills ──
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                _filterPill(
                  label: 'All ${_notifications.length}',
                  selected: !_unreadOnly,
                  onSelected: () => _setFilter(false),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _filterPill(
                    label: 'Unread $unread',
                    selected: _unreadOnly,
                    onSelected: () => _setFilter(true),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: page.when(
              loading: () => _notifications.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _list(),
              error: (error, _) => _notifications.isEmpty
                  ? _ErrorView(
                      message: error is ApiException
                          ? error.message
                          : 'Could not load notifications.',
                      onRetry: _loadFirst,
                    )
                  : _list(),
              data: (_) => _notifications.isEmpty ? const _EmptyState() : _list(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _list() => RefreshIndicator(
        onRefresh: _loadFirst,
        child: ListView.builder(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          itemCount: _notifications.length + (_loadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= _notifications.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final notification = _notifications[index];
            return _NotificationTile(
              notification: notification,
              onTap: () => _openNotification(notification),
              onMarkRead: notification.read ? null : () => _markRead(notification),
            );
          },
        ),
      );

  /// Pill-shaped unread count badge (secondary-fixed tint).
  static Widget _unreadBadge(int count) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: FieldOpsDesignTokens.secondaryFixed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count New',
        style: TextStyle(
          color: FieldOpsDesignTokens.onSecondaryFixed,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.04,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  /// Pill-shaped filter chip.
  Widget _filterPill({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      showCheckmark: false,
      selectedColor: FieldOpsDesignTokens.secondaryFixed,
      backgroundColor: const Color(0xFFF1F5F9),
      side: BorderSide.none,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        fontFamily: 'Inter',
        color: selected
            ? FieldOpsDesignTokens.onSecondaryFixed
            : FieldOpsDesignTokens.textSubtext,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.radiusFull),
      ),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.onTap,
    this.onMarkRead,
  });

  final AppNotification notification;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;

  IconData get _icon => switch (notification.type) {
        'ticket' => Icons.confirmation_number_outlined,
        'request' => Icons.assignment_outlined,
        _ => Icons.info_outline,
      };

  Color get _iconColor => switch (notification.type) {
        'ticket' => FieldOpsDesignTokens.primary,
        'request' => FieldOpsDesignTokens.completedForeground,
        _ => FieldOpsDesignTokens.secondary,
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unread = !notification.read;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: FieldOpsDesignTokens.shadowLevel1,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(FieldOpsDesignTokens.cardRadius),
        onTap: onTap,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Unread indicator strip (3dp primary bar on the left edge).
              if (unread)
                Container(
                  width: 3,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(14),
                      bottomLeft: Radius.circular(14),
                    ),
                  ),
                )
              else
                const SizedBox(width: 3),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(13, 14, 16, 14),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon circle.
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _iconColor.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_icon, size: 20, color: _iconColor),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: unread ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              notification.message,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (notification.createdAt != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                notification.createdAt!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                            if (onMarkRead != null) ...[
                              const SizedBox(height: 4),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: onMarkRead,
                                  child: Text(
                                    'Mark read',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: theme.colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 48),
        SizedBox(
          height: 140,
          width: 140,
          child: Center(
            child: Lottie.asset('assets/lottie/empty_list.json', repeat: true),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'No notifications',
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'You\'re all caught up.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      );
}