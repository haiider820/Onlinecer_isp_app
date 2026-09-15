import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/network/api_exceptions.dart';

/// The three installation-stage backend messages are best-guess wording until
/// confirmed against the backend API checklist (see the constants' comment).
/// These tests pin the current strings so a change is a deliberate edit.
void main() {
  group('ApiErrorMapper', () {
    test('maps the three installation-stage messages', () {
      for (final message in [
        ApiErrorMapper.installationAlreadyCompletedMessage,
        ApiErrorMapper.invalidInstallationFatNodeMessage,
        ApiErrorMapper.invalidTotalWireUsedMessage,
      ]) {
        final mapped = ApiErrorMapper.fromMessage(message);
        expect(mapped.message, message);
        expect(mapped.statusCode, isNull);
      }
    });

    test('falls back to the raw server message for unknown text', () {
      const unknownText = 'Some unexpected backend message.';
      final mapped = ApiErrorMapper.fromMessage(unknownText, statusCode: 422);
      expect(mapped.message, unknownText);
      expect(mapped.statusCode, 422);
    });

    test('treats empty server messages as an unknown/generic response', () {
      final mapped = ApiErrorMapper.surfacing(
        serverMessage: null,
        statusCode: 500,
        isNetworkError: false,
      );
      expect(mapped.message, 'Something went wrong. Please try again.');
      expect(mapped.statusCode, 500);
    });

    test('surfaces a network exception when the request never reached the server',
        () {
      final mapped = ApiErrorMapper.surfacing(
        serverMessage: null,
        statusCode: null,
        isNetworkError: true,
      );
      expect(mapped, isA<NetworkException>());
    });
  });
}