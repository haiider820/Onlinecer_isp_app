import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/paginated_request_list_screen.dart';
import 'installation_providers.dart';

/// Installation connection requests (`status=installation_assigned`).
///
/// Renders through the shared [PaginatedRequestListScreen] — the status-filtered
/// queue provider and the detail tap target differ from survey.
class InstallationListScreen extends StatelessWidget {
  const InstallationListScreen({super.key});

  @override
  Widget build(BuildContext context) => PaginatedRequestListScreen(
        title: 'Installation Requests',
        pageProvider: installationRequestsProvider,
        detailRouteFor: Routes.installationDetailFor,
      );
}