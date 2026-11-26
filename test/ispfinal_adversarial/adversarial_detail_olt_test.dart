/// Flow 5 (detail + allowed_actions) + Flow 6 (OLT list + waiting ONUs).
/// Model / provider tests with faked repositories; never a live server.
///
/// Tests marked DEFECT-DOCUMENTING assert the correct behaviour and are
/// EXPECTED TO FAIL against the current tree — the failure is the finding.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/lookups/presentation/sub_branch_providers.dart';
import 'package:isp_onlinecer/features/onu/data/olt_network.dart';
import 'package:isp_onlinecer/features/onu/data/olt_repository.dart';
import 'package:isp_onlinecer/features/onu/presentation/olt_list_screen.dart';
import 'package:isp_onlinecer/features/onu/presentation/olt_providers.dart';
import 'package:isp_onlinecer/models/connection_request.dart';
import 'package:isp_onlinecer/models/direct_olt.dart';
import 'package:isp_onlinecer/models/sub_branch.dart';
import 'package:isp_onlinecer/models/waiting_onu.dart';

import 'helpers.dart';

ConnectionRequestDetail _detail({
  String status = 'installation_assigned',
  String? singular,
  List<String>? plural,
}) {
  return ConnectionRequestDetail(
    request: ConnectionRequest(
      id: 'req-1',
      requestNumber: 'CRQ-1',
      status: status,
    ),
    allowedAction: singular,
    allowedActions: plural,
  );
}

/// The authorize-button rule exactly as written in
/// installation_request_detail_screen.dart:185-186.
bool canAuthorizeOnu(ConnectionRequestDetail detail) =>
    detail.request.status == 'installation_assigned' &&
    detail.actions.contains(ConnectionRequestAction.authorizeOnu);

class _ScriptedOltNetwork implements OltNetwork {
  _ScriptedOltNetwork({this.olts, this.waiting, this.discoverError, this.discoverResult});

  final Map<String, dynamic>? olts;
  final Map<String, dynamic>? waiting;
  final Object? discoverError;
  final Map<String, dynamic>? discoverResult;
  int fetchOltsCalls = 0;
  int fetchWaitingCalls = 0;
  int discoverCalls = 0;

  @override
  Future<Map<String, dynamic>> fetchDirectOlts({String? subBranchId}) async {
    fetchOltsCalls++;
    return olts ?? const {'data': []};
  }

  @override
  Future<Map<String, dynamic>> discoverWaitingOnus(String oltId, {String? subBranchId}) async {
    discoverCalls++;
    if (discoverError != null) throw discoverError!;
    return discoverResult ??
        const {'message': 'Discovery complete', 'source': 'live', 'seen_count': 1, 'data': []};
  }

  @override
  Future<Map<String, dynamic>> fetchWaitingOnus(String oltId, {String? subBranchId}) async {
    fetchWaitingCalls++;
    return waiting ?? const {'data': []};
  }

  @override
  Future<Map<String, dynamic>> fetchProfiles(String oltId, {String? subBranchId}) async {
    return const {
      'olt': {},
      'line_profiles': [],
      'service_profiles': [],
      'vlans': [],
    };
  }
}

