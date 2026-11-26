import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/features/lookups/presentation/sub_branch_providers.dart';
import 'package:isp_onlinecer/features/onu/data/olt_network.dart';
import 'package:isp_onlinecer/features/onu/data/olt_repository.dart';
import 'package:isp_onlinecer/features/onu/presentation/olt_providers.dart';
import 'package:isp_onlinecer/models/waiting_onu.dart';

class _FakeOltNetwork implements OltNetwork {
  _FakeOltNetwork({
    this.oltsResult = const {'data': <Object?>[]},
    this.waitingResult = const {'data': <Object?>[]},
    this.profilesResult = const {
      'olt': {},
      'line_profiles': <Object?>[],
      'service_profiles': <Object?>[],
      'vlans': <Object?>[],
    },
    this.discoverResult = const {
      'message': 'Discovery complete',
      'source': 'live',
      'seen_count': 0,
      'data': <Object?>[],
    },
    this.error,
  });

  final Map<String, dynamic> oltsResult;
  final Map<String, dynamic> waitingResult;
  final Map<String, dynamic> profilesResult;
  final Map<String, dynamic> discoverResult;
  final Exception? error;

  String? lastSubBranchId;
  String? lastOltId;
  int discoverCalls = 0;

  @override
  Future<Map<String, dynamic>> fetchDirectOlts({String? subBranchId}) async {
    lastSubBranchId = subBranchId;
    if (error != null) throw error!;
    return oltsResult;
  }

  @override
  Future<Map<String, dynamic>> discoverWaitingOnus(
    String oltId, {
    String? subBranchId,
  }) async {
    lastOltId = oltId;
    lastSubBranchId = subBranchId;
    discoverCalls++;
    if (error != null) throw error!;
    return discoverResult;
  }

  @override
  Future<Map<String, dynamic>> fetchWaitingOnus(
    String oltId, {
    String? subBranchId,
  }) async {
    lastOltId = oltId;
    lastSubBranchId = subBranchId;
    if (error != null) throw error!;
    return waitingResult;
  }

  @override
  Future<Map<String, dynamic>> fetchProfiles(
    String oltId, {
    String? subBranchId,
  }) async {
    lastOltId = oltId;
    lastSubBranchId = subBranchId;
    if (error != null) throw error!;
    return profilesResult;
  }
}

/// Fixed sub-branch scope for controller tests: no scope resolved, so the
/// OLT calls go out without a `sub_branch_id` and no real HTTP ever happens.
class _FixedSubBranchState extends SubBranchController {
  @override
  SubBranchState build() => const SubBranchState(isLoading: false);
}

const _oltsMap = {
  'data': [
    {
      'id': 'olt_1',
      'name': 'OLT-Gulberg-01',
      'vendor': 'huawei',
      'model': 'MA5608T',
      'connection_status': 'online',
      'authorization_preset': {
        'ready': false,
        'line_profile': null,
        'service_profile': null,
        'vlan': null,
        'user_vlan': null,
        'gemport': null,
      },
      'running_authorizations_count': 0,
    },
    {
      'id': 'olt_2',
      'name': 'OLT-VSOL-01',
      'vendor': 'vsol',
      'authorization_preset': {
        'ready': true,
        'line_profile': 'FTTH-100M',
        'service_profile': 'IPTV-DATA',
        'vlan': 100,
        'user_vlan': 101,
        'gemport': 1,
      },
    },
  ],
};

const _waitingMap = {
  'data': [
    {
      'id': 'onu_1',
      'serial_number': 'HWTC12345678',
      'pon_port': '0/1/1',
      'detected_onu_type': 'HG8245H',
      'authorization_status': 'waiting_authorization',
      'authorization_reason': null,
      'last_discovered_at': '2026-11-23T10:00:00Z',
    },
    {
      'id': 'onu_2',
      'serial_number': 'HWTC87654321',
      'pon_port': '0/1/2',
      'detected_onu_type': 'HG8245H',
      'authorization_status': 'failed',
      'authorization_reason': 'OLT rejected the serial number',
      'last_discovered_at': '2026-11-23T10:00:00Z',
    },
  ],
};

