# Data Model: Guild Management Web UI (Feature 001)

**Date**: 2026-09-25 | **Spec**: [spec.md](spec.md)

The UI owns no persistence — the GuildApplicationAPI is the single source of
truth. This model defines the **client-side DTOs** (mirroring the backend
contract in GuildApplicationAPI feature 0001), the validation rules the UI
enforces for immediate feedback, and the **NgRx state slices** that hold
server data between routes.

## Entity Reference (client DTOs)

All DTOs use `readonly` properties (constitution III). Authoritative field
definitions live in the backend spec; the client mirrors the response shapes
below.

### Session & identity

- **CurrentUser**: Discord identity (`id` snowflake, `username`, `globalName`),
  active `guildId`, `role` (`Member | Officer | GuildLeader`), and
  `timezonePreference?: string` (IANA identifier — client-persisted via the
  backend settings/profile or local profile endpoint; see open point below).
  - Validation: `role` drives template gating (advisory only — API is
    authoritative per spec FR-002).
- **AuthSession**: no client-held fields by design (cookie-based; research R5).

### Roster domain

- **Player**: `id`, `name`, `mainCharacterId`, `characters: Character[]`
  (mains with nested alts per spec US2).
- **Character**: `id`, `name` (case-insensitively unique per guild),
  `classId/className/category`, `level?: number` (nullable — 0/blank is
  `null`), `isMain`, `mainCharacterId?`, `ownerPlayerId`,
  `approvalStatus: 'Active' | 'Pending'`, `unlinked: boolean`,
  `progression: Record<flagName, state>` (generic map — never game-specific
  field names).
  - Validation: name required + unique (server-checked, inline errors on
    `400`); class MUST come from the guild's configured class list; level
    within guild `MinCharacterLevel`/`MaxCharacterLevel` bounds.
- **Class**: `id`, `name`, `category` (guild configuration; leader-only
  mutation).
- **CharacterClaim**: `id`, `characterId`, `claimantPlayerId`, `status:
  'Pending' | 'Approved' | 'Rejected'`.

### Events domain

- **Event**: `id`, `name`, `location`, `date`, `startTimeUtc` (API returns
  UTC — research R6), `originalTimezoneLabel`, `status:
  'Scheduled' | 'Completed' | 'Cancelled'`.
  - State transitions (officer-initiated): `Scheduled → Completed`,
    `Scheduled/Completed → Cancelled` (confirmation dialog; cancelled events
    are excluded from all computed totals everywhere they display).
- **EventAttendee**: `id`, `eventId`, `characterId`, `groupNumber`,
  `isGroupLeader`. Unique per event+character (duplicate → conflict surfacing).
- **EventRoleAssignment**: `id`, `eventId`, `roleDefinitionId` (guild-
  configured roles), `attendeeId`.
- **BulkAwardRequest**: `eventId`, `defaultAmount`, `overrides:
  {attendeeId, amount}[]`, `idempotencyKey` (client-generated per submission;
  guards double-submit).

### Points domain

- **PointsLedgerEntry** (read-only): `id`, `characterId`, `type:
  'EventAward' | 'LootCharge' | 'Adjustment'`, `amount`, `dateUtc`,
  `source` (event id, loot award id, or officer id). **No edit/delete
  affordances anywhere** (append-only).
- **PointsStanding** (computed): `characterId`, `earned`, `spent`, `balance`
  (may be negative — valid state), `eventsAttended`, `totalEvents`,
  `attendancePercent`, computed over a queryable `dateWindow`.
- **AdjustmentRequest**: `characterId`, `amount`, `reason` (required).

### Loot domain

- **LootAward**: `id`, `eventId`, `characterId`, `itemName`, `amount`
  (0 = free/random), `method: 'Purchase' | 'Free' | 'RandomRoll'`,
  `dateUtc`.
  - Validation: character MUST exist on roster (picker constrains input).

### Progression domain

- **ProgressionFlagDefinition**: `id`, `name`, `shape:
  'Boolean' | 'MultiStep' | 'Enum'`, `states: string[]` (leader-managed).
- **CharacterProgressionValue**: `characterId`, `flagDefinitionId`,
  `state: string` — validated client-side against the definition's state set
  with the definition-appropriate control (toggle / stepper / select).

### Calendar domain

- **CalendarEntry**: `id`, `date`, `startTimeUtc?` + `timezoneLabel?`,
  `type` (guild/server/community/event-day), `notes`.

### Guild settings (read by UI, leader-mutated via API)

- **GuildSettings**: `memberCharacterApprovalRequired: boolean` (default
  false), `claimApprovalRequired: boolean` (default false),
  `minCharacterLevel`, `maxCharacterLevel`, `eventReadyLevelThreshold`.
  - The UI MUST render different flows per these switches (pending states,
    claim queues).

## Shared API envelope

- **PagedResult<T>**: `items: T[]`, `page`, `pageSize`, `totalCount` — all
  list endpoints (spec FR mandates pagination with totals).
- **ProblemDetails** (errors): `400` field errors map inline to form fields;
  `401` → auth redirect; `403` → friendly denial; `409` → conflict message;
  `429` → paced retry messaging; `502/503` → upstream/unavailable states.

## NgRx state slices (per-domain, matching DDD folders)

| Feature slice | Contents | Notes |
|---|---|---|
| `auth` | `currentUser`, `role`, sign-in state | Signal selectors expose `role` for gating |
| `roster` | players, characters, classes, claims, approvals, filters, pagination | `@ngrx/entity` collections |
| `events` | events, attendees, role assignments, award results | Bulk-award idempotency handled in effects |
| `points` | standings, leaderboard, ledger entries, window filters | Read-mostly |
| `loot` | awards, history filters, pagination | |
| `progression` | flag definitions, per-character values | |
| `analytics` | roster stats, event summaries | Read-only computed data |
| `calendar` | month entries, upcoming | |
| `settings` | user timezone preference | Persisted via API profile/settings endpoint |

Component-local UI state (dialog open states, filter drafts, picker
selections) uses Angular `signal()` directly and is NOT stored in NgRx
(constitution standards).

## Validation summary (client-side, always backed by server authority)

- Client-side validation provides immediate feedback only; server `400`
  field errors MUST render inline on the same fields (spec FR-021).
- Character forms: name (required/unique), class (from configured list),
  level (bounds, nullable), main/alt linkage (alt requires same-player main).
- Event forms: name/location/date required; start time + timezone label.
- Loot forms: item, character, method required; amount numeric ≥0.
- Adjustment dialog: amount + reason required.
- Progression values: state MUST ∈ definition's state set.