import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/dashboard.dart';
import '../../auth/presentation/providers.dart';
import '../data/dashboard_network.dart';
import '../data/dashboard_repository.dart';

/// Real HTTP-backed dashboard network.
final dashboardNetworkProvider = Provider<DashboardNetwork>((ref) {
  return DioDashboardNetwork(ref.watch(apiClientProvider));
});

/// Dashboard repository wiring the network layer.
final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository(network: ref.watch(dashboardNetworkProvider));
});

/// Fetches the dashboard summary. Auto-disposed when the screen leaves, so a
/// login/session change can never be served a summary (or cached 401 error)
/// fetched under a previous session — the next dashboard mount refetches.
final dashboardSummaryProvider = FutureProvider.autoDispose<DashboardSummary>((ref) {
  return ref.watch(dashboardRepositoryProvider).fetch();
});