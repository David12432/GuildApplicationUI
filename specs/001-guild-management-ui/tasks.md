---

description: "Task list for feature 001-guild-management-ui"
---

# Tasks: Guild Management Web UI

**Input**: Design documents from `/specs/001-guild-management-ui/`

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/, quickstart.md

**Tests**: INCLUDED — constitution v1.3.0 Principle VII (NON-NEGOTIABLE): Vitest unit/component tests with ≥85% coverage at all times, Playwright e2e. Every user story phase includes test tasks written FIRST (failing) before implementation.

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

## Path Conventions

- Angular workspace root: `GuildApplicationUI/` (application sources under `GuildApplicationUI/src/app/`)
- E2E tests: `GuildApplicationUI/e2e/`
- Source structure per plan.md: `core/` (auth, http, shell, time), `ui/` (Spartan owned primitives), `shared/`, `features/<domain>/` — all under `src/app/`

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Toolchain initialization before any feature code

- [ ] T001 Replace Karma/Jasmine with Vitest: remove `GuildApplicationUI/karma.conf.js` + jasmine deps; configure the Angular builder's Vitest unit-test runner with jsdom, `@testing-library/angular`, and v8 coverage thresholds ≥85% in `GuildApplicationUI/vitest.config.ts` + `package.json` scripts (`test`, `test:coverage`)
- [ ] T002 [P] Install Tailwind CSS v4 (CSS-first config) and define brand palette theme tokens per constitution — primary `#2754F5`, white `#FFFFFF`, warm gray/charcoal neutral scale — in `GuildApplicationUI/src/styles/`
- [ ] T003 [P] Install Spartan UI CLI and generate owned UI primitives into `GuildApplicationUI/src/app/ui/` (helm, sidebar, breadcrumb, avatar, dialog, sheet, select, table, tabs, tooltip, pagination, button, input, checkbox, dropdown-menu, card, form)
- [ ] T004 [P] Configure Angular ESLint (flat config `GuildApplicationUI/eslint.config.js`) with strict TypeScript + template rules; add `lint` script; lint failures MUST block build
- [ ] T005 [P] Set up Playwright: `GuildApplicationUI/playwright.config.ts` (webServer = dev server on :4200, baseURL) + `GuildApplicationUI/e2e/`; run `npx playwright install`
- [ ] T006 Create DDD source structure per plan.md: `src/app/core/{auth,http,shell,time}`, `src/app/shared/{models,export,components,pipes,validators}`, `src/app/features/{dashboard,roster,events,points,loot,progression,analytics,calendar,settings}` in `GuildApplicationUI/src/app/`
- [ ] T007 Configure dev-server proxy for `/api` → local GuildApplicationAPI backend (`GuildApplicationUI/angular.json` dev-server proxy or vite proxy) + API base URLs in `GuildApplicationUI/src/environments/`
- [ ] T077 [P] Create containerization assets in `GuildApplicationUI/`: multi-stage `Dockerfile` (Node build stage → serve-stage for the production bundle) + `.dockerignore`, targeting Linux to match the backend container strategy (constitution v1.4.0, spec NFR-005). Numbered T077 to preserve existing task-ID references; belongs to the Setup phase.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented

**⚠️ CRITICAL**: No user story work can begin until this phase is complete

