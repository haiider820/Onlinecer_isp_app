# ISPFINAL — Defect list (critical testing, 2026-11-23)

**App:** Onlinecer ISP (Malik Fiber), `haiider820/Onlinecer_isp_app`
**Branch:** `feature/kit-navy-redesign`, remote tip `38908ab`
**Base URL:** `https://184-164-137-101.sslip.io/api/mobile` (changed 2026-11-24 — backend developer moved the server off the old `http://184.164.137.101/api/mobile`, which is dead; the 2026-11-23 "base URL never changes" rule is superseded)
**Status:** 14 defects (2 blocker, 7 major, 5 minor). **ALL FIXED 2026-11-23 in the local tree (not pushed)** — D0 (bounce) + D1–D13, verified by the full suite (338 pass, 1 pre-existing fail) and `flutter analyze` 0 issues. Each section below carries its fix + test evidence.
**How found:** widget tests with faked network (never a live server) in `test/ispfinal_adversarial/` — 91 tests, 78 pass, 13 fail at discovery. After the fixes all 13 DEFECT tests pass; the full suite is 338 pass / 1 fail (pre-existing `test/installation/complete_installation_flow_test.dart`, fails to load — imports non-existent files; unrelated). `flutter analyze lib --no-pub`: 0 issues.

---

## D0 — BLOCKER — FIXED — Scanner-login link bounced back instead of opening the scanner form

- **Flow:** Scanner login (the bug Haider reported 2026-11-23 ~15:44 PKT).
- **Repro:** On the phone, with an employee token in storage, tap "Device scanner? Sign in here" on the login page → lands on the dashboard (and, via the chain below, can end up back on login), never reaches the scanner form.
- **Expected:** The scanner login form.
- **Actual (pre-fix):** Bounced to `/dashboard`.
- **Root cause (proven by failing-then-passing test):** `lib/core/router/app_router.dart:137-139` (pre-fix) — the redirect's scanner-login branch ran whenever EITHER session existed:
  ```dart
  if (onScannerLogin) {
    return scannerLoggedIn ? Routes.scannerHome : Routes.dashboard;
  }
  ```
  `isScannerLoggedIn()` (`lib/core/storage/secure_storage.dart:127`) is pure token-presence, so any user with an employee token stored was bounced to `/dashboard` and could never reach the scanner form. A second defect surfaced while fixing: the redirect also bounced on token presence alone to `/scanner/home` — a stale scanner token that 401s on `GET /me` sent the user to a scanner home with no session to show. The redirect cannot verify a token; only `ScannerLoginScreen._tryRestore` can, via real `GET /me`.
- **The "login, not dashboard" half:** `DashboardShell` never navigates to login; `SessionTeamGuard` bounces to `/dashboard`, never login. The only automatic path back to `/login` found is D2 (`lib/main.dart:30` rebuilds the router in `build()`, resetting navigation to `/boot`). Likely bridge on Haider's phone: redirect → dashboard on a stale employee session → dashboard `GET /dashboard` 401 → session cleared → next boot/rebuild lands on login.
- **Fix (in the tree, not pushed):** `lib/core/router/app_router.dart:137-155` — the `onScannerLogin` branch now always returns `null`; the scanner form is only ever reached by an explicit tap, and `_tryRestore` proves the token with `GET /me`, forwarding to scanner home only when it verifies, otherwise showing the form.
- **Tests:** new `test/routing/scanner_login_redirect_test.dart` — 6/6 pass (pre-fix, 2 failed: employee-only tap and stale-scanner-token tap both landed on the dashboard). Existing auth + routing suites: 38/38 pass. Full suite: 230 pass, 1 fail (pre-existing `test/installation/complete_installation_flow_test.dart`, fails to load — imports non-existent files; unrelated).
- **Needs:** app fix — DONE, awaiting push with the rest of this round.

---

## D1 — BLOCKER — FIXED 2026-11-23 — Scanner logout doesn't stick; scanner form unreachable until app restart

- **Flow:** Scanner login / logout.
- **Repro:** Seed a scanner session → scanner home → tap Sign out → lands on staff login → tap "Device scanner? Sign in here" → bounces straight back to staff login, never shows the form.
- **Expected:** The scanner login form.
- **Actual:** Redirect loop to staff login.
- **Evidence:** `lib/features/device_scan/presentation/scanner_providers.dart` — `scannerSessionProvider` is a plain non-`autoDispose` `FutureProvider`, never invalidated in `ScannerAuthController.logout()` (lines 76–88) or anywhere (only the home error-state Retry invalidates it); `lib/features/device_scan/presentation/scanner_login_screen.dart:62` `_tryRestore` reads the cached value. Tests: `DEFECT: after scanner logout, scannerSessionProvider still returns the old session` (container: storage cleared but provider still returns session, 0 new network calls) + widget test failing at the re-tap step.
- **Fix (2026-11-23):** `lib/features/device_scan/presentation/scanner_providers.dart:103-130` — `ScannerAuthController.logout()` now does `ref.refresh(scannerSessionProvider)` BEFORE the storage clear (forces a synchronous rebuild while the token is still stored, so the restore hits the network) and `ref.invalidate(scannerSessionProvider)` AFTER it. A lone post-clear invalidate was verified insufficient (Riverpod 2.6.1: invalidate only schedules a refresh; every `read` flushes it synchronously). `lib/features/device_scan/presentation/scanner_home_screen.dart:102-111` — sign-out now navigates to `Routes.login` (staff login) instead of `Routes.scannerLogin`. **Behaviour change:** sign-out fires one `GET /me` before clearing and lands on the staff login; the scanner form is one tap away via "Device scanner? Sign in here". **Tests:** `adversarial_auth_scanner_test.dart` 20/20 (incl. the D1 DEFECT test), full suite green.

## D2 — BLOCKER — FIXED 2026-11-23 — Router rebuilt inside `build()` resets navigation

- **Flow:** Any deep screen (navigation stability).
- **Repro (widget test, real app + counting fake `GET /me`):** log in → `/survey/requests` → toggle theme → user is back on the dashboard; `GET /me` fired twice.
- **Expected:** Stay on the list, no re-verification.
- **Actual:** New GoRouter at `/boot`, boot re-runs, deep screen gone.
- **Evidence:** `lib/main.dart:30` builds `buildAppRouter()` inside `IspOnlinecerApp.build()`, which watches `themeModeProvider`. This is also the only automatic path back to `/login` found (see D0).
- **Fix (2026-11-23):** `lib/main.dart` — `IspOnlinecerApp` converted from `ConsumerWidget` to `ConsumerStatefulWidget`; the router is built once as `late final GoRouter _router = buildAppRouter(storage: widget.storage)` and `build()` only watches `themeModeProvider`. Boot gate and redirect behaviour untouched. **Tests:** `adversarial_router_rebuild_test.dart` + `adversarial_branding_shell_test.dart` 6/6 (theme toggle stays on `/survey/requests` with exactly 1 `GET /me`), full suite green.

