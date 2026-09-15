import '../../../models/ticket.dart';
import 'ticket_network.dart';

class TicketRepository {
  TicketRepository({required this.network});
  final TicketNetwork network;

  Future<TicketSummary> fetchPage({
    required int page,
    String? status,
    String? search,
  }) async => TicketSummary.fromJson(
    await network.fetchPage(page: page, status: status, search: search),
  );

  Future<TicketDetail> fetchDetail(String id) async =>
      TicketDetail.fromJson(await network.fetchDetail(id));

  Future<TicketAdvanceResult> advance(String id, {String? note}) async =>
      TicketAdvanceResult.fromJson(await network.advance(id, note: note));
}