- [ ] T008 Create shared DTO interfaces per data-model.md (readonly, strict) in `GuildApplicationUI/src/app/shared/models/`: CurrentUser, Player, Character, Class, CharacterClaim, Event, EventAttendee, EventRoleAssignment, PointsLedgerEntry, PointsStanding, LootAward, ProgressionFlagDefinition, CalendarEntry, GuildSettings, `PagedResult<T>`, ProblemDetails
- [ ] T009 [P] Create HTTP infrastructure in `GuildApplicationUI/src/app/core/http/`: `ApiBaseService` (typed per-domain pattern) + `error.interceptor.ts` mapping ProblemDetails per contracts/api-client.md — 400→inline field errors, 401→signin redirect w/ returnUrl, 403→friendly denial, 404→not-found, 409→conflict, 429→paced retry, 502→upstream error, 503→unavailable+retry
- [ ] T010 [P] Create auth guards in `GuildApplicationUI/src/app/core/auth/guards/`: `AuthGuard` (redirect `/signin` with returnUrl) and `RoleGuard(role)` (block activation; server remains authoritative per spec FR-002)
- [ ] T011 [P] Create time display in `GuildApplicationUI/src/app/core/time/`: `TimeDisplayService` (IANA timezone via `Intl.DateTimeFormat`, browser-detected fallback) + `LocalTimePipe` converting API UTC timestamps for display (spec FR-025)
- [ ] T012 Create app shell in `GuildApplicationUI/src/app/core/shell/`: collapsible sidebar grouped by domain, breadcrumb trail reflecting the current route, avatar menu (name, role, settings link, sign out) using Spartan primitives (spec FR-004)
- [ ] T013 Create root routes with lazy-loaded feature routes per contracts/ui-routes.md in `GuildApplicationUI/src/app/app.routes.ts` (19 routes with role gating + guards)
- [ ] T014 Configure NgRx in `GuildApplicationUI/src/app/`: `provideStore` root, register `auth` slice, establish per-domain slice pattern (Store + Effects + `@ngrx/entity` + signal-based selectors) per research.md R3
- [ ] T015 [P] Create shared `ExportService` in `GuildApplicationUI/src/app/shared/export/export.service.ts` (ExcelJS; column-schema + row-provider API respecting active filters) per research.md R2 / spec FR-029
- [ ] T016 [P] Create shared state components in `GuildApplicationUI/src/app/shared/components/`: loading skeleton, empty state (with guidance), retryable error view — every data surface uses this triad per spec FR-005

**Checkpoint**: Foundation ready — user story implementation can begin in parallel

---

## Phase 3: User Story 1 - Sign in with Discord and browse a role-aware application (Priority: P1) 🎯 MVP

**Goal**: Discord sign-in, role-aware navigation, app shell, session lifecycle, user settings (timezone)

**Independent Test**: Sign in with a seeded identity of each role (Member, Officer, Guild Leader) and verify navigation options and page access match the role matrix; unauthenticated visits redirect to sign-in (quickstart scenario 1)

### Tests for User Story 1 (FIRST — must fail before implementation)

- [ ] T017 [P] [US1] Vitest component/guard tests: signin page states, `AuthGuard` redirect w/ returnUrl, `RoleGuard` gating, avatar-menu sign-out in `GuildApplicationUI/src/app/features/auth/signin.component.spec.ts` + `core/auth/guards/*.spec.ts`
- [ ] T018 [P] [US1] Playwright e2e: unauthenticated redirect, stub sign-in per role, sidebar visibility matrix, session-expiry return flow in `GuildApplicationUI/e2e/us1-auth.spec.ts`

### Implementation for User Story 1

- [ ] T019 [US1] Implement `/signin` page in `GuildApplicationUI/src/app/features/auth/signin.component.ts`: Discord sign-in button → backend `GET /api/v1/auth/login?returnUrl=`; friendly denied-consent and upstream-failure (502) states; never handles Discord credentials (spec FR-001)
- [ ] T020 [US1] Implement auth bootstrap in `GuildApplicationUI/src/app/core/auth/auth.facade.ts`: hydrate `GET /api/v1/auth/me` on app start; expose `role` as a signal for template gating; handle no-active-membership state clearly (spec FR-002, FR-003)
- [ ] T021 [US1] Implement sign-out in `GuildApplicationUI/src/app/core/shell/avatar-menu.component.ts`: `POST /api/v1/auth/logout` → route to `/signin`
- [ ] T022 [US1] Implement role-gated navigation in `GuildApplicationUI/src/app/core/shell/sidebar.component.ts`: sections per the role matrix in contracts/ui-routes.md (Member read-only, Officer +operational, Leader +configuration); `RoleGuard` blocks activation (spec FR-002)
- [ ] T023 [US1] Implement session-expiry flow in `GuildApplicationUI/src/app/core/http/auth.interceptor.ts`: 401 mid-action → `/signin?returnUrl=` → return user to prior location after re-auth (spec US1.6)
- [ ] T024 [US1] Implement user settings page `/settings` in `GuildApplicationUI/src/app/features/settings/`: IANA timezone picker (`Intl.supportedValuesOf('timeZone')`), persist preference, `LocalTimePipe` honors it, browser fallback until configured (spec FR-025)