## D3 — MAJOR — FIXED 2026-11-23 — Expired tokens still count as logged in

- **Flow:** Session / expiry.
- **Repro:** Session with `expires_at` 2020 → `isLoggedIn()` returns `true`, `hasExpiredToken()` returns `true`.
- **Expected:** `isLoggedIn()` returns `false` for an expired token.
- **Actual:** Router guard admits expired sessions; scanner restore sends a dead token to the scanner home first.
- **Evidence:** `lib/core/storage/secure_storage.dart` — `isLoggedIn()` / `isScannerLoggedIn()` check token presence only; only the boot gate consults `hasExpiredToken()`.
- **Fix (2026-11-23):** `lib/core/storage/secure_storage.dart:127-148,270-278` — `isLoggedIn()` / `isScannerLoggedIn()` now return false for an expired token (new `hasExpiredScannerToken()` mirroring `hasExpiredToken()`; unparseable/missing `expires_at` stays lenient). Boot gate untouched. `lib/features/device_scan/data/scanner_repository.dart:90-99` — `restoreSession()` short-circuits an expired scanner token (clears it locally, returns null, no `GET /me`), so an expired token never bounces to a dead scanner home, including offline. **Fixture:** `test/auth/auth_repository_test.dart:91-96` — the pre-existing `loginJson()` fixture carried `expires_at` 2026-10-10 (now past); bumped to 2099-10-10 with a comment. **Tests:** `adversarial_expiry_security_test.dart` 9/9, full suite green.

## D4 — MAJOR — FIXED 2026-11-23 — `_loggingOut` guard is a no-op

- **Flow:** Security / 401 handling.
- **Repro:** Source-level proof (could not execute end-to-end: no Dio injection seam — itself a testability gap). Concurrent 401s both pass the guard and both clear/redirect.
- **Expected:** Second concurrent 401 suppressed while the first logout is in flight.
- **Actual:** Flag is clear before the async clear finishes.
- **Evidence:** `lib/core/network/api_client.dart:145–153` — sets `_loggingOut = true`, fires `unawaited(_onUnauthorized())`, sets `false` synchronously.
- **Fix (2026-11-23):** `lib/core/network/api_client.dart:145-163` — `unawaited(_onUnauthorized().whenComplete(() => _loggingOut = false))`; the flag now stays set until the async clear finishes and resets on failure too (a failed clear never wedges the guard). No Dio injection seam built. **Tests:** `adversarial_expiry_security_test.dart` 9/9, full suite green.

## D5 — MAJOR — FIXED 2026-11-23 — 401 logout leaves the sub-branch scope in place

- **Flow:** Sub-branch selector / session.
- **Repro:** Select sub-branch `b`, then `clearSession()` (exactly what the 401 path does) → selection still `b`, `canProceed` still true.
- **Expected:** Scope dropped on session clear.
- **Actual:** The next employee's session can inherit the previous scope.
- **Evidence:** `ApiClient` 401 handling only calls `storage.clearSession()`; `invalidateSubBranchState` is called only from the manual dashboard logout (`lib/features/dashboard/presentation/team_dashboard_screen.dart:148`).
- **Fix (2026-11-23):** the DEFECT test invokes `storage.clearSession()` directly, so the drop is triggered by `clearSession()` itself. `lib/core/storage/secure_storage.dart:283-309` — `SecureStorage` gained a session-cleared listener registry (`add/removeSessionClearedListener`), notified at the end of `clearSession()` only. `lib/features/lookups/presentation/sub_branch_providers.dart:24-58` — `selectedSubBranchProvider` is now a `NotifierProvider<SelectedSubBranchNotifier, String?>` (same read/write API) whose build subscribes and, on clear, drops the selection and invalidates the cached list. Scope stays in-memory in Riverpod (not moved into secure storage). Scanner clears never notify, so scanner logout can't drop employee scope. Manual dashboard logout unchanged. **Tests:** `adversarial_sub_branch_test.dart` 14/14, full suite green.

## D6 — MAJOR — FIXED 2026-11-23 — Create submit with no sub-branch scope still POSTs

- **Flow:** Create request.
- **Repro:** Valid draft + `submit(subBranchId: null)` → 201, `createCalls == 1`.
- **Expected:** Refused before POST with an error.
- **Actual:** POSTs without the scope; the screen gates on `canProceed`, but the controller (the last line of defence) doesn't enforce it.
- **Evidence:** `lib/features/connection_requests/presentation/create_request_providers.dart` — `submit()` never checks `subBranchId == null`; it just omits the field.
- **Fix (2026-11-23):** `lib/features/connection_requests/presentation/create_request_providers.dart:287` — `CreateRequestController.submit()` now refuses before POST when `subBranchId == null`: sets `errorMessage: 'Select a sub-branch before submitting.'` and returns `null` (0 network calls). The check sits after draft validation so field errors still surface first; the valid-scope path is unchanged. **Tests:** `adversarial_create_request` DEFECT tests pass, full suite green.

## D7 — MAJOR — FIXED 2026-11-23 — `allowed_actions` with only unknown values drops the valid singular fallback

- **Flow:** Detail / stage buttons.
- **Repro:** `allowed_actions: ["some_future_action"]` + `allowed_action: "complete_survey"` → `actions` yields `[]`, every stage button disappears.
- **Expected:** Fall back to singular when the plural parses to empty.
- **Actual:** Non-empty plural list is parsed, unknowns dropped, no fallback.
- **Evidence:** `lib/models/connection_request.dart` — `actions` getter.
- **Fix (2026-11-23):** `lib/models/connection_request.dart:124` — the `actions` getter now parses the plural and returns it only when at least one known action parses; when it parses to zero known actions it falls back to the singular `allowed_action` (previously `[]`). Plural-with-known-values behaviour and wire values unchanged. A pre-existing model test that pinned the old behaviour (plural-only-unknown + valid singular → empty) was updated to expect the fallback. **Tests:** `adversarial_detail_olt` DEFECT tests pass; 14 new tests (model + repo + controller + widget), full suite green.

