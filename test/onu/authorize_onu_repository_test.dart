import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/onu/data/authorize_onu_network.dart';
import 'package:isp_onlinecer/features/onu/data/authorize_onu_repository.dart';

class _FakeAuthorizeOnuNetwork implements AuthorizeOnuNetwork {
  _FakeAuthorizeOnuNetwork({
    this.authorizeResult = const {
      'message': 'ONU authorization queued',
      'data': {'id': 'job_1'},
    },
    this.jobResult = const {
      'data': {'id': 'job_1', 'status': 'pending'},
    },
  });

  final Map<String, dynamic> authorizeResult;
  final Map<String, dynamic> jobResult;

  Map<String, Object?>? lastAuthorizeBody;
  String? lastAuthorizeRequestId;
  String? lastJobRequestId;
  String? lastJobId;
  int authorizeCalls = 0;

  @override
  Future<Map<String, dynamic>> authorizeOnu(
    String requestId,
    Map<String, Object?> body,
  ) async {
    lastAuthorizeRequestId = requestId;
    lastAuthorizeBody = Map<String, Object?>.from(body);
    authorizeCalls++;
    return authorizeResult;
  }

  @override
  Future<Map<String, dynamic>> fetchAuthorizationJob(
    String requestId,
    String jobId,
  ) async {
    lastJobRequestId = requestId;
    lastJobId = jobId;
    return jobResult;
  }
}

void main() {
  group('AuthorizeOnuRepository.authorizeDiscovered (shape 1)', () {
    test('sends exactly the discovered-ONU shape', () async {
      final network = _FakeAuthorizeOnuNetwork();
      final repository = AuthorizeOnuRepository(network: network);

      final result = await repository.authorizeDiscovered(
        requestId: 'req_1',
        directOltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );

      expect(network.authorizeCalls, 1);
      expect(network.lastAuthorizeRequestId, 'req_1');
      expect(network.lastAuthorizeBody, {
        'direct_olt_id': 'olt_1',
        'direct_olt_unconfigured_onu_id': 'onu_1',
        'description': 'Ahmed Raza',
      });
      expect(result.jobId, 'job_1');
      expect(result.message, 'ONU authorization queued');
    });

    test('reads the job id from data.job_id when data.id is absent', () async {
      final network = _FakeAuthorizeOnuNetwork(
        authorizeResult: const {
          'message': 'ONU authorization queued',
          'data': {'job_id': 'job_9'},
        },
      );
      final repository = AuthorizeOnuRepository(network: network);

      final result = await repository.authorizeDiscovered(
        requestId: 'req_1',
        directOltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );

      expect(result.jobId, 'job_9');
    });
  });

  group('AuthorizeOnuRepository.authorizeBySerial (shape 2)', () {
    test('preset-ready: profiles omitted when empty, gemport from preset',
        () async {
      final network = _FakeAuthorizeOnuNetwork();
      final repository = AuthorizeOnuRepository(network: network);

      await repository.authorizeBySerial(
        requestId: 'req_1',
        directOltId: 'olt_1',
        serialNumber: 'HWTC12345678',
        lineProfile: null,
        serviceProfile: null,
        vlan: null,
        userVlan: null,
        gemport: 3,
        description: 'Ahmed Raza',
      );

      expect(network.lastAuthorizeBody, {
        'direct_olt_id': 'olt_1',
        'serial_number': 'HWTC12345678',
        'gemport': 3,
        'description': 'Ahmed Raza',
      });
    });

    test('manual profiles: all fields sent when given', () async {
      final network = _FakeAuthorizeOnuNetwork();
      final repository = AuthorizeOnuRepository(network: network);

      await repository.authorizeBySerial(
        requestId: 'req_1',
        directOltId: 'olt_1',
        serialNumber: 'HWTC12345678',
        lineProfile: 'FTTH-100M',
        serviceProfile: 'IPTV-DATA',
        vlan: 100,
        userVlan: 101,
        gemport: 2,
        description: 'Ahmed Raza',
      );

      expect(network.lastAuthorizeBody, {
        'direct_olt_id': 'olt_1',
        'serial_number': 'HWTC12345678',
        'line_profile': 'FTTH-100M',
        'service_profile': 'IPTV-DATA',
        'vlan': 100,
        'user_vlan': 101,
        'gemport': 2,
        'description': 'Ahmed Raza',
      });
    });

    test('gemport defaults to 1 when neither caller nor preset gives one',
        () async {
      final network = _FakeAuthorizeOnuNetwork();
      final repository = AuthorizeOnuRepository(network: network);

      await repository.authorizeBySerial(
        requestId: 'req_1',
        directOltId: 'olt_1',
        serialNumber: 'HWTC12345678',
        description: 'Ahmed Raza',
      );

      expect(network.lastAuthorizeBody?['gemport'], 1);
      expect(network.lastAuthorizeBody?.containsKey('line_profile'), isFalse);
      expect(network.lastAuthorizeBody?.containsKey('vlan'), isFalse);
    });
  });

  group('AuthorizeOnuRepository.fetchJob', () {
    test('unwraps the data envelope and parses the job', () async {
      final network = _FakeAuthorizeOnuNetwork(
        jobResult: const {
          'data': {
            'id': 'job_1',
            'status': 'succeeded',
            'ont_id': '5',
          },
        },
      );
      final repository = AuthorizeOnuRepository(network: network);

      final job = await repository.fetchJob('req_1', 'job_1');

      expect(network.lastJobRequestId, 'req_1');
      expect(network.lastJobId, 'job_1');
      expect(job.id, 'job_1');
      expect(job.status, 'succeeded');
      expect(job.isTerminal, isTrue);
      expect(job.ontId, '5');
    });
  });
}
