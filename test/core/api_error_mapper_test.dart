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

  group('device-validation 422 classification', () {
    test('keeps the real message for a duplicate MAC on the scanner portal',
        () {
      // The scanner portal's duplicate 422 names "mac" but says nothing
      // about a mismatch — masking it as DeviceMismatchException hid the
      // cause AND broke Add Details' inline duplicate handling.
      final mapped = ApiErrorMapper.surfacing(
        serverMessage: 'The mac address has already been taken.',
        statusCode: 422,
        isNetworkError: false,
      );
      expect(mapped, isNot(isA<DeviceMismatchException>()));
      expect(mapped.message, 'The mac address has already been taken.');
      expect(mapped.statusCode, 422);
    });

    test('keeps the real message for a MAC format-validation 422', () {
      final mapped = ApiErrorMapper.surfacing(
        serverMessage: 'The mac address must be a valid MAC address.',
        statusCode: 422,
        isNetworkError: false,
      );
      expect(mapped, isNot(isA<DeviceMismatchException>()));
      expect(mapped.message, 'The mac address must be a valid MAC address.');
    });

    test('classifies free text only when it states a mismatch', () {
      final mapped = ApiErrorMapper.surfacing(
        serverMessage:
            'The scanned device does not match the assigned device.',
        statusCode: 422,
        isNetworkError: false,
      );
      expect(mapped, isA<DeviceMismatchException>());
      expect(mapped.statusCode, 422);
    });

    test('maps errors keyed by the installed-device fields to the mismatch',
        () {
      final mapped = ApiErrorMapper.surfacing(
        serverMessage: 'The given data was invalid.',
        statusCode: 422,
        isNetworkError: false,
        errorFields: const {'installed_device_mac': ['mismatch']},
      );
      expect(mapped, isA<DeviceMismatchException>());
    });

    test('unavailability wording wins over mismatch wording', () {
      final mapped = ApiErrorMapper.surfacing(
        serverMessage:
            'The scanned device is already assigned to another customer.',
        statusCode: 422,
        isNetworkError: false,
      );
      expect(mapped, isA<DeviceNotAvailableException>());
    });
  });
}