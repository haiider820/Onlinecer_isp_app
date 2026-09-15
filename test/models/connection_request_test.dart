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