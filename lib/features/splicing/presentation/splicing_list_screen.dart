import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/paginated_request_list_screen.dart';
import 'splicing_providers.dart';

class SplicingListScreen extends StatelessWidget {
  const SplicingListScreen({super.key});

  @override
  Widget build(BuildContext context) => PaginatedRequestListScreen(
        title: 'Pending Splicing',
        pageProvider: splicingRequestsProvider,
        detailRouteFor: Routes.splicingDetailFor,
      );
}