**Checkpoint**: US1 fully functional — users sign in, see a role-correct shell, and can set their timezone. MVP demoable.

---

## Phase 4: User Story 2 - Browse and manage the roster (Priority: P2)

**Goal**: Roster browsing (search/filters/pagination), self-service character registration, approvals queue, unlinked-character claims

**Independent Test**: Sign in as different roles and verify roster browsing, registration with validation errors surfaced inline, officer approval queue, and the claim flow against a seeded guild (quickstart scenarios 3–4)

### Tests for User Story 2 (FIRST — must fail before implementation)

- [ ] T025 [P] [US2] Vitest tests in `GuildApplicationUI/src/app/features/roster/`: RosterTable filter/search/pagination behavior; registration form validation (duplicate name → inline 400, class-from-config, level bounds per data-model.md); approvals/claims state logic
- [ ] T026 [P] [US2] Playwright e2e: roster browse/search/filter/pagination, register character, officer approve/reject, claim unlinked character in `GuildApplicationUI/e2e/us2-roster.spec.ts`

### Implementation for User Story 2

- [ ] T027 [US2] Implement typed API services per contracts/api-client.md in `GuildApplicationUI/src/app/features/roster/api/`: `RosterApiService` (paged roster w/ filters: class, category, level range, main/alt; search; stats), `CharactersApiService` (CRUD, pending approve/reject, progression), `ClaimsApiService` (unlinked list, claim, claims approve/reject)
- [ ] T028 [US2] Implement roster NgRx slice in `GuildApplicationUI/src/app/features/roster/state/`: entity collections (players, characters), filters, pagination, approvals and claims state via effects
- [ ] T029 [US2] Implement roster list view in `GuildApplicationUI/src/app/features/roster/roster-list/`: smart container + dumb `RosterTableComponent` — search by name, filters (class/category/level range/main-alt) with clearable chips, pagination, mains with grouped alts, loading/empty/error triad (spec FR-006)
- [ ] T030 [US2] Implement character registration/edit form in `GuildApplicationUI/src/app/features/roster/register/character-form.component.ts`: typed reactive form — name required (server-checked unique, inline 400), class from configured list, level within `MinCharacterLevel`/`MaxCharacterLevel` (nullable), main/alt linkage (alt requires same-player main); member-own vs officer-any editing (403 handled friendly) (spec FR-007)
- [ ] T031 [US2] Implement officer approvals queue `/roster/approvals` in `GuildApplicationUI/src/app/features/roster/approvals/`: pending characters (member name, class, level), approve/reject actions (spec FR-008)
- [ ] T032 [US2] Implement claims in `GuildApplicationUI/src/app/features/roster/claims/`: unlinked-character browse + claim action, claimant status view, officer claims queue with approve/reject (competing-claims outcome visible) (spec FR-009)
- [ ] T033 [US2] Implement character detail hub `/roster/characters/:id` in `GuildApplicationUI/src/app/features/roster/character-detail/`: tabbed hub (standings, ledger, progression, loot) per spec FR-024; this phase builds the hub + roster/identity content; ledger/standings/progression/loot tabs wire in during US4–US6

**Checkpoint**: US1 + US2 independently functional — roster fully browsable and self-service character management works

---

## Phase 5: User Story 3 - Run events: schedule, attendance, point awards (Priority: P3)

