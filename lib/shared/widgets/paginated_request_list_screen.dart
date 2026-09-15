import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../core/network/api_exceptions.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/field_ops_design_tokens.dart';
import '../../models/connection_request.dart';
import 'branded_header.dart';
import 'request_card.dart';

/// Shared, paginated list of connection requests for a team queue.
///
/// Owns the page accumulation / infinite-scroll / pull-to-refresh / back
/// behavior used by every team's request list, so feature screens stay thin
/// wrappers. The caller supplies the [pageProvider] (keyed by 1-based page —
/// it may encode a server-side status filter) and a [detailRouteFor] builder
/// for tap-through.
///
/// Adds optional client-side status filter chips and a text search bar
/// (matching the DESIGN.md dispatch-card list mockup). The status chips
/// are computed from the loaded data; the search is a debounced name-area
/// filter. Both are purely client-side since the server returns the full
/// team-scoped queue already.
class PaginatedRequestListScreen extends ConsumerStatefulWidget {
  const PaginatedRequestListScreen({
    super.key,
    required this.title,
    required this.pageProvider,
    this.detailRouteFor,
  });

  /// AppBar title, e.g. 'Survey Requests'.
  final String title;

  /// Produces page N of the queue. Survey uses [connectionRequestsProvider]
  /// (no filter); installation filters by `installation_assigned` server-side.
  final FutureProviderFamily<ConnectionRequestPage, int> pageProvider;

  /// Concrete detail path for a given request id.
  final String Function(String id)? detailRouteFor;

  @override
  ConsumerState<PaginatedRequestListScreen> createState() => _PaginatedRequestListScreenState();
}

