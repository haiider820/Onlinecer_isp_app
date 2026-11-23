/// Flow 7 (authorize ONU + polling) — adversarial controller tests.
/// Faked network only; never a live server. fakeAsync drives the 3 s timer.
///
/// Tests marked DEFECT-DOCUMENTING assert the correct behaviour and are
/// EXPECTED TO FAIL against the current tree — the failure is the finding.
import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/features/onu/data/authorize_onu_network.dart';
import 'package:isp_onlinecer/features/onu/data/authorize_onu_repository.dart';
import 'package:isp_onlinecer/features/onu/presentation/authorize_onu_providers.dart';
import 'package:isp_onlinecer/features/onu/presentation/olt_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/models/connection_request.dart';
import 'package:isp_onlinecer/models/waiting_onu.dart';

Map<String, dynamic> _job(String status, {String? ontId, String? error}) {
  return {
    'data': {
      'id': 'job_1',
      'status': status,
      'serial_number': 'HWTC12345678',
      if (ontId != null) 'ont_id': ontId,
      if (error != null) 'error_message': error,
    },
  };
}

/// Scripted network: each poll consumes the next scripted step; the last
/// step repeats. authorizeOnu can be held open with a Completer to test
/// in-flight races.
class _ScriptedNetwork implements AuthorizeOnuNetwork {
  _ScriptedNetwork(this.jobScript, {this.authorizeGate});

  final List<Object> jobScript;
  final Completer<Map<String, dynamic>>? authorizeGate;

  int authorizeCalls = 0;
  int fetchJobCalls = 0;
  Map<String, Object?>? lastAuthorizeBody;

  @override
  Future<Map<String, dynamic>> authorizeOnu(
    String requestId,
    Map<String, Object?> body,
  ) async {
    authorizeCalls++;
    lastAuthorizeBody = Map<String, Object?>.from(body);
    if (authorizeGate != null) return authorizeGate!.future;
    return const {
      'message': 'ONU authorization queued',
      'data': {'id': 'job_1'},
    };
  }

  @override
  Future<Map<String, dynamic>> fetchAuthorizationJob(
    String requestId,
    String jobId,
  ) async {
    fetchJobCalls++;
    final index = fetchJobCalls - 1 < jobScript.length
        ? fetchJobCalls - 1
        : jobScript.length - 1;
    final next = jobScript[index];
    if (next is Exception) throw next;
    return next as Map<String, dynamic>;
  }
}

ProviderContainer _container(_ScriptedNetwork network) {
  return ProviderContainer(
    overrides: [
      authorizeOnuRepositoryProvider.overrideWithValue(
        AuthorizeOnuRepository(network: network),
      ),
      waitingOnusProvider.overrideWith(
        (ref, oltId) async => const WaitingOnuList(data: []),
      ),
      connectionRequestDetailProvider.overrideWith(
        (ref, id) async => ConnectionRequestDetail(
          request: ConnectionRequest(
            id: id,
            requestNumber: 'CRQ-1',
            status: 'installation_assigned',
          ),
        ),
      ),
    ],
  );
}

