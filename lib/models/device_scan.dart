/// Device Scanning models (`/device-scan/…` on the main host). Hand-rolled
/// lenient parsing (splicing.dart conventions): every optional block stays
/// nullable so one unexpected shape never throws a whole screen away.
///
/// Rules honored from the workflow doc:
/// - scanned values are stored as-given (trimmed only) — no case conversion,
///   no MAC reformatting; lookups are case-insensitive server-side;
/// - `status` is never sent — the server recomputes it on every save;
/// - save bodies carry ONLY changed fields; `""` is never sent (the server
///   would silently ignore it, so omitting is identical and explicit).
class ScannerAccount {
  const ScannerAccount({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.isActive = true,
    this.organizationId,
    this.companyId,
    this.branchId,
    this.subBranchId,
    this.warehouseId,
  });

  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final bool isActive;
  final String? organizationId;
  final String? companyId;
  final String? branchId;
  final String? subBranchId;
  final String? warehouseId;

  factory ScannerAccount.fromJson(Map<String, dynamic> json) =>
      ScannerAccount(
        id: _string(json['id']),
        name: _string(json['name']),
        email: _string(json['email']),
        phone: _string(json['phone']),
        isActive: json['is_active'] != false,
        organizationId: _string(json['organization_id']),
        companyId: _string(json['company_id']),
        branchId: _string(json['branch_id']),
        subBranchId: _string(json['sub_branch_id']),
        warehouseId: _string(json['warehouse_id']),
      );

  static ScannerAccount? fromJsonOrNull(Map<String, dynamic>? json) =>
      json == null ? null : ScannerAccount.fromJson(json);
}

class ScannerWarehouse {
  const ScannerWarehouse({this.id, this.name, this.location});

  final String? id;
  final String? name;
  final String? location;

  factory ScannerWarehouse.fromJson(Map<String, dynamic> json) =>
      ScannerWarehouse(
        id: _string(json['id']),
        name: _string(json['name']),
        location: _string(json['location']),
      );
}

/// `POST /device-scan/login` (and the unified `/login` for scanner accounts).
/// [isScanner] is the branch the app logs in on — anything else keeps the
/// existing employee flow untouched.
class ScannerLogin {
  const ScannerLogin({
    this.message,
    this.accountType,
    this.token,
    this.expiresAt,
    this.account,
    this.warehouses = const [],
  });

  final String? message;
  final String? accountType;
  final String? token;
  final String? expiresAt;
  final ScannerAccount? account;
  final List<ScannerWarehouse> warehouses;

  bool get isScanner => accountType == 'scanner';

  factory ScannerLogin.fromJson(Map<String, dynamic> json) => ScannerLogin(
        message: _string(json['message']),
        accountType: _string(json['account_type']),
        token: _string(json['token']),
        expiresAt: _string(json['expires_at']),
        account: ScannerAccount.fromJsonOrNull(_map(json['account'])),
        warehouses: (json['warehouses'] as List? ?? const [])
            .whereType<Map>()
            .map((e) =>
                ScannerWarehouse.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false),
      );
}

/// Serialized inventory item a device can be registered against (`GET /items`).
/// The picker is populated ONLY from this call — ids are never invented.
class DeviceItem {
  const DeviceItem({this.id, this.name, this.sku});

  final String? id;
  final String? name;
  final String? sku;

  factory DeviceItem.fromJson(Map<String, dynamic> json) => DeviceItem(
        id: _string(json['id']),
        name: _string(json['name']),
        sku: _string(json['sku']),
      );
}

/// One physical device (list row, lookup hit, register/update result).
class ScannedDevice {
  const ScannedDevice({
    this.id,
    this.deviceCode,
    this.serialNumber,
    this.macAddress,
    this.status,
    this.condition,
    this.notes,
    this.item,
    this.warehouse,
    this.customerName,
    this.assignedAt,
  });

  final String? id;
  final String? deviceCode;
  final String? serialNumber;
  final String? macAddress;
  final String? status;
  final String? condition;
  final String? notes;
  final DeviceItem? item;
  final ScannerWarehouse? warehouse;
  final String? customerName;
  final String? assignedAt;

  bool get isUntracked => status == 'untracked';

  /// True when at least one identifier is on file (rendered, never sent).
  bool get hasIdentifier =>
      (serialNumber?.trim().isNotEmpty == true) ||
      (macAddress?.trim().isNotEmpty == true);

  factory ScannedDevice.fromJson(Map<String, dynamic> json) {
    final customer = _map(json['customer']);
    return ScannedDevice(
      id: _string(json['id']),
      deviceCode: _string(json['device_code']),
      serialNumber: _string(json['serial_number']),
      macAddress: _string(json['mac_address']),
      status: _string(json['status']),
      condition: _string(json['condition']),
      notes: _string(json['notes']),
      item: json['item'] is Map
          ? DeviceItem.fromJson(Map<String, dynamic>.from(json['item'] as Map))
          : null,
      warehouse: json['warehouse'] is Map
          ? ScannerWarehouse.fromJson(
              Map<String, dynamic>.from(json['warehouse'] as Map))
          : null,
      customerName: _string(customer?['name']),
      assignedAt: _string(json['assigned_at']),
    );
  }

