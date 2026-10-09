# Malik Fiber — Field App Design System ("FIBER BLUE")

**Product:** ISP field-operations mobile app for Malik Fiber technicians (Survey, Installation, Fiber Splicing, Verification, Closing, Inventory, Tickets, Internal Tasks).

**Who uses this:** Field technicians and layman operators — often outdoors, in bright sunlight, one-handed, with low tech literacy. This is a **simple work tool**, not a pro console: one screen does one specific job, details stay minimal, and every action is obvious at a glance.

**Design principles:**
1. **One screen, one job.** Never crowd a screen with details that belong elsewhere. Dashboard = stats only; identity lives in the profile; each queue shows its own work.
2. **Plain language.** Sentence case everywhere ('In Progress', never 'IN_PROGRESS'). No jargon, no shouting caps.
3. **One accent color.** A single cobalt blue marks every tappable/go/active moment. Status colors mean status only and never invite a tap.
4. **Outdoor-legible.** High contrast, bold type, minimum 48dp touch targets.
5. **Consistent, not creative-per-screen.** Every screen pulls from `field_ops_design_tokens.dart` / `FieldOpsColors`. No hardcoded hex, radius, or font size in screens.
6. **Real data only.** Never design UI around data the API doesn't send.

---

## 1. Color System — "FIBER BLUE"

Cloud-white surfaces carry the data, one confident cobalt blue carries every action, and crisp **1px borders** separate every box.

### Brand / Primary (chrome + action)
| Token | Hex | Usage |
|---|---|---|
| `primary` / `secondary` / `signal` | `#1D4ED8` (cobalt) | AppBar/sidebar-header chrome, primary CTA fill, active indicators — always with white ink on top |
| `onPrimary` / `onSecondary` / `onChassis` | `#FFFFFF` | Ink on cobalt |
| `primaryDark` | `#0A1B47` | Deepest brand navy — full-bleed hero canvases (login, splash) |
| `chassisRaised` | `#173FB5` | Raised chrome blocks, snackbars |
| `buttonPressed` | `#1740B8` | Pressed state of cobalt CTAs (a deeper cobalt, never grey) |
| `signalDeep` | `#1D4ED8` | Accent TEXT/ICONS on cloud (links, text buttons, focus rings) |
| `signalWash` / `secondaryContainer` | `#EEF3FE` / `#D9E4FD` | Focus fills / selected surfaces behind cobalt ink (`#123280`) |

### Neutrals (cloud surfaces)
| Token | Hex | Usage |
|---|---|---|
| `surface` | `#F4F6FA` | Page/scaffold background (calm cloud) |
| `surfaceContainerLowest` | `#FFFFFF` | Card backgrounds |
| `outline` / `cardBorder` | `#E3E8F1` / `#DCE3EE` | Crisp 1px hairline borders |
| `onSurface` | `#10182B` | Primary body text |
| `onSurfaceVariant` | `#5C6880` | Secondary/muted text, captions |

### Semantic (status & priority) — opaque tint + full-strength ink
| Token | Background / Foreground | Meaning |
|---|---|---|
| `pending` / `assigned` / OPEN ticket | `#FFF0D0` / `#7A4E00` (amber) | Awaiting action |
| `inProgress` | `#D5EDF5` / `#0B5C75` (blue-teal) | Actively being worked |
| `completed` / RESOLVED / CLOSED | `#D9F0E2` / `#0E6B41` (green) | Done / success |
| `review` | `#E8E1FB` / `#5730B8` (violet) | Needs human review |
| `cancelled` | `#E7E5DC` / `#575E55` (gray) | Terminal, inactive |
| HIGH priority | `#FBDDD7` / `#A62B1B` (red) | Fault red |
| MEDIUM priority | amber pair | — |
| LOW priority | neutral gray pair | — |
| `error` | `#B3261E` | Validation errors, destructive actions |

Dark mode keeps the same grammar on a blue-navy ladder: canvas `#0F1524`, cards `#161E31`, borders `#27314A`, text `#ECF1FB`, chrome `#0F1F4A`, signal `#60A5FA` (see `field_ops_colors.dart` `dark`).

**Rule:** every status/priority badge maps to exactly one token pair above via `StatusBadge` / `PriorityBadge` — never a hardcoded color per screen.

---

## 2. Typography

**Three bundled families** (`assets/fonts/`):
- **Archivo Black** — display only: app name on login/splash, boot percentage.
- **IBM Plex Sans** — workhorse: titles, body, buttons, form labels, badge labels.
- **IBM Plex Mono** — instrument data only: request numbers/IDs, counts, timestamps.