**Goal**: Event creation/status, attendance with groups + leader flags, event roles, bulk awards with overrides, officer corrections, server-computed summaries

**Independent Test**: An Officer creates an event, records attendance in groups, assigns a role, posts a bulk award with an override, corrects a misrecorded attendee, and cancels the event (quickstart scenario 5)

### Tests for User Story 3 (FIRST — must fail before implementation)

- [ ] T034 [P] [US3] Vitest tests in `GuildApplicationUI/src/app/features/events/`: event form validation (name/location/date/start time + timezone label), attendance picker duplicate prevention (409), bulk-award override/idempotency/double-submit-guard logic, cancel confirmation
- [ ] T035 [P] [US3] Playwright e2e: create event, attendance groups + leader flags, role assignment, bulk award with override, correction, cancel w/ confirmation in `GuildApplicationUI/e2e/us3-events.spec.ts`

### Implementation for User Story 3

- [ ] T036 [US3] Implement `EventsApiService` in `GuildApplicationUI/src/app/features/events/api/events-api.service.ts`: list/create/edit + status transitions; attendees CRUD (edit/remove per FR-028); role assignments; bulk awards (default + per-attendee overrides + client `idempotencyKey`); server summary
- [ ] T037 [US3] Implement events NgRx slice in `GuildApplicationUI/src/app/features/events/state/`
- [ ] T038 [US3] Implement events list page in `GuildApplicationUI/src/app/features/events/event-list/`: paged/filterable, status badges (Scheduled/Completed/Cancelled), cancelled events visibly marked (spec FR-010)
- [ ] T039 [US3] Implement event create/edit form in `GuildApplicationUI/src/app/features/events/event-form/`: name, location, date, start time + timezone label captured as entered for UTC normalization (spec FR-026); cancel via confirmation dialog warning totals exclusion (spec FR-010)
- [ ] T040 [US3] Implement attendance grid in `GuildApplicationUI/src/app/features/events/attendance/`: roster-driven character picker (mains + alts), group assignment, group-leader toggle, duplicate prevented/conflict surfaced (spec FR-011)
- [ ] T041 [US3] Implement event role assignment in `GuildApplicationUI/src/app/features/events/attendance/role-assignments.component.ts`: assign guild-configured event roles to attendees (spec FR-011)
- [ ] T042 [US3] Implement bulk award dialog in `GuildApplicationUI/src/app/features/events/bulk-award/`: default amount + optional per-attendee overrides in one operation, idempotency key per submission, buttons disable during submission, per-attendee result confirmation (spec FR-012)
- [ ] T043 [US3] Implement corrections + summary in `GuildApplicationUI/src/app/features/events/event-detail/`: edit/remove attendance and role assignments, award corrections via backend mutations (ledger stays append-only, spec FR-028); display server-computed attendee counts per class/category (spec FR-013)

**Checkpoint**: US1–US3 functional — the Officers' daily working screen is complete

---

## Phase 6: User Story 4 - Points standings and leaderboard (Priority: P4)

**Goal**: Per-character standings over date windows, leaderboard sorted by balance, read-only ledger, officer adjustments

**Independent Test**: View a character with known awards/charges, verify earned/spent/balance and attendance % for a chosen window, browse the leaderboard, record an adjustment (quickstart scenario 6)

### Tests for User Story 4 (FIRST — must fail before implementation)

- [ ] T044 [P] [US4] Vitest tests in `GuildApplicationUI/src/app/features/points/`: date-window state, leaderboard sort-by-balance, negative-balance rendering, adjustment form (amount + required reason)
- [ ] T045 [P] [US4] Playwright e2e: standings window, leaderboard ranking, ledger read-only (no edit affordances), officer adjustment appears in ledger in `GuildApplicationUI/e2e/us4-points.spec.ts`

### Implementation for User Story 4

