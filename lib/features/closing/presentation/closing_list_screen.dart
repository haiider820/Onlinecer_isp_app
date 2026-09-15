import 'package:flutter/material.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/paginated_request_list_screen.dart';
import 'closing_providers.dart';

class ClosingListScreen extends StatelessWidget {
  const ClosingListScreen({super.key});

  @override
  Widget build(BuildContext context) => PaginatedRequestListScreen(
        title: 'Pending Closing',
        pageProvider: closingRequestsProvider,
        detailRouteFor: Routes.closingDetailFor,
      );
}
