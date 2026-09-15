import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/survey_submission.dart';

void main() {
  group('CompleteSurveyResponse.fromJson', () {
    test('parses the documented success payload', () {
      final response = CompleteSurveyResponse.fromJson(const {
        'message': 'Survey marked as completed.',
        'data': {
          'id': '101',
          'request_number': 'CRQ-20260910-ABCD',
          'status': 'installation_assigned',
          'current_team': {
            'id': 'team_uuid',
            'name': 'Installation Team',
            'functional_team_type': 'installation',
          },
          'timestamps': {'surveyed_at': '2026-09-10T11:00:00.000000Z'},
        },
      });

      expect(response.message, 'Survey marked as completed.');
      expect(response.data?.requestNumber, 'CRQ-20260910-ABCD');
      expect(response.data?.status, 'installation_assigned');
      expect(response.data?.currentTeam?.functionalTeamType, 'installation');
      expect(response.data?.timestamps?.surveyedAt, '2026-09-10T11:00:00.000000Z');
    });

    test('survives a minimal or empty payload', () {
      final minimal = CompleteSurveyResponse.fromJson(const {
        'message': 'Survey marked as completed.',
      });

      expect(minimal.message, 'Survey marked as completed.');
      expect(minimal.data, isNull);

      final empty = CompleteSurveyResponse.fromJson(const {});
      expect(empty.message, isNull);
      expect(empty.data, isNull);
    });
  });
}