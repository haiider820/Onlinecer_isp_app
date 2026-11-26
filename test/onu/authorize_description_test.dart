import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/features/onu/presentation/authorize_onu_screen.dart';
import 'package:isp_onlinecer/models/olt_profiles.dart';

/// D19 (guide §15–§16): the authorize description is capped at 64 chars,
/// and the line/service/VLAN fields are dropdowns fed by the §15 profiles
/// response — with the current (preset) value kept as an extra item when
/// the profiles list does not contain it, so a pre-filled value can never
/// crash the dropdown.
void main() {
  group('validateAuthorizeDescription', () {
    test('missing description is an error', () {
      expect(validateAuthorizeDescription(null), 'Description is required.');
      expect(validateAuthorizeDescription(''), 'Description is required.');
      expect(validateAuthorizeDescription('   '), 'Description is required.');
    });

    test('64 characters pass, 65 fail', () {
      expect(validateAuthorizeDescription('a' * 64), isNull);
      expect(
        validateAuthorizeDescription('a' * 65),
        'Description must be 64 characters or fewer.',
      );
    });

    test('a long pre-filled customer name is flagged, not silently sent', () {
      expect(
        validateAuthorizeDescription(
          'Muhammad Ahmed Raza Khan — House 12, Street 5, Gulberg III, Lahore',
        ),
        'Description must be 64 characters or fewer.',
      );
    });
  });

  group('profileDropdownItems', () {
    const options = [
      OltProfileOption(value: 'Ahmed-Nagar-to-Swedish', label: '13 - Ahmed-Nagar-to-Swedish', huaweiProfileId: 13),
      OltProfileOption(value: 'HSI-2', label: '14 - HSI-2', huaweiProfileId: 14),
    ];

    test('options map value → payload, label → display', () {
      final items = profileDropdownItems(options, null);
      expect(items, hasLength(2));
      expect(items[0].value, 'Ahmed-Nagar-to-Swedish');
      expect((items[0].child as Text).data, '13 - Ahmed-Nagar-to-Swedish');
    });

    test('current value already in the list adds no duplicate', () {
      final items = profileDropdownItems(options, 'HSI-2');
      expect(items, hasLength(2));
      expect(items.map((i) => i.value), contains('HSI-2'));
    });

    test('current value missing from the list is appended as an extra item', () {
      final items = profileDropdownItems(options, 'Preset-Only-Profile');
      expect(items, hasLength(3));
      expect(items.last.value, 'Preset-Only-Profile');
    });

    test('empty current value adds nothing', () {
      expect(profileDropdownItems(options, ''), hasLength(2));
      expect(profileDropdownItems(options, null), hasLength(2));
    });
  });

  group('vlanDropdownItems', () {
    const options = [
      OltVlanOption(value: 346, label: 'VLAN 346', vlanId: 346, name: 'VLAN 346'),
      OltVlanOption(value: 347, label: 'VLAN 347', vlanId: 347, name: 'VLAN 347'),
    ];

    test('options map int value → payload, label → display', () {
      final items = vlanDropdownItems(options, null);
      expect(items, hasLength(2));
      expect(items[0].value, 346);
      expect((items[0].child as Text).data, 'VLAN 346');
    });

    test('current value missing from the list is appended', () {
      final items = vlanDropdownItems(options, 100);
      expect(items, hasLength(3));
      expect(items.last.value, 100);
      expect((items.last.child as Text).data, 'VLAN 100');
    });

    test('current value already in the list adds no duplicate', () {
      expect(vlanDropdownItems(options, 346), hasLength(2));
    });
  });
}