  static ScannedDevice? fromJsonOrNull(Map<String, dynamic>? json) =>
      json == null ? null : ScannedDevice.fromJson(json);
}

/// `GET …/lookup?code=` — a MISS is still HTTP 200, so callers branch on
/// [found], never on the status code.
class LookupResult {
  const LookupResult({this.found = false, this.code, this.message, this.device});

  final bool found;
  final String? code;
  final String? message;
  final ScannedDevice? device;

  factory LookupResult.fromJson(Map<String, dynamic> json) => LookupResult(
        found: json['found'] == true,
        code: _string(json['code']),
        message: _string(json['message']),
        device: ScannedDevice.fromJsonOrNull(_map(json['device'])),
      );
}

/// Shared shape of the register (`201`) and update (`200`) responses:
/// `{message, device}`. The message already words the outcome
/// ("…ready for assignment." vs "…Complete its missing details") so the UI
/// shows it verbatim.
class DeviceSaveResult {
  const DeviceSaveResult({this.message, this.device});

  final String? message;
  final ScannedDevice? device;

  factory DeviceSaveResult.fromJson(Map<String, dynamic> json) =>
      DeviceSaveResult(
        message: _string(json['message']),
        device: ScannedDevice.fromJsonOrNull(_map(json['device'])),
      );
}

/// `GET /devices` envelope — capped server-side (no pagination).
class DevicesPage {
  const DevicesPage({this.devices = const [], this.count = 0});

  final List<ScannedDevice> devices;
  final int count;

  factory DevicesPage.fromJson(Map<String, dynamic> json) => DevicesPage(
        devices: (json['devices'] as List? ?? const [])
            .whereType<Map>()
            .map((e) => ScannedDevice.fromJson(Map<String, dynamic>.from(e)))
            .toList(growable: false),
        count: _int(json['count']) ?? 0,
      );
}

/// Save gate (doc §4.7/§6): at least one identifier must be non-empty after
/// trimming, or the server answers `422`.
bool hasIdentifier(String? serial, String? mac) =>
    (serial?.trim().isNotEmpty == true) ||
    (mac?.trim().isNotEmpty == true);

/// Builds the PUT/POST body carrying ONLY fields that changed versus the
/// loaded values. Empty strings are omitted (never sent): the server would
/// silently ignore them, so omitting is identical — and it can never wipe a
/// stored value by accident.
Map<String, Object?> changedDeviceFields({
  String? initialSerial,
  String? initialMac,
  String? initialCode,
  String? initialCondition,
  String? initialNotes,
  String? serial,
  String? mac,
  String? code,
  String? condition,
  String? notes,
}) {
  String? norm(String? v) {
    final t = v?.trim() ?? '';
    return t.isEmpty ? null : t;
  }

  final body = <String, Object?>{};
  final serialNorm = norm(serial);
  if (serialNorm != norm(initialSerial)) {
    if (serialNorm != null) body['serial_number'] = serialNorm;
  }
  final macNorm = norm(mac);
  if (macNorm != null &&
      macNorm != norm(initialMac) &&
      !_sameMacHex(macNorm, norm(initialMac))) {
    body['mac_address'] = macNorm;
  }
  final codeNorm = norm(code);
  if (codeNorm != norm(initialCode)) {
    if (codeNorm != null) body['device_code'] = codeNorm;
  }
  final conditionNorm = norm(condition);
  if (conditionNorm != norm(initialCondition)) {
    if (conditionNorm != null) body['condition'] = conditionNorm;
  }
  final notesNorm = norm(notes);
  if (notesNorm != norm(initialNotes)) {
    if (notesNorm != null) body['notes'] = notesNorm;
  }
  return body;
}

/// True when [a] and [b] are the same MAC written in a different style
/// (`E86E4424D818` vs `E8-6E-44-24-D8-18` vs `E8:6E:44:24:D8:18`).
/// Separator style alone is never a real change — sending it would rewrite
/// the stored value for nothing (and could trip the backend's unique rule
/// against the row itself). Non-MAC values are never "the same".
bool _sameMacHex(String? a, String? b) {
  String? hex(String? v) {
    if (v == null) return null;
    final stripped = v.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();
    return stripped.length == 12 ? stripped : null;
  }

  final ha = hex(a);
  return ha != null && ha == hex(b);
}

Map<String, dynamic>? _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : null;
String? _string(Object? value) => value?.toString();
int? _int(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}
