import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/ticket.dart';
import '../../auth/presentation/providers.dart';
import '../data/ticket_network.dart';
import '../data/ticket_repository.dart';

final ticketNetworkProvider = Provider<TicketNetwork>(
  (ref) => DioTicketNetwork(ref.watch(apiClientProvider)),
);
final ticketRepositoryProvider = Provider<TicketRepository>(
  (ref) => TicketRepository(network: ref.watch(ticketNetworkProvider)),
);

class TicketQuery {
  const TicketQuery({this.status, this.search});
  final String? status;
  final String? search;

  @override
  bool operator ==(Object other) =>
      other is TicketQuery && other.status == status && other.search == search;

  @override
  int get hashCode => Object.hash(status, search);
}

final ticketPageProvider =
    FutureProvider.family<TicketSummary, ({TicketQuery query, int page})>((ref, arg) {
  return ref.watch(ticketRepositoryProvider).fetchPage(
    page: arg.page,
    status: arg.query.status,
    search: arg.query.search,
  );
});

final ticketDetailProvider = FutureProvider.family<TicketDetail, String>((ref, id) {
  return ref.watch(ticketRepositoryProvider).fetchDetail(id);
});

/// Incremented after a ticket changes so any mounted ticket list reloads its
/// currently selected filter/search page.
final ticketListRefreshProvider = StateProvider<int>((ref) => 0);