### D7 extension — `review_survey` (backend doc `~/workspace/user/files/MOBILE-API-REPLY-survey-inventory-review.txt`, folded into D7 per Haider)
- **Known action:** `ConnectionRequestAction.reviewSurvey` added (`lib/models/connection_request.dart:24,35,48`, wire value `'review_survey'`); the D7 fallback keeps it (plural-only-unknown + singular `review_survey` → `[reviewSurvey]`).
- **Review button:** `lib/features/survey/presentation/survey_request_detail_screen.dart:73,751` — `canReviewSurvey = detail.actions.contains(reviewSurvey)`, driven by `allowed_action`, never status; the sticky shelf shows a **"Review"** button (replaces "Complete Survey"; mutually exclusive per backend). New route `Routes.reviewSurvey` (`/survey/requests/:id/review-survey`, `app_router.dart:270`), same `SubmitSurveyScreen` in review mode.
- **Review submit, same endpoint:** `POST /connection-requests/{id}/complete-survey` — new optional `feasibilityStatus` threaded through network/repository/providers (`submit_survey_network.dart:22,47`, `submit_survey_repository.dart:54`, `submit_survey_providers.dart:50,58`); `isReview: true` → `'feasible'`, normal submit passes nothing. Body is `survey_feasibility_status: "feasible"` + `survey_notes` on both JSON and multipart (voice_note) paths. **Doc-vs-code note:** the doc's step-2 example shows a normal survey sending `requested_items`, but this app's submit flow never had an items picker and never sent them — so the review path omits them by construction. No new endpoint.
- **Review screen content:** new `lib/models/item_request.dart:13,47` — lenient `ItemRequest` / `ItemRequestItem` (status, approval_notes, requested-by team name, per-item name/unit/quantity_requested/quantity_approved; missing `items` → empty, bad quantities → null, never throws). `ConnectionRequest.itemRequests` (`connection_request.dart:81`). The detail screen shows an "Inventory Approval" card (`survey_request_detail_screen.dart:108,630`) when present.
- **List filter:** `GET /connection-requests?status=survey_review` already works at the network layer (optional `status` query param passes through verbatim) — but there is no status-filter UI in the list, so none was built in this round.
- **Codegen caveat:** `build_runner` regenerated `connection_request.freezed.dart` fine, but the scoped `json_serializable` run wrote 0 outputs and a full run was OOM-killed on the VM, so `connection_request.g.dart` was hand-updated in exact codegen style (verified by parsing tests). **A PC-side `flutter pub run build_runner build` should confirm it regenerates identically before/after the next build.**
- **Tests:** 14 new tests — model (`review_survey` plural/singular/fallback/unknown-dropped/status-vs-action + `item_requests` doc-example/absent/lenient), repo (review JSON + multipart bodies, normal submit omits feasibility), controller (`isReview` forwards feasible), widget (Review button shown / Complete Survey hidden, Inventory Approval card contents).

## D8 — MAJOR — FIXED 2026-11-23 — Back button mid-poll: polling continues up to 5 min after leaving; a second authorization is silently refused

- **Flow:** Authorize ONU / polling.
- **Repro (fakeAsync):** Submit req_1 → polling → elapse 9 s with no screen → 3 further job polls; submit for req_2 → no second POST and no error anywhere (`errorMessage` is null).
- **Expected:** Polling stops on leaving; a refused submit explains itself.
- **Actual:** Polling continues; the refusal is silent.
- **Evidence:** `authorizeOnuControllerProvider` is a plain (non-`autoDispose`) `NotifierProvider`; `AuthorizeOnuScreen.dispose()` only disposes text controllers and nothing invalidates the controller.
- **Fix (2026-11-23):** `lib/features/onu/presentation/authorize_onu_providers.dart` — `build()` registers `ref.onCancel` (lines 177–181): the screen is the provider's only listener, so when it is popped the timer stops and state resets to fresh idle; the in-flight server job is NOT cancelled, only screen-side polling. Deliberately NOT `autoDispose` (tried first — broke 4 existing tests: Riverpod 2.6.1 disposes a no-listener autoDispose provider on the next flush, resetting polling-test state). A refused submit now explains itself (lines 241–246): `errorMessage: 'An authorization job is already active.'`, surfaced in the screen's `_JobStatusCard`. `_disposed` flag (line 157, set in `onDispose`) with guards after every await, so in-flight work never touches state after dispose. Screen file untouched. **Tests:** `adversarial_authorize_test.dart` + `test/onu/` 32/32 (incl. both DEFECT tests); second authorization after leaving confirmed with a scratch test (deleted after the run), full suite green.

## D9 — MINOR — FIXED 2026-11-23 — `cancelWait` during submit is undone when the in-flight POST lands

- **Flow:** Authorize ONU / polling.
- **Repro:** Gate the POST, `cancelWait()` → `cancelled`, complete POST → `polling`.
- **Expected:** Cancel sticks.
- **Actual:** `_submit` doesn't re-check phase after `await call()`. Controller-level race only — the screen disables Stop while submitting, so users can't reach it today.
- **Evidence:** `lib/features/onu/presentation/authorize_onu_providers.dart` — `_submit`.
- **Fix (2026-11-23):** `lib/features/onu/presentation/authorize_onu_providers.dart:261-270` — `_submit` re-checks phase after `await call()`: if `cancelled`, it stays cancelled (no transition to polling) but keeps the landed `jobId`/`message`/`job`, so `resumePolling()` can still resume from it. Same guard in both catch blocks (lines 308, 317) so a failed POST landing after a cancel doesn't reset to idle. Screen behaviour unchanged (Stop still disabled while submitting). **Tests:** `adversarial_authorize_test.dart` + `test/onu/` 32/32, full suite green.

## D10 — MAJOR — FIXED 2026-11-23 — Valid session, unknown/empty team strands the user

- **Flow:** Dashboard shell.
- **Repro:** Log in with a session whose team is null/unknown → ComingSoon screen with no button of any kind — no logout, no back. Only escape is killing the app / clearing app data.
- **Expected:** A way out (e.g. Sign out).
- **Actual:** Stranded.
- **Evidence:** `lib/features/dashboard/dashboard_shell.dart` returns `ComingSoonScreen` for a null team; `lib/shared/widgets/coming_soon_screen.dart` has no button.
- **Fix (2026-11-23):** `lib/shared/widgets/coming_soon_screen.dart` — optional `VoidCallback? onSignOut`; when provided, a `FilledButton.icon` labelled **"Log out"** renders below the message (screens passing nothing render exactly as before). `lib/features/dashboard/dashboard_shell.dart` — the null-team branch passes `onSignOut: () => _signOut(context, ref)`, mirroring the dashboard header's logout path: `clearSession()` (employee keys only — scanner keys and theme untouched) + `invalidateSubBranchState(ref)` + `ref.invalidate(dashboardSummaryProvider)` + `context.go(Routes.login)`. **Tests:** `adversarial_branding_shell_test.dart` (with router-rebuild tests) 6/6, full suite green. No screenshot re-render (no ComingSoon shot exists in v4).

