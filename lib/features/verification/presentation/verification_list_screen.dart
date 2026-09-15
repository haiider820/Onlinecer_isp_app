import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../shared/widgets/paginated_request_list_screen.dart';
import 'verification_providers.dart';

class VerificationListScreen extends StatelessWidget {
  const VerificationListScreen({super.key});

  @override
  Widget build(BuildContext context) => PaginatedRequestListScreen(
        title: 'Pending Verification',
        pageProvider: verificationRequestsProvider,
        detailRouteFor: Routes.verificationDetailFor,
      );
}
