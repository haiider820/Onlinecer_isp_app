import '../models/team_stage_detail.dart';
import 'team_stage_detail_network.dart';

class TeamStageDetailRepository {
  TeamStageDetailRepository({required this.network});
  final TeamStageDetailNetwork network;

  Future<TeamStageDetail> fetch(String requestId) async =>
      TeamStageDetail.fromJson(await network.fetchDetail(requestId));
}