void main() {
  group('Flow 5 — ConnectionRequestDetail.actions (plural vs singular)', () {
    test('plural list wins when present', () {
      final detail = _detail(
        singular: 'complete_survey',
        plural: ['complete_installation', 'authorize_onu'],
      );
      expect(
        detail.actions,
        [ConnectionRequestAction.completeInstallation, ConnectionRequestAction.authorizeOnu],
      );
    });

    test('singular fallback when plural is absent', () {
      final detail = _detail(singular: 'complete_survey');
      expect(detail.actions, [ConnectionRequestAction.completeSurvey]);
    });

    test('singular fallback when plural is an EMPTY list', () {
      final detail = _detail(singular: 'complete_survey', plural: []);
      expect(detail.actions, [ConnectionRequestAction.completeSurvey]);
    });

    test('no actions at all yields an empty list (never a phantom button)', () {
      expect(_detail().actions, isEmpty);
    });

    test('unknown wire values are dropped, never crash parsing', () {
      final detail = _detail(plural: ['complete_survey', 'some_future_action']);
      expect(detail.actions, [ConnectionRequestAction.completeSurvey]);
    });

    test('DEFECT: plural with ONLY unknown values drops the valid singular fallback', () {
      // Backend sends allowed_actions: ["some_future_action"] (a value this
      // build does not know yet) AND allowed_action: "complete_survey".
      // Correct: fall back to the singular so the technician keeps a working
      // button. Actual: actions == [] — every stage button disappears even
      // though the backend offered a known action.
      final detail = _detail(
        singular: 'complete_survey',
        plural: ['some_future_action'],
      );
      expect(detail.actions, contains(ConnectionRequestAction.completeSurvey));
    });

    test('fromJson parses the guide payload shape (plural + singular together)', () {
      final detail = ConnectionRequestDetail.fromJson({
        'data': {
          'id': 'req-1',
          'request_number': 'CRQ-1',
          'status': 'installation_assigned',
        },
        'allowed_action': 'authorize_onu',
        'allowed_actions': ['authorize_onu'],
      });
      expect(detail.actions, [ConnectionRequestAction.authorizeOnu]);
    });
  });

  group('Flow 5 — authorize button visibility rule', () {
    test('shown: installation_assigned + authorize_onu offered', () {
      expect(
        canAuthorizeOnu(_detail(plural: ['authorize_onu'])),
        isTrue,
      );
    });

    test('hidden: wrong status even when authorize_onu is offered', () {
      expect(
        canAuthorizeOnu(_detail(status: 'survey_assigned', plural: ['authorize_onu'])),
        isFalse,
      );
    });

    test('hidden: right status but authorize_onu NOT offered', () {
      expect(
        canAuthorizeOnu(_detail(plural: ['complete_installation'])),
        isFalse,
      );
    });

    test('hidden: right status, no actions at all', () {
      expect(canAuthorizeOnu(_detail()), isFalse);
    });

    test('singular fallback still shows the button on old payloads', () {
      expect(
        canAuthorizeOnu(_detail(singular: 'authorize_onu')),
        isTrue,
      );
    });
  });

  group('Flow 6 — OLT vendor gating', () {
    test('Huawei and VSOL (any case) support the flow', () {
      expect(OltListScreen.supportsOnuFlow('Huawei'), isTrue);
      expect(OltListScreen.supportsOnuFlow('HUAWEI MA5608T'), isTrue);
      expect(OltListScreen.supportsOnuFlow('VSOL'), isTrue);
      expect(OltListScreen.supportsOnuFlow('vsol V1600D'), isTrue);
    });

    test('other vendors and null/empty are labelled unsupported, never a dead button', () {
      expect(OltListScreen.supportsOnuFlow('ZTE'), isFalse);
      expect(OltListScreen.supportsOnuFlow('FiberHome'), isFalse);
      expect(OltListScreen.supportsOnuFlow(null), isFalse);
      expect(OltListScreen.supportsOnuFlow(''), isFalse);
    });

    test('preset.ready=false parses (manual profiles required downstream)', () {
      final olt = DirectOlt.fromJson({
        'id': 'olt-1',
        'name': 'OLT-1',
        'vendor': 'Huawei',
        'authorization_preset': {
          'ready': false,
          'line_profile': null,
          'service_profile': null,
          'vlan': null,
          'user_vlan': null,
          'gemport': null,
        },
      });
      expect(olt.authorizationPreset!.ready, isFalse);
      expect(olt.authorizationPreset!.gemport, isNull);
    });

    test('empty OLT list parses to an empty list (empty state, not a crash)', () {
      expect(DirectOltList.fromJson(const {'data': []}).data, isEmpty);
    });

    test('waiting ONU without error_message parses; only authorization_reason is shown', () {
      final onu = WaitingOnu.fromJson({
        'id': 'onu-1',
        'serial_number': 'HWTC12345678',
        'authorization_status': 'failed',
        'authorization_reason': 'ONT already registered',
      });
      expect(onu.authorizationReason, 'ONT already registered');
    });
  });

  group('Flow 6 — discovery keeps the cached list on failure', () {
    ProviderContainer containerWith(_ScriptedOltNetwork network) {
      final backing = InMemoryFlutterSecureStorage();
      return ProviderContainer(
        overrides: [
          secureStorageProvider.overrideWithValue(freshStorage(backing)),
          oltRepositoryProvider.overrideWithValue(OltRepository(network: network)),
          // Fresh scope so waitingOnusProvider passes a sub-branch id.
          subBranchStateProvider.overrideWith(
            () => _FakeSubBranchController(),
          ),
        ],
      );
    }

    test('failed refresh (422) keeps the cached rows and records the message', () async {
      final network = _ScriptedOltNetwork(
        waiting: const {
          'data': [
            {'id': 'onu-1', 'serial_number': 'HWTC12345678', 'authorization_status': 'waiting_authorization'},
          ],
        },
        discoverError: const ApiException(
          message: 'OLT unreachable.',
          statusCode: 422,
        ),
      );
      final container = containerWith(network);
      addTearDown(container.dispose);

      // Cached list loads first.
      final cached = await container.read(waitingOnusProvider('olt-1').future);
      expect(cached.data, hasLength(1));
      expect(network.fetchWaitingCalls, 1);

      // Failed discovery must NOT blank the cached list.
      await container
          .read(discoveryControllerProvider('olt-1').notifier)
          .discover();
      final discovery = container.read(discoveryControllerProvider('olt-1'));
      expect(discovery.hasError, isTrue);
      expect(discovery.errorMessage, 'OLT unreachable.');
      expect(discovery.isDiscovering, isFalse);
      final stillCached = await container.read(waitingOnusProvider('olt-1').future);
      expect(stillCached.data, hasLength(1));
    });

    test('successful discovery invalidates the cached list (fresh rows re-read)', () async {
      final network = _ScriptedOltNetwork(
        waiting: const {
          'data': [
            {'id': 'onu-1', 'serial_number': 'HWTC12345678'},
          ],
        },
        discoverResult: const {
          'message': 'Discovery complete',
          'source': 'live',
          'seen_count': 2,
          'data': [],
        },
      );
      final container = containerWith(network);
      addTearDown(container.dispose);
      await container.read(waitingOnusProvider('olt-1').future);
      expect(network.fetchWaitingCalls, 1);
      await container
          .read(discoveryControllerProvider('olt-1').notifier)
          .discover();
      final discovery = container.read(discoveryControllerProvider('olt-1'));
      expect(discovery.hasError, isFalse);
      expect(discovery.source, 'live');
      expect(discovery.seenCount, 2);
      // Invalidation forces a re-read of the cached GET on next watch.
      await container.read(waitingOnusProvider('olt-1').future);
      expect(network.fetchWaitingCalls, 2);
    });

    test('double-tap Refresh is ignored while a discovery is in flight', () async {
      final network = _ScriptedOltNetwork();
      final container = containerWith(network);
      addTearDown(container.dispose);
      final controller =
          container.read(discoveryControllerProvider('olt-1').notifier);
      await Future.wait([controller.discover(), controller.discover()]);
      expect(network.discoverCalls, 1);
    });
  });
}

// Minimal SubBranchController stand-in: a fresh scoped single-branch list so
// waitingOnusProvider resolves a scope id. Only the state shape matters here.
class _FakeSubBranchController extends SubBranchController {
  @override
  SubBranchState build() {
    return SubBranchState(
      lastKnownList: SubBranchList(
        mode: 'scoped',
        data: [
          SubBranch(id: 'sub-1', name: 'Sub 1'),
        ],
      ),
      lastUpdated: DateTime.now(),
      isLoading: false,
    );
  }
}
