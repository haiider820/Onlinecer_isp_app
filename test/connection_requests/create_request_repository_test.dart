import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/connection_requests/data/create_request_network.dart';
import 'package:isp_onlinecer/features/connection_requests/data/create_request_repository.dart';

class _FakeCreateRequestNetwork implements CreateRequestNetwork {
  _FakeCreateRequestNetwork(this.createResult, this.createDataResult, {this.error});

  final Map<String, dynamic> createResult;
  final Map<String, dynamic> createDataResult;
  final Exception? error;

  FormData? lastForm;
  String? lastSubBranchId;
  int createCount = 0;

  @override
  Future<Map<String, dynamic>> fetchCreateData({String? subBranchId}) async {
    lastSubBranchId = subBranchId;
    if (error != null) throw error!;
    return createDataResult;
  }

  @override
  Future<Map<String, dynamic>> createConnectionRequest(FormData form) async {
    lastForm = form;
    createCount++;
    if (error != null) throw error!;
    return createResult;
  }
}

const _createDataMap = {
  'data': {
    'customer_types': [
      {'value': 'home', 'label': 'Home'},
      {'value': 'business', 'label': 'Business'},
    ],
    'plans': [
      {'id': 'plan_1', 'name': 'Fiber 20 Mbps', 'price_minor': 120000},
    ],
    'fat_nodes': [
      {'id': 'node_1', 'name': 'FAT-A Gulberg', 'node_type': 'dp'},
    ],
    'team_flows': [
      {'id': 'flow_1', 'name': 'Standard', 'functional_team_type': 'survey'},
    ],
  },
};

const _createdMap = {
  'message': 'Connection request created.',
  'data': {
    'id': 'req_9',
    'request_number': 'CRQ-20261123-0001',
    'status': 'survey_assigned',
    'customer_name': 'Rahim Uddin',
    'sub_branch': {'id': 'sb_only', 'name': 'Only Sub-Branch'},
    'requested_plan': {'id': 'plan_1', 'name': 'Fiber 20 Mbps'},
  },
  'allowed_action': 'complete_survey',
  'allowed_actions': ['complete_survey'],
};

/// Field values of a captured [FormData] as a plain map.
Map<String, String> _fields(FormData form) => Map.fromEntries(form.fields);

/// File field names of a captured [FormData].
Set<String> _fileFields(FormData form) =>
    form.files.map((entry) => entry.key).toSet();

