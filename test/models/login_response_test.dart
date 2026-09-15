import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/auth.dart';

void main() {
  group('LoginResponse.fromJson', () {
    test('parses the documented login response', () {
      final json = <String, Object?>{
        'message': 'Login successful.',
        'token_type': 'Bearer',
        'token': 'plain_token_here',
        'expires_at': '2026-10-10T11:00:00.000000Z',
        'user': {'id': 25, 'name': 'Ahmed Raza', 'email': 'ahmed.raza@malikfiber.pk'},
        'employee': {
          'id': 'employee_uuid',
          'user_id': 25,
          'employee_code': 'EMP-001',
          'name': 'Ahmed Raza',
          'email': 'ahmed.raza@malikfiber.pk',
          'phone': null,
          'is_active': true,
          'organization': {'id': 'organization_uuid', 'name': 'Malik Fiber'},
          'team': {
            'id': 'team_uuid',
            'name': 'Survey Team',
            'code': 'SURVEY',
            'functional_team_type': 'survey',
            'flow_order': 1,
            'is_active': true,
          },
        },
        'permissions': <Object?>[],
        'permission_labels': <Object?>[],
      };

      final login = LoginResponse.fromJson(json);

      expect(login.token, 'plain_token_here');
      expect(login.tokenType, 'Bearer');
      expect(login.expiresAt, '2026-10-10T11:00:00.000000Z');
      expect(login.user?.name, 'Ahmed Raza');
      expect(login.employee?.employeeCode, 'EMP-001');
      expect(login.employee?.team?.functionalTeamType, 'survey');
      expect(login.employee?.team?.flowOrder, 1);
      expect(login.employee?.organization?.name, 'Malik Fiber');
      expect(login.permissions, isEmpty);
    });

    test('survives null optional, team, and permissions', () {
      final json = <String, Object?>{
        'message': 'Login successful.',
        'token_type': 'Bearer',
        'token': 't',
        'user': null,
        'employee': {
          'id': 'employee_uuid',
          'name': 'Name',
          'email': 'e@x.pk',
          'team': null,
        },
      };

      final login = LoginResponse.fromJson(json);

      expect(login.user, isNull);
      expect(login.employee?.team, isNull);
      expect(login.employee?.name, 'Name');
    });
  });
}