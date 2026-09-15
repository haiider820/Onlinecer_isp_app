import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';
import 'package:isp_onlinecer/features/stage_shared/data/team_stage_completion_network.dart';
import 'package:isp_onlinecer/features/stage_shared/data/team_stage_completion_repository.dart';
import 'package:isp_onlinecer/features/stage_shared/models/team_stage_detail.dart';
import 'package:isp_onlinecer/features/stage_shared/team_stage_config.dart';

class _FakeStageNetwork implements TeamStageCompletionNetwork {
  TeamStageConfig? jsonConfig;
  TeamStageConfig? multipartConfig;
  String? jsonNotes;
  String? multipartNotes;
  String? multipartPath;
  String? multipartMime;

  @override
  Future<Map<String, dynamic>> postJson(
    TeamStageConfig config,
    String requestId, {
    String? notes,
  }) async {
    jsonConfig = config;
    jsonNotes = notes;
    return {
      'message': 'Completed',
      'data': {
        'id': requestId,
        'status': config.isTerminal ? 'closing_completed' : 'closing_assigned',
        'current_team': config.isTerminal ? null : {'id': 'closing-team', 'name': 'Closing Team'},
      },
    };
  }

  @override
  Future<Map<String, dynamic>> postMultipart(
    TeamStageConfig config,
    String requestId, {
    String? notes,
    required String voiceNotePath,
    required String voiceNoteMimeType,
  }) async {
    multipartConfig = config;
    multipartNotes = notes;
    multipartPath = voiceNotePath;
    multipartMime = voiceNoteMimeType;
    return {
      'message': 'Completed',
      'data': {
        'id': requestId,
        'status': config.isTerminal ? 'closing_completed' : 'closing_assigned',
        'current_team': config.isTerminal ? null : {'id': 'closing-team', 'name': 'Closing Team'},
      },
    };
  }
}

Map<String, dynamic> _detailJson(String action) => {
      'allowed_action': action,
      'data': {
        'id': 'request-1',
        'request_number': 'CRQ-101',
        'status': action == 'complete_verification' ? 'verification_assigned' : 'closing_assigned',
        'assigned_users': {
          'surveyor': {'id': 'survey-1', 'name': 'Surveyor'},
          'technician': {'id': 'tech-1', 'name': 'Technician'},
          'splicer': {'id': 'splice-1', 'name': 'Splicer'},
        },
        'locations': {
          'fat_node': {'id': 'fat-1', 'name': 'FAT North', 'latitude': 33.72, 'longitude': 73.07},
        },
        'charges': {'connection_charges_minor': 2500, 'subscription_charges_minor': 250000, 'inventory_cost_minor': 0},
        'timestamps': {'surveyed_at': '2026-01-01T00:00:00Z'},
        'notes': [
          {'type': 'splicing', 'note': 'Spliced.', 'voice_note_url': 'https://example.test/splice.m4a'},
        ],
        'items': [
          {'item_name': 'Drop cable', 'quantity': 1, 'total_minor': 0},
        ],
        'documents': {'id_card_front_url': 'https://example.test/id-front.jpg'},
        'stage_data': {'survey_notes': 'Survey complete', 'total_wire_used': 75},
      },
    };

void main() {
  test('verification parses detail, gates action, and uses JSON then multipart completion', () async {
    final detail = TeamStageDetail.fromJson(_detailJson(TeamStageConfig.verification.allowedAction));
    final network = _FakeStageNetwork();
    final repository = TeamStageCompletionRepository(network: network);

    expect(detail.allows(TeamStageConfig.verification.allowedAction), isTrue);
    expect(detail.allows(TeamStageConfig.closing.allowedAction), isFalse);
    expect(detail.assignedUsers, hasLength(3));
    expect(detail.fatNode?.name, 'FAT North');
    expect(detail.notes.single.voiceNoteUrl, contains('splice.m4a'));
    expect(detail.items.single.values['item_name'], 'Drop cable');
    expect(detail.documents.single.url, contains('id-front.jpg'));
    expect(detail.stageData['survey_notes'], 'Survey complete');

    final jsonResult = await repository.submit(
      config: TeamStageConfig.verification,
      requestId: detail.id,
      notes: 'Signal verified.',
    );
    expect(network.jsonConfig, same(TeamStageConfig.verification));
    expect(network.jsonNotes, 'Signal verified.');
    expect(jsonResult.status, 'closing_assigned');

    final temp = await Directory.systemTemp.createTemp('stage_voice_test_');
    try {
      final voice = File('${temp.path}${Platform.pathSeparator}verification.m4a');
      await voice.writeAsBytes([1, 2, 3]);
      await repository.submit(
        config: TeamStageConfig.verification,
        requestId: detail.id,
        notes: 'Signal verified.',
        voiceNotePath: voice.path,
      );
      expect(network.multipartConfig, same(TeamStageConfig.verification));
      expect(network.multipartNotes, 'Signal verified.');
      expect(network.multipartPath, voice.path);
      expect(network.multipartMime, 'audio/mp4');
    } finally {
      await temp.delete(recursive: true);
    }
  });

  test('closing parses detail, gates action, completes terminally, and reuses stage errors', () async {
    final detail = TeamStageDetail.fromJson(_detailJson(TeamStageConfig.closing.allowedAction));
    final network = _FakeStageNetwork();
    final repository = TeamStageCompletionRepository(network: network);

    expect(detail.allows(TeamStageConfig.closing.allowedAction), isTrue);
    expect(detail.allows(TeamStageConfig.verification.allowedAction), isFalse);

    final result = await repository.submit(
      config: TeamStageConfig.closing,
      requestId: detail.id,
      notes: 'Customer informed and job closed.',
    );
    expect(network.jsonConfig, same(TeamStageConfig.closing));
    expect(network.jsonNotes, 'Customer informed and job closed.');
    expect(result.status, 'closing_completed');
    expect(result.currentTeam, isNull);

    final unauthorized = ApiErrorMapper.fromMessage(ApiErrorMapper.notAuthorizedForActionMessage, statusCode: 403);
    final notReady = ApiErrorMapper.fromMessage(ApiErrorMapper.notReadyMessage, statusCode: 422);
    expect(unauthorized.message, ApiErrorMapper.notAuthorizedForActionMessage);
    expect(unauthorized.statusCode, 403);
    expect(notReady.message, ApiErrorMapper.notReadyMessage);
    expect(notReady.statusCode, 422);
  });
}
