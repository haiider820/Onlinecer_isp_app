import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/closing/models/closing_activation.dart';
import 'package:isp_onlinecer/features/stage_shared/data/team_stage_completion_repository.dart';

void main() {
  group('ClosingActivation.fromJson', () {
    test('parses the full live shape', () {
      final activation = ClosingActivation.fromJson({
        'pppoe_username': 'user123',
        'pppoe_password': 'secret-pass',
        'portal_email': 'customer@example.com',
        'portal_password': 'portal-pass',
        'radius_synced': true,
      });

      expect(activation.pppoeUsername, 'user123');
      expect(activation.pppoePassword, 'secret-pass');
      expect(activation.portalEmail, 'customer@example.com');
      expect(activation.portalPassword, 'portal-pass');
      expect(activation.radiusSynced, isTrue);
      expect(activation.hasAnyValue, isTrue);
    });

    test('missing fields parse to null, never crash', () {
      final activation = ClosingActivation.fromJson({});

      expect(activation.pppoeUsername, isNull);
      expect(activation.pppoePassword, isNull);
      expect(activation.portalEmail, isNull);
      expect(activation.portalPassword, isNull);
      expect(activation.radiusSynced, isNull);
      expect(activation.hasAnyValue, isFalse);
    });

    test('radius_synced false survives the parse', () {
      final activation = ClosingActivation.fromJson({
        'pppoe_username': 'user123',
        'radius_synced': false,
      });

      expect(activation.radiusSynced, isFalse);
      expect(activation.hasAnyValue, isTrue);
    });

    test('non-boolean radius_synced parses to null', () {
      final activation = ClosingActivation.fromJson({
        'radius_synced': 'false',
      });

      expect(activation.radiusSynced, isNull);
    });

    test('blank strings parse to null', () {
      final activation = ClosingActivation.fromJson({
        'pppoe_username': '   ',
        'pppoe_password': '',
      });

      expect(activation.pppoeUsername, isNull);
      expect(activation.pppoePassword, isNull);
      expect(activation.hasAnyValue, isFalse);
    });

    test('numeric values coerce to strings', () {
      final activation = ClosingActivation.fromJson({
        'pppoe_username': 12345,
      });

      expect(activation.pppoeUsername, '12345');
    });
  });

  group('TeamStageCompletionResult.fromJson — activation (D24)', () {
    test('parses activation from response.data.data.activation', () {
      final result = TeamStageCompletionResult.fromJson({
        'message': 'Connection closed successfully.',
        'data': {
          'id': 'req-1',
          'status': 'connected',
          'activation': {
            'pppoe_username': 'user123',
            'pppoe_password': 'secret-pass',
            'portal_email': 'customer@example.com',
            'portal_password': 'portal-pass',
            'radius_synced': false,
          },
        },
      });

      expect(result.message, 'Connection closed successfully.');
      expect(result.status, 'connected');
      expect(result.activation, isNotNull);
      expect(result.activation!.pppoeUsername, 'user123');
      expect(result.activation!.portalPassword, 'portal-pass');
      expect(result.activation!.radiusSynced, isFalse);
    });

    test('absent activation parses to null (older response)', () {
      final result = TeamStageCompletionResult.fromJson({
        'message': 'Job closed.',
        'data': {'id': 'req-1', 'status': 'connected'},
      });

      expect(result.activation, isNull);
      expect(result.status, 'connected');
    });

    test('non-map activation parses to null, never throws', () {
      final result = TeamStageCompletionResult.fromJson({
        'message': 'Job closed.',
        'data': {'id': 'req-1', 'status': 'connected', 'activation': 'nope'},
      });

      expect(result.activation, isNull);
    });

    test('verification-style response has no activation', () {
      final result = TeamStageCompletionResult.fromJson({
        'message': 'Verification completed.',
        'data': {'id': 'req-1', 'status': 'closing_assigned'},
      });

      expect(result.activation, isNull);
    });
  });
}