## D11 — MINOR — FIXED 2026-11-23 — Splash still says MALIK FIBER

- **Flow:** Branding (splash vs login).
- **Repro:** Open the app — splash shows MALIK FIBER while both logins are ISP 360.
- **Expected:** Consistent ISP 360 branding (wording per Haider).
- **Actual:** `lib/features/splash/presentation/splash_screen.dart:110` `'MALIK FIBER'`, line 339 `'Malik Telecom Infrastructure Group © 2025'`.
- **Fix (2026-11-23):** `lib/features/splash/presentation/splash_screen.dart:110` — `'MALIK FIBER'` → `'ISP 360'`; line 339 — `'Malik Telecom Infrastructure Group © 2025'` → `'ISP 360 © 2025'` (no invented legal/group name; code comment at line 100 updated likewise). **Tests:** `adversarial_branding_shell_test.dart` 6/6 (splash source contains `ISP 360`, no `MALIK FIBER` / `Malik Telecom Infrastructure Group`), full suite green. No screenshot re-render (no splash shot exists in v4).

## D12 — MINOR — FIXED 2026-11-23 — "Remember this handheld unit" is UI-only

- **Flow:** Employee login.
- **Repro:** Toggle it, dispose + remount the screen → resets to ON (proven by widget test).
- **Expected:** Persisted preference, or no toggle.
- **Actual:** Local `_rememberDevice` bool, never written to storage or read back.
- **Evidence:** `lib/features/auth/presentation/login_screen.dart:44,249–253`.
- **Fix (2026-11-23):** persisted (Haider chose the fix-all round, so the toggle was kept and wired, not removed). `lib/core/storage/secure_storage.dart` — new key `ui.remember_device` (follows the existing `ui.theme_mode` naming) with `getRememberDevice()` (`bool?`, null = never chosen) and `setRememberDevice(bool)`; a `ui.*` key, so `clearSession()` never wipes it. `lib/features/auth/presentation/login_screen.dart:43-56,249-260` — `_rememberDevice` is restored in `initState` (defaults to ON when never chosen) and written to secure storage on every tap. Login behaviour otherwise unchanged. The pre-existing test that pinned the buggy behaviour (asserted no `remember` key is ever written) was updated to assert the fixed behaviour. **Tests:** `adversarial_branding_shell_test.dart` 6/6, full suite green.

## D13 — MINOR — FIXED 2026-11-23 — Employee login double-tap fires two `POST /login`

- **Flow:** Employee login.
- **Repro:** Two rapid taps → 2 network calls, both succeed.
- **Expected:** Second tap ignored while a login is in flight.
- **Actual:** `AuthController.login` has no in-flight guard (unlike `AuthorizeOnuController`).
- **Evidence:** `lib/features/auth/presentation/providers.dart` — `AuthController.login`.
- **Fix (2026-11-23):** `lib/features/auth/presentation/providers.dart:63-100` — `AuthController` holds `_loginInFlight`; a second `login()` while one is in flight returns the same future (one POST, both callers get the response). Guard clears in `_performLogin`'s `finally`, so a failed attempt can always be retried. Same gap was present in scanner login and fixed the same way (`lib/features/device_scan/presentation/scanner_providers.dart:57-96`). The pre-existing test that pinned the buggy behaviour (`loginCalls == 2`) was flipped to assert `loginCalls == 1`, with retry-after-failure tests added for both controllers. **Tests:** `adversarial_auth_scanner_test.dart` 20/20, full suite green.

---

## D14 — BLOCKER — FIXED 2026-11-25 — Normal survey submit never sends `survey_feasibility_status`; the Complete Survey screen has no feasibility picker

- **Flow:** Survey → Complete Survey → Submit Survey.
- **Repro:** Fill notes/photos/checklist, tap Submit Survey → red banner "The survey feasibility status field is required." (server 422). No way to fill the field: the screen has no Feasible / Not feasible input anywhere.
- **Expected:** The screen collects the feasibility verdict; the POST carries `survey_feasibility_status` (`"feasible"` / `"not_feasible"`), plus `survey_not_feasible_reason` when not feasible.
- **Actual:** `submit_survey_providers.dart:58` passed `feasibilityStatus: isReview ? 'feasible' : null` — the field was sent only on the review path; a normal submit sent nothing. The screen had only Voice Note / Field Notes / Site Photos / Site Checklist.
- **Evidence:** Backend answers (2026-11-25): allowed values are ONLY `feasible` / `not_feasible`; a `not_feasible` verdict REQUIRES `survey_not_feasible_reason`; `requested_items` is OPTIONAL (omit is valid — no items picker built, per the answers).
- **Fix (2026-11-25):** `lib/features/survey/presentation/submit_survey_screen.dart` — "Feasibility" card above Field Notes (normal flow only; hidden in review mode), a `SegmentedButton` (Feasible / Not feasible) plus a "Reason (required)" field shown when Not feasible is picked. `lib/features/survey/presentation/submit_survey_providers.dart` — `submit()` gains `feasibilityStatus` + `notFeasibleReason` params and validates client-side before any network call (no pick → "Select whether the site is feasible."; not-feasible with no reason → "Add a reason why the site is not feasible."); review still forces `'feasible'` with no reason. `lib/features/survey/data/submit_survey_repository.dart` + `submit_survey_network.dart` — both JSON and multipart paths send `survey_feasibility_status` always and `survey_not_feasible_reason` only when the value is `'not_feasible'` (never when feasible). The pre-existing controller test that pinned "normal submit forwards nothing" was rewritten to the new contract. **Tests:** new `submit_survey_controller_review_test.dart` (5), `submit_survey_repository_test.dart` (+3 reason tests), `submit_survey_network_test.dart` (5 wire-level, via a capturing `ApiClient`), `submit_survey_feasibility_screen_test.dart` (5 widget tests incl. review-mode hiding); `survey_flow_test.dart` updated to pick Feasible before submitting.

## D15 — MAJOR — FIXED 2026-11-25 (partial — see limit) — Request Detail bottom shelf overflows at narrow width