void main() {
  group('OltRepository.fetchDirectOlts', () {
    test('parses preset ready:false (manual profiles) and ready:true', () async {
      final network = _FakeOltNetwork(oltsResult: _oltsMap);
      final repository = OltRepository(network: network);

      final list = await repository.fetchDirectOlts(subBranchId: 'sb_1');

      expect(list.data, hasLength(2));
      expect(list.data.first.vendor, 'huawei');
      expect(list.data.first.authorizationPreset?.ready, isFalse);
      expect(list.data.first.authorizationPreset?.lineProfile, isNull);
      expect(list.data.last.authorizationPreset?.ready, isTrue);
      expect(list.data.last.authorizationPreset?.lineProfile, 'FTTH-100M');
      expect(list.data.last.authorizationPreset?.gemport, 1);
      expect(network.lastSubBranchId, 'sb_1');
    });

    test('passes no sub_branch_id when none is resolved', () async {
      final network = _FakeOltNetwork(oltsResult: _oltsMap);
      final repository = OltRepository(network: network);

      await repository.fetchDirectOlts();

      expect(network.lastSubBranchId, isNull);
    });
  });

  group('OltRepository.fetchWaitingOnus', () {
    test('parses cached rows incl. failed reason', () async {
      final network = _FakeOltNetwork(waitingResult: _waitingMap);
      final repository = OltRepository(network: network);

      final list = await repository.fetchWaitingOnus('olt_1');

      expect(list.data, hasLength(2));
      expect(list.data.first.serialNumber, 'HWTC12345678');
      expect(list.data.first.ponPort, '0/1/1');
      expect(list.data.first.detectedOnuType, 'HG8245H');
      expect(
        list.data.first.authorizationStatus,
        'waiting_authorization',
      );
      expect(list.data.last.authorizationStatus, 'failed');
      expect(
        list.data.last.authorizationReason,
        'OLT rejected the serial number',
      );
      expect(network.lastOltId, 'olt_1');
    });
  });

  group('OltRepository.discoverWaitingOnus', () {
    test('returns source + seen_count from the discovery envelope', () async {
      final network = _FakeOltNetwork(
        discoverResult: {
          'message': 'Discovery complete',
          'source': 'live',
          'seen_count': 2,
          'data': (_waitingMap['data'] as List).toList(),
        },
      );
      final repository = OltRepository(network: network);

      final result = await repository.discoverWaitingOnus('olt_1');

      expect(result.source, 'live');
      expect(result.seenCount, 2);
      expect(result.data, hasLength(2));
    });

    test('surfaces a 422 failure with the backend message', () async {
      final network = _FakeOltNetwork(
        error: const ApiException(
          message: 'OLT unreachable.',
          statusCode: 422,
        ),
      );
      final repository = OltRepository(network: network);

      expect(
        repository.discoverWaitingOnus('olt_1'),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'OLT unreachable.')
              .having((e) => e.statusCode, 'statusCode', 422),
        ),
      );
    });
  });

  group('DiscoveryController', () {
    test('failed discovery keeps the previous cached list', () async {
      const cached = WaitingOnuList(data: [
        WaitingOnu(
          id: 'onu_1',
          serialNumber: 'HWTC12345678',
          authorizationStatus: 'waiting_authorization',
        ),
      ]);
      final network = _FakeOltNetwork(
        error: const ApiException(
          message: 'OLT unreachable.',
          statusCode: 422,
        ),
      );
      final container = ProviderContainer(
        overrides: [
          oltRepositoryProvider.overrideWithValue(
            OltRepository(network: network),
          ),
          subBranchStateProvider.overrideWith(_FixedSubBranchState.new),
          waitingOnusProvider.overrideWith(
            (ref, oltId) async => cached,
          ),
        ],
      );
      addTearDown(container.dispose);

      // Warm the cached list first.
      final before = await container.read(waitingOnusProvider('olt_1').future);
      expect(before.data, hasLength(1));

      await container
          .read(discoveryControllerProvider('olt_1').notifier)
          .discover();

      final state = container.read(discoveryControllerProvider('olt_1'));
      expect(state.isDiscovering, isFalse);
      expect(state.errorMessage, 'OLT unreachable.');

      // The cached list is untouched — the screen never blanks on a failed
      // refresh.
      final after = await container.read(waitingOnusProvider('olt_1').future);
      expect(after.data, hasLength(1));
      expect(after.data.first.serialNumber, 'HWTC12345678');
    });

    test('successful discovery records source + seen_count', () async {
      final network = _FakeOltNetwork(
        discoverResult: {
          'message': 'Discovery complete',
          'source': 'live',
          'seen_count': 2,
          'data': (_waitingMap['data'] as List).toList(),
        },
      );
      final container = ProviderContainer(
        overrides: [
          oltRepositoryProvider.overrideWithValue(
            OltRepository(network: network),
          ),
          subBranchStateProvider.overrideWith(_FixedSubBranchState.new),
          // Discovery success invalidates the cached list; stub it so no
          // refetch can ever reach the real server from a unit test.
          waitingOnusProvider.overrideWith(
            (ref, oltId) async => const WaitingOnuList(data: []),
          ),
        ],
      );
      addTearDown(container.dispose);

      await container
          .read(discoveryControllerProvider('olt_1').notifier)
          .discover();

      final state = container.read(discoveryControllerProvider('olt_1'));
      expect(state.isDiscovering, isFalse);
      expect(state.hasError, isFalse);
      expect(state.source, 'live');
      expect(state.seenCount, 2);
      expect(state.discoveredAt, isNotNull);
      expect(network.discoverCalls, 1);
    });
  });
}
