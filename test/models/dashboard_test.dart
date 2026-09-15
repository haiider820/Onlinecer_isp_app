import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/dashboard.dart';

void main() {
  group('DashboardSummary.fromJson', () {
    test('parses the documented dashboard response', () {
      final json = {
        'employee': {
          'id': '7',
          'name': 'Rafiq Hossain',
          'email': 'rafiq@example.com',
          'team': {
            'id': '2',
            'name': 'Gulshan Survey Team',
            'functional_team_type': 'survey',
          },
        },
        'stats': {
          'connection_requests': {'total': 40, 'pending': 12, 'completed': 28},
          'tickets': {'total': 4, 'pending': 1, 'completed': 3},
        },
        'recent_connection_requests': [
          {
            'id': '101',
            'request_number': 'CR-001-2026',
            'status': 'assigned',
            'customer_name': 'Karim Ahmed',
          },
        ],
        'recent_tickets': [],
      };

      final summary = DashboardSummary.fromJson(json);

      expect(summary.employee, isNotNull);
      expect(summary.employee!.name, 'Rafiq Hossain');
      expect(summary.employee!.team?.functionalTeamType, 'survey');

      expect(summary.stats, isNotNull);
      expect(summary.stats!.connectionRequests, isNotNull);
      expect(summary.stats!.connectionRequests!.pending, 12);
      expect(summary.stats!.connectionRequests!.completed, 28);

      expect(summary.recentConnectionRequests, hasLength(1));
      expect(summary.recentConnectionRequests!.first.status, 'assigned');
    });

    test('survives an empty/missing dashboard payload', () {
      final summary = DashboardSummary.fromJson(const {});

      expect(summary.employee, isNull);
      expect(summary.stats, isNull);
      expect(summary.recentConnectionRequests, isNull);
      expect(summary.recentTickets, isNull);
    });
  });

  group('DashboardStats.fromJson', () {
    test('maps snake_case keys to camelCase fields', () {
      final stats = DashboardStats.fromJson(const {
        'connection_requests': {'total': 1, 'pending': 1, 'completed': 0},
      });

      expect(stats.connectionRequests?.total, 1);
      expect(stats.connectionRequests?.pending, 1);
      expect(stats.connectionRequests?.completed, 0);
      expect(stats.tickets, isNull);
    });
  });
}