class _PaginatedRequestListScreenState extends ConsumerState<PaginatedRequestListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  int _currentPage = 1;
  final List<ConnectionRequest> _requests = [];
  PaginationMeta? _meta;
  bool _loadingMore = false;

  /// Active status filter (`null` = show all).
  String? _statusFilter;

  /// Search query applied after a debounce.
  String _searchQuery = '';

  /// Whether the collapsible search bar is currently visible.
  bool _searchVisible = true;

  /// All loaded requests, unfiltered — used for chip counts.
  List<ConnectionRequest> get _allLoaded => _requests;

  /// Requests visible after applying the active status + search filters.
  List<ConnectionRequest> get _filtered {
    return _requests.where((r) {
      if (_statusFilter != null && r.status != _statusFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final name = (r.customerName ?? '').toLowerCase();
        final area = (r.customerArea ?? '').toLowerCase();
        final num = r.requestNumber.toLowerCase();
        if (!name.contains(q) && !area.contains(q) && !num.contains(q)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  /// Unique statuses present in the loaded data, for chip generation.
  List<String> get _statusesInData {
    final seen = <String>{};
    for (final r in _allLoaded) {
      if (r.status.isNotEmpty) seen.add(r.status);
    }
    return seen.toList()..sort();
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Page 1 isn't fetched by _loadMore (which starts at page 2 and only runs
    // once a page is already on screen), so load it explicitly or the list
    // shows the empty state on first entry even when requests exist.
    _preloadFirstPage();
  }

  Future<void> _preloadFirstPage() async {
    try {
      final first = await ref.read(widget.pageProvider(1).future);
      if (!mounted) return;
      setState(() {
        _meta = first.meta;
        _requests.addAll(first.data);
      });
    } catch (_) {
      // The first page's error state is rendered through the watched provider.
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final hasMore = (_meta?.lastPage ?? _currentPage) > _currentPage;
    if (_loadingMore || !hasMore) return;
    setState(() => _loadingMore = true);
    final nextPage = _currentPage + 1;
    try {
      final next = await ref.read(widget.pageProvider(nextPage).future);
      if (!mounted) return;
      setState(() {
        _currentPage = nextPage;
        _meta = next.meta;
        _requests.addAll(next.data);
      });
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(widget.pageProvider(1));
    final first = await ref.read(widget.pageProvider(1).future);
    if (!mounted) return;
    setState(() {
      _currentPage = 1;
      _meta = first.meta;
      _requests
        ..clear()
        ..addAll(first.data);
    });
  }

  @override
  Widget build(BuildContext context) {
    final page = ref.watch(widget.pageProvider(_currentPage));
    // True when the list sits above another route (pushed from the dashboard);
    // false when a submit replaced the stack via `go` — in that case both the
    // AppBar back button and the system back gesture should fall through to
    // the dashboard instead of exiting the app.
    final canPop = Navigator.of(context).canPop();

    final Widget scaffold;
    // Error state — also marks the very first failure before history exists.
    if (page.hasError && _requests.isEmpty) {
      scaffold = Scaffold(
        appBar: _buildHeader(canPop),
        body: _ErrorView(
          message: page.error is ApiException
              ? (page.error! as ApiException).message
              : 'Something went wrong.',
          onRetry: () => ref.invalidate(widget.pageProvider(_currentPage)),
        ),
      );
    } else {
      scaffold = Scaffold(
        appBar: _buildHeader(canPop),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: _body(page),
        ),
      );
    }

    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.dashboard);
      },
      child: scaffold,
    );
  }

  /// Branded header (matches the stitch request-list mockup): back button,
  /// title, active-count pill and a search toggle.
  PreferredSizeWidget _buildHeader(bool canPop) {
    final activeCount = _meta?.total ?? _allLoaded.length;
    return BrandedHeader(
      title: widget.title,
      onBack: () => canPop ? context.pop() : context.go(Routes.dashboard),
      actions: [
        if (activeCount > 0) _activeCountBadge(count: activeCount),
        IconButton(
          tooltip: _searchVisible ? 'Hide search' : 'Search requests',
          onPressed: () => setState(() => _searchVisible = !_searchVisible),
          icon: Icon(_searchVisible ? Icons.close : Icons.search),
        ),
      ],
    );
  }

  /// Pill with the active-request count (secondary-fixed tint).
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

  Widget _body(AsyncValue<ConnectionRequestPage> page) {
    // First page still loading → full-screen spinner.
    if (page.isLoading && _requests.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final filtered = _filtered;

    return Column(
      children: [
        // Collapsible search bar (toggled from the header search icon).
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _searchVisible
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search requests',
                      // Slimmer search field per mockup (40dp, quiet fill).
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (value) {
                      _searchDebounce?.cancel();
                      _searchDebounce = Timer(
                        const Duration(milliseconds: 350),
                        () => setState(() => _searchQuery = value),
                      );
                    },
                  ),
                )
              : const SizedBox.shrink(),
        ),
        // Status filter pills — horizontal scroll, counts from loaded data.
        if (_statusesInData.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              children: [
                _filterPill(
                  label: 'All ${_meta?.total ?? _allLoaded.length}',
                  selected: _statusFilter == null,
                  onSelected: () => setState(() => _statusFilter = null),
                ),
                for (final status in _statusesInData)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _filterPill(
                      label: '${_formatStatus(status)} ${_statusCount(status)}',
                      selected: _statusFilter == status,
                      onSelected: () => setState(() => _statusFilter = status),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(height: 4),
        // Request list.
        Expanded(
          child: filtered.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 40),
                    Center(
                      child: SizedBox(
                        height: 140,
                        width: 140,
                        child: Lottie.asset(
                          'assets/lottie/empty_list.json',
                          repeat: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        _requests.isEmpty
                            ? 'No connection requests yet.'
                            : 'No requests match this filter.',
                      ),
                    ),
                  ],
                )
              : ListView.builder(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length + (_loadingMore || page.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index >= filtered.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final request = filtered[index];
                    return RequestCard(
                      request: request,
                      onTap: widget.detailRouteFor == null
                          ? null
                          : () => context.push(widget.detailRouteFor!(request.id)),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Formats `survey_assigned` → `Survey Assigned`.
  static String _formatStatus(String status) =>
      status.replaceAll('_', ' ').split(' ').map((w) => w[0].toUpperCase() + w.substring(1)).join(' ');

  /// Number of loaded requests with the given status (for chip counts).
  int _statusCount(String status) =>
      _allLoaded.where((r) => r.status == status).length;

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

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ],
        ),
      ),
    );
  }
}
