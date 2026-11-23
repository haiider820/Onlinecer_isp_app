import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/connection_request.dart';
import 'package:isp_onlinecer/models/team.dart';

void main() {
  group('ConnectionRequest.fromJson', () {
    test('parses the documented list-item shape', () {
      final json = <String, Object?>{
        'id': 'connection_request_uuid',
        'request_number': 'CRQ-20260910-ABCD',
        'status': 'survey_assigned',
        'customer_name': 'Customer Name',
        'customer_type': 'home',
        'customer_phone': '03000000000',
        'customer_address': 'House address',
        'customer_area': 'Area Name',
        'requested_plan': {'id': 'plan_uuid', 'name': '20 Mbps', 'price_minor': 250000},
        'current_team': {
          'id': 'team_uuid',
          'name': 'Survey Team',
          'functional_team_type': 'survey',
        },
      };

      final request = ConnectionRequest.fromJson(json);

      expect(request.id, 'connection_request_uuid');
      expect(request.requestNumber, 'CRQ-20260910-ABCD');
      expect(request.status, 'survey_assigned');
      expect(request.customerArea, 'Area Name');
      expect(request.requestedPlan?.name, '20 Mbps');
      expect(request.requestedPlan?.priceMinor, 250000);
      expect(request.currentTeam?.functionalTeamType, 'survey');
    });

    test('current_team can be partial (id/name/functional_team_type only)', () {
      final json = <String, Object?>{
        'id': 'connection_request_uuid',
        'request_number': 'CRQ-1',
        'status': 'survey_assigned',
        'current_team': {
          'id': 'team_uuid',
          'name': 'Survey Team',
          'functional_team_type': 'survey',
        },
      };

      final request = ConnectionRequest.fromJson(json);

      expect(request.currentTeam, isA<Team>());
      expect(request.currentTeam?.name, 'Survey Team');
    });
  });

  group('ConnectionRequestDetail.fromJson', () {
    test('parses data + allowed_action envelope', () {
      final json = <String, Object?>{
        'data': {
          'id': 'connection_request_uuid',
          'request_number': 'CRQ-20260910-ABCD',
          'status': 'survey_assigned',
          'customer_address': 'House address',
        },
        'allowed_action': 'complete_survey',
      };

      final detail = ConnectionRequestDetail.fromJson(json);

      expect(detail.request.requestNumber, 'CRQ-20260910-ABCD');
      expect(detail.action, ConnectionRequestAction.completeSurvey);
    });

    test('null allowed_action exposes no action', () {
      final json = <String, Object?>{
        'data': {
          'id': 'connection_request_uuid',
          'request_number': 'CRQ-X',
          'status': 'installation_assigned',
        },
        'allowed_action': null,
      };

      final detail = ConnectionRequestDetail.fromJson(json);

      expect(detail.action, isNull);
    });
  });

  group('ConnectionRequestDetail allowed_actions (plural)', () {
    test('parses plural list including authorize_onu', () {
      final json = <String, Object?>{
        'data': {
          'id': 'connection_request_uuid',
          'request_number': 'CRQ-20260910-ABCD',
          'status': 'installation_assigned',
          'customer_address': 'House address',
        },
        'allowed_action': 'authorize_onu',
        'allowed_actions': <Object?>['authorize_onu', 'complete_installation'],
      };

      final detail = ConnectionRequestDetail.fromJson(json);

      expect(detail.allowedActions, ['authorize_onu', 'complete_installation']);
      expect(detail.actions, [
        ConnectionRequestAction.authorizeOnu,
        ConnectionRequestAction.completeInstallation,
      ]);
      expect(detail.actions, contains(ConnectionRequestAction.authorizeOnu));
      expect(ConnectionRequestAction.authorizeOnu.wireValue, 'authorize_onu');
      expect(ConnectionRequestAction.parse('authorize_onu'),
          ConnectionRequestAction.authorizeOnu);
    });

    test('falls back to singular allowed_action when plural is absent', () {
      final json = <String, Object?>{
        'data': {
          'id': 'connection_request_uuid',
          'request_number': 'CRQ-1',
          'status': 'survey_assigned',
        },
        'allowed_action': 'complete_survey',
      };

      final detail = ConnectionRequestDetail.fromJson(json);

      expect(detail.allowedActions, isNull);
      expect(detail.actions, [ConnectionRequestAction.completeSurvey]);
    });

    test('falls back to singular when plural is empty; unknown values dropped', () {
      final json = <String, Object?>{
        'data': {
          'id': 'connection_request_uuid',
          'request_number': 'CRQ-1',
          'status': 'installation_assigned',
        },
        'allowed_action': 'complete_installation',
        'allowed_actions': <Object?>['not_a_real_action'],
      };

      final detail = ConnectionRequestDetail.fromJson(json);

      expect(detail.actions, isEmpty);
    });

    test('no actions when both plural and singular are absent', () {
      final json = <String, Object?>{
        'data': {
          'id': 'connection_request_uuid',
          'request_number': 'CRQ-1',
          'status': 'installation_assigned',
        },
        'allowed_action': null,
      };

      final detail = ConnectionRequestDetail.fromJson(json);

      expect(detail.actions, isEmpty);
      expect(detail.action, isNull);
    });
  });

  group('ConnectionRequest sub_branch + installed_device', () {
    test('parses both blocks leniently as maps', () {
      final json = <String, Object?>{
        'id': 'connection_request_uuid',
        'request_number': 'CRQ-1',
        'status': 'installation_assigned',
        'sub_branch': {
          'id': 'sub_branch_uuid',
          'name': 'Gulberg Sub-Branch',
        },
        'installed_device': {
          'serial_number': 'HWTC12345678',
          'ont_id': '5',
        },
      };

      final request = ConnectionRequest.fromJson(json);

      expect(request.subBranch?['id'], 'sub_branch_uuid');
      expect(request.subBranch?['name'], 'Gulberg Sub-Branch');
      expect(request.installedDevice?['serial_number'], 'HWTC12345678');
      expect(request.installedDevice?['ont_id'], '5');
    });

    test('tolerates both blocks absent', () {
      final json = <String, Object?>{
        'id': 'connection_request_uuid',
        'request_number': 'CRQ-1',
        'status': 'survey_assigned',
      };

      final request = ConnectionRequest.fromJson(json);

      expect(request.subBranch, isNull);
      expect(request.installedDevice, isNull);
    });
  });

  group('ConnectionRequestPage.fromJson', () {
    test('parses data + meta envelope', () {
      final json = <String, Object?>{
        'data': <Object?>[
          {
            'id': 'id1',
            'request_number': 'CRQ-1',
            'status': 'survey_assigned',
          }
        ],
        'meta': {'current_page': 1, 'per_page': 20, 'total': 1, 'last_page': 1},
      };

      final page = ConnectionRequestPage.fromJson(json);

      expect(page.data, hasLength(1));
      expect(page.meta.total, 1);
      expect(page.meta.lastPage, 1);
    });
  });
}