- [ ] T046 [US4] Implement `PointsApiService` in `GuildApplicationUI/src/app/features/points/api/points-api.service.ts`: standings (window), leaderboard (sort by balance, paged), ledger (read-only), adjustments (spec FR-014, FR-015)
- [ ] T047 [US4] Implement points NgRx slice in `GuildApplicationUI/src/app/features/points/state/` (window filters, standings, leaderboard)
- [ ] T048 [US4] Implement points explorer `/points` in `GuildApplicationUI/src/app/features/points/points-explorer/`: selectable date window, standings (earned/spent/balance/events attended/attendance %), paginated leaderboard sorted by balance, negative balances displayed correctly (spec FR-014); wire standings + ledger tabs into the character hub (T033)
- [ ] T049 [US4] Implement officer adjustment dialog in `GuildApplicationUI/src/app/features/points/adjustments/adjustment-dialog.component.ts`: amount + required reason; new entry appears in the character's ledger (spec FR-015)

**Checkpoint**: US1–US4 functional — the points economy is transparent

---

## Phase 7: User Story 5 - Record and browse loot awards (Priority: P5)

**Goal**: Officer loot recording (event-linked, method-tagged) and browsable history

**Independent Test**: An Officer records a charged purchase and a free award, then browses history by character and date range (quickstart scenario 7)

### Tests for User Story 5 (FIRST — must fail before implementation)

- [ ] T050 [P] [US5] Vitest tests in `GuildApplicationUI/src/app/features/loot/`: award form validation (character-from-roster picker, method, amount 0 for free/random), history filters + sort
- [ ] T051 [P] [US5] Playwright e2e: record charged + free awards, browse history filtered by character/date range newest-first in `GuildApplicationUI/e2e/us5-loot.spec.ts`

### Implementation for User Story 5

- [ ] T052 [US5] Implement `LootApiService` in `GuildApplicationUI/src/app/features/loot/api/loot-api.service.ts` + NgRx slice in `GuildApplicationUI/src/app/features/loot/state/` (spec FR-016)
- [ ] T053 [US5] Implement loot history page `/loot` in `GuildApplicationUI/src/app/features/loot/loot-history/`: filters (character, date range), newest first, pagination, ExportService button respecting active filters (spec FR-016, FR-029)
- [ ] T054 [US5] Implement record-award form in `GuildApplicationUI/src/app/features/loot/record-award/`: event-linked, roster character picker, item, amount, method (Purchase/Free/RandomRoll); wire loot tab into the character hub (T033) (spec FR-016)

**Checkpoint**: US1–US5 functional — loot history drives reconciliation

---

## Phase 8: User Story 6 - Track character progression (Priority: P6)

**Goal**: Per-character flag values with definition-appropriate controls, roster queries by flag+state, leader-managed flag definitions

**Independent Test**: An Officer sets boolean and multi-step flag values, a user filters "who is keyed for X", and a Guild Leader defines a new flag (quickstart scenario 8)

### Tests for User Story 6 (FIRST — must fail before implementation)

- [ ] T055 [P] [US6] Vitest tests in `GuildApplicationUI/src/app/features/progression/`: state-set validation for Boolean/MultiStep/Enum controls, flag+state query filters
- [ ] T056 [P] [US6] Playwright e2e: set flag values, filter roster by flag+state, leader defines a flag (403 for non-leaders) in `GuildApplicationUI/e2e/us6-progression.spec.ts`

### Implementation for User Story 6

- [ ] T057 [US6] Implement `ProgressionApiService` + NgRx slice in `GuildApplicationUI/src/app/features/progression/` (definitions CRUD leader-only; per-character values; roster flag/state query) (spec FR-017, FR-018)
- [ ] T058 [US6] Implement progression query view `/progression` in `GuildApplicationUI/src/app/features/progression/progression-query/`: filter by flag + state → matching characters ("who is keyed for X"); wire progression tab into the character hub (T033) (spec FR-018)
- [ ] T059 [US6] Implement flag definition management `/progression/definitions` (leader-only: name, shape Boolean/MultiStep/Enum, state set) + per-character value editing with definition-appropriate controls and inline state-set validation (spec FR-017, FR-018)

