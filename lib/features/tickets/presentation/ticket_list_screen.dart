import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../../core/network/api_exceptions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/field_ops_design_tokens.dart';
import '../../../models/connection_request.dart';
import '../../../models/ticket.dart';
import '../../../shared/widgets/branded_header.dart';
import '../../../shared/widgets/ticket_card.dart';
import 'ticket_providers.dart';

/// Ticket queue for the logged-in employee, matching the stitch ticket-list
/// mockup: branded header with an active-count pill and search toggle, pill
/// status filters, and the shared [TicketCard] list. Pagination, server-side
/// status/search queries and pull-to-refresh are preserved unchanged.
class TicketListScreen extends ConsumerStatefulWidget {
  const TicketListScreen({super.key});
  @override
  ConsumerState<TicketListScreen> createState() => _TicketListScreenState();
}

class _TicketListScreenState extends ConsumerState<TicketListScreen> {
  final _search = TextEditingController();
  final _scroll = ScrollController();
  TicketQuery _query = const TicketQuery();
  final List<Ticket> _tickets = [];
  PaginationMeta? _meta;
  int _page = 1;
  bool _loadingMore = false;
  Timer? _debounce;
  bool _searchVisible = true;

  static const _statuses = <String>[
    'OPEN', 'IN_PROGRESS', 'WAITING_CUSTOMER', 'RESOLVED', 'CLOSED',
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    _loadFirst();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadFirst() async {
    try {
      final result = await ref.read(ticketPageProvider((query: _query, page: 1)).future);
      if (!mounted) return;
      setState(() { _page = 1; _meta = result.meta; _tickets..clear()..addAll(result.data); });
    } catch (_) {}
  }

  void _onScroll() {
    if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 250) _loadMore();
  }

  Future<void> _loadMore() async {
    if (_loadingMore || (_meta?.lastPage ?? 1) <= _page) return;
    setState(() => _loadingMore = true);
    try {
      final next = await ref.read(ticketPageProvider((query: _query, page: _page + 1)).future);
      if (!mounted) return;
      setState(() { _page++; _meta = next.meta; _tickets.addAll(next.data); });
    } finally { if (mounted) setState(() => _loadingMore = false); }
  }

  void _setQuery({String? status, String? search}) {
    setState(() => _query = TicketQuery(status: status, search: search));
    _loadFirst();
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(ticketPageProvider((query: _query, page: _page)));
    final canPop = Navigator.of(context).canPop();
    final activeCount = _meta?.total ?? _tickets.length;

    return Scaffold(
      appBar: BrandedHeader(
        title: 'My Tickets',
        onBack: () => canPop ? context.pop() : context.go(Routes.dashboard),
        actions: [
          if (activeCount > 0) _activeCountBadge(count: activeCount),
          IconButton(
            tooltip: _searchVisible ? 'Hide search' : 'Search tickets',
            onPressed: () => setState(() => _searchVisible = !_searchVisible),
            icon: Icon(_searchVisible ? Icons.close : Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          // Collapsible search bar.
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _searchVisible
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: TextField(
                      controller: _search,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        hintText: 'Search tickets',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                      onChanged: (value) {
                        _debounce?.cancel();
                        _debounce = Timer(
                          const Duration(milliseconds: 350),
                          () => _setQuery(status: _query.status, search: value),
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Filter pills (horizontal scroll).
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                _filterPill(
                  label: 'All ${_meta?.total ?? _tickets.length}',
                  selected: _query.status == null,
                  onSelected: () => _setQuery(search: _search.text),
                ),
                for (final status in _statuses)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _filterPill(
                      label: _format(status),
                      selected: _query.status == status,
                      onSelected: () => _setQuery(status: status, search: _search.text),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: page.when(
              loading: () => _tickets.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : _list(),
              error: (error, _) => _tickets.isEmpty
                  ? _Error(
                      message: error is ApiException
                          ? error.message
                          : 'Could not load tickets.',
                      onRetry: _loadFirst,
                    )
                  : _list(),
              data: (_) => _tickets.isEmpty ? _emptyState() : _list(),
            ),
          ),
        ],
      ),
    );
  }

  /// Pill with the total ticket count (secondary-fixed tint).
  static Widget _activeCountBadge({required int count}) {
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: FieldOpsDesignTokens.secondaryFixed,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count Active',
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

  Widget _list() => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(ticketPageProvider((query: _query, page: 1)));
          await _loadFirst();
        },
        child: ListView.builder(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: _tickets.length + (_loadingMore ? 1 : 0),
          itemBuilder: (context, index) => index == _tickets.length
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              : TicketCard(
                  ticket: _tickets[index],
                  onTap: () => context.push(Routes.ticketDetailFor(_tickets[index].id)),
                ),
        ),
      );

  /// Empty-queue state with the shared empty-list animation.
  Widget _emptyState() {
    final theme = Theme.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
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
          'No tickets found.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static String _format(String status) =>
      status.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  /// Pill-shaped status filter chip: secondary-fixed when selected, quiet
  /// neutral surface otherwise (DESIGN.md §Semantic Status Badges).
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

class _Error extends StatelessWidget {
  const _Error({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}