# Onlinecer ISP App — APP_BRIEF (Rule 10 research)

**App:** haiider820/Onlinecer_isp_app — "Malik Fiber", ISP field-operations app for
technicians: survey, installation, fiber splicing, verification, closing,
inventory, tickets, internal tasks.
**Date:** 2026-11-22. **Status:** research only — no code changed, no push.
**Direction change:** the old Midnight Ops dark look was REJECTED by Haider on
2026-11-22. The new design must come from `haider-design-kit/DESIGN.md`
Rules 1–14, not from Midnight Ops. Colour is chosen from the 9 Instagram
palettes (@uiuxaadi, `haider-design-kit/COLOR-PALETTES.md`) — see §4.
**Users:** field technicians, often outdoors in bright sunlight, one-handed,
low tech literacy. Outdoor legibility and big touch targets matter more than
pretty gradients. Dark is the default (kit Rule 4); light must follow the
same rules.

**Honesty note on sources:** the app descriptions below come from the apps'
official pages and 2026 comparison/review roundups (links given). Play Store
screenshots were not individually inspected for Jobber / Housecall Pro /
ServiceTitan theme details, so theme/typography notes for those three are
marked as "from descriptions" and must be re-checked against store screenshots
before any pixel is copied. Nothing here invents ratings, user counts, or
claims the apps do not make themselves.

---

## 1. Apps researched

### (a) AdminFiber — fiber-technician field app (closest direct analogue)
- Link: https://adminfiber.com/features/field-app
- Home first: **Today screen** — the current job on top with a timer, the
  rest of the day below it, sorted by time. One job = one record
  (client, crew, materials, status, photos, completion form).
- Tabs / screens: Today, job detail / completion form, Time (hours, time
  off), work orders, scheduling board, materials/stock.
- Job flow: Today → tap job → clock in on arrival (status becomes On site,
  position saved once) → set status (En route / On site / In progress /
  Blocked / Follow-up) → completion form in steps (Result → Details →
  Materials → Photos → Sign) → Submit. Clock-out is automatic on submit.
  Roughly: open job (1 tap) → clock in (1) → status updates (1 each) →
  stepped form (5 steps) → submit (1).
- Theme: light, plain, high-contrast work tool on the official page; no
  dark-mode claim made. Typography is plain sans, sentence case, big
  readable labels. No mascot on the work screens (a fiber mascot appears
  only in marketing images).
- Motion: none claimed on work screens; the "moment" is the timer and the
  "1 required step left" counter on the completion form.
- Reviews / what users like: no public store rating was cited on the page.
  The page's own selling points are: each person sees only their own jobs,
  the app speaks their language, drafts survive a dropped connection.
- What to learn: **Today-first, one current job hero + timer; stepped
  completion (not a wall of fields); materials must balance
  (used + returned + damaged = handed over); draft saved on the phone.**

### (b) Dispatch by PacketProspector — field-service app for fiber ISP technicians
- Link: https://www.packetprospector.com/dispatch
- Status: **Coming Soon · iOS** at time of research (not yet on the App
  Store) — treat its claims as a product page, not a shipped app.
- Home first: **Today's job list** — installations, surveys, locate
  tickets sorted by ETA, one tap to navigate to the customer's address.
- Tabs / screens: Today's jobs, job record (install docs, photos, QR
  scans of modems/ONTs/drop labels), site surveys, OneCall/811 locate
  replies, customer attestation (signature), equipment provisioning.
- Job flow: next job surfaces automatically → navigate (1 tap) → capture
  on site (photos / scan serials, validated live against provisioning) →
  customer signs on screen → office is updated the moment work is done.
  "No paperwork, no end-of-day data entry."
- Theme: explicitly **"Designed for outside, on a phone, often offline"**
  — high-contrast UI, one-handed use, readability in direct sunlight.
  Face ID sign-in (no password typing between installs). No colour
  scheme is stated on the page; the page itself is dark/purple marketing.
- Motion: none claimed; the design emphasis is state, not animation.
- Reviews: none — unreleased.
- What to learn: **the field brief in one line — "parked truck, bright
  sun, one free hand"; offline-first sync; scan serials instead of typing
  them; validate ONT/modem serials live so a mis-cabled install is caught
  before the customer notices.**

