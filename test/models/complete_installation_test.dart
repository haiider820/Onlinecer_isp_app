import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/complete_installation.dart';

void main() {
  group('CompleteInstallationResponse.fromJson', () {
    test('parses the documented success payload', () {
      final response = CompleteInstallationResponse.fromJson(const {
        'message': 'Installation marked as completed.',
        'data': {
          'id': '102',
          'request_number': 'CRQ-20260911-IN21',
          'status': 'splicing_assigned',
          'current_team': {
            'id': 'team_5',
            'name': 'Splicing Team',
            'functional_team_type': 'splicing',
          },
          'timestamps': {'installed_at': '2026-09-12T10:00:00.000000Z'},
        },
      });

      expect(response.message, 'Installation marked as completed.');
      expect(response.data?.requestNumber, 'CRQ-20260911-IN21');
      expect(response.data?.status, 'splicing_assigned');
      expect(response.data?.currentTeam?.functionalTeamType, 'splicing');
      expect(response.data?.timestamps?.installedAt, '2026-09-12T10:00:00.000000Z');
    });

    test('survives a minimal or empty payload', () {
      final minimal = CompleteInstallationResponse.fromJson(const {
        'message': 'Installation marked as completed.',
      });

      expect(minimal.message, 'Installation marked as completed.');
      expect(minimal.data, isNull);

      final empty = CompleteInstallationResponse.fromJson(const {});
      expect(empty.message, isNull);
      expect(empty.data, isNull);
    });
  });
}