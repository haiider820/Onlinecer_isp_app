# ISPFINAL — Mobile Connection + ONU Authorization: Implementation Plan

**App:** Onlinecer ISP (Malik Fiber), `haiider820/Onlinecer_isp_app`
**Branch:** `feature/kit-navy-redesign`, tip `c7fff8a8` (plan written against this tip)
**Status:** IMPLEMENTED 2026-11-23 (Phases 0–G, local tree only, NOT pushed). Haider re-checks screenshots + test report first. Base URL changed 2026-11-24 (see note below). See "Implementation notes" at the end for divergences from this plan.
**Base URL: `https://184-164-137-101.sslip.io/api/mobile`** (see §0). No endpoint, field, or URL in this plan is invented — everything comes from the ISPFINAL guide or from code read at tip `c7fff8a8`.
**NOTE 2026-11-24 — the 2026-11-23 "base URL never changes" rule is SUPERSEDED:** the backend developer moved the server to `https://184-164-137-101.sslip.io/api/mobile` (valid Let's Encrypt certificate, verified live 2026-11-24). The old URL `http://184.164.137.101/api/mobile` is dead — it 301-redirects to https and port 443 on the raw IP serves nothing (empty reply), so login could no longer succeed. SSL verification stays ON; no cert bypass anywhere.

---

## §0 — Ground truth (read from code, not guessed)

### Base URL — exact, as set in code

`lib/core/constants/app_constants.dart:14`:

```dart
static const String _defaultBaseUrl = 'https://184-164-137-101.sslip.io/api/mobile';
```

- Scheme `https`, host `184-164-137-101.sslip.io`, **no port**, path prefix `/api/mobile`.
- `AppConstants.baseUrl` returns this unless `--dart-define=API_BASE_URL=...` is passed (local dev only, `http://127.0.0.1:8000/api/mobile`).
- Dio is built once on this base URL (`lib/core/network/api_client.dart`); every endpoint in `Endpoints` is a relative path (`/login`, `/connection-requests/$id`, …), so `POST /login` in code = `POST https://184-164-137-101.sslip.io/api/mobile/login`, exactly the guide's `POST /api/mobile/login`. (The 2026-11-23 "do not change the base URL" instruction was superseded 2026-11-24 — see the note at the top of this file.)
- Timeouts: connect 15s, receive 30s. Headers: `Accept: application/json`, `Content-Type: application/json`, `Authorization: Bearer <token>` via `AuthInterceptor` (reads `SecureStorage.getToken()` per request).

### Current login vs guide §1

- Endpoint matches: `POST /login` with `{email, password, device_name?}` (`lib/features/auth/data/auth_repository.dart`, `auth_network.dart`). `device_name` is sent when the caller provides it (`DeviceInfo.defaultDeviceName()` exists in code; the login screen's wiring to be confirmed in Phase A).
- Token storage: `flutter_secure_storage` keys `auth.token`, `auth.token_type`, `auth.expires_at`, `employee.id/name/email`, `employee.functional_team_type`, `employee.team_name` (`lib/core/storage/secure_storage.dart`). Readiness gate: login only succeeds after a read-back proves the token + team type persisted (`verifySessionPersistence`).
- **Gap:** `LoginResponse` (`lib/models/auth.dart`) has **no `account_type` field** — the guide's `account_type: "employee"` is dropped on parse. `Employee` parses `organization` + `team` only; **no `branch` / `sub_branch` fields** in the model. `permissions: List<String>` is parsed but nothing in the app gates UI on it (no usage found).
- 401 handling: central — `ApiClient` clears the whole session (`clearSession()` = `deleteAll()`, including the `ui.theme_mode` key) and the router redirects to `/login`. 422s are classified by `ApiErrorMapper` (device-validation wordings for complete-installation). 403/404 have no dedicated handling — they surface the backend's `message` as a generic `ApiException`.

### Per-section status (§1–§14)

| Guide § | Topic | Status | One-line evidence |
|---|---|---|---|
| §1 | Login | **PARTIAL** | Endpoint + fields match; `account_type` ignored, `branch`/`sub_branch` not parsed, `permissions` unused |
| §2 | Load sub-branches | **MISSING** | No endpoint, no model, no UI. Only `subBranchId` field exists, inside the orphaned `lib/models/device_scan.dart` |
| §3 | Create-data | **MISSING** | No `create-data` endpoint. Adjacent pieces exist: `GET /lookups/plans` (`lib/features/lookups/data/plan_lookup_network.dart`) and `GET /lookups/fat-nodes?connection_request_id=` (`lib/features/survey/data/route_network.dart`) — different shapes, not the guide's |
| §4 | Create connection request | **MISSING** | No `POST /connection-requests`, no create screen. Multipart pattern exists and is reusable (`ApiClient.postMultipart`, used by submit-survey / complete-installation / complete-splicing with `FormData` + `MultipartFile`) |
| §5 | Load OLTs | **MISSING** | Only trace: `OltOwnership` constants (`user`/`company` wire values for `olt_device_ownership` on complete-installation) in `app_constants.dart` |
| §6 | Discover waiting ONUs (POST) | **MISSING** | Nothing |
| §7 | Cached waiting ONUs (GET) | **MISSING** | Nothing |
| §8 | Stage completes | **PARTIAL** | complete-survey, complete-installation, complete-splicing have dedicated repos + screens. complete-verification / complete-closing go through shared `lib/features/stage_shared/team_stage_config.dart` (`completionPathFor: Endpoints.completeVerification/completeClosing`) — no dedicated repos; verify in Phase D |
| §9 | Authorize ONU | **MISSING** | `ConnectionRequestAction` enum has only the 5 stage actions; **no `authorize_onu`** value. Detail parses singular `allowed_action` only — **plural `allowed_actions` is NOT parsed** |
| §10 | Poll authorization job | **MISSING** | Nothing (no polling helper exists in the app) |
| §11 | Detail | **PARTIAL** | `GET /connection-requests/{id}` exists; parses `data`, `allowed_action`, `stage_data`. NOT parsed: `allowed_actions` (plural), `installed_device`, `sub_branch` |
| §12 | Centralized vs scoped | **MISSING** | No mode handling anywhere |
| §13 | Status codes | **PARTIAL** | 401 central logout; 422 classified (device issues); 403/404 = generic backend message, no dedicated handling |
| §14 | Security | **PARTIAL** | Token in secure storage, never in code. **Risk to verify in Phase G:** Dio `LogInterceptor` is added in debug builds — confirm the `Authorization` header is not printed in logs |

### Scanner-login state (checked in the tree at tip `c7fff8a8`)

- **The orphaned scanner files STILL EXIST locally** — the PC agent has NOT deleted them: `lib/features/device_scan/presentation/scanner_login_screen.dart`, `add_device_details_screen.dart`, `lib/features/installation/presentation/device_scan_screen.dart`, `lib/shared/widgets/installation_locations_card.dart`, `lib/models/device_scan.dart`. (34 pre-existing analyze errors, unchanged.)
- **The login page has NO scanner entry.** `lib/features/auth/presentation/login_screen.dart` has exactly one CTA (`FilledButton` "Log in"), two `OpsTextField`s, a "remember this handheld" toggle. No `TextButton`, no scanner link.
- **No scanner route exists.** `Routes` (`lib/core/router/app_router.dart`) has `boot`, `login`, `dashboard`, survey/installation/splicing/verification/closing lists + details, tickets, notifications — no `scannerLogin`, no `scannerHome`.
- The old scanner screen is **unrepairable as-is, not just broken**: it imports `core/theme/field_ops_colors.dart` and `scanner_providers.dart` (both deleted — files do not exist), navigates to `Routes.scannerHome` (does not exist), and its docstring says it "posts to the scanner-only endpoint" — **no such endpoint exists in code, and the guide documents no scanner endpoint either** (see Open Questions).
- `device_scan_screen.dart` imports `package:mobile_scanner/mobile_scanner.dart` — **`mobile_scanner` is NOT in `pubspec.yaml`** (deps: dio, riverpod, go_router, flutter_secure_storage, intl, logger, record, path_provider, geolocator, http_parser, image_picker, freezed/json_annotation, flutter_map, latlong2, audioplayers, url_launcher, lottie).
- `lib/models/device_scan.dart` is self-contained and sound (hand-rolled lenient parsing; `ScannerAccount` carries `organization_id/company_id/branch_id/sub_branch_id/warehouse_id`; docstring says models are for "`/device-scan/…` on the main host"). It is imported ONLY by `add_device_details_screen.dart` — i.e. only by another orphan.

### Existing provider pattern (to copy, not reinvent)

- `lib/features/auth/presentation/providers.dart`: `Provider` for storage → `apiClientProvider` → `authNetworkProvider` → `authRepositoryProvider` → `AuthController extends Notifier<AuthState>` (`authControllerProvider`). `lib/features/survey/presentation/connection_request_providers.dart`: same shape — network `Provider`, repository `Provider`, `FutureProvider.family<ConnectionRequestPage, int>` for lists, `FutureProvider.family<ConnectionRequestDetail, String>` for detail. **All new work follows this shape. No new state library.**

---

## §1 — Scanner-login button (login page)

**Placement (Rule 14: one title + one CTA — no second primary button):**
- Below the primary "Log in" `FilledButton`, inside the same frosted/glass card, add a **secondary `TextButton`**: "Scanner login" (with a small `Icons.qr_code_scanner_outlined` icon, theme primary colour, no fill).
- It is a navigation link, not a submit action: it never triggers the employee login, never touches the employee token.
- Order on the card: Work email → Password → Remember toggle → **Log in** (primary) → **Scanner login** (text link, 8 px below the button).

**Route:** new `Routes.scannerLogin = '/scanner-login'`, `GoRoute` → rebuilt `ScannerLoginScreen`. The route is **exempt from the auth redirect** like `/login` (see `app_router.dart` redirect logic — `onLogin` check must also accept the scanner route, otherwise an unauthenticated user is bounced back to employee login).

**How the scanner flow differs (per guide §1 + old screen's docstring):**
- The guide says: *"Use account_type to distinguish the employee mobile application from the separate device-scanner account flow."* So the scanner flow authenticates through the **same** `POST /api/mobile/login` (the guide documents no other login endpoint) and the response's `account_type` decides which session this is. **This is the single biggest open question — see §Risks.**
- **Token separation (mandatory):** the scanner token must NEVER overwrite the employee token. New `SecureStorage` keys: `scanner.token`, `scanner.token_type`, `scanner.expires_at`, `scanner.account_id`, `scanner.account_name` (new methods `saveScannerSession` / `getScannerToken` / `clearScannerSession`, mirroring the employee ones — do not reuse `auth.*` keys).
- **Interceptor:** `AuthInterceptor` currently reads only `auth.token`. It must become session-aware: employee routes send the employee token; scanner routes send the scanner token. Simplest correct rule, to be confirmed against the backend: the scanner flow uses its **own `ApiClient` instance** (same base URL, own interceptor reading `scanner.token`), provided as `scannerApiClientProvider`. The two sessions never mix, and employee 401 handling must not wipe the scanner session (today `clearSession()` = `deleteAll()` — it would wipe `scanner.*` keys too; Phase A must scope the employee logout to `auth.*`/`employee.*` keys only).
- **Restore:** on opening the scanner screen, try silent restore first (old screen's `_tryRestore` behaviour, kept): if a scanner token exists, `GET /me` — success → go to scanner home; 401/network → fall through to the form, never strand the user.
- **Scanner home destination:** `Routes.scannerHome = '/scanner/home'`. What lives there depends on the §Risks decision (device-scan screens need `mobile_scanner` + rewritten providers — see Phase A2). The scanner-login button + screen + token separation ship in Phase A; the scan UI itself is Phase A2, gated on Haider's call.

---

## §2 — Phases (dependency order)

### Phase 0 — Groundwork: endpoints + models (no UI)

**Goal:** every guide endpoint exists in code with typed models, before any screen touches them.
**Endpoints to add** (`lib/core/constants/app_constants.dart`, `Endpoints`):
- `subBranches({String? subBranchId})` → `GET /lookups/sub-branches` (+ `?sub_branch_id=` when given)
- `createData({String? subBranchId})` → `GET /connection-requests/create-data`
- `createConnectionRequest()` → `POST /connection-requests`
- `directOlts({String? subBranchId})` → `GET /lookups/direct-olts`
- `discoverWaitingOnus(String oltId)` → `POST /lookups/direct-olts/{olt}/discover-waiting-onus`
- `waitingOnus(String oltId)` → `GET /lookups/direct-olts/{olt}/waiting-onus`
- `authorizeOnu(String requestId)` → `POST /connection-requests/{request}/authorize-onu`
- `authorizationJob(String requestId, String jobId)` → `GET /connection-requests/{request}/authorization-jobs/{job}`
- `scannerLogin` is NOT a new endpoint — it reuses `Endpoints.login` (see §1 / Risks).

**Models to add** (freezed, following `lib/models/connection_request.dart` + `lib/models/auth.dart`):
- `lib/models/sub_branch.dart` — `SubBranch{id, name, type, organizationId, companyId, branchId, parentId}` + envelope `{mode, selectedSubBranchId, data}`. `mode` is `"centralized"` | scoped (guide: centralized when org has centralized inventory enabled).
- `lib/models/create_data.dart` — `customer_types[{value,label}]`, `plans`, `fat_nodes`, `team_flows` (fields per backend payload; keep every list item lenient/nullable — the guide only sketches the shape).
- `lib/models/direct_olt.dart` — `DirectOlt{id, name, vendor, model, managementIp, connectionStatus, companyId, branchId, subBranchId, authorizationPreset{ready, lineProfile, serviceProfile, vlan, userVlan, gemport}, runningAuthorizationsCount}`.
- `lib/models/waiting_onu.dart` — `WaitingOnu{id, serialNumber, ponPort, detectedOnuType, authorizationStatus, authorizationReason, lastDiscoveredAt}` + discover envelope `{message, source, seenCount, data}`.
- `lib/models/authorization_job.dart` — `AuthorizationJob{id, status (pending|running|succeeded|failed), serialNumber, ponPort, ontId, lineProfile, serviceProfile, vlan, userVlan, gemport, errorMessage, startedAt, finishedAt}`.
- `ConnectionRequestDetail`: add `allowed_actions: List<String>?` (plural, alongside existing singular `allowed_action` — do not remove the singular; old backend payloads still send it).
- `ConnectionRequestAction`: add `authorizeOnu` (`'authorize_onu'` wire value).
- `ConnectionRequest`: add `sub_branch` + `installed_device` as nullable parsed fields (guide §11 lists them; parse leniently).

**State management:** none yet (models + endpoint constants only).
**Verification:** `flutter analyze lib --no-pub` (0 new issues); new model tests in `test/models/` (`sub_branch_test.dart`, `direct_olt_test.dart`, `waiting_onu_test.dart`, `authorization_job_test.dart` — fromJson with the guide's exact example payloads, incl. `authorization_preset.ready: false`).

### Phase A — Login alignment + scanner-login entry

**Goal:** guide §1 fully honoured; scanner button on the login page; two sessions that cannot overwrite each other.
**Endpoints:** `POST /login` (unchanged). **Response handling changes:**
- Parse `account_type` into `LoginResponse` (new field, nullable for old payloads). If `account_type != "employee"`, do NOT save it as an employee session — surface an error telling the user to use Scanner login (exact wording from backend message when present).
- Parse `employee.branch` / `employee.sub_branch` if the backend sends them (guide §1 shows them); store as `employee.branch_name` / `employee.sub_branch_name` keys (new, additive — never rename existing keys).
- Keep `permissions` parsed; no UI gating in this phase.

**Files:**
- Modify: `lib/models/auth.dart` (+ regenerate `auth.freezed.dart` / `auth.g.dart` via `build_runner` on the PC — VM build_runner is fine to run, but generated files must be committed by the same push), `lib/features/auth/data/auth_repository.dart` (account_type branch), `lib/features/auth/presentation/providers.dart` (scanner client provider), `lib/core/storage/secure_storage.dart` (scanner keys + scoped employee logout), `lib/core/network/api_client.dart` (session-aware token selection OR second client instance — pick the second-client option; it is the smaller diff), `lib/core/router/app_router.dart` (new routes + redirect exemption), `lib/features/auth/presentation/login_screen.dart` (TextButton link only).
- Create: `lib/features/device_scan/presentation/scanner_login_screen.dart` (**rebuild from scratch** — the old file is unrecoverable: deleted imports + deleted providers + nonexistent route; rebuild reuses `OpsTextField`, the login visual family, and the `AuthController` submit pattern), `lib/features/device_scan/data/scanner_network.dart` + `scanner_repository.dart` (same network/repository seam as `AuthNetwork`/`AuthRepository`), `lib/features/device_scan/presentation/scanner_providers.dart` (providers in the §0 pattern).

**State management:** `scannerAuthControllerProvider` (`Notifier`, mirrors `AuthController`: `isSubmitting` / `errorMessage`); `scannerSessionProvider` (`FutureProvider`, restore via `GET /me`).
**UI states:** form → submitting (button spinner, fields disabled) → error banner with backend message → success → scanner home. Restore attempt shows a brief loading state, never a dead end.
**Offline:** login requires network (no offline login — matches existing behaviour); error shows "Network error. Check your connection." with retry.
**Verification:** analyze 0 new; `test/auth/login_readiness_gate_test.dart` still passes + new `test/auth/scanner_login_test.dart` (token separation: employee login after scanner login leaves `scanner.token` intact, and vice versa; 401 on employee logout does not wipe scanner keys). Haider checks on phone: employee login works as before; "Scanner login" link opens the scanner form; logging in as scanner does not log the employee out (and vice versa).

### Phase A2 — Device-scan screens: repair-or-delete decision (gated on Haider)

**Goal:** decide the fate of the 4 orphaned files + `mobile_scanner` before the scanner flow can do real work.
**Options (Haider picks one; do not start this phase without his pick):**
1. **Repair:** add `mobile_scanner` (verify a version that resolves on Flutter 3.35 / Dart 3.9 — check `pubspec.yaml` SDK `^3.9.2` first), rewrite `scanner_providers.dart` fresh, re-theme both scan screens onto theme tokens (replace `field_ops_colors.dart` usage), re-wire `device_scan_screen.dart` to the scanner session. Cost: a full rewrite of 3 screens.
2. **Delete:** delete the 4 orphaned files + `lib/models/device_scan.dart` (imported only by an orphan) and ship scanner login WITHOUT scan UI — scanner home becomes a simple account/session screen until a scan feature is specced. The PC-agent delete prompt Haider already has covers exactly this file list.
3. **Defer:** keep the files (still 34 analyze errors), scanner login routes to a "coming soon" scanner home. Not recommended — the errors stay.

**Note for the decision:** the guide does NOT document any `/device-scan/…` endpoints — the old `device_scan.dart` docstring references them, but their contract is unknown. If Haider wants real scanning, the backend's device-scan endpoints must be documented first (same shape as this guide), otherwise option 2 is the honest scope.

### Phase B — Sub-branch selector (centralized vs scoped)

**Goal:** guide §2 + §12.
**Endpoints:** `GET /lookups/sub-branches` (+ `?sub_branch_id=`).
**Files:**
- Create: `lib/features/lookups/data/sub_branch_network.dart` + `sub_branch_repository.dart`, `lib/features/lookups/presentation/sub_branch_providers.dart`.
- Modify: `lib/features/lookups/data/plan_lookup_network.dart` is untouched; callers pass the selected id.
- **Scope holder:** new `selectedSubBranchProvider` — a Riverpod `StateProvider<String?>` (in-memory, NOT secure storage: scope is a per-session choice, re-fetched on boot). Every Phase C/E/F call reads it and passes `sub_branch_id` as a query param / field.

**UI + rules (guide §12):**
- After login (and on the create-request entry point), fetch sub-branches. `mode == "centralized"` → show a selector (bottom sheet, radio list with names + `type`); the selection is required before create-data / OLT calls. Scoped mode → if one row, hide the selector and use it silently; if several, show the selector too (guide: the list is restricted to the assignment).
- **Never invent or submit a sub-branch ID** — only IDs returned by this endpoint. If the endpoint returns an empty list, show an empty state ("No sub-branch assigned — contact the office") with retry, not a free-text field.
- **State management:** `FutureProvider` for the list; selection in `StateProvider`; invalidation on logout.
- **Offline:** cached last selection is shown with a "last updated …" label (APP_BRIEF rule: show stale data, label it stale); creating without a fresh list is blocked with a clear message.
- **Verification:** analyze 0 new; new `test/lookups/sub_branch_repository_test.dart` (centralized envelope, scoped single-row, empty list). Haider checks: centralized org shows the selector; scoped single-branch org does not.

### Phase C — Create-data + create connection request

**Goal:** guide §3 + §4 — the first half of the ISPFINAL flow (today the app can only work requests that already exist).
**Endpoints:** `GET /connection-requests/create-data?sub_branch_id=`, `POST /connection-requests` (multipart, expect 201).
**Request fields (guide §4, exact):** required `customer_name`, `customer_phone`, `customer_type` (`home`), `id_card_front`, `id_card_back` (file: jpg/jpeg/png/webp/pdf, max 10 MB each). Optional: `sub_branch_id` (from Phase B only), `customer_area`, `customer_address`, `requested_plan_id`, `team_flow_id`, `price_mode` (`selling_price`/`custom_price`/other), `custom_price`, `discount_type`, `discount_value`, `utility_bill` (file), `connection_form` (file).
**Files:**
- Create: `lib/features/connection_requests/data/create_request_network.dart` + `create_request_repository.dart` (multipart via existing `ApiClient.postMultipart`, same `FormData`/`MultipartFile` pattern as `submit_survey_network.dart:44` and `complete_installation_network.dart:108`), `lib/features/connection_requests/presentation/create_request_providers.dart`, `lib/features/connection_requests/presentation/create_request_screen.dart`.
- Modify: `Endpoints` (Phase 0), router (new route, e.g. `/requests/new`, reachable from the dashboard — exact entry point per Haider: dashboard "New request" button vs Requests list; propose dashboard, confirm in review).
- **File picking:** `image_picker` (already a dep) covers jpg/png/webp photos. **PDFs need a picker that returns files, not images — `image_picker` cannot pick PDFs.** Decision needed (see Risks): add `file_picker` (verify version resolves on Dart 3.9) OR accept images only in v1 and show "PDF coming" — do not silently drop the PDF case. Validate client-side before upload: MIME in {jpg, jpeg, png, webp, pdf}, each file ≤ 10 MB (`maxIdCardBytes = 10 * 1024 * 1024`, mirroring `maxVoiceNoteBytes`).
- **State management:** `createRequestControllerProvider` (`Notifier`: form state, per-file state, `isSubmitting`, `errorMessage`); create-data via `FutureProvider.family` keyed by selected sub-branch (reload when selection changes — guide §3).
- **UI states:** loading create-data (skeleton) → form (plans/FAT/team-flow as dropdowns fed ONLY by create-data, never hardcoded) → validation errors inline → submitting (button disabled, progress) → success (201: show `request_number`, `status: survey_assigned`, `allowed_action: complete_survey`; store the returned request id; button "Open request" → detail).
- **Offline (APP_BRIEF: drafts survive):** the form is a local draft — text fields + picked file paths persist in the controller while the screen lives; if the network drops mid-submit, keep the draft on screen with the error and a retry button. Do NOT claim a queued offline submit in v1 (no outbox exists in the app); say so in the UI ("Couldn't send — your entries are still here. Retry.").
- **Verification:** analyze 0 new; new `test/connection_requests/create_request_repository_test.dart` (multipart field names, 10 MB rejection, 201 parsing) + `create_request_flow_test.dart` (widget). Haider checks: create a request on the phone with real ID photos; request appears in the survey queue with the returned `request_number`.

### Phase D — Detail + `allowed_actions`-driven stage buttons

**Goal:** guide §8 + §11 — the UI stops assuming a fixed stage sequence.
**Endpoints:** `GET /connection-requests/{id}` (exists — extend parsing only).
**Files:**
- Modify: `lib/models/connection_request.dart` (Phase 0 additions), `lib/features/survey/presentation/connection_request_providers.dart` (detail refetch after every transition — `ref.invalidate(connectionRequestDetailProvider(id))`), each detail screen's action area (`survey_request_detail_screen.dart`, `installation_request_detail_screen.dart`, `splicing_request_detail_screen.dart`, `verification_request_detail_screen.dart`, `closing_request_detail_screen.dart`).
- **Rule:** every stage button renders ONLY if its wire value is present in `allowed_actions` (plural) — fall back to singular `allowed_action` for old payloads. `authorize_onu` is a button under the same rule (visible only when `status == installation_assigned` AND `allowed_actions` contains `authorize_onu` — guide §8).
- **After every stage transition:** refetch detail (guide §11) and re-derive buttons; never navigate on a stale `allowed_action`.
- **State management:** no new providers — reuse `connectionRequestDetailProvider`; each stage keeps its existing controller (submit-survey / complete-installation / complete-splicing / shared stage config for verification+closing — confirm the shared path actually posts `complete-verification`/`complete-closing` in Phase D verification, it is only referenced in `team_stage_config.dart` today).
- **Verification:** analyze 0 new; extend `test/survey/connection_request_repository_test.dart` + `test/models/connection_request_test.dart` (plural parsing, `authorize_onu` in list, fallback to singular). Haider checks: a request at each stage shows only its real next action; after completing survey, the detail refreshes and the next stage's button appears.

### Phase E — OLT lookup + waiting-ONU discovery

**Goal:** guide §5 + §6 + §7.
**Endpoints:** `GET /lookups/direct-olts?sub_branch_id=`, `POST /lookups/direct-olts/{olt}/discover-waiting-onus?sub_branch_id=`, `GET /lookups/direct-olts/{olt}/waiting-onus?sub_branch_id=`.
**Files:**
- Create: `lib/features/onu/data/olt_network.dart` + `olt_repository.dart` (or extend `lib/features/lookups/data/` — prefer a new `onu` feature folder: the OLT/ONU flow is a workflow, not a lookup), `lib/features/onu/presentation/olt_providers.dart`, `lib/features/onu/presentation/olt_list_screen.dart`, `waiting_onu_list_screen.dart` (one screen per OLT, or a section inside the installation detail — propose a dedicated screen reached from the installation detail's Authorize-ONU entry; confirm in review).
- Modify: installation detail screen (entry point: "Authorize ONU" button, shown only under the Phase D rule).
- **Behaviour (guide §6/§7):** screen opens with the **cached** GET list (fast, no OLT contact) + "last updated …" label; a "Refresh from OLT" button fires the POST discovery. Discovery failure = HTTP 422 with message: show the message + Retry, keep showing the previous cached list (backend preserves previous rows — never blank the screen on a failed refresh).
- Show per-row: serial, PON port, detected ONU type, `authorization_status` (waiting_authorization / queued / authorizing / failed / needs_attention), `authorization_reason` / `error_message` for failed rows, `last_discovered_at`. Only Huawei + VSOL OLTs support the flow — if the OLT vendor is anything else, show that plainly instead of a dead button.
- **State management:** `FutureProvider.family` for OLT list (keyed by sub-branch) and for cached ONUs (keyed by OLT id); discovery via a `Notifier` (`isDiscovering`, `errorMessage`, `source` + `seen_count` from the response).
- **Verification:** analyze 0 new; new `test/onu/olt_repository_test.dart` (preset parsing incl. `ready: false`; 422 discovery keeps cached list). Haider checks: open an OLT, cached ONUs appear instantly, Refresh updates the list, a failed refresh keeps the old list with the error.

### Phase F — Authorize ONU + job polling

**Goal:** guide §9 + §10 — the core new capability.
**Endpoints:** `POST /connection-requests/{request}/authorize-onu` (201), `GET /connection-requests/{request}/authorization-jobs/{job}`.
**Request shapes (guide §9, both):**
1. Discovered ONU: `{direct_olt_id, direct_olt_unconfigured_onu_id, description}`.
2. Serial fallback: `{direct_olt_id, serial_number, line_profile, service_profile, vlan, user_vlan, gemport, description}`. `line_profile`/`service_profile` optional ONLY when the OLT has saved defaults (`authorization_preset.ready == true`); `vlan`/`user_vlan` optional; `gemport` defaults to the OLT's saved value or 1.
**Files:**
- Create: `lib/features/onu/data/authorize_onu_network.dart` + `authorize_onu_repository.dart`, `lib/features/onu/presentation/authorize_onu_providers.dart`, `lib/features/onu/presentation/authorize_onu_screen.dart` (form: OLT fixed from Phase E, ONU pre-filled from the waiting row, description pre-filled with customer name, profile fields pre-filled from preset when `ready`, editable/manual when `ready == false`).
- Modify: `Endpoints` (Phase 0), `ConnectionRequestAction` (Phase 0), installation detail (button wiring from Phase D).
- **Polling:** after a 201, start polling the job endpoint every **2–3 s** (use a `Timer.periodic` inside the controller, cancelled on dispose / on terminal status / on leaving the screen), max screen wait **~5 min** then stop with "Still running — check again later" + a manual Refresh. Terminal: `succeeded` → refresh waiting-ONU list + refetch request detail (invalidate both providers), show success with `ont_id` when present; `failed` → show `error_message` + Retry (after reviewing OLT state). **Idempotency:** the backend will not duplicate a pending/running job for the same waiting ONU — the app must not re-POST while a job is pending/running; the Authorize button is **disabled while a job is pending or running** (guide §14).
- **State management:** `authorizeOnuControllerProvider` (`Notifier`: form, `isSubmitting`, `job` state machine `idle → queued → polling → succeeded|failed|timedOut`, `errorMessage`); job status via a `FutureProvider.family` keyed by job id, refetched by the poll timer.
- **UI states:** form → submitting (button disabled, spinner) → polling (progress + live status text + elapsed time + Cancel-wait option that stops polling but does NOT cancel the server job) → succeeded/failed/timed-out. Never leave the technician guessing whether the command was sent: the 201 response is shown ("ONU authorization queued", job id).
- **Offline:** authorizing requires network; if the connection drops mid-poll, keep the job id on screen with Retry-polling; never re-POST blindly (idempotency is server-side, but a double-tap must still be impossible client-side).
- **Verification:** analyze 0 new; new `test/onu/authorize_onu_repository_test.dart` (both request shapes, preset-ready vs manual profiles, gemport default) + `test/onu/authorize_onu_polling_test.dart` (poll cadence, terminal transitions, button disabled while pending, no second POST). Haider checks on phone against a real OLT: authorize a waiting ONU, watch it go pending → running → succeeded with an `ont_id`; a failed job shows the backend error and allows retry.

### Phase G — Security checklist (guide §14) + release verification

**Checklist (each item verified, not assumed):**
- [ ] Bearer token stored only in `flutter_secure_storage`; never in code, logs, or crash reports.
- [ ] No OLT credentials or raw CLI commands anywhere in the app (the app never talks to Huawei/VSOL directly — only the Laravel backend does).
- [ ] All IDs treated as opaque UUIDs (no parsing, no constructing IDs client-side — incl. sub-branch: §Phase B rule).
- [ ] Authorize button disabled while a job is pending/running (Phase F).
- [ ] `authorization_reason` / `error_message` displayed for failed ONU rows (Phase E) and failed jobs (Phase F).
- [ ] Request detail refreshed after every successful operation (Phase D).
- [ ] **Debug logging:** confirm Dio `LogInterceptor` does not print the `Authorization` header (it is added only in debug builds; if it logs headers, restrict it to `requestBody: true, responseBody: true` with headers off, or strip the header in the interceptor).
- [ ] 401 anywhere → central logout to `/login` (existing); scanner session unaffected by employee logout (Phase A).
- [ ] `.gitignore` covers `lib/firebase_options.dart` + `android/app/google-services.json` (secret-alert follow-up, 2026-11-23 — verify on the feature branch; add if missing).

**Release verification (whole feature):** `flutter analyze lib --no-pub` = 0 issues **only if** Phase A2 deleted the orphans (otherwise still 35 pre-existing — record which); full targeted test run (`test/auth/`, `test/survey/`, `test/installation/`, `test/onu/`, `test/lookups/`, `test/connection_requests/`); Haider's phone pass on the 184 server: employee login → sub-branch selector → create request with ID photos → survey → installation → OLT list → discover → authorize → poll to succeeded → detail refresh.

---

## §3 — Risks / open questions for Haider (answer before Phase A starts)

1. **Scanner login endpoint — the guide does not say.** The guide documents only `POST /api/mobile/login` and says to use `account_type` to distinguish the scanner flow. The old scanner screen's docstring says it "posts to the scanner-only endpoint". Which is it? (a) Same `/api/mobile/login`, response `account_type` tells us which session it is — the plan assumes this. (b) A separate scanner endpoint (path unknown — the backend must name it). **Do not implement Phase A until this is confirmed — the token-separation design depends on it.**
2. **Does `POST /api/mobile/login` return `account_type` today?** The app's `LoginResponse` ignores it. If the backend does not send it yet, Phase A needs a backend change first (or the scanner flow cannot be distinguished client-side).
3. **Device-scan endpoints are not in the guide.** The old models reference "`/device-scan/…` on the main host" but no contract is documented. If scanning is in scope, the backend must document those endpoints like this guide; otherwise Phase A2 option 2 (delete) is the honest scope.
4. **PDF ID cards need a file picker.** `image_picker` cannot pick PDFs. Add `file_picker` (version must resolve on Flutter 3.35 / Dart 3.9) or accept images only in v1? Haider's call.
5. **Where does "New request" live?** Dashboard button vs Requests list entry — Haider's call (plan proposes dashboard).
6. **Authorize-ONU entry point:** dedicated screen from the installation detail (plan proposes this) vs a section inside the detail screen — Haider's call.
7. **Selected sub-branch persistence:** in-memory per session (plan proposes) vs persisted across restarts — Haider's call.
8. **Orphaned scanner files:** delete (Phase A2 option 2) vs repair (option 1) — Haider's call. Note: they still exist in the local tree; the PC agent was given a delete prompt but has not run it (or ran it on his PC only — verify on his PC before Phase A: `ls lib/features/device_scan/presentation/`).
9. **Base URL confirmation:** the plan keeps `https://184-164-137-101.sslip.io/api/mobile` exactly as set (no port). Haider confirmed on 2026-11-23 ("184 wali jo abhi set hay wohi rakhni hay") — that confirmation referred to the old `http://184.164.137.101/api/mobile`, which the backend developer replaced on 2026-11-24 with the sslip.io URL (old URL dead: 301 + empty 443); the 2026-11-23 "never changes" rule is superseded — see the note at the top of this file.
10. **Backend readiness:** the guide's endpoints (`create-data`, `direct-olts`, `authorize-onu`, …) are assumed live on the 184 server. If any returns 404 today, that phase blocks on the backend, not the app — check with a raw call (curl/Postman) before the phase starts.

---

## Appendix — file inventory for the phases

| Phase | New files | Modified files |
|---|---|---|
| 0 | 5 models (`sub_branch`, `create_data`, `direct_olt`, `waiting_onu`, `authorization_job`) | `app_constants.dart` (endpoints), `models/connection_request.dart` |
| A | `scanner_login_screen.dart` (rebuild), `scanner_network.dart`, `scanner_repository.dart`, `scanner_providers.dart` | `auth.dart` (+generated), `auth_repository.dart`, `providers.dart`, `secure_storage.dart`, `api_client.dart`, `app_router.dart`, `login_screen.dart` |
| A2 | — (decision) | delete list OR `mobile_scanner` + 3 screens |
| B | `sub_branch_network.dart`, `sub_branch_repository.dart`, `sub_branch_providers.dart` | `app_constants.dart` (Phase 0), callers pass `sub_branch_id` |
| C | `create_request_network.dart`, `create_request_repository.dart`, `create_request_providers.dart`, `create_request_screen.dart` | `app_router.dart`, dashboard entry point |
| D | — | `connection_request.dart`, `connection_request_providers.dart`, 5 detail screens, `team_stage_config.dart` (verify) |
| E | `olt_network.dart`, `olt_repository.dart`, `olt_providers.dart`, `olt_list_screen.dart`, `waiting_onu_list_screen.dart` | installation detail screen |
| F | `authorize_onu_network.dart`, `authorize_onu_repository.dart`, `authorize_onu_providers.dart`, `authorize_onu_screen.dart` | installation detail screen |
| G | — | `api_client.dart` (logging, if needed), `.gitignore` (if needed) |

**Totals:** ~22 new files, ~15 modified files, 7 phases (+ A2 decision). No new packages except possibly `file_picker` (Phase C, Haider's call) and `mobile_scanner` (Phase A2 option 1, Haider's call). No base-URL change. No new state library.

---

## Implementation notes (2026-11-23 — what actually shipped, where reality diverged)

- **Phases 0–G implemented, NOT pushed.** Analyze: 35 issues → **0 issues** (orphan files deleted in Phase A). Full suite: **224 pass, 1 fail** — the single failure is pre-existing `test/installation/complete_installation_flow_test.dart`, which fails to compile (imports 7 files that don't exist in this tree, incl. `request_detail_screen.dart`); untouched by this work.
- **No new dependencies added.** No `file_picker` (ID card images only, per Haider), no `mobile_scanner` (no scan UI — see A2).
- **Phase A2 decision (Haider: repair by rebuilding):** scanner login rebuilt from scratch; scanner home is a plain session/account screen — no scan UI, because no device-scan endpoints are documented in the guide. Orphan files deleted (`add_device_details_screen.dart`, `device_scan_screen.dart`, `installation_locations_card.dart`, `models/device_scan.dart` — all verified zero importers first).
- **Scanner login + missing `account_type` (judgement call, needs Haider's confirm):** employee login refuses a non-`"employee"` account_type and falls back to employee when the field is missing. Scanner login **accepts** a missing `account_type` (the user deliberately opened scanner login, and the backend may not send the field yet — refusing would make scanner login unusable until a backend change). One-line change in `ScannerRepository.login` if Haider wants it refused instead.
- **Phase C:** FAT dropdown deliberately NOT rendered and `fat_node_id` NOT submitted — guide §4's exact field list has no fat-node field, and FAT selection already lives at the survey stage. If the backend expects a FAT node on create, it must name the field. `discount_type` is free-text (guide lists the field but no enum). `customer_type` defaults to `'home'`.
- **Phase F:** polling lives in `AuthorizeOnuController` (Timer.periodic, 3 s) rather than a separate `FutureProvider.family` keyed by job id — same behaviour, covered by fakeAsync tests. `AuthorizeOnuResult` reads the job id leniently (`data.id` / `data.job_id` / `job_id` / `id`) because the guide doesn't pin the authorize 201 shape — confirm on the phone pass.
- **`WaitingOnu` has no `error_message` field** (only `authorization_reason`); failed rows show `authorization_reason`. If the backend sends `error_message` on waiting ONUs, add the field — it was not invented.
- **`sub_branch_id` on discover/waiting-onus is sent as a query param** (endpoint paths carry no sub-branch segment).
- **Phase G:** Dio `LogInterceptor` headers explicitly OFF on both clients (Phase A found dio defaults log headers). `.gitignore` now covers `lib/firebase_options.dart` + `android/app/google-services.json`. `pubspec.yaml`/`pubspec.lock` were NOT changed by this work (no new deps); the lockfile churn in the tree is from `pub get` runs only — do not include them in a push manifest unless deps change.
- **Still needs Haider on his phone (184 server, real OLT):** employee login → sub-branch selector → create request with real ID photos → survey → installation → OLT list → discover → authorize → poll to succeeded with `ont_id` → detail refresh. And: does `POST /login` return `account_type` today? (Unverified — no scanner credentials to test with.)

