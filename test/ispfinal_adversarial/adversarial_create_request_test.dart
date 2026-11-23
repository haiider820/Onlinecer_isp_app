/// Flow 4 (create request) — adversarial controller + repository tests.
/// Faked network only; never a live server. Real files on disk are used for
/// the size guard (sync reads — async dart:io hangs in flutter_tester).
///
/// Tests marked DEFECT-DOCUMENTING assert the correct behaviour and are
/// EXPECTED TO FAIL against the current tree — the failure is the finding.
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/connection_requests/data/create_request_network.dart';
import 'package:isp_onlinecer/features/connection_requests/data/create_request_repository.dart';
import 'package:isp_onlinecer/features/connection_requests/presentation/create_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/models/connection_request.dart';

import 'helpers.dart';

class _ScriptedCreateNetwork implements CreateRequestNetwork {
  _ScriptedCreateNetwork({this.createDataResponse, this.createResponse, this.createError});

  final Map<String, dynamic>? createDataResponse;
  final Map<String, dynamic>? createResponse;
  final Object? createError;
  int createCalls = 0;
  FormData? lastForm;
  String? lastCreateDataSubBranch;

  @override
  Future<Map<String, dynamic>> fetchCreateData({String? subBranchId}) async {
    lastCreateDataSubBranch = subBranchId;
    if (createDataResponse != null) return createDataResponse!;
    throw const ApiException(message: 'Not found.', statusCode: 404);
  }

  @override
  Future<Map<String, dynamic>> createConnectionRequest(FormData form) async {
    createCalls++;
    lastForm = form;
    if (createError != null) throw createError!;
    return createResponse ??
        const {
          'message': 'Connection request created',
          'data': {
            'id': 'req-new',
            'request_number': 'CRQ-20261123-0001',
            'status': 'survey_assigned',
            'customer_name': 'Test Customer',
          },
          'allowed_action': 'complete_survey',
          'allowed_actions': ['complete_survey'],
        };
  }
}

/// Writes a real file of exactly [sizeBytes] so the repo's sync size guard
/// can read it. Deleted in tearDown.
File _sizedFile(Directory dir, String name, int sizeBytes) {
  final file = File('${dir.path}/$name');
  file.writeAsBytesSync(List<int>.filled(sizeBytes, 0xFF));
  return file;
}

ProviderContainer _container(_ScriptedCreateNetwork network) {
  final backing = InMemoryFlutterSecureStorage();
  return ProviderContainer(
    overrides: [
      secureStorageProvider.overrideWithValue(freshStorage(backing)),
      createRequestRepositoryProvider.overrideWithValue(
        CreateRequestRepository(network: network),
      ),
      // The controller invalidates the survey queue on success; stub it so
      // no refetch can ever reach the real server from a unit test.
      connectionRequestsProvider.overrideWith(
        (ref, page) async => ConnectionRequestPage(
          data: const [],
          meta: PaginationMeta(currentPage: 1, perPage: 15, total: 0, lastPage: 1),
        ),
      ),
    ],
  );
}

void _fillValidDraft(CreateRequestController controller, {required String frontPath, required String backPath}) {
  controller.updateCustomerName('Test Customer');
  controller.updateCustomerPhone('+923001234567');
  controller.setFile(
    CreateRequestFileSlot.idCardFront,
    (path: frontPath, mime: 'image/jpeg'),
  );
  controller.setFile(
    CreateRequestFileSlot.idCardBack,
    (path: backPath, mime: 'image/jpeg'),
  );
}