void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('create_request_test');
  });

  tearDown(() => tempDir.deleteSync(recursive: true));

  CreateRequestFile image(String name) {
    final file = File('${tempDir.path}/$name')
      ..writeAsBytesSync(List.filled(1024, 0));
    return (path: file.path, mime: 'image/jpeg');
  }

  group('CreateRequestRepository.fetchCreateData', () {
    test('parses customer types, plans, FAT nodes and team flows', () async {
      final network = _FakeCreateRequestNetwork(_createdMap, _createDataMap);
      final repository = CreateRequestRepository(network: network);

      final response = await repository.fetchCreateData(subBranchId: 'sb_only');

      expect(network.lastSubBranchId, 'sb_only');
      expect(response.data?.customerTypes, hasLength(2));
      expect(response.data?.customerTypes?.first.value, 'home');
      expect(response.data?.plans, hasLength(1));
      expect(response.data?.plans?.first.name, 'Fiber 20 Mbps');
      expect(response.data?.fatNodes, hasLength(1));
      expect(response.data?.fatNodes?.first.name, 'FAT-A Gulberg');
      expect(response.data?.teamFlows, hasLength(1));
      expect(response.data?.teamFlows?.first.functionalTeamType, 'survey');
    });

    test('forwards a null sub-branch id (no query param)', () async {
      final network = _FakeCreateRequestNetwork(_createdMap, _createDataMap);
      final repository = CreateRequestRepository(network: network);

      await repository.fetchCreateData();

      expect(network.lastSubBranchId, isNull);
    });

    test('propagates network failures', () async {
      final network = _FakeCreateRequestNetwork(
        _createdMap,
        _createDataMap,
        error: Exception('server unreachable'),
      );
      final repository = CreateRequestRepository(network: network);

      expect(repository.fetchCreateData(), throwsException);
    });
  });

  group('CreateRequestRepository.create', () {
    test('sends the exact guide §4 field names and parses the 201', () async {
      final network = _FakeCreateRequestNetwork(_createdMap, _createDataMap);
      final repository = CreateRequestRepository(network: network);

      final response = await repository.create(
        customerName: 'Rahim Uddin',
        customerPhone: '+92 300 1234567',
        subBranchId: 'sb_only',
        idCardFront: image('front.jpg'),
        idCardBack: image('back.jpg'),
      );

      final fields = _fields(network.lastForm!);
      expect(fields['customer_name'], 'Rahim Uddin');
      expect(fields['customer_phone'], '+92 300 1234567');
      expect(fields['customer_type'], 'home');
      expect(fields['sub_branch_id'], 'sb_only');
      // No optional field is sent when the user left it empty.
      expect(fields.containsKey('customer_area'), isFalse);
      expect(fields.containsKey('requested_plan_id'), isFalse);
      expect(fields.containsKey('price_mode'), isFalse);
      expect(_fileFields(network.lastForm!), {'id_card_front', 'id_card_back'});

      expect(response.message, 'Connection request created.');
      expect(response.data?.id, 'req_9');
      expect(response.data?.requestNumber, 'CRQ-20261123-0001');
      expect(response.data?.status, 'survey_assigned');
      expect(response.data?.customerName, 'Rahim Uddin');
      expect(response.data?.subBranch?['name'], 'Only Sub-Branch');
      expect(response.data?.requestedPlan?['name'], 'Fiber 20 Mbps');
      expect(response.allowedAction, 'complete_survey');
      expect(response.allowedActions, ['complete_survey']);
    });

    test('sends every optional field when provided', () async {
      final network = _FakeCreateRequestNetwork(_createdMap, _createDataMap);
      final repository = CreateRequestRepository(network: network);

      await repository.create(
        customerName: 'Rahim Uddin',
        customerPhone: '+92 300 1234567',
        customerType: 'business',
        customerArea: 'Gulberg',
        customerAddress: 'House 12, Street 5',
        requestedPlanId: 'plan_1',
        teamFlowId: 'flow_1',
        priceMode: 'custom_price',
        customPrice: '1500',
        discountType: 'fixed',
        discountValue: '200',
        idCardFront: image('front.jpg'),
        idCardBack: image('back.jpg'),
        utilityBill: image('bill.jpg'),
        connectionForm: image('form.jpg'),
      );

      final fields = _fields(network.lastForm!);
      expect(fields['customer_type'], 'business');
      expect(fields['customer_area'], 'Gulberg');
      expect(fields['customer_address'], 'House 12, Street 5');
      expect(fields['requested_plan_id'], 'plan_1');
      expect(fields['team_flow_id'], 'flow_1');
      expect(fields['price_mode'], 'custom_price');
      expect(fields['custom_price'], '1500');
      expect(fields['discount_type'], 'fixed');
      expect(fields['discount_value'], '200');
      expect(_fileFields(network.lastForm!), {
        'id_card_front',
        'id_card_back',
        'utility_bill',
        'connection_form',
      });
    });

    test('omits sub_branch_id when no scope was resolved', () async {
      final network = _FakeCreateRequestNetwork(_createdMap, _createDataMap);
      final repository = CreateRequestRepository(network: network);

      await repository.create(
        customerName: 'Rahim Uddin',
        customerPhone: '+92 300 1234567',
        idCardFront: image('front.jpg'),
        idCardBack: image('back.jpg'),
      );

      expect(_fields(network.lastForm!).containsKey('sub_branch_id'), isFalse);
    });

    test('rejects an ID card image larger than 10 MB before any call', () async {
      // Sparse 11 MB file: length reports 11 MB without writing 11 MB.
      final big = File('${tempDir.path}/big.jpg')..createSync();
      final raf = big.openSync(mode: FileMode.write);
      raf.truncateSync(11 * 1024 * 1024);
      raf.closeSync();
      expect(big.lengthSync(), 11 * 1024 * 1024);

      final network = _FakeCreateRequestNetwork(_createdMap, _createDataMap);
      final repository = CreateRequestRepository(network: network);

      expect(
        () => repository.create(
          customerName: 'Rahim Uddin',
          customerPhone: '+92 300 1234567',
          idCardFront: (path: big.path, mime: 'image/jpeg'),
          idCardBack: image('back.jpg'),
        ),
        throwsA(isA<IdCardTooLargeException>()),
      );
      expect(network.createCount, 0);
    });

    test('accepts an ID card image of exactly 10 MB', () async {
      final exact = File('${tempDir.path}/exact.jpg')..createSync();
      final raf = exact.openSync(mode: FileMode.write);
      raf.truncateSync(10 * 1024 * 1024);
      raf.closeSync();

      final network = _FakeCreateRequestNetwork(_createdMap, _createDataMap);
      final repository = CreateRequestRepository(network: network);

      await repository.create(
        customerName: 'Rahim Uddin',
        customerPhone: '+92 300 1234567',
        idCardFront: (path: exact.path, mime: 'image/jpeg'),
        idCardBack: image('back.jpg'),
      );

      expect(network.createCount, 1);
    });

    test('rejects a non-image MIME type before any call', () async {
      final network = _FakeCreateRequestNetwork(_createdMap, _createDataMap);
      final repository = CreateRequestRepository(network: network);

      expect(
        () => repository.create(
          customerName: 'Rahim Uddin',
          customerPhone: '+92 300 1234567',
          idCardFront: (path: image('front.jpg').path, mime: 'application/pdf'),
          idCardBack: image('back.jpg'),
        ),
        throwsA(isA<UnsupportedIdCardException>()),
      );
      expect(network.createCount, 0);
    });

    test('rejects an optional file with a bad MIME type too', () async {
      final network = _FakeCreateRequestNetwork(_createdMap, _createDataMap);
      final repository = CreateRequestRepository(network: network);

      expect(
        () => repository.create(
          customerName: 'Rahim Uddin',
          customerPhone: '+92 300 1234567',
          idCardFront: image('front.jpg'),
          idCardBack: image('back.jpg'),
          utilityBill: (path: image('bill.jpg').path, mime: 'text/plain'),
        ),
        throwsA(isA<UnsupportedIdCardException>()),
      );
      expect(network.createCount, 0);
    });

    test('propagates network failures to the caller', () async {
      final network = _FakeCreateRequestNetwork(
        _createdMap,
        _createDataMap,
        error: Exception('server unreachable'),
      );
      final repository = CreateRequestRepository(network: network);

      expect(
        () => repository.create(
          customerName: 'Rahim Uddin',
          customerPhone: '+92 300 1234567',
          idCardFront: image('front.jpg'),
          idCardBack: image('back.jpg'),
        ),
        throwsException,
      );
    });
  });

  group('CreateRequestRepository.mimeTypeForExtension', () {
    test('maps image extensions to image MIME types', () {
      expect(
        CreateRequestRepository.mimeTypeForExtension('id.JPG'),
        'image/jpeg',
      );
      expect(
        CreateRequestRepository.mimeTypeForExtension('id.jpeg'),
        'image/jpeg',
      );
      expect(
        CreateRequestRepository.mimeTypeForExtension('id.png'),
        'image/png',
      );
      expect(
        CreateRequestRepository.mimeTypeForExtension('id.webp'),
        'image/webp',
      );
    });

    test('maps anything else to octet-stream, which the guard rejects', () {
      expect(
        CreateRequestRepository.mimeTypeForExtension('id.pdf'),
        'application/octet-stream',
      );
      expect(
        CreateRequestRepository.mimeTypeForExtension('id'),
        'application/octet-stream',
      );
    });
  });

  group('CreateConnectionRequestResponse', () {
    test('parses a 201 without allowed_actions (old payload)', () {
      final response = CreateConnectionRequestResponse.fromJson({
        'message': 'Created.',
        'data': {
          'id': 'req_1',
          'request_number': 'CRQ-1',
          'status': 'survey_assigned',
        },
        'allowed_action': 'complete_survey',
      });

      expect(response.allowedAction, 'complete_survey');
      expect(response.allowedActions, isNull);
      expect(response.data?.requestNumber, 'CRQ-1');
    });
  });
}
