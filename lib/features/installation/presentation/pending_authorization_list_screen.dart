import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/paginated_request_list_screen.dart';
import 'installation_providers.dart';

/// Requests awaiting ONU authorization (D25).
///
/// The ONU Authorization tile's fallback target: the installation-assigned
/// queue (`GET /connection-requests?status=installation_assigned`, via
/// [installationRequestsProvider]) — the exact queue the tile's count
/// derives from, so 0 Pending opens an empty list that honestly says no
/// request awaits authorization instead of the survey list (the D20–D24
/// fallback, which confused the count with a different queue).
///
/// A dedicated route (not [Routes.installationList]): that route's guard
/// is strict (installation team only, D18 deliberately left list routes
/// strict), so a survey-session user would bounce off it back to the
/// dashboard — a dead tap. This route is unguarded like the tickets list;
/// the data is backend-scoped by the employee token, and the same queue is
/// already readable from the dashboard tile's count.
class PendingAuthorizationListScreen extends StatelessWidget {
  const PendingAuthorizationListScreen({super.key});

  @override
  Widget build(BuildContext context) => PaginatedRequestListScreen(
        title: 'Pending Authorization',
        pageProvider: installationRequestsProvider,
        detailRouteFor: Routes.installationDetailFor,
      );
}
