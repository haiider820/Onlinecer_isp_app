import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/survey/data/submit_survey_network.dart';

import '../helpers/capturing_api_client.dart';

/// Wire-level tests for [DioSubmitSurveyNetwork] (D14): the exact JSON body
/// and FormData fields the app sends to `POST .../complete-survey`.
///
/// The repository tests only see the interface parameters — only these tests
/// prove the reason field is really omitted when the site is feasible and
/// really present when it is not, on both the JSON and multipart paths.
const _successMap = {
  'message': 'Survey marked as completed.',
  'data': {
    'id': '101',
    'request_number': 'CRQ-20260910-ABCD',
    'status': 'installation_assigned',
    'current_team': {'id': 'team_uuid', 'name': 'Installation Team', 'functional_team_type': 'installation'},
    'timestamps': {'surveyed_at': '2026-09-10T11:00:00.000000Z'},
  },
};

void main() {
  group('DioSubmitSurveyNetwork wire payloads', () {
    test('JSON feasible: sends status, never a reason', () async {
      final api = CapturingApiClient(_successMap);
      final network = DioSubmitSurveyNetwork(api.client);

      await network.completeSurveyJson(
        '101',
        notes: 'All good',
        feasibilityStatus: 'feasible',
        notFeasibleReason: 'stale reason that must not be sent',
      );

      final body = api.captured.data as Map<String, dynamic>;
      expect(body['survey_feasibility_status'], 'feasible');
      expect(body.containsKey('survey_not_feasible_reason'), isFalse);
      expect(body['survey_notes'], 'All good');
    });

    test('JSON not-feasible: sends status + reason', () async {
      final api = CapturingApiClient(_successMap);
      final network = DioSubmitSurveyNetwork(api.client);

      await network.completeSurveyJson(
        '101',
        notes: 'No FAT nearby.',
        feasibilityStatus: 'not_feasible',
        notFeasibleReason: 'No FAT port is reachable from this address',
      );

      final body = api.captured.data as Map<String, dynamic>;
      expect(body['survey_feasibility_status'], 'not_feasible');
      expect(
        body['survey_not_feasible_reason'],
        'No FAT port is reachable from this address',
      );
    });

    test('JSON not-feasible with an empty reason omits the reason field',
        () async {
      final api = CapturingApiClient(_successMap);
      final network = DioSubmitSurveyNetwork(api.client);

      await network.completeSurveyJson(
        '101',
        feasibilityStatus: 'not_feasible',
        notFeasibleReason: '',
      );

      final body = api.captured.data as Map<String, dynamic>;
      expect(body['survey_feasibility_status'], 'not_feasible');
      expect(body.containsKey('survey_not_feasible_reason'), isFalse);
    });

    test('multipart feasible: status travels with the voice note, no reason',
        () async {
      final dir = await Directory.systemTemp.createTemp('survey_net');
      addTearDown(() => dir.delete(recursive: true));
      final voice = File('${dir.path}/voice.m4a')
        ..writeAsBytesSync(List.filled(1024, 0));

      final api = CapturingApiClient(_successMap);
      final network = DioSubmitSurveyNetwork(api.client);

      await network.completeSurveyMultipart(
        '101',
        notes: 'All good',
        feasibilityStatus: 'feasible',
        voiceNotePath: voice.path,
        voiceNoteMimeType: 'audio/mp4',
      );

      final form = api.captured.data as FormData;
      final fields = formFields(form);
      expect(fields['survey_feasibility_status'], 'feasible');
      expect(fields.containsKey('survey_not_feasible_reason'), isFalse);
      expect(fields['survey_notes'], 'All good');
      expect(formFileFields(form), contains('voice_note'));
    });

    test('multipart not-feasible: status + reason travel with the voice note',
        () async {
      final dir = await Directory.systemTemp.createTemp('survey_net');
      addTearDown(() => dir.delete(recursive: true));
      final voice = File('${dir.path}/voice.m4a')
        ..writeAsBytesSync(List.filled(1024, 0));

      final api = CapturingApiClient(_successMap);
      final network = DioSubmitSurveyNetwork(api.client);

      await network.completeSurveyMultipart(
        '101',
        notes: 'No FAT nearby.',
        feasibilityStatus: 'not_feasible',
        notFeasibleReason: 'No FAT port is reachable from this address',
        voiceNotePath: voice.path,
        voiceNoteMimeType: 'audio/mp4',
      );

      final form = api.captured.data as FormData;
      final fields = formFields(form);
      expect(fields['survey_feasibility_status'], 'not_feasible');
      expect(
        fields['survey_not_feasible_reason'],
        'No FAT port is reachable from this address',
      );
      expect(formFileFields(form), contains('voice_note'));
    });
  });
}