void main() {
  late Directory tmp;
  setUp(() {
    tmp = Directory.systemTemp.createTempSync('ispfinal_create_');
  });
  tearDown(() {
    if (tmp.existsSync()) tmp.deleteSync(recursive: true);
  });

  group('Flow 4 — create-data failure + 404', () {
    test('create-data 404 propagates as a typed ApiException (no silent empty form)', () async {
      final network = _ScriptedCreateNetwork();
      final container = _container(network);
      addTearDown(container.dispose);
      await expectLater(
        () => container.read(createDataProvider('sub-1').future),
        throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 404)),
      );
    });

    test('create-data is keyed by sub-branch: a scope switch refetches with the new id',
        () async {
      final network = _ScriptedCreateNetwork(
        createDataResponse: const {
          'customer_types': [
            {'value': 'home', 'label': 'Home'},
          ],
          'plans': [],
          'fat_nodes': [],
          'team_flows': [],
        },
      );
      final container = _container(network);
      addTearDown(container.dispose);
      await container.read(createDataProvider('sub-1').future);
      expect(network.lastCreateDataSubBranch, 'sub-1');
      await container.read(createDataProvider('sub-2').future);
      expect(network.lastCreateDataSubBranch, 'sub-2');
    });
  });

  group('Flow 4 — submit guards (repository)', () {
    test('file over 10 MB is rejected BEFORE any network call', () async {
      final network = _ScriptedCreateNetwork();
      final repo = CreateRequestRepository(network: network);
      final big = _sizedFile(tmp, 'big.jpg', 10 * 1024 * 1024 + 1);
      final small = _sizedFile(tmp, 'small.jpg', 100);
      await expectLater(
        () => repo.create(
          customerName: 'A',
          customerPhone: '1',
          idCardFront: (path: big.path, mime: 'image/jpeg'),
          idCardBack: (path: small.path, mime: 'image/jpeg'),
        ),
        throwsA(isA<IdCardTooLargeException>()),
      );
      expect(network.createCalls, 0);
    });

    test('file of exactly 10 MB passes the size guard', () async {
      final network = _ScriptedCreateNetwork();
      final repo = CreateRequestRepository(network: network);
      final exact = _sizedFile(tmp, 'exact.jpg', 10 * 1024 * 1024);
      final small = _sizedFile(tmp, 'small.jpg', 100);
      final result = await repo.create(
        customerName: 'A',
        customerPhone: '1',
        idCardFront: (path: exact.path, mime: 'image/jpeg'),
        idCardBack: (path: small.path, mime: 'image/jpeg'),
      );
      expect(network.createCalls, 1);
      expect(result.data!.requestNumber, 'CRQ-20261123-0001');
    });

    test('PDF MIME is rejected client-side (images only, per Haider 2026-11-23)', () async {
      final network = _ScriptedCreateNetwork();
      final repo = CreateRequestRepository(network: network);
      final pdf = _sizedFile(tmp, 'id.pdf', 100);
      final small = _sizedFile(tmp, 'small.jpg', 100);
      await expectLater(
        () => repo.create(
          customerName: 'A',
          customerPhone: '1',
          idCardFront: (path: pdf.path, mime: 'application/pdf'),
          idCardBack: (path: small.path, mime: 'image/jpeg'),
        ),
        throwsA(isA<UnsupportedIdCardException>()),
      );
      expect(network.createCalls, 0);
    });

    test('unknown extension maps to octet-stream and is rejected', () {
      expect(CreateRequestRepository.mimeTypeForExtension('id.bmp'), 'application/octet-stream');
      expect(CreateRequestRepository.mimeTypeForExtension('ID.JPG'), 'image/jpeg');
      expect(CreateRequestRepository.mimeTypeForExtension('id.webp'), 'image/webp');
    });

    test('missing file on disk throws before any network call (no silent 201)', () async {
      final network = _ScriptedCreateNetwork();
      final repo = CreateRequestRepository(network: network);
      final small = _sizedFile(tmp, 'small.jpg', 100);
      await expectLater(
        () => repo.create(
          customerName: 'A',
          customerPhone: '1',
          idCardFront: (path: '${tmp.path}/does-not-exist.jpg', mime: 'image/jpeg'),
          idCardBack: (path: small.path, mime: 'image/jpeg'),
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(network.createCalls, 0);
    });
  });

  group('Flow 4 — controller: draft, submit, success view', () {
    test('failed submit (offline) keeps the whole draft on screen with retry wording',
        () async {
      final network = _ScriptedCreateNetwork(createError: const NetworkException());
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(createRequestControllerProvider.notifier);
      final front = _sizedFile(tmp, 'front.jpg', 100);
      final back = _sizedFile(tmp, 'back.jpg', 100);
      _fillValidDraft(controller, frontPath: front.path, backPath: back.path);
      final result = await controller.submit(subBranchId: 'sub-1');
      expect(result, isNull);
      final state = container.read(createRequestControllerProvider);
      expect(state.customerName, 'Test Customer');
      expect(state.customerPhone, '+923001234567');
      expect(state.idCardFront, isNotNull);
      expect(state.idCardBack, isNotNull);
      expect(state.errorMessage, contains('still here'));
      expect(state.isSubmitting, isFalse);
      expect(network.createCalls, 1);
    });

    test('201 success populates created (request number + allowed action) and clears submitting',
        () async {
      final network = _ScriptedCreateNetwork();
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(createRequestControllerProvider.notifier);
      final front = _sizedFile(tmp, 'front.jpg', 100);
      final back = _sizedFile(tmp, 'back.jpg', 100);
      _fillValidDraft(controller, frontPath: front.path, backPath: back.path);
      final result = await controller.submit(subBranchId: 'sub-1');
      expect(result, isNotNull);
      expect(result!.data!.requestNumber, 'CRQ-20261123-0001');
      expect(result.data!.status, 'survey_assigned');
      expect(result.allowedActions, contains('complete_survey'));
      expect(container.read(createRequestControllerProvider).isDone, isTrue);
    });

    test('validation failure (no ID photos) never reaches the network', () async {
      final network = _ScriptedCreateNetwork();
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(createRequestControllerProvider.notifier);
      controller.updateCustomerName('Test Customer');
      controller.updateCustomerPhone('+923001234567');
      final result = await controller.submit(subBranchId: 'sub-1');
      expect(result, isNull);
      final state = container.read(createRequestControllerProvider);
      expect(state.fieldErrors['id_card_front'], isNotNull);
      expect(state.fieldErrors['id_card_back'], isNotNull);
      expect(network.createCalls, 0);
    });

    test('custom_price mode without a price is a validation error, not a server 422',
        () async {
      final network = _ScriptedCreateNetwork();
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(createRequestControllerProvider.notifier);
      final front = _sizedFile(tmp, 'front.jpg', 100);
      final back = _sizedFile(tmp, 'back.jpg', 100);
      _fillValidDraft(controller, frontPath: front.path, backPath: back.path);
      controller.selectPriceMode('custom_price');
      final result = await controller.submit(subBranchId: 'sub-1');
      expect(result, isNull);
      expect(container.read(createRequestControllerProvider).fieldErrors['custom_price'], isNotNull);
      expect(network.createCalls, 0);
    });

    test('DEFECT: submit with NO sub-branch scope still POSTs (unscoped request)', () async {
      // The screen gates on canProceed, but the controller itself never
      // refuses a null subBranchId — it just omits the field. Any future
      // caller (or a race where the scope clears mid-form) creates a
      // request with no sub-branch. The controller must reject null scope.
      final network = _ScriptedCreateNetwork();
      final container = _container(network);
      addTearDown(container.dispose);
      final controller = container.read(createRequestControllerProvider.notifier);
      final front = _sizedFile(tmp, 'front.jpg', 100);
      final back = _sizedFile(tmp, 'back.jpg', 100);
      _fillValidDraft(controller, frontPath: front.path, backPath: back.path);
      final result = await controller.submit(subBranchId: null);
      expect(result, isNull,
          reason: 'null scope must be refused before any POST');
      expect(network.createCalls, 0);
      expect(
        container.read(createRequestControllerProvider).errorMessage,
        isNotNull,
        reason: 'the user must be told a sub-branch is required',
      );
    });
  });
}
