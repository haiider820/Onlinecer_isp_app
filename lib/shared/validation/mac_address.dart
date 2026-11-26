/// MAC address validation + normalisation for the installed ONU/ONT device
/// (ISPFINAL guide §9: `installed_device_mac` is a REQUIRED field on
/// complete-installation).
///
/// Accepts colon-, dash- or dot-separated forms, a bare 12-hex string, and
/// an optional `MAC:` prefix — all normalised to canonical uppercase
/// colon-separated form (`AA:BB:CC:DD:EE:FF`). This mirrors the classifier
/// the old device-scan flow used (`normalizeMacAddress`); that file is gone
/// from the tree, so the helper lives here now and the installation form is
/// its only caller.
String? normalizeMacAddress(String input) {
  var cleaned = input.trim().toUpperCase();
  if (cleaned.startsWith('MAC:')) cleaned = cleaned.substring(4);
  final hex = cleaned.replaceAll(RegExp(r'[^0-9A-F]'), '');
  if (!RegExp(r'^[0-9A-F]{12}$').hasMatch(hex)) return null;
  final pairs = <String>[];
  for (var i = 0; i < 12; i += 2) {
    pairs.add(hex.substring(i, i + 2));
  }
  return pairs.join(':');
}

/// True when [input] is a 12-hex-digit MAC address in any accepted form.
bool isMacAddress(String input) => normalizeMacAddress(input) != null;

/// Validator for the required "Device MAC address" field on the
/// complete-installation form. Returns an error message, or `null` when the
/// value is a valid MAC address.
String? validateMacAddress(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Enter the installed device MAC address.';
  }
  if (normalizeMacAddress(value) == null) {
    return 'Enter a valid MAC address (e.g. AA:BB:CC:DD:EE:FF).';
  }
  return null;
}