### (c) Jobber — field-service management, small/mid-size home-service teams
- Link: https://www.getjobber.com/academy/best-field-service-management-software/
  and https://www.getjobber.com/academy/best-mobile-field-service-apps/
  (comparison pages); Play listing via
  https://www.appbrain.com/app/jobber-field-service-software/com.getjobber.jobber
- Home first (from descriptions): schedule / job list for the day; job
  checklist (job forms) on the mobile app; quoting → scheduling → job →
  invoicing → payment in one flow.
- Tabs / screens: Schedule, Jobs, Clients, Invoicing, (desktop: quotes,
  dispatch board, client hub). Mobile: a tech can schedule, add notes and
  photos, invoice and take payment without touching a desktop.
- Job flow: quote auto-converts to a job on approval → job appears on the
  schedule → tech opens it, works the checklist, adds photos/notes →
  invoice + payment from the phone. Few taps per step; drag-and-drop
  scheduling on desktop.
- Theme (from descriptions): **modern and clean, neutral colour palette,
  uncluttered**; green is Jobber's brand accent in its marketing. Light
  theme is the default in descriptions; no dark-mode claim was verified.
- Typography/icons: clean sans, simple icons, colour-coded appointments.
- Motion: not a selling point in any source found; motion lives in
  status/progress feedback, not decoration.
