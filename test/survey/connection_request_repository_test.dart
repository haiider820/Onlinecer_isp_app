import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_network.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_repository.dart';
import 'package:isp_onlinecer/models/connection_request.dart';

class _FakeConnectionRequestNetwork implements ConnectionRequestNetwork {
  _FakeConnectionRequestNetwork(this.result, {this.error});

  final Map<String, dynamic> result;
  final Exception? error;
  int lastPage = 0;
  String? lastStatus;

  @override
  Future<Map<String, dynamic>> fetchPage({required int page, String? status}) async {
    lastPage = page;
    lastStatus = status;
    if (error != null) throw error!;
    return result;
  }

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) async {
    if (error != null) throw error!;
    return result;
  }
}

void main() {
  group('ConnectionRequestRepository.fetchPage', () {
    test('parses the paginated envelope into a ConnectionRequestPage', () async {
      final network = _FakeConnectionRequestNetwork({
        'data': [
          {
            'id': '101',
            'request_number': 'CR-001-2026',
            'status': 'assigned',
            'customer_name': 'Karim Ahmed',
            'customer_area': 'Dhanmondi',
          },
        ],
        'meta': {'current_page': 2, 'per_page': 15, 'total': 31, 'last_page': 3},
      });

      final repository = ConnectionRequestRepository(network: network);
      final page = await repository.fetchPage(page: 2);

      expect(network.lastPage, 2);
      expect(page.data, hasLength(1));
      expect(page.data.first.requestNumber, 'CR-001-2026');
      expect(page.meta.currentPage, 2);
      expect(page.meta.lastPage, 3);
      expect(page.meta.total, 31);
    });

    test('forwards an optional status filter to the network', () async {
      final network = _FakeConnectionRequestNetwork({
        'data': [],
        'meta': {'current_page': 1, 'per_page': 15, 'total': 0, 'last_page': 1},
      });

      final repository = ConnectionRequestRepository(network: network);
      await repository.fetchPage(page: 1, status: 'installation_assigned');

      expect(network.lastStatus, 'installation_assigned');
    });

    test('omits the status when not provided', () async {
      final network = _FakeConnectionRequestNetwork({
        'data': [],
        'meta': {'current_page': 1, 'per_page': 15, 'total': 0, 'last_page': 1},
      });

      final repository = ConnectionRequestRepository(network: network);
      await repository.fetchPage(page: 1);

      expect(network.lastStatus, isNull);
    });

    test('propagates network failures to the caller', () async {
      final network = _FakeConnectionRequestNetwork(
        const {},
        error: Exception('server unreachable'),
      );
      final repository = ConnectionRequestRepository(network: network);

      expect(repository.fetchPage(page: 1), throwsException);
    });
  });

  group('ConnectionRequestRepository.fetchDetail', () {
    test('parses the data + allowed_action envelope', () async {
      final network = _FakeConnectionRequestNetwork({
        'data': {
          'id': '101',
          'request_number': 'CR-001-2026',
          'status': 'assigned',
          'customer_name': 'Karim Ahmed',
          'customer_area': 'Dhanmondi',
        },
        'allowed_action': 'complete_survey',
      });

      final repository = ConnectionRequestRepository(network: network);
      final detail = await repository.fetchDetail('101');

      expect(detail.request.requestNumber, 'CR-001-2026');
      expect(detail.action, ConnectionRequestAction.completeSurvey);
    });

    test('null allowed_action exposes no action', () async {
      final network = _FakeConnectionRequestNetwork({
        'data': {
          'id': '101',
          'request_number': 'CR-001-2026',
          'status': 'completed',
        },
      });

      final repository = ConnectionRequestRepository(network: network);
      final detail = await repository.fetchDetail('101');

      expect(detail.request.status, 'completed');
      expect(detail.action, isNull);
    });
  });
}