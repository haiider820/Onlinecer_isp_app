import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/shared/validation/mac_address.dart';

/// D19 (guide §9): the installed device MAC is a REQUIRED field on
/// complete-installation. The form accepts colon/dash/dot-separated and
/// bare forms and normalises to canonical `AA:BB:CC:DD:EE:FF` before
/// sending; a missing or invalid MAC blocks the submit client-side.
void main() {
  group('normalizeMacAddress', () {
    test('canonical colon form passes through unchanged', () {
      expect(normalizeMacAddress('AA:BB:CC:DD:EE:FF'), 'AA:BB:CC:DD:EE:FF');
    });

    test('lowercase is uppercased', () {
      expect(normalizeMacAddress('aa:bb:cc:dd:ee:ff'), 'AA:BB:CC:DD:EE:FF');
    });

    test('dash-separated form is normalised', () {
      expect(normalizeMacAddress('AA-BB-CC-DD-EE-FF'), 'AA:BB:CC:DD:EE:FF');
    });

    test('bare 12-hex form is normalised', () {
      expect(normalizeMacAddress('aabbccddeeff'), 'AA:BB:CC:DD:EE:FF');
    });

    test('dot-separated (Cisco) form is normalised', () {
      expect(normalizeMacAddress('aabb.ccdd.eeff'), 'AA:BB:CC:DD:EE:FF');
    });

    test('MAC: prefix is stripped', () {
      expect(normalizeMacAddress('MAC:AA:BB:CC:DD:EE:FF'), 'AA:BB:CC:DD:EE:FF');
    });

    test('surrounding whitespace is trimmed', () {
      expect(normalizeMacAddress('  AA:BB:CC:DD:EE:FF  '), 'AA:BB:CC:DD:EE:FF');
    });

    test('too short / too long / non-hex are rejected', () {
      expect(normalizeMacAddress('AA:BB:CC:DD:EE'), isNull);
      expect(normalizeMacAddress('AA:BB:CC:DD:EE:FF:00'), isNull);
      expect(normalizeMacAddress('GG:BB:CC:DD:EE:FF'), isNull);
      expect(normalizeMacAddress('not-a-mac'), isNull);
      expect(normalizeMacAddress(''), isNull);
    });
  });

  group('isMacAddress', () {
    test('accepts valid forms, rejects the rest', () {
      expect(isMacAddress('AA:BB:CC:DD:EE:FF'), isTrue);
      expect(isMacAddress('aabbccddeeff'), isTrue);
      expect(isMacAddress('AA:BB:CC:DD:EE'), isFalse);
      expect(isMacAddress(''), isFalse);
    });
  });

  group('validateMacAddress (form validator)', () {
    test('missing MAC is an error', () {
      expect(validateMacAddress(null), 'Enter the installed device MAC address.');
      expect(validateMacAddress(''), 'Enter the installed device MAC address.');
      expect(validateMacAddress('   '), 'Enter the installed device MAC address.');
    });

    test('invalid MAC is an error', () {
      expect(
        validateMacAddress('not-a-mac'),
        'Enter a valid MAC address (e.g. AA:BB:CC:DD:EE:FF).',
      );
      expect(
        validateMacAddress('AA:BB:CC:DD:EE'),
        'Enter a valid MAC address (e.g. AA:BB:CC:DD:EE:FF).',
      );
    });

    test('valid MAC in any accepted form passes', () {
      expect(validateMacAddress('AA:BB:CC:DD:EE:FF'), isNull);
      expect(validateMacAddress('aabbccddeeff'), isNull);
      expect(validateMacAddress('AA-BB-CC-DD-EE-FF'), isNull);
    });
  });
}
