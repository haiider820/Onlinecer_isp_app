import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isp_onlinecer/core/storage/secure_storage.dart';
import 'package:isp_onlinecer/features/auth/presentation/providers.dart';
import 'package:isp_onlinecer/features/installation/data/complete_installation_network.dart';
import 'package:isp_onlinecer/features/installation/data/complete_installation_repository.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_network.dart';
import 'package:isp_onlinecer/features/installation/data/inventory_repository.dart';
import 'package:isp_onlinecer/features/installation/presentation/complete_installation_screen.dart';
import 'package:isp_onlinecer/features/installation/presentation/installation_providers.dart';
import 'package:isp_onlinecer/features/installation/presentation/installation_request_detail_screen.dart';
import 'package:isp_onlinecer/shared/widgets/location_map.dart';

import '../helpers/fake_tile_provider.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_network.dart';
import 'package:isp_onlinecer/features/survey/data/connection_request_repository.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_network.dart';
import 'package:isp_onlinecer/features/survey/data/dashboard_repository.dart';
import 'package:isp_onlinecer/features/survey/data/route_network.dart';
import 'package:isp_onlinecer/features/survey/data/route_repository.dart';
import 'package:isp_onlinecer/features/survey/presentation/connection_request_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/dashboard_providers.dart';
import 'package:isp_onlinecer/features/survey/presentation/route_providers.dart';
import 'package:isp_onlinecer/main.dart';

/// In-memory [FlutterSecureStorage] so widget tests don't hit the platform
/// channel. Only the keys [SecureStorage] uses are needed.
class _InMemoryFlutterSecureStorage extends FlutterSecureStorage {
  final Map<String, String> store = {};

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      store.remove(key);

