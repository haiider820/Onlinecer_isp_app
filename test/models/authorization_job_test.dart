import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/models/authorization_job.dart';

void main() {
  group('AuthorizationJob.fromJson', () {
    test('parses a running job', () {
      final json = <String, Object?>{
        'id': 'job_uuid',
        'status': 'running',
        'serial_number': 'HWTC12345678',
        'pon_port': '0/1/1',
        'ont_id': null,
        'line_profile': 'FTTH-100M',
        'service_profile': 'IPTV-DATA',
        'vlan': 100,
        'user_vlan': 101,
        'gemport': 1,
        'error_message': null,
        'started_at': '2026-11-23T10:05:00Z',
        'finished_at': null,
      };

      final job = AuthorizationJob.fromJson(json);

      expect(job.id, 'job_uuid');
      expect(job.status, 'running');
      expect(job.parsedStatus, AuthorizationJobStatus.running);
      expect(job.isTerminal, isFalse);
      expect(job.serialNumber, 'HWTC12345678');
      expect(job.ponPort, '0/1/1');
      expect(job.ontId, isNull);
      expect(job.lineProfile, 'FTTH-100M');
      expect(job.serviceProfile, 'IPTV-DATA');
      expect(job.vlan, 100);
      expect(job.userVlan, 101);
      expect(job.gemport, 1);
      expect(job.errorMessage, isNull);
      expect(job.startedAt, '2026-11-23T10:05:00Z');
      expect(job.finishedAt, isNull);
    });

    test('parses a succeeded job with an ont_id', () {
      final json = <String, Object?>{
        'id': 'job_uuid',
        'status': 'succeeded',
        'serial_number': 'HWTC12345678',
        'pon_port': '0/1/1',
        'ont_id': '5',
        'line_profile': 'FTTH-100M',
        'service_profile': 'IPTV-DATA',
        'vlan': 100,
        'user_vlan': 101,
        'gemport': 1,
        'error_message': null,
        'started_at': '2026-11-23T10:05:00Z',
        'finished_at': '2026-11-23T10:05:42Z',
      };

      final job = AuthorizationJob.fromJson(json);

      expect(job.parsedStatus, AuthorizationJobStatus.succeeded);
      expect(job.isTerminal, isTrue);
      expect(job.ontId, '5');
      expect(job.finishedAt, '2026-11-23T10:05:42Z');
    });

    test('parses a failed job with its error message', () {
      final json = <String, Object?>{
        'id': 'job_uuid',
        'status': 'failed',
        'serial_number': 'HWTC12345678',
        'pon_port': '0/1/1',
        'ont_id': null,
        'line_profile': 'FTTH-100M',
        'service_profile': 'IPTV-DATA',
        'vlan': 100,
        'user_vlan': 101,
        'gemport': 1,
        'error_message': 'OLT rejected the serial number',
        'started_at': '2026-11-23T10:05:00Z',
        'finished_at': '2026-11-23T10:06:10Z',
      };

      final job = AuthorizationJob.fromJson(json);

      expect(job.parsedStatus, AuthorizationJobStatus.failed);
      expect(job.isTerminal, isTrue);
      expect(job.errorMessage, 'OLT rejected the serial number');
    });

    test('parses a pending job and an unknown status defensively', () {
      final pending = AuthorizationJob.fromJson(<String, Object?>{
        'id': 'job_uuid',
        'status': 'pending',
      });

      expect(pending.parsedStatus, AuthorizationJobStatus.pending);
      expect(pending.isTerminal, isFalse);
      expect(pending.serialNumber, isNull);

      final unknown = AuthorizationJob.fromJson(<String, Object?>{
        'id': 'job_uuid',
        'status': 'queuing',
      });

      expect(unknown.parsedStatus, AuthorizationJobStatus.unknown);
      expect(unknown.isTerminal, isFalse);
    });
  });

  group('AuthorizationJobResponse.fromJson', () {
    test('parses the data envelope', () {
      final json = <String, Object?>{
        'data': {
          'id': 'job_uuid',
          'status': 'running',
          'serial_number': 'HWTC12345678',
        },
      };

      final response = AuthorizationJobResponse.fromJson(json);

      expect(response.data?.id, 'job_uuid');
      expect(response.data?.parsedStatus, AuthorizationJobStatus.running);
    });
  });
}
