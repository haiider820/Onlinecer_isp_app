import '../../../models/dashboard.dart';
import 'dashboard_network.dart';

/// Fetches the survey dashboard summary from `GET /dashboard`.
///
/// Failures surface as typed [ApiException]s (see `api_exceptions.dart`),
/// consistent with the rest of the app.
class DashboardRepository {
  DashboardRepository({required this.network});

  final DashboardNetwork network;

  Future<DashboardSummary> fetch() async {
    final map = await network.fetchDashboard();
    // The shared request counter calls the active bucket `pending`, while the
    // ticket API calls the equivalent bucket `open`. Normalize the latter at
    // the boundary so both can use [DashboardCounts] without another model.
    final stats = map['stats'];
    if (stats is Map && stats['tickets'] is Map) {
      final tickets = Map<String, dynamic>.from(stats['tickets'] as Map);
      tickets.putIfAbsent('pending', () => tickets['open']);
      map['stats'] = Map<String, dynamic>.from(stats)..['tickets'] = tickets;
    }
    return DashboardSummary.fromJson(map);
  }
}
