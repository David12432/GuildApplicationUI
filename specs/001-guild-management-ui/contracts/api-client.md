# API Client Contract (consumed by GuildApplicationUI)

**Date**: 2026-09-25 | **Authoritative source**:
`GuildApplicationAPI/specs/0001-guild-management-api/spec.md`

The UI wraps every endpoint in typed Angular services — **one service per
domain** (constitution standards: no HTTP calls from components). Base path:
`/api/v1`. Sessions are cookie-based (research R5; confirm at backend plan).

## Auth domain — `AuthApiService` (+ `RoleService` helper)

| Operation | Backend surface | UI usage |
|---|---|---|
| Start sign-in | `GET /api/v1/auth/login?returnUrl=` → redirect to Discord | Sign-in button; never handles Discord credentials (spec FR-001) |
| OAuth callback | `/api/v1/auth/callback` (backend redirects) | Landing after redirect; error param → friendly sign-in error |
| Current user | `GET /api/v1/auth/me` | App bootstrap (role, identity); 401 → sign-in redirect |
| Sign out | `POST /api/v1/auth/logout` | Avatar menu |
| User settings (timezone) | current-user profile/settings endpoint *(coordination point: confirm exact route in backend plan)* | Settings page persists IANA timezone (FR-025) |

## Roster domain — `RosterApiService`, `CharactersApiService`, `ClaimsApiService`

- `GET /roster` — players with mains + nested alts; filters: class, category,
  level range, main/alt; search by name; pagination + totals (FR-006).
- `POST/PUT /characters`, member-scoped; `400` field errors → inline (FR-007).
- Pending characters list / approve / reject (officer) — approval workflow
  (FR-008).
- Unlinked characters list; `POST claim`; claims list / approve / reject
  (officer) (FR-009).
- `GET /characters/{id}` — character detail hub hydration (standings, ledger,
  progression, loot) (FR-024).
- `GET /classes` — configured class list for pickers/validation.
- `GET /roster/stats` — analytics (FR-019).

## Events domain — `EventsApiService`

- `GET /events` (paged, filterable), `POST /events`, `PUT /events/{id}`
  (incl. status transitions), cancel = status change (FR-010).
- `GET/POST/PUT/DELETE /events/{id}/attendees` — attendance CRUD, character
  picker driven by roster; conflict (`409`) on duplicate (FR-011, FR-028).
- Event-role assignments CRUD (`roleDefinitionId` × `attendeeId`) (FR-011).
- `POST /events/{id}/awards/bulk` — default amount + per-attendee overrides +
  `idempotencyKey`; response = per-attendee summary (FR-012).
- Attendance/award correction endpoints *(coordination point: exact mutation
  surface confirmed in backend plan — spec FR-028 requires edit/remove
  capability)*.
- `GET /events/{id}/summary` — server-computed class/category counts (FR-013).

## Points domain — `PointsApiService`

- `GET /points/standings?characterId&window` — earned/spent/balance/
  attendance % over date window (FR-014).
- `GET /points/leaderboard?sort=balance` — paginated ranking (FR-014).
- `GET /points/ledger?characterId` — read-only entries; **no mutation
  endpoints exist or are called** (append-only, FR-015).
- `POST /points/adjustments` — officer adjustment with amount + reason
  (FR-015).

## Loot domain — `LootApiService`

- `GET /loot?character&from&to` — history, newest first, paginated (FR-016).
- `POST /loot` — award recording (character, item, amount, method) (FR-016).

## Progression domain — `ProgressionApiService`

- `GET /progression-definitions`; leader-managed definition CRUD (FR-018).
- `GET/PUT /characters/{id}/progression` — per-character state values,
  validated against state sets (FR-017).
- `GET /roster/progression?flag&state` — "who has flag X" queries (FR-018).

## Calendar domain — `CalendarApiService`

- `GET /calendar?month=YYYY-MM`, `GET /calendar/upcoming` (FR-020).
- `POST/PUT/DELETE /calendar` entries (officer; delete behind confirmation)
  (FR-020).

## Guild settings — `GuildSettingsApiService`

- `GET /guild/settings` — approval toggles, level bounds, event-ready
  threshold; leader-only mutation (rendering flows switch per toggles).

## Cross-cutting error contract (all services)

The HTTP error interceptor (`core/http`) maps (spec FR-023):

| Status | UI behavior |
|---|---|
| 400 | Field errors inline on the originating form |
| 401 | Redirect to sign-in with `returnUrl` |
| 403 | Friendly "not permitted" message; action remains blocked |
| 404 | Not-found state for the view |
| 409 | Conflict message (e.g., duplicate attendee, last-leader demotion) |
| 429 | "Too many attempts" + paced retry |
| 502 | Upstream (Discord) failure — sign-in screen explanation |
| 503 | Service-unavailable state with retry |

All timestamps in responses are **UTC** (spec clarification Q2); display
conversion happens client-side via `TimeDisplayService` (research R6).
Export endpoints: none consumed — XLSX is generated client-side (research R2).