| Style | Family | Size | Weight | Usage |
|---|---|---|---|---|
| `displayLg` | Archivo Black | 32 | 900 | App name, boot % |
| `dataLg` | IBM Plex Mono | 28 | 600 | Hero readouts, big stats |
| `headlineLg` | Plex Sans | 24 | 700 | Screen titles |
| `headlineMd` | Plex Sans | 20 | 600 | Section headers, request numbers |
| `headlineSm` | Plex Sans | 18 | 600 | Card titles |
| `bodyLg` | Plex Sans | 16 | 500 | Primary content |
| `bodyMd` | Plex Sans | 14 | 400 | Secondary content |
| `bodySm` | Plex Sans | 12 | 400 | Captions, timestamps |
| `labelLg` | Plex Sans | 14 | 600 | Button text |
| `labelMd` | Plex Sans | 12 | 600 | Form labels |
| `labelSm` | Plex Sans | 11 | 700 | Tags/legends (sentence case, tracking 0.01) |
| `dataMd`/`dataSm` | IBM Plex Mono | 14/12 | 500 | IDs, inline values |

**Rules:**
- Status/priority labels are always sentence case ('In Progress'), never uppercase.
- Request numbers, IDs, counts stay mono. Never reintroduce Inter/system-default for app copy.

---

## 3. Spacing & Layout

**Base unit: 8pt grid.** `spaceSm` 8, `spaceMd` 16 (**standard screen side margin**), `spaceLg` 24, `spaceXl` 32.

### Radii
Rectangles, no rounded corners anywhere: every card, button, input, dialog,
chip and badge is a crisp square (`radius*` / `cardRadius` / `controlRadius`
are all 0). Only true circles (avatars, status dots) keep their shape.

### Touch targets
Minimum **48×48dp** for anything tappable.

### Borders
Every box — cards, inputs, dialogs, bars — carries a **1px** hairline border. Focus/error rings may be 2px (they signal state, not structure).

### Dark mode rule
No light-only paint in dark mode: screens read `colorScheme` / `context.fieldOpsColors` (both mode-aware), never light constants, for every background, text, border and icon — including input wells (dark blue fill + light ink in dark mode). The only deliberate light surfaces in dark mode are the splash and header logo plates (the navy mark needs a light label to stay visible). The login screen shows the app name only — no logo plate, no tagline, no support row.

---

## 4. Navigation (sidebar, no bottom nav)

- There is **no bottom navigation bar**. All destinations live in the sidebar drawer (`FieldOpsSidebar`), opened from any root screen's header menu button.
- Sidebar: **Home / Queue / Tickets / Tasks** + **Profile** group (employee details, theme switch, log out). **Alerts is NOT in the sidebar** — it opens from the header bell.
- **Dashboard (Home)** shows only pending-task stats (Pending / In progress / Overdue tiles → tasks list). No employee card, no request lists, no "Dashboard" heading.
- Root screens: **no back button** (menu instead). Pushed screens: back button.

---

## 5. Components

### AppBar (`BrandedHeader`)
- Background: cobalt chrome (light) / deep blue-navy (dark), white foreground — both modes.
- Content: `[menu|back] [logo] [title, ellipsis] [actions: badge/bell/search]`. 64dp + safe area, 1px bottom divider.

### Cards
- White on cloud (light) / raised navy with hairline border (dark). `cardRadius`, Level-1 shadow + **1px** border. 16px internal padding.
- Request cards: 4px status-colour rail, mono request number, capped status pill (never overflows).

### Buttons
- **Primary (filled):** cobalt fill, white text, 12px radius, min 48dp height. Pressed → deeper cobalt.
- **Secondary (outlined):** cobalt border + text, transparent fill.
- **Text/link:** cobalt text, no background.
- **Sticky submit bar:** workflow forms that opt in (splicing today) register their submit control into the detail screen's pinned bottom bar (cloud surface, 1px top border, 16/12 padding) instead of an inline button. Registration clears on dispose; the bar gates on the live action.

### Status & Priority Badges
Pill, opaque semantic tint + full-strength ink, dot + sentence-case label (`StatusBadge.labelFor`). One shared widget each.

### Inputs
- 52dp height, white fill, 12px radius, **1px** border, 2px cobalt focus ring. Error: red border + helper text. Label above the field.

### Voice notes
- `VoiceNoteSection`: 'Voice note' card with mic header, state chip, waveform readout, Play / Record / discard controls. Recording/playback state lives in the owning form.

### Maps
- Rounded card, user marker in brand ink, DP marker green. Real multi-point route; straight-line fallback only on genuine failure, labeled 'Approximate route'.

---

## 6. Motion — Lottie Usage

Sparingly, only for feedback: login loading, empty states (one shared animation), success checkmark after a completion submit. Files bundled under `assets/lottie`, short loops, palette-matched.

---

## 7. Formatting Conventions

- **Currency:** `Rs` prefix, thousands separators (`Rs 3,500.00`).
- **Dates:** relative under 24h ('2h ago'), absolute after.
- **Overflow:** single-line fields use `ellipsis` + `maxLines: 1`.

---

## 8. What NOT to do

- Don't invent UI for data the API doesn't send.
- Don't hardcode a color, radius, or font size in a screen.
- Don't duplicate a control on the same screen (e.g., two logouts).
- Don't put details on a screen that belong elsewhere — dashboard stays stats-only.
- Don't render status labels in uppercase.
- Don't ship a box without its 1px border.
- Don't leave a disabled control unexplained.