- Reviews — what users like (GetApp, 1,487 verified reviews, overall 4.6;
  FSM Advisor Android 4.6 from 479 ratings): easy to start even without
  technical knowledge, visually simple to find what is needed, saves time,
  reduces paperwork, invoicing/payment from the field. What they complain
  about: **no true offline mode** (the most repeated field complaint),
  app slowness / freezing mid-quote or invoice (one reviewer: "the app is
  constantly locking up… I have to kill the app, restart"), duplicate
  invoices on mobile, per-user pricing getting expensive, learning curve
  on payments setup.
- What to learn: **cleanest-in-category onboarding ("crews onboarded in
  a single afternoon" per one roundup); the whole job lifecycle on the
  phone; checklists with photos + signature as the on-site standard.**

### (d) Housecall Pro — consumer-focused home services, dispatch-heavy
- Link: https://www.g2.com/products/housecall-pro/reviews
  (G2, 4.3 from 211 reviews) and https://www.workyard.com/compare/housecall-pro-review
- Home first (from descriptions): dispatch board / schedule — "Dispatch
  in seconds and run every job from one screen"; drag-and-drop scheduling,
  live vehicle GPS, automatic "on my way" texts.
- Tabs / screens: Schedule/dispatch, Jobs, Estimates, Invoicing &
  payments, Customers, Marketing/review automation.
- Job flow: estimate → job → dispatch (drag-and-drop) → tech checks
  route, takes photos, charges and closes the job from the phone →
  automatic review request. "Get paid before you leave the driveway."
- Theme (from descriptions): bright, consumer-friendly light UI; blue is
  the brand colour in marketing. No dark-mode claim was verified.
- Typography/icons: friendly, rounded, plain-language labels.
- Motion: status updates ("on my way") and automation are the motion;
  no decorative animation is claimed.
- Reviews — what users like: powerful mobile app — technicians can check
  routes, take photos, charge and close jobs from the phone; easy to use
  and modify; estimates convert to jobs; "on my way" + GPS tracking.
  What they complain about: **no offline mode** (FSM Advisor), **no
  real-time location tracking** in some plans, add-ons stack up and get
  expensive as the team grows, slow photo uploads, limited inventory
  system, one reviewer wanted a map on the scheduling screen to group
  nearby jobs.
- What to learn: **one-screen dispatch; automatic customer texts
  ("on my way") so the tech does not have to message; review requests
  triggered automatically on close.**

### (e) ServiceTitan — enterprise field service (large fleets)
- Link: https://www.fsmadvisor.com/best/android-app and
  https://help.servicetitan.com/release-hub/docs/see-your-schedule-sooner-with-a-faster-more-reliable-field-mobile-app
- Home first: **Field Mobile App Home = Today's schedule** — jobs appear
  as soon as the minimum required information is ready (a 2026 redesign:
  previously the app waited until ALL job data downloaded, so jobs could
  disappear or show up hours into a shift with no explanation and no
  loading feedback).
- Tabs / screens: Home/schedule, job detail (deep job data, good/better/
  best in-home sales presentations), dispatch board, call tracking,
  forms, analytics.
- Job flow: schedule → open job → deep job data on the phone → present
  options in the home → complete, capture, invoice. More steps than
  Jobber by design — it is built for complex, multi-location work.
- Theme (from descriptions): dense, data-heavy, professional light UI.
  No dark-mode claim was verified.
- Typography/icons: dense tables and forms; status is shown with text +
  colour, not colour alone.
- Motion: loading/sync feedback is the motion — see §5 for its sync-icon
  pattern.
- Reviews — what users like (FSM Advisor Android 4.4): **offline mode
  included**, deep job data on the phone, in-home sales presentations.
  What they complain about: enterprise pricing (~$350/user/mo in one
  roundup) and 12-month contracts, **heavier learning curve**, heavier
  app than the small-business tools.
- What to learn: **never make the tech wait for all data before showing
  anything (show the job as soon as time + address + job number are
  ready); per-card sync state; in-app retry instead of "restart the app".**

---

## 2. Common patterns (present in 3+ apps — users expect these)

1. **Today-first home.** The day's jobs, in time/ETA order, with the
   current job on top — never a stats dashboard as the first thing a
   tech sees. (AdminFiber, Dispatch, Jobber, Housecall Pro, ServiceTitan.)
2. **One-tap Navigate / Call from the job card.** Every job row carries
   Navigate (maps) and Call; the tech never has to open the detail to
   reach the customer. (AdminFiber, Dispatch, Jobber, Housecall Pro.)
3. **Explicit job status, set by the tech, in plain words.** En route →
   On site → In progress → Done / Blocked / Follow-up. Status is a
   big, tappable state, not a small grey label. (All five.)
4. **Stepped completion, not a wall of fields.** Result → Details →
   Materials → Photos → Sign, with a "steps left" counter. Photos and
   signature are part of closing, not an afterthought. (AdminFiber,
   Dispatch, Jobber checklists.)
5. **Materials / inventory must balance.** Used + returned + damaged =
   handed over; serials scanned, not typed. (AdminFiber, Dispatch,
   AT&T Atlas case study — see note in §6.)
6. **Route order, nearest first.** The day is a route, not a list;
   a route link opens maps with the day's stops. (AdminFiber, Dispatch,
   Housecall Pro GPS.)
7. **Offline is a first-class state, not an error.** Work continues
   without signal; sync happens when connectivity returns; the app says
   so plainly. (AdminFiber drafts, Dispatch offline-first, ServiceTitan
   offline mode, Fieldwire — see §5.)
8. **Close the loop automatically.** Submit → office updated, customer
   texted ("on my way" / done), review requested — the tech does not do
   end-of-day data entry. (Dispatch, Housecall Pro, Jobber.)

---

## 3. The 9 Instagram palettes, judged for ISP field-ops

Contrast figures below are WCAG relative-luminance ratios computed from
the palette hexes (text colour on the palette's dark background). 4.5+
passes for normal text. "Primary" means the brightest usable
signal colour in the palette; "accent" means the last/warm colour.

| # | Palette | Verdict for this business |
|---|---------|---------------------------|
| 1 | Warm brown / cream `#1A120E #3A2418 #6B4A2E #A88462 #D5C4AE #4A4A46` | NO — brown reads coffee/food, not network/tech. Mid browns go muddy in sunlight; no bright signal colour for a primary CTA. |
| 2 | Deep purple / lavender `#0E0B1D #2A1E4D #5A3B8C #8B7CC7 #C9C2E3 #3A3A52` | NO — purple reads premium SaaS, not field/trust. The usable lavender `#8B7CC7` is 5.35:1 but the deep purple `#5A3B8C` fails at 2.25:1; no warm accent that survives sunlight. |
| 3 | Deep green / sage `#0F1F17 #1E3A2E #3E5A3F #6B7F67 #C7CBB8 #3D4337` | NO — sage `#6B7F67` FAILS at 3.95:1, mid green `#3E5A3F` fails at 2.23:1. Too muted/washed out in sunlight; and it is the FleetFlow green family — brand collision. |
| 4 | Navy / sky / orange `#0B132B #1C2541 #3A506B #5BC0DE #F4D6B0 #D97706` | **YES — recommended (see §4).** Deep navy = trust/network; sky `#5BC0DE` 8.79:1 on the dark bg; cream `#F4D6B0` 13.21:1; orange `#D97706` 5.77:1 on dark. |
| 5 | Slate / pink `#121212 #1F2937 #334155 #64748B #F1F5F9 #EC4899` | NO — pink `#EC4899` (5.31:1) is the wrong mood for field work; reads consumer/fashion and sits too close to HIGH-priority red to be a safe accent. |
| 6 | Teal / burnt orange `#0A0F14 #0F3D3E #2E6F73 #7FB3B8 #EADCC8 #C6601F` | NO (close second) — teal `#7FB3B8` 8.29:1 and cream 14.27:1 are good, burnt orange `#C6601F` 4.67:1 just passes, BUT teal + orange is the FleetFlow teal/amber family — brand collision with Haider's other app. |
| 7 | Purple / pink-red `#1A0F2E #3B1B4F #7A2E6F #D6598F #F4D7D4 #FF6B6B` | NO — pink `#D6598F` 4.94:1 is borderline, and the red `#FF6B6B` (6.57:1) as an accent is dangerous: it collides with error / HIGH-priority red, so a user cannot tell "accent" from "fault". |
| 8 | Indigo / violet / amber `#1A1A1F #2D2B55 #6A5ACD #A678B9 #F0D9B5 #F4A62A` | NO — violet `#A678B9` 4.96:1 is borderline, amber `#F4A62A` 8.53:1 is good, but indigo/violet reads consumer-premium, not outdoor field work; violet also collides with the Review-status violet. |
| 9 | Dark green / gold `#0B0F0D #1F2A1F #3E5A3F #8CA98C #D9C7A3 #B08D57` | NO — contrast passes (sage `#8CA98C` 7.51:1, cream 11.62:1, gold `#B08D57` 6.24:1) but green + gold is the TaxMate emerald/gold family — brand collision, and gold is too soft as a primary CTA in sunlight. |

---

## 4. RECOMMENDED palette — exactly one: #4 Navy / sky / orange

Chosen from the 9 Instagram palettes. It is the only one that is (a) a
trust/network colour story for an ISP, (b) high-contrast in sunlight in
both modes, and (c) free of brand collisions with FleetFlow (teal/amber),
TaxMate (emerald/gold) and Aquapura (sky/coral — note: the sky here is a
signal blue, not Aquapura's sky/coral pair, and the app keeps its own
Malik Fiber identity).

| Role | Dark (default) | Light | Contrast note |
|---|---|---|---|
| Background | `#0B132B` deep navy | `#F4F6FA` cloud | — |
| Surface | `#1C2541` navy surface | `#FFFFFF` | Dark text `#ECF1FB` on surface 13.34:1 |
| Surface high | `#27314A` raised navy | `#EEF3FE` tint | — |
| Border (1px) | `#3A506B` | `#DCE3EE` | Hairline only, never a colour carrier |
| Text | `#ECF1FB` | `#10182B` | 16.23:1 dark / 16.34:1 light |
| Muted text | `#94A3B8` | `#5C6880` | 7.17:1 dark / 5.18:1 light |
| Primary | `#5BC0DE` sky (text/icon on dark; filled button uses dark-navy `#0B132B` ink — white on sky is only 2.09:1, so NEVER white text on sky) | `#1D4ED8` cobalt (repo FIBER BLUE — kept for continuity; filled button with white ink 6.70:1) | Sky on dark bg 8.79:1; cobalt on light bg 6.19:1 |
| Accent | `#D97706` orange (text/icon on dark 5.77:1; filled accent uses dark-navy ink, 5.55:1) | `#B45309` darker orange for text on light (4.64:1); filled accent `#D97706` with dark ink, or `#B45309` fill with white ink (5.02:1) | Orange `#D97706` as TEXT on light bg is only 2.94:1 — never use it as light-mode text. White on `#D97706` is only 3.19:1 — never white text on orange. |
| Status (kit Rule 4, unchanged) | success `#4ADE80`, warning `#FBBF24`, danger `#FB7185` — icon + word, never colour alone | same | On dark bg: 10.55 / 11.01 / (danger checked at implementation) |

**Why this beats the others for ISP field-ops:**
1. **Sunlight legibility.** The two colours that carry meaning — sky
   8.79:1 and cream 13.21:1 on navy — are the brightest in the set; the
   primary CTA stays readable outdoors where the muted greens and
   purples wash out.
2. **Trust + network story.** Deep navy + sky blue is the visual
   language of networks and connectivity (and it keeps the repo
   DESIGN.md's FIBER BLUE cobalt alive in light mode instead of
   throwing the original spec away).
3. **Accent with a job.** Orange is used for exactly one thing — the
   urgent / next-action accent (e.g. the sticky primary on the current
   job, the "1 step left" counter) — and it is kept away from status
   colours, so orange never means "warning" and red never means "accent".
4. **No brand collision.** It is not FleetFlow teal, not TaxMate
   emerald/gold, not Aquapura sky/coral, and not CloudsBin cyan/violet.

**Kit compliance:** 1 primary (sky/cobalt) + 1 accent (orange), Plus
Jakarta Sans, spacing 4/8/12/16/24/32/48, surfaces + 1px hairline for
depth (no shadows/gradients on work screens), body ≥ 14sp, dark default.

---

## 5. State management — what the researched apps do that users feel (addendum)

Haider's addendum: state management and everything must be done properly —
users must not face problems. This section is the pattern list the redesign
must follow so a new look never breaks state. Sources: ServiceTitan Field
Mobile home-screen redesign (2026), Fieldwire offline docs, AdminFiber
dead-zone behaviour, and offline-first field-service architecture write-ups
(DEV "Offline-First Field Service PWAs", AppVerticals, Akshara Flutter
offline-first with sqflite, Actiknow).

### How the researched apps handle state users feel

- **ServiceTitan (Home sync icons + retry):** jobs appear as soon as the
  minimum info (job number, time window, address) is ready — the app
  never waits for ALL data. Each job card carries a sync icon: checkmark
  = fully loaded, download arrow = still syncing. A "Refresh in progress"
  indicator sits under "Today's schedule" during background downloads.
  If a card fails to load, a warning chip on the card + a yellow global
  banner let the tech retry ONE job or ALL jobs with one tap — no app
  restart, no call to the office. Before this redesign, jobs could
  disappear or arrive hours into a shift with no explanation.
- **Fieldwire (offline = normal):** mobile apps work fully offline —
  downloaded project content is viewable, new content is added locally
  and auto-synced when connectivity returns. Login needs a connection
  (stated plainly in the docs). Sync conflicts need manual intervention
  sometimes (a known complaint); logging out on Android while unsynced
  content exists LOSES it — the docs warn against it explicitly.
- **AdminFiber (drafts survive dead zones):** fiber work happens in
  cellars/stairwells with no signal. Form answers, material quantities
  and the signer's name are saved on the phone as they are typed; only
  photo/signature upload and final submit need a connection. Without
  one, the app says "draft is saved, reconnect to submit" — it never
  pretends the job is submitted.
- **Dispatch by PacketProspector (offline-first):** job updates save
  locally and upload the moment connectivity returns; high-contrast UI
  for sunlight; Face ID so no password is typed between installs.
- **Offline-first architecture pattern (DEV / AppVerticals / Akshara /
  Actiknow):** the device is the first place data is written, the server
  is second. Every action becomes an outbox row BEFORE any network call:
  client-generated UUID + base version + payload + attempts + created
  time. The server must accept each UUID once (idempotent — retries
  cannot duplicate a job/invoice), store photos separately, and reject
  stale edits with a version/ETag check (412 = conflict). In Flutter
  this is a local SQLite (`sqflite`) table + a `sync_queue` table drained
  by a background process when the network returns; the UI never awaits
  a network response. Token refresh must happen BEFORE draining the
  queue after hours offline, or the whole queue fails on auth.

### Patterns to ADOPT (redesign must keep / build these)

1. **Local-first writes.** Every tap that changes state (status, notes,
   materials, photos, signature) writes to the device first and shows
   the new state immediately. The network is a sync step, never a gate
   for the UI. Never block a button on a network call.
2. **Visible sync state, per card + global.** Copy ServiceTitan: a sync
   icon on each job/ticket card (synced / syncing / failed / pending
   count) and one global "Syncing… / All synced / N pending" line. A
   user must always be able to answer "did my work reach the office?"
   without guessing.
3. **Idempotent submit + version check.** Each submit carries a
   client-generated UUID so a retry cannot create a duplicate job,
   invoice or completion; each edit carries the base version so a stale
   copy cannot silently overwrite a supervisor's correction. A conflict
   is shown to the user (keep mine / take theirs), never resolved
   silently.
4. **Never silently lose work.** Drafts (survey notes, install form,
   photos) are saved on the phone as typed. If submit fails, the draft
   stays, the failure is named ("No connection — draft saved"), and
   retry is one tap. Logging out with pending changes must warn and
   must not delete the queue (Fieldwire's Android logout trap).
5. **Show partial data, don't hide it.** If a job's detail is still
   downloading, show the job number + time + address and let the tech
   proceed; load the rest in the background. Never hide a job because
   one linked record is missing.
6. **Loading = skeleton in the shape of the screen, error = one clear
   retry, empty = a moment not a blank page** (kit Rules 5/8). No bare
   spinner on a dead screen; no "something went wrong" without a retry
   button; an empty queue gets a line + the one useful action.
7. **Stale data must be labelled.** Reference data (prices, rates,
   checklists, customer history) carries a "last updated" time; if it
   is older than the day's sync, the screen says so. A job completed
   against two-week-old prices is a silent failure (AppVerticals).
8. **State survives the redesign.** Theme toggle, language, login
   session and any existing persisted keys keep their keys and meaning;
   a reskin must not rename a storage key, reset a queue, or change a
   status value. Verify the queue + a status change end-to-end after
   every visual change, not just the pixels.
9. **Photos are separate from the form.** Upload photos as their own
   queued items with their own retry; a slow photo upload must never
   block a status update or a submit.

### What NOT to adopt

- Jobber / Housecall Pro's **no-offline-mode** gap — the single most
  repeated field complaint in their reviews. Do not copy it.
- ServiceTitan's old behaviour: waiting for all data before showing
  anything, no loading feedback, "restart the app" as the only recovery.
- Fieldwire's silent conflict / logout-loses-unsynced-data traps.
- Silent partial saves (half a form survived, half did not, and the
  app said "saved") — the fastest way to lose a technician's trust.

---

## 6. What to adopt / what NOT to adopt (design)

**Adopt:**
- Today-first home: current job hero (job no. + timer + status) + rest
  of the day below, in route order. (AdminFiber, Dispatch, ServiceTitan.)
- One-tap Navigate / Call / WhatsApp on every job card; status as a
  big tappable state, not a small label. (All five.)
- Stepped completion with a "steps left" counter; photos + signature
  inside closing. (AdminFiber, Dispatch.)
- Materials balance (used + returned + damaged = handed over); scan
  ONT/modem serials instead of typing. (AdminFiber, Dispatch, and the
  AT&T Atlas case study: technicians scanning/reporting equipment on
  the spot raised reporting by 37% — source:
  https://www.simranc.com/atlas-inventory-management — the lesson is
  "automate and pre-populate; show only the actions for this job stage".)
- Route order, nearest first; a route link for the day. (AdminFiber.)
- Kit motion, and only kit motion: button press ~100 ms, screen
  transition 200–300 ms, list stagger 40–60 ms once, count-up hero
  numbers, skeleton loading, success as a real moment. (DESIGN.md
  Rules 5/8.)
- Rule 14 login: one title + one CTA, full picture/scene background
  (fiber/network scene for this app), frosted card, living logo
  top-left, no fade/grow on success — straight to dashboard.

**Deliberately NOT adopt:**
- Midnight Ops (rejected 2026-11-22) — no near-black cyan-on-black
  console look, no glow-everywhere.
- Jobber/Housecall Pro marketing, quotes/invoicing depth, or their
  no-offline gap — Onlinecer is a technician work tool, not a
  back-office sales app.
- ServiceTitan's density and enterprise weight — no dense tables, no
  12-month-contract complexity in the UI, no "good/better/best" sales
  presentations.
- Any other app's logo, mascot, exact layout, copy, or brand colours.
- Emoji icons, uppercase tracked eyebrows, gradient-everywhere,
  greeting headlines ("Welcome back"), tile grids duplicating tabs,
  demo-data labels in the UI. (Kit Rules 8/11.)
- A second filled button competing with the primary on any screen
  (Rule 3/12: one primary, bottom, full-width, sticky).

## 7. The app's ONE living thing (kit Rules 1 + 9)

**A fiber signal pulse — "Signal".** A thin fiber line with a pulse of
sky-blue light travelling along it. It is not a copy of TaxMate's coin,
Aquapura's droplet, or FleetFlow's F + route dot.
- Splash: the pulse travels along a fiber line as the Malik Fiber mark
  lands (under 2 s, then straight in).
- Success (install/survey/ticket closed): the pulse reaches the end of
  the line and the check appears — one real moment, not a loop.
- Idle: a slow, calm pulse dot on the login mark only (transform-only,
  no opacity fade on login per Rule 14).
- Work screens: NO living thing — the job is the hero (Rule 1). Only
  Rule 5 motion there (press, transition, stagger, count-up).
- Empty queue: the pulse waits at the start of the line + one line +
  one primary action (Rule 5 empty state).

## 8. Differentiation — one thing better / different

The researched apps are either generic (Jobber, Housecall Pro,
ServiceTitan — built for every trade) or unreleased / browser-only for
fiber (Dispatch, AdminFiber). Onlinecer's edge is **fiber-native +
field-honest**: the job record speaks fiber (OLT, FAT node, drop cable
length, ONT serial/lamps, splicing) in the same stepped flow as the
generic apps, AND the app is honest about state — per-card sync icons,
drafts that survive dead zones, and a retry that works without a restart.
No researched app combines fiber-native fields with that level of
visible sync honesty in a light, outdoor-legible, one-handed tool.

---

## Sources

- AdminFiber field app: https://adminfiber.com/features/field-app
- Dispatch by PacketProspector: https://www.packetprospector.com/dispatch
- Jobber best FSM 2026: https://www.getjobber.com/academy/best-field-service-management-software/
- Jobber mobile field-service apps: https://www.getjobber.com/academy/best-mobile-field-service-apps/
- Jobber Play listing: https://www.appbrain.com/app/jobber-field-service-software/com.getjobber.jobber
- Housecall Pro reviews (G2): https://www.g2.com/products/housecall-pro/reviews
- Housecall Pro review: https://www.workyard.com/compare/housecall-pro-review
- FSM Advisor best Android FSM apps 2026: https://www.fsmadvisor.com/best/android-app
- ServiceTitan Field Mobile home-screen reliability: https://help.servicetitan.com/release-hub/docs/see-your-schedule-sooner-with-a-faster-more-reliable-field-mobile-app
- Fieldwire offline Q&A: https://help.fieldwire.com/hc/en-us/articles/202631944-Q-A-Can-I-use-Fieldwire-while-offline
- Fieldwire Android sync troubleshooting: https://help.fieldwire.com/hc/en-us/articles/360000567483-How-to-troubleshoot-Sync-issues-on-an-Android-device
- AT&T Atlas inventory (technician UX case study): https://www.simranc.com/atlas-inventory-management
- Offline-first field-service PWAs (outbox/UUID/version): https://dev.to/muhammadalimughal/offline-first-field-service-pwas-sync-without-data-loss-5cp
- What breaks without signal: https://www.appverticals.com/blog/what-happens-inside-an-offline-field-service-app/
- Offline-first Flutter + sqflite sync queue: https://www.aksharatech.com/blog-posts/flutter-offline-first-field-service-app
- Offline-first architecture: https://developerlabs.actiknow.com/custom-app-development-company/offline-field-service-app-development/
- Kit: `~/workspace/haider-design-kit/DESIGN.md` (Rules 1–14)
- Palettes: `~/workspace/haider-design-kit/COLOR-PALETTES.md` (@uiuxaadi, 9 slides)
- Repo spec: `~/workspace/onlinecer-app/DESIGN.md` (FIBER BLUE)