  @override
  Future<void> deleteAll({
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      store.clear();

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async =>
      store.containsKey(key);
}

// ─── Fixtures ───────────────────────────────────────────────────────────────

const _requestId = 'req_ist1';
const _requestNumber = 'CRQ-20260911-IN21';

const _requestMap = {
  'id': _requestId,
  'request_number': _requestNumber,
  'status': 'installation_assigned',
  'customer_name': 'Rahim Uddin',
  'customer_type': 'Residential',
  'customer_phone': '+8801712345678',
  'customer_area': 'Dhanmondi',
  'customer_address': 'House 12, Road 5, Dhanmondi',
};

const _dashboardMap = {
  'employee': {
    'id': 'emp_2',
    'name': 'Tanvir Installer',
    'team': {'id': 'team_2', 'name': 'Installation Team', 'functional_team_type': 'installation'},
  },
  'stats': {
    'connection_requests': {'pending': 4, 'completed': 1, 'total': 5},
  },
  'recent_connection_requests': [_requestMap],
};

const _pageMap = {
  'data': [_requestMap],
  'meta': {'current_page': 1, 'per_page': 15, 'total': 1, 'last_page': 1},
};

const _detailMap = {
  'data': {
    ..._requestMap,
    'requested_plan': {'id': 'plan_5', 'name': 'Fiber 40 Mbps', 'price_minor': 200000},
    'current_team': {
      'id': 'team_2',
      'name': 'Installation Team',
      'functional_team_type': 'installation',
    },
  },
  'allowed_action': 'complete_installation',
};

const _fatNodesMap = {
  'data': [
    {
      'id': 'node_1',
      'name': 'FAT-A Dhanmondi',
      'node_type': 'dp',
      'latitude': 23.7444,
      'longitude': 90.3788,
    },
    {
      'id': 'node_2',
      'name': 'FAT-B Bashundhara',
      'node_type': 'dp',
      'latitude': 23.8101,
      'longitude': 90.4049,
    },
  ],
};

const _inventoryMap = {
  'data': [
    {'id': 'item_1', 'name': 'Faceplate', 'unit': 'box'},
    {'id': 'item_2', 'name': 'Drop cable', 'unit': 'm'},
  ],
};

const _submitResultMap = {
  'message': 'Installation marked as completed.',
  'data': {
    'id': _requestId,
    'request_number': _requestNumber,
    'status': 'splicing_assigned',
    'current_team': {
      'id': 'team_5',
      'name': 'Splicing Team',
      'functional_team_type': 'splicing',
    },
    'timestamps': {'installed_at': '2026-09-12T10:00:00.000000Z'},
  },
};

// ─── Fakes ──────────────────────────────────────────────────────────────────

class _FakeDashboardNetwork implements DashboardNetwork {
  @override
  Future<Map<String, dynamic>> fetchDashboard() async => _dashboardMap;
}

class _FakeConnectionRequestNetwork implements ConnectionRequestNetwork {
  @override
  Future<Map<String, dynamic>> fetchPage({required int page, String? status}) async => _pageMap;

  @override
  Future<Map<String, dynamic>> fetchDetail(String id) async => _detailMap;
}

class _FakeRouteNetwork implements RouteNetwork {
  @override
  Future<Map<String, dynamic>> fetchFatNodes(String connectionRequestId) async => _fatNodesMap;

  @override
  Future<Map<String, dynamic>> calculateRoute(
    String connectionRequestId, {
    required double userLatitude,
    required double userLongitude,
    required double dpLatitude,
    required double dpLongitude,
  }) async =>
      {'distance_meters': 100.0};
}

class _FakeCompleteInstallationNetwork implements CompleteInstallationNetwork {
  String? lastId;
  String? lastOwnership;
  String? lastFatNodeId;
  double? lastDpLatitude;
  double? lastDpLongitude;
  num? lastWire;
  String? lastNotes;
  List<InventoryLine>? lastInventoryLines;
  List<InstallationPhoto>? lastPhotos;
  String? lastVoiceNotePath;
  String? lastVoiceNoteMimeType;

  int jsonCalls = 0;
  int multipartCalls = 0;

  @override
  Future<Map<String, dynamic>> completeInstallationJson(
    String id, {
    required String oltDeviceOwnership,
    required String connectionFatNodeId,
    required double dpLatitude,
    required double dpLongitude,
    num? totalWireUsed,
    String? notes,
    List<InventoryLine>? inventoryLines,
  }) async {
    jsonCalls++;
    lastId = id;
    lastOwnership = oltDeviceOwnership;
    lastFatNodeId = connectionFatNodeId;
    lastDpLatitude = dpLatitude;
    lastDpLongitude = dpLongitude;
    lastWire = totalWireUsed;
    lastNotes = notes;
    lastInventoryLines = inventoryLines;
    return _submitResultMap;
  }

  @override
  Future<Map<String, dynamic>> completeInstallationMultipart(
    String id, {
    required String oltDeviceOwnership,
    required String connectionFatNodeId,
    required double dpLatitude,
    required double dpLongitude,
    num? totalWireUsed,
    String? notes,
    List<InventoryLine>? inventoryLines,
    List<InstallationPhoto>? photos,
    String? voiceNotePath,
    String? voiceNoteMimeType,
  }) async {
    multipartCalls++;
    lastId = id;
    lastOwnership = oltDeviceOwnership;
    lastFatNodeId = connectionFatNodeId;
    lastDpLatitude = dpLatitude;
    lastDpLongitude = dpLongitude;
    lastWire = totalWireUsed;
    lastNotes = notes;
    lastInventoryLines = inventoryLines;
    lastPhotos = photos;
    lastVoiceNotePath = voiceNotePath;
    lastVoiceNoteMimeType = voiceNoteMimeType;
    return _submitResultMap;
  }
}

class _FakeInventoryNetwork implements InventoryNetwork {
  @override
  Future<Map<String, dynamic>> fetchInventory() async => _inventoryMap;
}

// ─── Helpers ────────────────────────────────────────────────────────────────

Future<SecureStorage> _sessionStorage() async {
  final storage = SecureStorage(_InMemoryFlutterSecureStorage());
  await storage.saveSession(
    token: 'test-token',
    tokenType: 'Bearer',
    expiresAt: null,
    employeeId: 'emp_2',
    employeeName: 'Tanvir Installer',
    employeeEmail: 'tanvir@example.com',
    functionalTeamType: 'installation',
    teamName: 'Installation Team',
  );
  return storage;
}

Widget _buildApp(
  SecureStorage storage,
  _FakeCompleteInstallationNetwork completeNetwork,
) {
  return ProviderScope(
    overrides: [
      secureStorageProvider.overrideWithValue(storage),
      dashboardRepositoryProvider.overrideWithValue(
        DashboardRepository(network: _FakeDashboardNetwork()),
      ),
      connectionRequestRepositoryProvider.overrideWithValue(
        ConnectionRequestRepository(network: _FakeConnectionRequestNetwork()),
      ),
      routeRepositoryProvider.overrideWithValue(
        RouteRepository(network: _FakeRouteNetwork()),
      ),
      inventoryRepositoryProvider.overrideWithValue(
        InventoryRepository(network: _FakeInventoryNetwork()),
      ),
      completeInstallationRepositoryProvider.overrideWithValue(
        CompleteInstallationRepository(network: completeNetwork),
      ),
      mapTileProviderProvider.overrideWithValue(FakeTileProvider()),
    ],
    child: IspOnlinecerApp(storage: storage),
  );
}

/// The completion form's submit button. It's the only 'Complete Installation'
/// label in the merged screen (the standalone-form AppBar is gone), scoped to
/// the embedded form and matched by subtype because FilledButton.icon lives in
/// a private subtype.
Finder _submitButton() {
  return find.ancestor(
    of: find.descendant(
      of: find.byType(CompleteInstallationForm),
      matching: find.text('Complete Installation'),
    ),
    matching: find.bySubtype<FilledButton>(),
  );
}

/// The merged detail screen's own scrollable — the first Scrollable under the
/// screen (its ListView). Scoping to the screen keeps nested TextField
/// scrollables and anything on covered routes from confusing
/// `scrollUntilVisible`, which requires the finder to resolve to one element.
Finder _formScrollable() {
  return find
      .descendant(
        of: find.byType(InstallationRequestDetailScreen),
        matching: find.byType(Scrollable),
      )
      .first;
}

/// Scrolls [finder] into the viewport and taps it.
///
/// `scrollUntilVisible` alone is not enough once the form outgrows the screen:
/// the ListView builds its children lazily, so `scrollUntilVisible` stops the
/// moment the target's ELEMENT exists (inside the viewport's cache extent)
/// while the widget is still off-screen. Center it on-screen before tapping —
/// a centered target can never be partially clipped at the viewport edge
/// (which made an edge-aligned tap land outside the 600×... test viewport).
Future<void> _revealAndTap(WidgetTester tester, Finder finder,
    {double delta = 300}) async {
  // `scrollUntilVisible` stops as soon as the target's ELEMENT exists inside
  // the lazy list's cache extent — which may still be off-screen (that used to
  // make the tap land past the 600px viewport's bottom edge, so _submit never
  // ran). A centered Scrollable.ensureVisible is no good here: while it plays
  // the sliver re-lays out and the target offset goes stale. `tester.ensureVisible`
  // is the robust primitive — a zero-duration jump, so it cannot deadlock in
  // FakeAsync (flutter_map's tile fades keep scheduling frames; pumpAndSettle
  // and animated scrolls never return while the map card is on screen).
  await tester.scrollUntilVisible(finder, delta, scrollable: _formScrollable());
  await tester.ensureVisible(finder);
  // Drain the jump's rebuild + any lazy-list relayout (and the Overlay's
  // transition absorb when a menu/dropdown just closed) BEFORE reading the
  // tap point, so the target's RenderBox has settled where it really paints.
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  await tester.tap(finder);
}

/// Taps the completion form's submit button deterministically.
///
/// The submit button is the LAST widget of the form. `_revealAndTap` can't
/// reliably reach it after a field was typed, because entering text schedules a
/// caret "show on screen" scroll and the lazy list re-lays out around it — the
/// two race the reveal, so the button's painted position drifts past the 600px
/// viewport on some runs and the tap silently misses. Pinning the list to its
/// maximum scroll extent parks the button at the bottom of the viewport: a
/// fixed position no caret/ballistic animation can steal.
Future<void> _tapSubmit(WidgetTester tester) async {
  // Let any in-flight caret scroll from the last entered field finish first.
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  final scrollable = tester.state<ScrollableState>(_formScrollable());
  scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
  await tester.pump(const Duration(milliseconds: 100));
  await tester.tap(_submitButton());
}

Future<void> _openCompletionForm(WidgetTester tester, SecureStorage storage,
    _FakeCompleteInstallationNetwork network) async {
  // Device-tall viewport: the bottom logout bar pushes the dashboard's recent
  // request card below the 800×600 test default's sliver build window.
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_buildApp(storage, network));
  await tester.pumpAndSettle();

  // Dashboard → detail. The completion form is embedded at the bottom of the
  // merged scroll view — no separate completion-form page anymore.
  await tester.tap(find.text(_requestNumber));
  await tester.pumpAndSettle();
}

/// Selects the 'User' ownership segment and a FAT node from the dropdown.
///
/// Both live inside the merged screen's lazy ListView below the customer,
/// request, pricing and map cards — scroll them into view before tapping.
Future<void> _fillRequiredFields(WidgetTester tester) async {
  await _revealAndTap(tester, find.text('User'));
  await _revealAndTap(tester, find.text('Select the FAT node used'));
  // `_revealAndTap` taps the trigger without pumping — let the menu overlay
  // render (bounded pumps: the FAT row sits right over the live map card,
  // whose tile fades never let pumpAndSettle return) before selecting its item.
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.tap(find.text('FAT-A Dhanmondi').last);
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

// ─── Tests ──────────────────────────────────────────────────────────────────

void main() {
  testWidgets('completion form maps validation errors for missing required fields',
      (tester) async {
    final storage = await _sessionStorage();
    await _openCompletionForm(tester, storage, _FakeCompleteInstallationNetwork());

    // Submit with nothing filled: ownership + FAT node errors surface inline.
    // pumpAndSettle lets the form's scroll-back animation finish so the
    // top-of-form error fields are built (the ListView is lazy).
    await _revealAndTap(tester, _submitButton());
    await tester.pumpAndSettle();

    expect(find.text('Select who the OLT device belongs to'), findsOneWidget);
    expect(find.text('Select a FAT node'), findsOneWidget);

    // Still on the form — no navigation happened.
    expect(find.text('Installation Requests'), findsNothing);
  });

  testWidgets('submitting with only required fields completes the installation',
      (tester) async {
    final storage = await _sessionStorage();
    final network = _FakeCompleteInstallationNetwork();
    await _openCompletionForm(tester, storage, network);

    await _fillRequiredFields(tester);
    await _tapSubmit(tester);
    // Bounded pumps, not pumpAndSettle: the submit button sits below the live
    // map card, whose tile fades keep scheduling frames forever — but the
    // successful submit navigates away, so drain the transition with frames.
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Payload carries only the required fields.
    expect(network.lastId, _requestId);
    expect(network.lastOwnership, 'user');
    expect(network.lastFatNodeId, 'node_1');
    // DP coordinates ride along from the selected FAT node (FAT-A Dhanmondi).
    expect(network.lastDpLatitude, 23.7444);
    expect(network.lastDpLongitude, 90.3788);
    expect(network.lastWire, isNull);
    expect(network.lastNotes, isNull);
    expect(network.lastInventoryLines, isNull);
    // No attachments → the repository takes the JSON branch, not multipart.
    expect(network.jsonCalls, 1);
    expect(network.multipartCalls, 0);

    // Success returns to the installation queue with the new status confirmed.
    expect(find.text('Installation submitted → splicing assigned'), findsOneWidget);
    expect(find.text('Installation Requests'), findsOneWidget);
    expect(find.text(_requestNumber), findsOneWidget);
  });

  testWidgets('optional wire usage and installation notes are sent when entered',
      (tester) async {
    final storage = await _sessionStorage();
    final network = _FakeCompleteInstallationNetwork();
    await _openCompletionForm(tester, storage, network);

    await _fillRequiredFields(tester);

    // Wire field comes first, notes second — both below the ownership/FAT
    // controls in the form, so reveal each label before typing.
    await tester.scrollUntilVisible(
      find.text('Total wire used (m)'),
      200,
      scrollable: _formScrollable(),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Total wire used (m)'),
      '35.5',
    );
    await tester.scrollUntilVisible(
      find.text('Installation notes'),
      200,
      scrollable: _formScrollable(),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Installation notes'),
      'Drop cable pulled to the DP.',
    );
    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    expect(network.lastWire, 35.5);
    expect(network.lastNotes, 'Drop cable pulled to the DP.');

    expect(find.text('Installation Requests'), findsOneWidget);
  });

  testWidgets('inventory rows are sent with item and quantity; untouched rows are stripped',
      (tester) async {
    final storage = await _sessionStorage();
    final network = _FakeCompleteInstallationNetwork();
    await _openCompletionForm(tester, storage, network);

    await _fillRequiredFields(tester);

    // Two rows: the first gets an item + quantity, the second stays untouched.
    await tester.scrollUntilVisible(
      find.text('Add item'),
      200,
      scrollable: _formScrollable(),
    );
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add item'));
    await tester.pumpAndSettle();

    // Row 1: pick 'Faceplate' (first Item dropdown), then enter its quantity.
    await tester.scrollUntilVisible(
      find.text('Item').first,
      200,
      scrollable: _formScrollable(),
    );
    await tester.tap(find.text('Item').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Faceplate').last);
    await tester.pumpAndSettle();
    // TextFormFields in tree order: wire (0), notes (1), then row quantities.
    // Row 1's quantity field (first 'Quantity' label in tree order), not a
    // positional index: after scrolling to the inventory section the wire and
    // notes fields higher up fall outside the lazy ListView's cache extent and
    // are no longer built.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Quantity').first,
      '12',
    );

    await _tapSubmit(tester);
    await tester.pumpAndSettle();

    // Only the filled row survives; the untouched second row is stripped.
    expect(network.lastInventoryLines, hasLength(1));
    expect(network.lastInventoryLines?[0].itemId, 'item_1');
    expect(network.lastInventoryLines?[0].quantity, 12);

    expect(find.text('Installation Requests'), findsOneWidget);
  });

  testWidgets('negative or non-numeric wire usage is rejected by validation',
      (tester) async {
    final storage = await _sessionStorage();
    final network = _FakeCompleteInstallationNetwork();
    await _openCompletionForm(tester, storage, network);

    await _fillRequiredFields(tester);
    await tester.scrollUntilVisible(
      find.text('Total wire used (m)'),
      200,
      scrollable: _formScrollable(),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Total wire used (m)'),
      '-5',
    );
    await _tapSubmit(tester);
    // `_tapSubmit` parks the view at the bottom of the form, but the inline
    // validation error renders under the wire field at the top — scroll back up
    // to bring the error into the lazy list's built range before asserting.
    await tester.scrollUntilVisible(
      find.text('Enter a valid amount (0 or more)'),
      -200,
      scrollable: _formScrollable(),
    );
    expect(find.text('Enter a valid amount (0 or more)'), findsOneWidget);

    // Nothing was submitted.
    expect(network.lastId, isNull);
    expect(find.text('Installation Requests'), findsNothing);
  });

  testWidgets(
      'photo card renders in the completion form and tolerates an empty pick',
      (tester) async {
    final storage = await _sessionStorage();
    await _openCompletionForm(tester, storage, _FakeCompleteInstallationNetwork());

    // The photo card's empty state renders once scrolled into view.
    await tester.scrollUntilVisible(
      find.text('Add photo'),
      300,
      scrollable: _formScrollable(),
    );
    expect(find.text('No photos attached.'), findsOneWidget);

    // With no platform picker the channel returns an empty list (a user
    // cancel) → the pick is a harmless no-op: card stays empty, no crash,
    // nothing staged for submission.
    await _revealAndTap(tester, find.text('Add photo'));
    await tester.pump();
    expect(find.text('No photos attached.'), findsOneWidget);

    // Voice section renders its permission-not-granted state.
    await tester.scrollUntilVisible(
      find.textContaining('Microphone permission'),
      200,
      scrollable: _formScrollable(),
    );
    expect(
      find.text('Microphone permission needed to record a voice note.'),
      findsOneWidget,
    );
  });
}