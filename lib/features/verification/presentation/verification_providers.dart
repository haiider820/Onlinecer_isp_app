import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/connection_request.dart';
import '../../stage_shared/team_stage_config.dart';
import '../../stage_shared/data/team_stage_detail_network.dart';
import '../../stage_shared/data/team_stage_detail_repository.dart';
import '../../stage_shared/models/team_stage_detail.dart';
import '../../auth/presentation/providers.dart';
import '../../survey/presentation/connection_request_providers.dart';

/// Verification's queue uses the common connection-request repository and its
/// stage configuration determines the server-side filter.
final verificationRequestsProvider =
    FutureProvider.family<ConnectionRequestPage, int>((ref, page) {
  return ref.watch(connectionRequestRepositoryProvider).fetchPage(
        page: page,
        status: TeamStageConfig.verification.statusFilter,
      );
});

final verificationDetailRepositoryProvider = Provider<TeamStageDetailRepository>((ref) =>
    TeamStageDetailRepository(network: DioTeamStageDetailNetwork(ref.watch(apiClientProvider))));
final verificationDetailProvider = FutureProvider.family<TeamStageDetail, String>((ref, requestId) =>
    ref.watch(verificationDetailRepositoryProvider).fetch(requestId));