- **Flow:** Request Detail (survey) bottom shelf.
- **Repro:** On a narrow phone the three-button row (Plan Route + Flag + Complete Survey) squeezes the Flag label vertical ("F I a g") and wraps/clips "Complete Survey" ("Comple te Survey", cut off at 52px).
- **Expected:** All three actions fit; "Complete Survey" renders fully on one line.
- **Actual:** `_BottomShelf` (`survey_request_detail_screen.dart:667-760`) laid out Plan Route at intrinsic width + Flag `Expanded` flex 1 + Complete Survey `Expanded` flex 2 at 52px height — too narrow for the labels.
- **Evidence:** Haider's phone screenshots, 2026-11-25 11:21 PKT.
- **Fix (2026-11-25):** `lib/features/survey/presentation/survey_request_detail_screen.dart` — the Flag button is now icon-only (52x52 `OutlinedButton` with the flag icon, same error colour/border and the same "not available yet" snackbar, `Semantics(label: 'Flag issue')`). Plan Route / Complete Survey labels, 52px height and button order are unchanged.
- **LIMIT (measured 2026-11-25, real Plus Jakarta Sans SemiBold metrics):** icon-only Flag alone does NOT make "Complete Survey" fit on one line at a real 360dp — the button gets 133.8dp but one line needs 185.6dp (icon 20 + gap 8 + text 117.6 + M3 icon-button padding 40). One line needs a screen ≥ 412dp; at 364–411dp the label renders on two clean lines without clipping; below 364dp it still clips to three lines. The one-line bar needs a follow-up decision (e.g. dropping the icon from Complete Survey too, or a tighter padding). The widget test runs at 600px (the test font renders ~2x wider than Jakarta Sans, so a 360px test viewport overflows even the fixed layout; 600px is the narrowest test width where the fixed shelf fits while the old one did not). **Tests:** new `detail_bottom_shelf_test.dart` (2: icon-only Flag + snackbar; verified to fail on the old code). **Phone check still needed:** confirm on Haider's phone whether the label now shows fully (one line on ≥412dp, two clean lines on 364–411dp) or still clips (<364dp).

## D16 — MAJOR — FIXED 2026-11-25 — Complete-installation sends `inventory_items`; the server only reads `items` (inventory usage silently dropped)

- **Flow:** Installation → Complete Installation with inventory rows.
- **Repro:** Submit an installation with inventory items → the server records no inventory usage (no error — the field is silently ignored).
- **Expected:** Inventory lines reach the server as `items`.
- **Actual:** `lib/features/installation/data/complete_installation_network.dart` sent `'inventory_items'` — a JSON array on the JSON path and a JSON-encoded string on the multipart path. The field name appears in no backend doc; the PDF doc lists `items[0][item_id]` / `items[0][quantity]`.
- **Evidence:** Backend answers (2026-11-25): the server reads `items`, NOT `inventory_items`. JSON: `"items": [{"item_id": "uuid", "quantity": 2}]`. Multipart: form fields `items[0][item_id]` / `items[0][quantity]`.
- **Fix (2026-11-25):** `lib/features/installation/data/complete_installation_network.dart` — JSON path now sends `"items": [{item_id, quantity}]`; multipart path now sends indexed `items[i][item_id]` / `items[i][quantity]` form fields (one index per line); all `inventory_items` sends removed (the unused `dart:convert` import dropped too). The `InventoryLine` record type and the repository/screen plumbing are unchanged; only the wire field name changed. `lib/features/installation/presentation/complete_installation_screen.dart:847` comment updated (`inventory_items` → `items`). **Tests:** new `complete_installation_network_test.dart` (4 wire-level tests via a capturing `ApiClient`: JSON `items` array, JSON no-lines, multipart indexed fields, multipart no-lines — all asserting `inventory_items` is never sent). Shared capture helper: `test/helpers/capturing_api_client.dart`.

## D17 — MAJOR — FIXED 2026-11-25 — Create-data ignores `default_team_flow_id` and flow stages; empty `team_flows` hides the section silently

