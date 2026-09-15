import '../../../core/constants/app_constants.dart';
import '../../../core/network/api_client.dart';

abstract interface class TicketNetwork {
  Future<Map<String, dynamic>> fetchPage({
    required int page,
    String? status,
    String? search,
  });
  Future<Map<String, dynamic>> fetchDetail(String id);
  Future<Map<String, dynamic>> advance(String id, {String? note});
}

class DioTicketNetwork implements TicketNetwork {
  DioTicketNetwork(this._client);
  final ApiClient _client;

  @override
  Future<Map<String, dynamic>> fetchPage({
    required int page,
    String? status,
    String? search,
  }) => _client.getMap(
    Endpoints.tickets,
    query: {
      'page': page,
      'per_page': 20,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    },
  );

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) =>
      _client.getMap(Endpoints.ticketDetail(id));

  @override
  Future<Map<String, dynamic>> advance(String id, {String? note}) =>
      _client.postMap(
        Endpoints.advanceTicket(id),
        data: {
          if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
        },
      );
}