**Checkpoint**: US1–US6 functional — progression gates event eligibility

---

## Phase 9: User Story 7 - Roster and event analytics (Priority: P7)

**Goal**: Server-computed roster composition stats and per-event attendance summaries

**Independent Test**: View the analytics dashboard against a seeded mixed roster; class/category counts, main/alt splits, event-ready counts match source data (quickstart scenario 9)

### Tests for User Story 7 (FIRST — must fail before implementation)

- [ ] T060 [P] [US7] Vitest tests in `GuildApplicationUI/src/app/features/analytics/`: stat card rendering from seeded data shapes, loading/empty/error triad
- [ ] T061 [P] [US7] Playwright e2e: analytics render, event summary matches attendee list, responsive under data load in `GuildApplicationUI/e2e/us7-analytics.spec.ts`

### Implementation for User Story 7

- [ ] T062 [US7] Implement `AnalyticsApiService` in `GuildApplicationUI/src/app/features/analytics/api/analytics-api.service.ts`: roster stats (counts per class/category, main/alt split, event-ready per configured threshold) + event summaries (spec FR-019)
- [ ] T063 [US7] Implement `/analytics` view in `GuildApplicationUI/src/app/features/analytics/analytics-dashboard/`: visual, scannable stat cards — server-computed only, no client recalculation (spec FR-019, NFR-002)

**Checkpoint**: US1–US7 functional — dashboards replace manual spreadsheet math

---

## Phase 10: User Story 8 - Maintain the event calendar (Priority: P8)

**Goal**: Month view + upcoming list for all users; officer entry CRUD with confirmations

**Independent Test**: An Officer creates entries for a month; a user browses the month view and upcoming list; delete requires confirmation (quickstart scenario 9)

### Tests for User Story 8 (FIRST — must fail before implementation)

- [ ] T064 [P] [US8] Vitest tests in `GuildApplicationUI/src/app/features/calendar/`: month-grid assembly from entries, entry form (optional time + timezone label, type, notes), delete confirmation
- [ ] T065 [P] [US8] Playwright e2e: month view + upcoming, officer create/edit/delete with confirmation, times rendered via LocalTimePipe in `GuildApplicationUI/e2e/us8-calendar.spec.ts`

### Implementation for User Story 8

- [ ] T066 [US8] Implement `CalendarApiService` + NgRx slice in `GuildApplicationUI/src/app/features/calendar/` (month view, upcoming, CRUD) (spec FR-020)
- [ ] T067 [US8] Implement calendar month view + upcoming list in `GuildApplicationUI/src/app/features/calendar/calendar-view/`: entries with date/type/notes; times via `LocalTimePipe` (spec FR-020)
- [ ] T068 [US8] Implement officer entry management in `GuildApplicationUI/src/app/features/calendar/entry-form/`: create/edit (date, optional time + timezone label, type, notes), delete behind confirmation dialog (spec FR-020)

**Checkpoint**: All eight user stories independently functional

---

## Phase 11: Polish & Cross-Cutting Concerns

**Purpose**: Improvements spanning multiple user stories

