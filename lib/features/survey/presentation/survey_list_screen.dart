import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/paginated_request_list_screen.dart';
import 'connection_request_providers.dart';

/// Survey connection requests (the team's unfiltered queue).
///
/// Renders through the shared [PaginatedRequestListScreen] — only the queue
/// provider and the detail tap target differ from other team lists.
class SurveyListScreen extends StatelessWidget {
  const SurveyListScreen({super.key});

  @override
  Widget build(BuildContext context) => PaginatedRequestListScreen(
        title: 'Survey Requests',
        pageProvider: connectionRequestsProvider,
        detailRouteFor: Routes.surveyDetailFor,
      );
}