import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/paginated_request_list_screen.dart';
import 'connection_request_providers.dart';

/// All connection requests visible to the user, across ALL stages (D25).
///
/// The Connection Flow tile's target: one unfiltered queue
/// (`GET /connection-requests` with no status filter, via
/// [connectionRequestsProvider] — the same provider the survey list already
/// uses). The tile's count reads page 1 of this exact provider, so the
/// number on the tile and the rows on this screen can never disagree the
/// way the D20/D23 tile did (2 flows counted, survey-stage list opened).
///
/// Taps route stage-aware (D18): the shared list screen picks the detail
/// screen from each request's `status`, not from the viewer's session team.
class AllRequestsScreen extends StatelessWidget {
  const AllRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) => PaginatedRequestListScreen(
        title: 'Connection Requests',
        pageProvider: connectionRequestsProvider,
        detailRouteFor: Routes.surveyDetailFor,
      );
}
