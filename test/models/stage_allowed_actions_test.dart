import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/stage_shared/models/team_stage_detail.dart';
import 'package:isp_onlinecer/models/splicing.dart';

/// Phase D: the stage detail models drive their action buttons from the
/// plural `allowed_actions` (singular `allowed_action` as fallback), never
/// from a fixed stage sequence.
void main() {
  group('SplicingDetail.actions (plural)', () {
    Map<String, dynamic> detailJson({
      List<String>? plural,
      String? singular,
    }) {
      return {
        'data': {
          'id': 'req_1',
          'request_number': 'CRQ-1',
          'status': 'splicing_assigned',
        },
        if (plural != null) 'allowed_actions': plural,
        if (singular != null) 'allowed_action': singular,
      };
    }

    test('plural list drives canComplete', () {
      final detail = SplicingDetail.fromJson(
        detailJson(plural: ['complete_splicing']),
      );

      expect(detail.actions, ['complete_splicing']);
      expect(detail.canComplete, isTrue);
    });

    test('plural without the stage action hides the button', () {
      final detail = SplicingDetail.fromJson(
        detailJson(plural: ['authorize_onu']),
      );

      expect(detail.actions, ['authorize_onu']);
      expect(detail.canComplete, isFalse);
    });

    test('falls back to singular when plural is absent', () {
      final detail = SplicingDetail.fromJson(
        detailJson(singular: 'complete_splicing'),
      );

      expect(detail.actions, ['complete_splicing']);
      expect(detail.canComplete, isTrue);
    });

    test('falls back to singular when plural is empty', () {
      final detail = SplicingDetail.fromJson(
        detailJson(plural: [], singular: 'complete_splicing'),
      );

      expect(detail.canComplete, isTrue);
    });

    test('plural wins over singular when both are present', () {
      final detail = SplicingDetail.fromJson(
        detailJson(
          plural: ['authorize_onu'],
          singular: 'complete_splicing',
        ),
      );

      expect(detail.actions, ['authorize_onu']);
      expect(detail.canComplete, isFalse);
    });

    test('unknown wire values are dropped', () {
      final detail = SplicingDetail.fromJson(
        detailJson(plural: ['not_a_real_action']),
      );

      expect(detail.actions, isEmpty);
      expect(detail.canComplete, isFalse);
    });
  });

  group('TeamStageDetail.allows (plural)', () {
    Map<String, dynamic> detailJson({
      List<String>? plural,
      String? singular,
    }) {
      return {
        'data': {
          'id': 'req_1',
          'request_number': 'CRQ-1',
          'status': 'verification_assigned',
        },
        if (plural != null) 'allowed_actions': plural,
        if (singular != null) 'allowed_action': singular,
      };
    }

    test('allows the action when the plural list contains it', () {
      final detail = TeamStageDetail.fromJson(
        detailJson(plural: ['complete_verification']),
      );

      expect(detail.actions, ['complete_verification']);
      expect(detail.allows('complete_verification'), isTrue);
      expect(detail.allows('complete_closing'), isFalse);
    });

    test('plural wins over singular when both are present', () {
      final detail = TeamStageDetail.fromJson(
        detailJson(
          plural: ['complete_closing'],
          singular: 'complete_verification',
        ),
      );

      expect(detail.allows('complete_verification'), isFalse);
      expect(detail.allows('complete_closing'), isTrue);
    });

    test('falls back to singular when plural is absent', () {
      final detail = TeamStageDetail.fromJson(
        detailJson(singular: 'complete_verification'),
      );

      expect(detail.allows('complete_verification'), isTrue);
    });

    test('no actions when both are absent', () {
      final detail = TeamStageDetail.fromJson(detailJson());

      expect(detail.actions, isEmpty);
      expect(detail.allows('complete_verification'), isFalse);
    });
  });
}
