import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/connection_request.dart';
import '../../auth/presentation/providers.dart';
import '../data/connection_request_network.dart';
import '../data/connection_request_repository.dart';

/// Real HTTP-backed connection-request network.
final connectionRequestNetworkProvider = Provider<ConnectionRequestNetwork>((ref) {
  return DioConnectionRequestNetwork(ref.watch(apiClientProvider));
});

/// Connection-request repository wiring the network layer.
final connectionRequestRepositoryProvider = Provider<ConnectionRequestRepository>((ref) {
  return ConnectionRequestRepository(network: ref.watch(connectionRequestNetworkProvider));
});

/// Fetches one page of connection requests, `page` is 1-based.
///
/// The list screen watches the page it needs and accumulates results locally.
final connectionRequestsProvider =
    FutureProvider.family<ConnectionRequestPage, int>((ref, page) {
  return ref.watch(connectionRequestRepositoryProvider).fetchPage(page: page);
});

/// Fetches the full detail for one request, keyed by request id.
final connectionRequestDetailProvider =
    FutureProvider.family<ConnectionRequestDetail, String>((ref, id) {
  return ref.watch(connectionRequestRepositoryProvider).fetchDetail(id);
});