void main() {
  group('Flow 7 — request shapes + gemport default (repository)', () {
    test('shape 1 sends exactly the discovered-ONU fields', () async {
      final network = _ScriptedNetwork([_job('pending')]);
      final repo = AuthorizeOnuRepository(network: network);
      await repo.authorizeDiscovered(
        requestId: 'req_1',
        directOltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );
      expect(network.lastAuthorizeBody, {
        'direct_olt_id': 'olt_1',
        'direct_olt_unconfigured_onu_id': 'onu_1',
        'description': 'Ahmed Raza',
      });
    });

    test('shape 2 defaults gemport to 1 when neither caller nor preset supplies one', () async {
      final network = _ScriptedNetwork([_job('pending')]);
      final repo = AuthorizeOnuRepository(network: network);
      await repo.authorizeBySerial(
        requestId: 'req_1',
        directOltId: 'olt_1',
        serialNumber: 'HWTC12345678',
        description: 'Ahmed Raza',
      );
      expect(network.lastAuthorizeBody!['gemport'], 1);
      expect(network.lastAuthorizeBody, isNot(contains('line_profile')));
      expect(network.lastAuthorizeBody, isNot(contains('service_profile')));
    });

    test('shape 2 sends preset profiles when the OLT preset is ready', () async {
      final network = _ScriptedNetwork([_job('pending')]);
      final repo = AuthorizeOnuRepository(network: network);
      await repo.authorizeBySerial(
        requestId: 'req_1',
        directOltId: 'olt_1',
        serialNumber: 'HWTC12345678',
        lineProfile: 'FTTH-100M',
        serviceProfile: 'HSI',
        vlan: 100,
        userVlan: 200,
        gemport: 4,
        description: 'Ahmed Raza',
      );
      expect(network.lastAuthorizeBody, {
        'direct_olt_id': 'olt_1',
        'serial_number': 'HWTC12345678',
        'line_profile': 'FTTH-100M',
        'service_profile': 'HSI',
        'vlan': 100,
        'user_vlan': 200,
        'gemport': 4,
        'description': 'Ahmed Raza',
      });
    });

    test('shape 2 trims blank profiles to absent (preset-ready manual edit)', () async {
      final network = _ScriptedNetwork([_job('pending')]);
      final repo = AuthorizeOnuRepository(network: network);
      await repo.authorizeBySerial(
        requestId: 'req_1',
        directOltId: 'olt_1',
        serialNumber: 'HWTC12345678',
        lineProfile: '   ',
        serviceProfile: '',
        description: 'Ahmed Raza',
      );
      expect(network.lastAuthorizeBody, isNot(contains('line_profile')));
      expect(network.lastAuthorizeBody, isNot(contains('service_profile')));
    });
  });

  group('Flow 7 — polling state machine (controller)', () {
    test('polls every 3 s: pending -> running -> succeeded with ont_id', () {
      fakeAsync((async) {
        final network = _ScriptedNetwork([
          _job('pending'),
          _job('running'),
          _job('succeeded', ontId: '5'),
        ]);
        final container = _container(network);
        addTearDown(container.dispose);
        final controller = container.read(authorizeOnuControllerProvider.notifier);
        controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'Ahmed Raza',
        );
        async.flushMicrotasks();
        expect(container.read(authorizeOnuControllerProvider).phase, AuthorizePhase.polling);
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(container.read(authorizeOnuControllerProvider).job?.parsedStatus.toString(),
            contains('pending'));
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        final state = container.read(authorizeOnuControllerProvider);
        expect(state.phase, AuthorizePhase.succeeded);
        expect(state.job?.ontId, '5');
        expect(network.fetchJobCalls, 3);
      });
    });

    test('failed job shows the backend error_message and allows retry', () async {
      final network = _ScriptedNetwork([_job('failed', error: 'ONT already registered')]);
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(authorizeOnuControllerProvider.notifier);
      await controller.submitDiscovered(
        requestId: 'req_1',
        oltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );
      await controller.pollOnce();
      final state = container.read(authorizeOnuControllerProvider);
      expect(state.phase, AuthorizePhase.failed);
      expect(state.errorMessage, 'ONT already registered');
      controller.resetForRetry();
      final reset = container.read(authorizeOnuControllerProvider);
      expect(reset.phase, AuthorizePhase.idle);
      expect(reset.jobId, isNull);
      // Retry re-POSTs exactly once.
      await controller.submitDiscovered(
        requestId: 'req_1',
        oltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );
      expect(network.authorizeCalls, 2);
    });

    test('double submit while polling issues NO second POST', () async {
      final network = _ScriptedNetwork([_job('pending')]);
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(authorizeOnuControllerProvider.notifier);
      final first = controller.submitDiscovered(
        requestId: 'req_1',
        oltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );
      final second = controller.submitDiscovered(
        requestId: 'req_1',
        oltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );
      await Future.wait([first, second]);
      expect(await second, isNull);
      expect(network.authorizeCalls, 1);
    });

    test('offline mid-poll keeps the job id and records a poll error (never re-POSTs)', () async {
      final network = _ScriptedNetwork([
        const NetworkException(),
        _job('running'),
        _job('succeeded', ontId: '5'),
      ]);
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(authorizeOnuControllerProvider.notifier);
      await controller.submitDiscovered(
        requestId: 'req_1',
        oltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );
      await controller.pollOnce();
      var state = container.read(authorizeOnuControllerProvider);
      expect(state.phase, AuthorizePhase.polling);
      expect(state.jobId, 'job_1');
      expect(state.pollErrorMessage, isNotNull);
      expect(network.authorizeCalls, 1);
      await controller.pollOnce();
      await controller.pollOnce();
      state = container.read(authorizeOnuControllerProvider);
      expect(state.phase, AuthorizePhase.succeeded);
      expect(state.pollErrorMessage, isNull);
    });

    test('cancel-wait stops polling but keeps the job; resume re-polls without re-POST', () async {
      final network = _ScriptedNetwork([_job('pending'), _job('succeeded', ontId: '5')]);
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(authorizeOnuControllerProvider.notifier);
      await controller.submitDiscovered(
        requestId: 'req_1',
        oltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );
      controller.cancelWait();
      var state = container.read(authorizeOnuControllerProvider);
      expect(state.phase, AuthorizePhase.cancelled);
      expect(state.jobId, 'job_1');
      controller.resumePolling();
      state = container.read(authorizeOnuControllerProvider);
      expect(state.phase, AuthorizePhase.polling);
      await controller.pollOnce();
      await controller.pollOnce();
      expect(container.read(authorizeOnuControllerProvider).phase, AuthorizePhase.succeeded);
      expect(network.authorizeCalls, 1);
    });

    test('5-minute cap: polling stops with timedOut and offers manual refresh', () {
      fakeAsync((async) {
        final network = _ScriptedNetwork([_job('pending')]);
        final container = _container(network);
        addTearDown(container.dispose);
        final controller = container.read(authorizeOnuControllerProvider.notifier);
        controller.pollInterval = const Duration(seconds: 3);
        controller.maxWait = const Duration(seconds: 9);
        controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'Ahmed Raza',
        );
        async.flushMicrotasks();
        // 3 ticks x 3 s = 9 s reaches the cap; the 4th tick would time out.
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        final state = container.read(authorizeOnuControllerProvider);
        expect(state.phase, AuthorizePhase.timedOut);
        expect(state.errorMessage, contains('Still running'));
        expect(state.jobId, 'job_1');
        expect(network.authorizeCalls, 1);
      });
    });

    test('DEFECT: cancelWait DURING submit is undone when the in-flight POST lands', () async {
      // The screen disables the Stop button while submitting, but the
      // controller itself accepts cancelWait() in phase==submitting
      // (isJobActive covers submitting). The in-flight POST then completes
      // and _submit unconditionally flips the state back to polling and
      // restarts the timer — the cancel is silently lost.
      final gate = Completer<Map<String, dynamic>>();
      final network = _ScriptedNetwork([_job('pending')], authorizeGate: gate);
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(authorizeOnuControllerProvider.notifier);
      final submit = controller.submitDiscovered(
        requestId: 'req_1',
        oltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );
      await Future<void>.delayed(Duration.zero);
      expect(container.read(authorizeOnuControllerProvider).phase, AuthorizePhase.submitting);
      controller.cancelWait();
      expect(container.read(authorizeOnuControllerProvider).phase, AuthorizePhase.cancelled);
      gate.complete(const {
        'message': 'ONU authorization queued',
        'data': {'id': 'job_1'},
      });
      await submit;
      expect(
        container.read(authorizeOnuControllerProvider).phase,
        AuthorizePhase.cancelled,
        reason: 'a cancel issued during submit must stick once the POST lands',
      );
    });

    test('DEFECT: back button mid-poll does not stop polling — and the shared controller blocks a second authorization', () {
      // authorizeOnuControllerProvider is a plain NotifierProvider (NOT
      // autoDispose) and AuthorizeOnuScreen.dispose() only disposes text
      // controllers — nothing ever stops the Timer or invalidates the
      // controller when the technician leaves the screen. Consequences:
      // (1) the poll keeps hitting the server for up to 5 min after the
      // screen is gone; (2) the controller is app-wide, so authorizing a
      // DIFFERENT ONU/request while the first poll runs is silently
      // refused (submit returns null, no error message).
      fakeAsync((async) {
        final network = _ScriptedNetwork([_job('pending')]);
        final container = _container(network);
        addTearDown(container.dispose);
        final controller = container.read(authorizeOnuControllerProvider.notifier);
        controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'First ONU',
        );
        async.flushMicrotasks();
        expect(container.read(authorizeOnuControllerProvider).phase, AuthorizePhase.polling);

        // "Leaving the screen": nothing in the app disposes/invalidates
        // this provider, so the timer must keep firing with no watcher.
        async.elapse(const Duration(seconds: 9));
        async.flushMicrotasks();
        expect(network.fetchJobCalls, 3,
            reason: 'polling continues after the screen is gone');

        // A second, unrelated authorization is refused — and the refusal
        // is SILENT: submit returns null, the state keeps no error, and the
        // screen shows nothing. The technician taps Authorize and nothing
        // happens, with no way to know another job is still polling.
        controller.submitDiscovered(
          requestId: 'req_2',
          oltId: 'olt_1',
          onuId: 'onu_2',
          description: 'Second ONU',
        );
        async.flushMicrotasks();
        expect(network.authorizeCalls, 1,
            reason: 'second POST must not fire while the first job polls');
        expect(
          container.read(authorizeOnuControllerProvider).errorMessage,
          isNotNull,
          reason: 'a refused submit must tell the technician a job is already active',
        );
      });
    });

    test('201 with NO job id and no terminal job fails loudly instead of polling null', () async {
      final container = ProviderContainer(
        overrides: [
          authorizeOnuRepositoryProvider.overrideWithValue(
            AuthorizeOnuRepository(network: _NoJobIdNetwork()),
          ),
          waitingOnusProvider.overrideWith(
            (ref, oltId) async => const WaitingOnuList(data: []),
          ),
          connectionRequestDetailProvider.overrideWith(
            (ref, id) async => ConnectionRequestDetail(
              request: ConnectionRequest(
                id: id,
                requestNumber: 'CRQ-1',
                status: 'installation_assigned',
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(authorizeOnuControllerProvider.notifier);
      await controller.submitDiscovered(
        requestId: 'req_1',
        oltId: 'olt_1',
        onuId: 'onu_1',
        description: 'Ahmed Raza',
      );
      final state = container.read(authorizeOnuControllerProvider);
      expect(state.phase, AuthorizePhase.failed);
      expect(state.errorMessage, isNotNull);
    });
  });
}

class _NoJobIdNetwork implements AuthorizeOnuNetwork {
  @override
  Future<Map<String, dynamic>> authorizeOnu(
    String requestId,
    Map<String, Object?> body,
  ) async {
    return const {'message': 'Queued (no id in this build)'};
  }

  @override
  Future<Map<String, dynamic>> fetchAuthorizationJob(
    String requestId,
    String jobId,
  ) async {
    throw UnimplementedError();
  }
}
