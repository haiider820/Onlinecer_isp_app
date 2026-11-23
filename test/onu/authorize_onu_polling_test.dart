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

/// Scripted network: each poll consumes the next scripted step (a job map
/// or an exception to throw); the last step repeats when the script runs out.
class _ScriptedNetwork implements AuthorizeOnuNetwork {
  _ScriptedNetwork(this.jobScript);

  final List<Object> jobScript;

  int authorizeCalls = 0;
  int fetchJobCalls = 0;

  @override
  Future<Map<String, dynamic>> authorizeOnu(
    String requestId,
    Map<String, Object?> body,
  ) async {
    authorizeCalls++;
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
      // The controller invalidates these on success; stub them so no
      // refetch can ever reach the real server from a unit test.
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
  group('AuthorizeOnuController polling', () {
    test('polls every 3s: pending -> running -> succeeded with ont_id', () {
      fakeAsync((async) {
        final network = _ScriptedNetwork([
          _job('pending'),
          _job('running'),
          _job('succeeded', ontId: '5'),
        ]);
        final container = _container(network);
        final controller =
            container.read(authorizeOnuControllerProvider.notifier);

        unawaited(controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'Ahmed Raza',
        ));
        async.flushMicrotasks();

        var state = container.read(authorizeOnuControllerProvider);
        expect(state.phase, AuthorizePhase.polling);
        expect(state.jobId, 'job_1');
        expect(state.message, 'ONU authorization queued');
        expect(state.isJobActive, isTrue);
        expect(network.fetchJobCalls, 0);

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(network.fetchJobCalls, 1);
        state = container.read(authorizeOnuControllerProvider);
        expect(state.job?.status, 'pending');
        expect(state.phase, AuthorizePhase.polling);

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(network.fetchJobCalls, 2);
        expect(
          container.read(authorizeOnuControllerProvider).job?.status,
          'running',
        );

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(network.fetchJobCalls, 3);
        state = container.read(authorizeOnuControllerProvider);
        expect(state.phase, AuthorizePhase.succeeded);
        expect(state.job?.ontId, '5');
        expect(state.isJobActive, isFalse);

        // Terminal: no further polls.
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        expect(network.fetchJobCalls, 3);

        container.dispose();
      });
    });

    test('second submit while polling is refused: no second POST', () {
      fakeAsync((async) {
        final network = _ScriptedNetwork([_job('pending')]);
        final container = _container(network);
        final controller =
            container.read(authorizeOnuControllerProvider.notifier);

        unawaited(controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'Ahmed Raza',
        ));
        async.flushMicrotasks();
        expect(network.authorizeCalls, 1);

        // Still polling: the Authorize button is disabled (isJobActive)
        // and a second submit is refused without touching the network.
        expect(
          container.read(authorizeOnuControllerProvider).isJobActive,
          isTrue,
        );
        unawaited(controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'Ahmed Raza',
        ));
        async.flushMicrotasks();
        expect(network.authorizeCalls, 1);

        container.dispose();
      });
    });

    test('failed job surfaces the backend error_message', () {
      fakeAsync((async) {
        final network = _ScriptedNetwork([
          _job('failed', error: 'OLT rejected the serial number'),
        ]);
        final container = _container(network);
        final controller =
            container.read(authorizeOnuControllerProvider.notifier);

        unawaited(controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'Ahmed Raza',
        ));
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();

        final state = container.read(authorizeOnuControllerProvider);
        expect(state.phase, AuthorizePhase.failed);
        expect(state.errorMessage, 'OLT rejected the serial number');
        expect(state.isJobActive, isFalse);

        container.dispose();
      });
    });

    test('cancel-wait stops polling; resume restarts from the kept job id',
        () {
      fakeAsync((async) {
        final network = _ScriptedNetwork([
          _job('pending'),
          _job('running'),
          _job('succeeded', ontId: '5'),
        ]);
        final container = _container(network);
        final controller =
            container.read(authorizeOnuControllerProvider.notifier);

        unawaited(controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'Ahmed Raza',
        ));
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(network.fetchJobCalls, 1);

        controller.cancelWait();
        var state = container.read(authorizeOnuControllerProvider);
        expect(state.phase, AuthorizePhase.cancelled);
        expect(state.jobId, 'job_1');

        // No further polls while cancelled.
        async.elapse(const Duration(seconds: 30));
        async.flushMicrotasks();
        expect(network.fetchJobCalls, 1);

        // Resume: polling restarts, never a re-POST.
        controller.resumePolling();
        expect(network.authorizeCalls, 1);
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(network.fetchJobCalls, 2);

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        state = container.read(authorizeOnuControllerProvider);
        expect(state.phase, AuthorizePhase.succeeded);

        container.dispose();
      });
    });

    test('times out after the max wait with a manual-refresh message', () {
      fakeAsync((async) {
        final network = _ScriptedNetwork([_job('pending')]);
        final container = _container(network);
        final controller =
            container.read(authorizeOnuControllerProvider.notifier);
        controller.maxWait = const Duration(seconds: 6);

        unawaited(controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'Ahmed Raza',
        ));
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        expect(network.fetchJobCalls, 1);
        expect(
          container.read(authorizeOnuControllerProvider).phase,
          AuthorizePhase.polling,
        );

        // At the 6 s tick the cap trips before another fetch.
        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        final state = container.read(authorizeOnuControllerProvider);
        expect(state.phase, AuthorizePhase.timedOut);
        expect(state.errorMessage, 'Still running — check again later');
        expect(state.jobId, 'job_1');
        expect(network.fetchJobCalls, 1);

        container.dispose();
      });
    });

    test('offline mid-poll keeps the job id and keeps polling', () {
      fakeAsync((async) {
        final network = _ScriptedNetwork([
          const NetworkException(),
          _job('succeeded', ontId: '5'),
        ]);
        final container = _container(network);
        final controller =
            container.read(authorizeOnuControllerProvider.notifier);

        unawaited(controller.submitDiscovered(
          requestId: 'req_1',
          oltId: 'olt_1',
          onuId: 'onu_1',
          description: 'Ahmed Raza',
        ));
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        var state = container.read(authorizeOnuControllerProvider);
        expect(network.fetchJobCalls, 1);
        expect(state.phase, AuthorizePhase.polling);
        expect(state.jobId, 'job_1');
        expect(state.pollErrorMessage, isNotNull);
        // No re-POST on a poll failure.
        expect(network.authorizeCalls, 1);

        async.elapse(const Duration(seconds: 3));
        async.flushMicrotasks();
        state = container.read(authorizeOnuControllerProvider);
        expect(state.phase, AuthorizePhase.succeeded);
        expect(state.job?.ontId, '5');

        container.dispose();
      });
    });
  });
}