- [ ] T069 Implement personal dashboard `/` in `GuildApplicationUI/src/app/features/dashboard/`: upcoming calendar entries, own characters + point standings, recent events — each deep-linking to its section (spec FR-027)
- [ ] T070 [P] Wire export buttons (shared `ExportService`) into roster, points, loot, and calendar views respecting active filters (spec FR-029)
- [ ] T071 [P] Brand palette audit across `GuildApplicationUI/src/`: all colors via Tailwind theme tokens (#2754F5 primary, #FFFFFF, warm gray/charcoal neutrals); document any status-color exceptions
- [ ] T072 [P] Accessibility pass (spec SC-007): keyboard-only navigation of primary flows, ARIA behaviors preserved from Spartan primitives, axe scan in Playwright
- [ ] T073 Performance pass (spec NFR-002): lazy-chunk audit, OnPush verification everywhere, initial bundle budget in `GuildApplicationUI/angular.json`, roster search <2s on ~1,000-character dataset
- [ ] T074 Coverage gate: Vitest coverage ≥85% verified in CI wiring (`package.json`/workflow); close gaps found by the report (constitution VII)
- [ ] T075 Run all quickstart.md validation scenarios end-to-end against the seeded GuildApplicationAPI backend; fix findings (spec SC-001–SC-007)
- [ ] T076 Update `GuildApplicationUI/README.md`: setup, dev proxy configuration, test commands (unit/e2e/coverage), quality gates

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Setup — BLOCKS all user stories
- **User Stories (Phases 3–10)**: All depend on Phase 2; then parallelizable or sequential P1→P8
- **Polish (Phase 11)**: Depends on the stories it touches (T069 needs US3/US4/US8 data slices)

### User Story Dependencies

- **US1 (P1)**: After Foundational — no other-story dependencies (MVP)
- **US2 (P2)**: After Foundational — independent; character hub (T033) hosts tabs filled by US4–US6
- **US3 (P3)**: After Foundational — roster picker (US2) enhances it but is not blocking (picker degrades to search)
- **US4–US8 (P4–P8)**: After Foundational — each independently testable; US4/US5/US6 tab wiring into the character hub (T033) happens in their own phases
- **Polish**: Dashboard (T069) after US3/US4/US8 slices exist

### Within Each User Story

- Tests first (must fail), then services → state → smart container → dumb components → integration
- Story complete when tests + e2e pass and coverage ≥85%

### Parallel Opportunities

- All Phase 1 tasks marked [P] (T002–T005); Foundational [P] tasks (T009–T011, T015, T016)
- Within each story: the two test tasks ([P]) run together; model/state and view scaffolding in different files run together
- Across stories: after Phase 2, different stories can proceed in parallel (different `features/<domain>/` folders, no file conflicts)

---

## Parallel Example: User Story 2

```bash
# Launch US2 tests together:
Task: "Vitest tests: RosterTable filters, registration form validation, approvals/claims (features/roster/)"
Task: "Playwright e2e: roster browse, register, approve, claim (e2e/us2-roster.spec.ts)"

# Then in parallel (different files):
Task: "Typed API services: RosterApiService, CharactersApiService, ClaimsApiService (features/roster/api/)"
Task: "Roster NgRx slice (features/roster/state/)"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup
2. Complete Phase 2: Foundational (CRITICAL — blocks all stories)
3. Complete Phase 3: US1
4. **STOP and VALIDATE**: quickstart scenarios 1–2, `npm run test:coverage` ≥85%, `npx playwright test e2e/us1-auth.spec.ts`
5. Demo: sign in, role-aware shell, timezone settings

### Incremental Delivery

1. Setup + Foundational → foundation ready
2. +US1 → MVP demo
3. +US2 → roster self-service (largest user-visible value after auth)
4. +US3 → officer daily workflow
5. +US4–US8 → each adds an independently testable section
6. Polish → dashboard, exports, accessibility, performance, full validation

### Constitution Gates (apply to EVERY task)

- Branch & PR workflow: all work on `001-guild-management-ui`; PR before merge to `main`
- Vitest coverage ≥85% at all times; Playwright e2e per story
- Spartan UI primitives only; brand palette via Tailwind tokens; free/OSS deps only
- Smart/dumb separation; DDD folders; lazy routes; `inject()`; OnPush; strict TS + Angular ESLint

---

## Notes

- [P] tasks = different files, no dependencies
- Backend coordination points (research.md): attendance/award mutation endpoints, session mechanism (cookie assumed), export pagination limits
- Verify tests fail before implementing (constitution VII)
- Commit after each task or logical group; PR per story or per feature branch as preferred
- Stop at any checkpoint to validate the story independently