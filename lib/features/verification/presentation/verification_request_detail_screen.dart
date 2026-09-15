import 'package:flutter/material.dart';

import '../../../core/router/functional_team.dart';
import '../../../core/router/team_module.dart';
import '../../stage_shared/presentation/team_stage_detail_screen.dart';
import 'verification_providers.dart';

class VerificationRequestDetailScreen extends StatelessWidget {
  const VerificationRequestDetailScreen({super.key, required this.requestId});
  final String requestId;
  @override
  Widget build(BuildContext context) {
    // Every label, route, and queue provider comes from the single dispatch;
    // nothing is hardcoded here.
    final module = TeamModule.forTeam(FunctionalTeamType.connectionVerification);
    return TeamStageDetailScreen(
      requestId: requestId,
      config: module.stageConfig!,
      title: module.detailTitle,
      detailProvider: verificationDetailProvider,
      listRoute: module.listRoute,
      listPageProvider: module.inboxPageProvider,
    );
  }
}