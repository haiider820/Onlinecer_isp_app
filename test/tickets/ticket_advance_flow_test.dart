import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/features/tickets/data/ticket_network.dart';
import 'package:isp_onlinecer/features/tickets/presentation/ticket_detail_screen.dart';
import 'package:isp_onlinecer/features/tickets/presentation/ticket_list_screen.dart';
import 'package:isp_onlinecer/features/tickets/presentation/ticket_providers.dart';

class _FakeTicketNetwork implements TicketNetwork {
  final List<String?> advanceNotes = [];
  int _advanceCount = 0;

  @override
  Future<Map<String, dynamic>> fetchPage({
    required int page,
    String? status,
    String? search,
  }) async => {
        'data': [
          {
            'id': 'ticket-1',
            'ticket_number': 'TKT-1',
            'subject': 'No internet connection',
            'priority': 'HIGH',
            'status': _advanceCount == 0
                ? 'IN_PROGRESS'
                : _advanceCount == 1
                    ? 'RESOLVED'
                    : 'CLOSED',
            'customer_name': 'Amina Khan',
            'updated_at': '2026-09-13T10:00:00Z',
          },
        ],
        'meta': {'current_page': 1, 'last_page': 1, 'per_page': 20, 'total': 1},
      };

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) async => {
        'next_status': _advanceCount == 0
            ? 'RESOLVED'
            : _advanceCount == 1
                ? 'CLOSED'
                : null,
        'data': {
          'id': id,
          'ticket_number': 'TKT-1',
          'subject': 'No internet connection',
          'priority': 'HIGH',
          'status': _advanceCount == 0
              ? 'IN_PROGRESS'
              : _advanceCount == 1
                  ? 'RESOLVED'
                  : 'CLOSED',
          'description': 'Connection drops every few minutes.',
          'customer_name': 'Amina Khan',
          'activities': [
            {
              'type': 'status_change',
              'old_value': 'OPEN',
              'new_value': 'IN_PROGRESS',
              'employee': {'name': 'Support Agent'},
              'created_at': '2026-09-13T09:00:00Z',
            },
            {
              'type': 'note',
              'message': 'Technician has been assigned.',
              'user': {'name': 'Support Agent'},
              'created_at': '2026-09-13T09:05:00Z',
            },
          ],
        },
      };

  @override
  Future<Map<String, dynamic>> advance(String id, {String? note}) async {
    advanceNotes.add(note);
    _advanceCount++;
    return {
      'data': {
        'status': _advanceCount == 1 ? 'RESOLVED' : 'CLOSED',
      },
    };
  }
}

void main() {
  testWidgets(
    'ticket list, timeline, note and empty-note advances refresh through final stage',
    (tester) async {
      final network = _FakeTicketNetwork();
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, __) => const TicketListScreen()),
          GoRoute(
            path: '/tickets/:id',
            builder: (_, state) => TicketDetailScreen(
              ticketId: state.pathParameters['id']!,
            ),
          ),
        ],
      );
      addTearDown(router.dispose);

      expect(
        ApiErrorMapper.fromMessage(
          ApiErrorMapper.ticketForbiddenMessage,
          statusCode: 403,
        ).message,
        "This ticket isn't assigned to you.",
      );
      expect(
        ApiErrorMapper.fromMessage(
          ApiErrorMapper.ticketFinalStageMessage,
          statusCode: 422,
        ).message,
        ApiErrorMapper.ticketFinalStageMessage,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [ticketNetworkProvider.overrideWithValue(network)],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('TKT-1'), findsOneWidget);
      await tester.tap(find.text('TKT-1'));
      await tester.pumpAndSettle();

      expect(find.text('Status changed'), findsOneWidget);
      expect(find.text('Technician has been assigned.'), findsOneWidget);
      expect(find.text('Advance to RESOLVED'), findsOneWidget);

      await tester.tap(find.text('Advance to RESOLVED'));
      // A focused TextField has a continuously blinking cursor, so a bounded
      // pump is appropriate here instead of waiting for the test tree to idle.
      await tester.pump(const Duration(milliseconds: 200));
      await tester.enterText(find.byType(TextField), 'Technician confirmed repair.');
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(network.advanceNotes, ['Technician confirmed repair.']);
      expect(find.text('Advance to CLOSED'), findsOneWidget);

      await tester.tap(find.text('Advance to CLOSED'));
      await tester.pump(const Duration(milliseconds: 200));
      await tester.tap(find.text('Confirm'));
      await tester.pumpAndSettle();

      expect(network.advanceNotes, orderedEquals(['Technician confirmed repair.', isNull]));
      expect(find.textContaining('Advance to'), findsNothing);
    },
  );
}