- **Flow:** New Request → Team flow dropdown.
- **Repro:** Open New Request as Umair (centralized scope, backend default flow "Cent-Tech Support") → the Team flow dropdown shows "Choose a team flow" with nothing pre-selected, even though create-data returns `default_team_flow_id: "12218cba-88b3-4f84-9578-421af30f6a0d"` and that id is in `team_flows`. Open as the survey account (scoped, no flow configured) → the Team flow section vanishes entirely with no explanation.
- **Expected:** (1) The backend default is pre-selected when it names a flow in the returned list; (2) flow stages parse (`stage_assignments`: `stage_key` / `stage_label` / `stage_order` + assigned team) for workflow logic; (3) an empty `team_flows` shows a note that no flow is configured and the request will stay pending for flow assignment, without blocking the rest of the form; (4) a sub-branch change re-applies the new scope's default instead of keeping a stale one; (5) `team_flow_id` is sent on create exactly when a flow is selected.
- **Actual:** `CreateDataTeamFlow` had only `id` / `name` / `functional_team_type`; `default_team_flow_id` was parsed nowhere (zero matches in lib/ + test/); stage fields were parsed nowhere; the screen hid the dropdown whenever the list was empty; the controller kept whatever `teamFlowId` it had across a sub-branch change (a stale id from the old scope could be submitted even though the dropdown showed nothing selected).
- **Evidence:** Live create-data (2026-11-25 ~15:33 PKT, after the backend's flow deploy + the create-data 500 fix): `data: {customer_types, fat_nodes, plans, team_flows, default_team_flow_id}`. A flow is `{id, name, stage_assignments, teams}` — there is NO `functional_team_type` on the flow itself (kept only as a lenient fallback). `stage_assignments` is `[{stage_key, stage_label, stage_order, team}]`, `team` is `{id, name, code, functional_team_type, functional_team_types[], flow_order, is_active}`. Umair (centralized, sub_branch `c348df56-736f-4fa9-bd45-1f20635c11d7`): default `12218cba-88b3-4f84-9578-421af30f6a0d`, 2 flows — "Installation" (`763419f4-be54-4b7d-9855-b1cc0af8a547`, 5 stages survey(1)/installation(2)/fiber_splicing(3)/connection_verification(4) → Long Haul Team, closing(5) → Main Team Test) and "Cent-Tech Support" (all 5 stages → Centralized Tech). Survey account (scoped, sub_branch `c580f80f-550a-4374-ad80-0adb6d0c2efb`): `team_flows: []`, `default_team_flow_id: null` — no flow configured for that scope yet, NOT an app bug.
- **Fix (2026-11-25):** `lib/models/create_data.dart` — new lenient `CreateDataTeam` + `CreateDataStageAssignment` models; `CreateDataTeamFlow` gains `stage_assignments` + `teams` (functional_team_type kept, never required); `CreateData` gains `default_team_flow_id`; `stagesInOrder` extension sorts assignments by `stage_order` (unordered last) and `firstStage` reads the first stage — workflow logic keys on `stage_key`/`stage_order`, `stage_label` is display only, no flow/stage/team id or key is hardcoded anywhere. `lib/features/connection_requests/presentation/create_request_screen.dart` — `_buildForm` applies the backend default post-frame (same pattern as the customer-type fallback): only when nothing is selected yet and the default id is in this scope's list; if the current selection is not in the fresh list (sub-branch changed scope) it is replaced by the new scope's default or cleared — a manual pick that is still in the list is never overridden. Empty `team_flows` now renders a note under the "Team flow" label instead of hiding the section. The repository is unchanged: `team_flow_id` was already sent when non-null (`create_request_repository.dart:196`), so the pre-selected default is submitted and an unselected flow is omitted. **Generated files:** `create_data.freezed.dart` / `create_data.g.dart` were regenerated by build_runner on this VM (NOT hand-edited) — see the build_runner note below. **Tests:** new `test/connection_requests/create_request_team_flow_test.dart` (10: live-shape parsing incl. out-of-order stages + `stagesInOrder`, empty-list parsing, toJson round-trip, default pre-selected, no pre-selection for an unknown default id, no pre-selection with no default, empty-flows note, submit sends `team_flow_id` for the pre-selected default, submit omits it with no flow, sub-branch change re-applies the new scope's default). **Phone check still needed:** New Request as Umair must show "Cent-Tech Support" pre-selected; as the survey account it must show the pending-assignment note.
- **Build_runner note (2026-11-25, READ BEFORE PUSHING):** the first filtered `build_runner` run regenerated `create_data.freezed.dart` but left `create_data.g.dart` stale (0 outputs — stale asset graph), and deleting `.dart_tool/build` to clear it made build_runner DELETE all 36 generated files (18 `.freezed.dart` + 18 `.g.dart`) before writing 0 outputs. A full unfiltered rebuild then regenerated all 54 outputs correctly. Every regenerated file was verified byte-for-byte against the remote tip `5487b556` via blob-SHA comparison (all 57 files in `lib/models/`): the ONLY differences are the three intended `create_data.*` files — plus one line in `connection_request.g.dart`, where the fresh regen dropped the hand-edit from the D-batch (`'item_requests': instance.itemRequests?.map((e) => e.toJson()).toList()` → plain `instance.itemRequests`). That hand-edit was RESTORED verbatim, so `connection_request.g.dart` is byte-identical to remote again (SHA `b353a708…`). The hand-edit is NOT what the generator emits (no `explicitToJson` on the class, and nothing in the app calls `ConnectionRequest.toJson()`), so it will be dropped again on every regen — it must be re-applied after each `build_runner` run, or the team must decide to drop it deliberately / add `explicitToJson: true`. **PC must run `flutter pub run build_runner build` and confirm identical regen for `create_data.*`; any diff beyond version/header noise must be reported, not committed.**

---

## Verified passing (no defect)

- Scanner bounce fix holds (employee session seeded → scanner link reaches the form, back link works).
- Missing `account_type` → employee fallback; non-employee `account_type` refused with nothing saved; wrong-password / offline login.
- Scanner/employee session isolation both directions; scanner restore 401-clears / offline-keeps-identity.
- Sub-branch resolution (centralized / scoped / stale / empty).
- 10 MB guard incl. exactly-10 MB boundary, MIME rejection, draft survives failed submit, 201 success view.
- Plural/singular `allowed_actions` + authorize visibility incl. wrong status; Huawei/VSOL gating; discovery failure keeps cached list.
- Authorize shapes 1+2, gemport default 1, 3 s polling pending→running→succeeded with `ont_id`, failed-job retry, double-submit blocked, offline mid-poll, 5-min cap, 201-without-job-id.
- Token never logged (LogInterceptor headers off); ISP 360 branding on both login screens (grep-verified: no `Malik Fiber` / `malikfiber` on either login screen).

## Incidental observations (not counted as defects)

- Scanner login accepts a missing `account_type` (known judgement call — needs Haider's confirm; test pins the behaviour).
- PDF ID cards rejected by design per Haider, vs guide §4 listing PDF.
- `WaitingOnu` has no `error_message` field (failed rows show `authorization_reason` only).
- `LoginResponse.fromJson` throws a raw `TypeError` (not `ApiException`) when the backend omits `user.email` (`AuthUser.email` is required, unlike `Employee.email`) — malformed payloads surface as generic "Something went wrong".
- Survey detail allows route planning when `actions` is empty (`canPlanRoute = actions.isEmpty || canCompleteSurvey`).

## Could not test

- No live server, real OLT, or real credentials used. Whether `POST /login` returns `account_type` live, and any 404 on the new endpoints, remain unverified — **backend developer / Haider phone pass**.
- Installation-detail authorize visibility proven at model + rule level only, not by pumping the real detail screen (heavy map/provider harness); back-button-mid-poll proven at controller level, not widget level.
- One flake note: the scanner-link widget test once timed out under parallel load (pump budget) but passes in isolation and in the full-dir run.

---

## Scanning restoration assessment (2026-11-23)

**Status:** Scanner login restored (Phase A, plain session home, no scan UI). Real scanning is NOT restorable from surviving code alone — the old flow's wiring (providers, routes, list screen, network layer) never existed in any retrievable commit.

**Correction (Haider, 2026-11-23 ~16:29 PKT):** "Pehlay scanner login ho rha tha, matlab jo existing endpoints han us say hi scanner login karta tha." Scanner LOGIN used ONLY the existing endpoints (the same `POST /api/mobile/login` + `GET /me` that Phase A implements) — **scanner login is NOT gated on any backend documentation.** The open question is only the DEVICE-SCAN part (looking up / saving devices after login). The endpoint audit below was re-done against the surviving old code at main `173d911` (fetched 2026-11-23) and now separates "operation existed (surviving call site) but path undocumented" from "docstring-only, no surviving caller".

**Retrieval note:** the remote branch `backup/pre-midnight-ops-20261020` (commits f286dff / 581de6c) no longer resolves via the GitHub API — `get_file_contents` and `list_commits` both 404 on that ref, and the tool rejects raw SHAs. This assessment is therefore based on main `173d911`, verified byte-identical to remote main (`lib/models/device_scan.dart` blob SHA `80751980c3b5d62d5883944fcf37eefed3b4867f`). If the backup branch held a working `scanner_providers.dart`, it is unrecoverable from the remote now.

### 1. What the old flow did end-to-end (from surviving code only)

Entry: staff login had a "Device scanner? Sign in here" link to `Routes.scannerLogin` — **that route never existed at HEAD, so the link was dead**. Scanner login (email + password) was supposed to POST to a scanner-only endpoint and restore silently via `GET /me`, then go to `Routes.scannerHome` — **that route also never existed, and there was never a scanner home screen**. After login the flow was supposed to show an **untracked-devices list** (devices with `status == 'untracked'`) — **no such screen, route, or provider ever existed in the repo**. Tapping a row opened `AddDeviceDetailsScreen` (route `extra` = `ScannedDevice`); it was scan-only by product rule (no text fields): "Scan serial + MAC" opened one camera session (`DeviceScanBothDialog`) classifying each code on the spot — MAC-like fills the MAC slot, serial-like fills the serial slot, both filled auto-closes; or "Scan Serial" / "Scan MAC" opened `DeviceScanDialog` for one code. Scanned MACs were normalized to canonical `AA:BB:CC:DD:EE:FF` (`normalizeMacAddress`, handles `MAC:` prefixes, dash/colon/bare-12-hex forms). Save was enabled once ≥1 identifier was present and sent **only changed fields** (never `status`, never `""`); on success the server message was shown verbatim, the untracked list was invalidated, and the screen popped. Error handling: save 403/404 → drop the stale row, refresh, pop; save 422 duplicate (`"already been taken"` + mac/serial wording match) → inline error plus a "Show existing device" action that ran a lookup and showed the existing device in a dialog. The camera dialogs were also *described* as used from the complete-installation form to capture the ONU/ONT MAC — **no such caller exists at HEAD** (`complete_installation_screen.dart` contains no scan call); their only surviving caller was `AddDeviceDetailsScreen`.

**What actually survived as real, working code:** the two camera dialogs (`DeviceScanDialog`, `DeviceScanBothDialog`), the classifiers/normalizers (`isMacAddress`, `normalizeMacAddress`, `isSerialNumber`, `ScannedIdentifiers`), the save helpers (`changedDeviceFields` with MAC-separator-insensitive comparison, `hasIdentifier`), and the lenient models in `lib/models/device_scan.dart`. **What did not survive (or never existed):** everything that would have made it run — `scanner_providers.dart` (imported by both old screens, zero hits in `git log --all`), the scanner network/repository (`restoreSession`, `login`, `updateDevice(id, body)`, `lookup(code)`, `untrackedDevicesProvider`), the scanner routes, the scanner home, and the untracked list.

**Headline:** Haider's "it worked before the redesign" cannot be confirmed from any surviving code — either it worked from a PC-only state that was never pushed (possibly the now-deleted backup branch), or from an earlier build. This does not disprove his memory; it means no surviving code proves the flow end-to-end.

### 2. Endpoint table (base `https://184-164-137-101.sslip.io/api/mobile`)

Every path below comes from a docstring comment or a method name in the surviving code — **no HTTP call site for any device-scan endpoint survives**, so method + path + payload are as-claimed, not as-verified. Nothing here is in the ISPFINAL guide or in `Endpoints` (which has no device-scan paths at all).

| # | Method + path (as claimed) | Payload / response (as written in old code) | Confidence |
|---|---|---|---|
| 1 | `POST /login` (unified; docstring also names `POST /device-scan/login`) | Req: `{email, password}` (+ device_name). Resp: `{message, account_type, token, expires_at, account: {id, name, email, phone, is_active, organization_id, company_id, branch_id, sub_branch_id, warehouse_id}, warehouses: [{id, name, location}]}`; `account_type == 'scanner'` selects the scanner branch | **RESOLVED (Haider, 2026-11-23): scanner login used the existing endpoints — the unified `POST /login` is the endpoint. The `POST /device-scan/login` alternative is docstring-only and NOT needed. Already implemented in Phase A.** |
| 2 | `GET /me` | Resp: session/account (shape not specified in old code) | MEDIUM — restore pattern matches new code, but old response parsing is lost with the providers file. |
| 3 | `GET /devices` | Resp: `{devices: [{id, device_code, serial_number, mac_address, status, condition, notes, item: {id, name, sku}, warehouse: {id, name, location}, customer: {name}, assigned_at}], count}`; "capped server-side (no pagination)" | **UNKNOWN — docstring-only.** No surviving caller at all (the `untrackedDevicesProvider` the screens invalidate is itself lost). Whether the list endpoint exists, and whether it filters server-side or client-side, is unverified. |
| 4 | `GET /items` | Resp: items `[{id, name, sku}]`; "picker is populated ONLY from this call — ids are never invented" | **UNKNOWN — docstring-only.** No picker UI exists in any surviving screen, so no surviving caller; possibly belonged to a register flow that was never built. |
| 5 | `GET …/lookup?code=` (prefix missing in the docstring) | Req: `code` = serial or MAC. Resp: `{found, code, message, device}`; a MISS is still HTTP 200 — callers must branch on `found`, never the status code | **EXISTED but path undocumented.** The call site survives (`AddDeviceDetailsScreen` calls `scannerRepositoryProvider.lookup(code)`), so the operation existed on the backend — but the repository implementation is lost, so the full path is unknown (presumably `/device-scan/lookup?code=`, unverified). |
| 6 | `PUT /devices/{id}` (inferred; model comment says "the PUT/POST body", "register (201) and update (200)") | Req: **only changed fields** from `{serial_number, mac_address, device_code, condition, notes}`; `status` never sent; `""` never sent; MAC separator-only changes not sent. Resp: `{message, device}` (201 register / 200 update); message worded for verbatim display | **EXISTED but path/method undocumented.** The call site survives (`AddDeviceDetailsScreen._save()` calls `scannerRepositoryProvider.updateDevice(id, body)`), so the update operation existed — but the repository implementation is lost, so `PUT /devices/{id}` is the natural reading, not a verified fact. No register (`POST`) call site survives anywhere. |

Also note an internal contradiction in the old code: the `device_scan.dart` header says "scanned values are stored as-given (trimmed only) — no case conversion, no MAC reformatting", but `AddDeviceDetailsScreen._scan()` actually calls `normalizeMacAddress()` and the `173d911` commit message records a "scanner save bug fix (MAC format normalize…)". The screen's behavior (normalize to `AA:BB:CC:DD:EE:FF`) is what ran; the docstring rule is stale.

### 3. Porting plan (onto the new theme tokens + new scanner session)

**Dependencies — one addition, no other new deps.**
- `mobile_scanner: ^7.5.0` (latest on pub.dev, 2026-11-01). Verified floor: 7.x requires Flutter ≥ 3.29.0 (7.0.0 changelog), satisfied by Flutter 3.35.2 / Dart 3.9.0 and by the app's `sdk: ^3.9.2`. **Not verified:** the exact Dart SDK range of 7.5.0 from a primary source — `flutter pub get` on the PC must confirm resolution; fallback pin `^7.2.0` / `^7.3.0` if it fails. Old dialog code uses `MobileScannerController(formats: …)`, `MobileScanner(controller:, onDetect:, errorBuilder:)`, `BarcodeCapture` / `barcode.rawValue` — all still current in the 7.x API docs, so no API migration is expected.
- Android: add `<uses-permission android:name="android.permission.CAMERA"/>` to `android/app/src/main/AndroidManifest.xml` (currently only `RECORD_AUDIO` + `ACCESS_FINE_LOCATION` are declared). No Gradle change: Flutter 3.35 defaults are minSdk 24 (≥ mobile_scanner 7.x's 23) and compileSdk 35 (≥ 34). iOS: `NSCameraUsageDescription` already present in `ios/Runner/Info.plist`. No `permission_handler` needed — denial is already handled by the dialogs' `errorBuilder` ("Camera unavailable. Type the MAC address manually instead.").
- The new scanner session is reused as-is: `POST /login` + `account_type` gate, `scanner.*` token keys, `GET /me` restore, `scannerSessionProvider`. (Haider confirmed 2026-11-23: scanner login used the existing endpoints — do NOT add a separate `POST /device-scan/login`.)

**Reusable verbatim (pure Dart, zero theme deps):** `isMacAddress`, `normalizeMacAddress`, `isSerialNumber`, `ScannedIdentifiers`, `changedDeviceFields` (+ `_sameMacHex`), `hasIdentifier`, and the models `ScannedDevice`, `DeviceItem`, `LookupResult`, `DeviceSaveResult`, `DevicesPage`, `ScannerWarehouse`, `ScannerAccount`. (`ScannerLogin` is superseded by the new freezed `LoginResponse` — its only unique field is `warehouses`, which no surviving UI ever used.)

**Must be written fresh (never existed):** `lib/features/device_scan/data/scanner_network.dart` — extend the existing `ScannerNetwork` seam with `lookup`, `getDevices`, `updateDevice` (and `registerDevice` only if the backend documents it); `ScannerRepository` methods for the same; `scanner_providers.dart` — rewrite fresh in the new §0 pattern (`ScannerAuthController` already exists; add `untrackedDevicesProvider` + an add-details controller); the **untracked-devices list screen** (new — list from `GET /devices`, filter `untracked`, tap → details); **scanner home** (extend the current plain session screen: account card + untracked list or a "Scan devices" entry — do not keep it as a dead-end screen).

**Must be rewritten (exists, but on deleted theme/primitives):** `DeviceScanDialog` + `DeviceScanBothDialog` — re-theme only (hardcoded black fullscreen, `BorderRadius.zero`, white bottom card, `IBM Plex Mono` slot values → `FieldOpsDesignTokens` + theme `colorScheme`; keep the classification logic untouched). `AddDeviceDetailsScreen` — re-theme + rewire: it imports deleted `field_ops_colors.dart` and deleted `FieldOpsCard`; `BrandedHeader`, `SectionCard`, `StatusBadge`, `InfoRow` survive in the new tree (modified — re-check their APIs at port time). Keep its scan-only product rule (no text fields), its `scanHandler` test seam, and its 403/404 + 422-duplicate handling.

**Files to write / rewrite (summary):** write — `scanner_network.dart` (extend), `scanner_repository.dart` (extend), `scanner_providers.dart` (fresh), untracked-list screen (new), `lib/models/device_scan.dart` (restore, minus `ScannerLogin`); rewrite — `device_scan_screen.dart` dialogs (re-theme), `add_device_details_screen.dart` (re-theme + rewire), `scanner_home_screen.dart` (extend), `pubspec.yaml` (+ `mobile_scanner`), `AndroidManifest.xml` (+ CAMERA), `app_router.dart` (+ list/details routes), `Endpoints` (+ device-scan paths once documented). Tests: model `fromJson` tests from real backend payloads, `changedDeviceFields` unit tests (incl. MAC-separator no-op), classifier tests (`isMacAddress`/`isSerialNumber` incl. bare-12-hex-is-MAC rule), repository tests with a fake network, token-separation tests (scanner vs employee).

**Effort estimate (app-side only, after backend docs exist):**
- Phase 1 — deps + permissions + re-themed dialogs + restored pure helpers/models: **S (~½ day)**.
- Phase 2 — network/repository/providers + endpoint constants + model tests: **S (~½ day)**.
- Phase 3 — untracked list + scanner home + re-themed add-details + routing: **M (~1–1.5 days)**.
- Phase 4 — tests + phone verification against the real server (login as scanner, scan a real ONU label, save, duplicate path, 403/404 path): **M (~1 day + Haider's phone rounds)**.
- Total app-side **~3–4 days** of focused work. **Gating, not counted above:** backend confirmation of the device-scan operations only — the exact paths for `lookup`, `updateDevice`, `GET /devices`, `GET /items` (owner: the backend developer — Haider works on app only). Scanner login is NOT gated (existing `POST /login`, Haider-confirmed). Without the device-scan paths the port would be guessing, which is how the old flow ended up with a docstring/backend mismatch already.

### 4. Genuinely unknown (do not guess these)

1. **The backup branch is gone** — whether f286dff / 581de6c contained a working `scanner_providers.dart`, routes, or list screen cannot be verified anywhere now.
2. **Login endpoint — RESOLVED (Haider, 2026-11-23):** scanner login used the existing endpoints — unified `POST /login` (+ `GET /me` restore), already implemented in Phase A. The `POST /device-scan/login` alternative in the old model docstring is not needed and must not be built. The only backend question left is the device-scan operations (rows 3–6 above).
3. **Every device-scan path/method**: no HTTP call site survives; `GET /devices`, `GET /items`, `…/lookup?code=`, `PUT /devices/{id}` are docstring/method-name inferences. The `/device-scan/` prefix itself is assumed — the model header says "`/device-scan/…` on the main host", which could equally be under `/api/mobile` or at host root.
4. **Whether `GET /devices` is filtered server-side** (query param?) or client-side (`isUntracked`), and what "capped server-side" caps at.
5. **Whether `GET /items` was ever called by any UI** (no picker survives) and whether a register (`POST`) flow existed at all.
6. **What `warehouses` in the old login response was for** — no surviving screen used it; possibly a warehouse picker that was never built.
7. **Duplicate-error wording contract**: the 422 handling string-matches `"already been taken"` + `mac`/`serial` in the backend message — exact backend wording unverified against the live server.
8. **mobile_scanner 7.5.0's exact Dart SDK range** — resolution must be proven by `flutter pub get` on the PC.
9. **Whether scanning ever worked end-to-end on a phone from this codebase** — no surviving code could compile the flow (missing providers + routes + `mobile_scanner`), so Haider's pre-redesign working state, if real, came from a build whose source is not in any retrievable commit.
