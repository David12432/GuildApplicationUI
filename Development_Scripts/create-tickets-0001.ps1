# create-tickets-0001.ps1
# Creates the 0001-guild-management-ui tickets as GitHub issues (one per phase/user story)
# in David12432/GuildApplicationUI, using the authenticated GitHub CLI (gh).
# Idempotent: skips issues whose titles already exist.
# Run from repo root:  powershell -ExecutionPolicy Bypass -File Development_Scripts/create-tickets-0001.ps1

$ErrorActionPreference = 'Stop'
$Repo = 'David12432/GuildApplicationUI'

# gh resolution: sessions started before the GitHub CLI install won't have it on PATH
$gh = Get-Command gh -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $gh) { $gh = 'C:\Program Files\GitHub CLI\gh.exe' }
if (-not (Test-Path $gh)) { Write-Error 'GitHub CLI not found. Install it or fix the path.' }

# --- labels (idempotent) ---
$labels = @('speckit','setup','infrastructure','user-story','mvp','polish')
$colors = @{ 'speckit'='5319E7'; 'setup'='C2E0C6'; 'infrastructure'='FBCA04'; 'user-story'='C5DEF5'; 'mvp'='0E8A16'; 'polish'='FFFFFF' }
foreach ($l in $labels) {
    & $gh label create $l --color $colors[$l] --repo $Repo --force 2>&1 | Out-Null
}

# --- existing titles for idempotency ---
$existing = @(& $gh issue list --repo $Repo --state all --limit 300 --json title --jq '.[].title')

function New-Ticket($title, $labels, $goal, $test, $tasks, $deps) {
    if ($existing -contains $title) { Write-Host "SKIP (exists): $title"; return }
    $body = @"
## Goal
$goal

## Independent test
$test

## Tasks
$tasks

## Dependencies
$deps

## Docs
- specs/001-guild-management-ui/tasks.md
- specs/001-guild-management-ui/spec.md
- specs/001-guild-management-ui/plan.md (constitution v1.3.0 gates: Vitest >=85% coverage, Playwright e2e, Spartan UI only, NgRx, DDD folders, lazy routes, smart/dumb split, brand palette #2754F5/#FFFFFF/warm gray, branch & PR workflow)

*Auto-generated from speckit tasks for feature 001-guild-management-ui.*
"@
    $issue = & $gh issue create --repo $Repo --title $title --body $body --label $labels 2>&1
    Write-Host "CREATED $issue - $title"
}

# --- tickets (one per phase/user story; full detail in tasks.md) ---

New-Ticket '[001] Setup: toolchain (Vitest, Tailwind v4 + brand tokens, Spartan UI, ESLint, Playwright, DDD structure, API proxy)' 'speckit,setup' `
    'Initialize the toolchain: replace Karma/Jasmine with Vitest (>=85% coverage thresholds), Tailwind CSS v4 with brand palette tokens (#2754F5 / #FFFFFF / warm gray-charcoal), Spartan UI owned primitives in src/app/ui/, Angular ESLint flat config, Playwright, DDD folder structure, and dev proxy to the API.' `
    'ng build, lint, and vitest run clean on the scaffold; Spartan primitives render; e2e harness boots the dev server.' `
    'T001 Vitest setup (karma/jasmine removal; jsdom; Testing Library; v8 coverage >=85%)
T002 [P] Tailwind CSS v4 + brand palette theme tokens (src/styles/)
T003 [P] Spartan UI CLI primitives into src/app/ui/ (sidebar, breadcrumb, avatar, dialog, sheet, select, table, tabs, pagination, ...)
T004 [P] Angular ESLint flat config; lint blocks build
T005 [P] Playwright config + e2e/ + browsers
T006 DDD source structure (core/, ui/, shared/, features/<9 domains>)
T007 Dev proxy /api -> backend + environments' `
    'None - start immediately. Blocks all later phases.'

New-Ticket '[001] Foundational: shared infrastructure (DTOs, HTTP/error interceptors, guards, shell, routes, NgRx, time display, export, state components)' 'speckit,infrastructure' `
    'Build the blocking prerequisites: shared readonly DTO models, ApiBase + ProblemDetails error interceptor (400/401/403/404/409/429/502/503), AuthGuard/RoleGuard, app shell (sidebar, breadcrumb, avatar menu), lazy route table (19 routes), NgRx root + per-domain slice pattern, TimeDisplayService/LocalTimePipe (IANA, UTC->user zone), ExcelJS ExportService, and the loading/empty/error state triad.' `
    'Scaffolded app boots to a shell with routes; 401 redirects to /signin; error states render from the interceptor; timezone pipe converts UTC fixtures.' `
    'T008 Shared DTO interfaces (shared/models/)
T009 [P] Core HTTP: ApiBaseService + error interceptor (core/http/)
T010 [P] AuthGuard + RoleGuard (core/auth/guards/)
T011 [P] TimeDisplayService + LocalTimePipe (core/time/)
T012 App shell (core/shell/): sidebar, breadcrumb, avatar menu
T013 Lazy route table per contracts/ui-routes.md (app.routes.ts)
T014 NgRx root + auth slice + per-domain pattern (Store/Effects/Entity + signal selectors)
T015 [P] ExportService (ExcelJS, shared/export/)
T016 [P] Loading/empty/retryable-error components (shared/components/)' `
    'Depends on Setup phase. BLOCKS all user stories.'

New-Ticket '[001] US1: Discord sign-in, role-aware shell, session lifecycle, timezone settings (MVP)' 'speckit,user-story,mvp' `
    'Users sign in via Discord through the backend OAuth flow, land in a role-correct shell (Member/Officer/Leader), get redirected safely on session expiry, and can set their display timezone (API returns UTC).' `
    'Sign in with a seeded identity of each role and verify navigation options and page access match the role matrix; unauthenticated visits redirect to sign-in (quickstart scenario 1).' `
    'T017 [P] Vitest: signin page, guards, sign-out (US1)
T018 [P] Playwright e2e us1-auth.spec.ts
T019 /signin page (Discord button, denied/502 states; never handles Discord credentials)
T020 Auth bootstrap: GET /auth/me, role signal, no-membership state
T021 Sign-out via avatar menu
T022 Role-gated sidebar + RoleGuard (server authoritative)
T023 Session-expiry flow (401 -> signin w/ returnUrl -> return)
T024 /settings timezone picker (IANA; browser fallback)' `
    'Depends on Foundational. No other-story dependencies. This is the MVP.'

New-Ticket '[001] US2: roster browsing, character registration, approvals, claims, character detail hub' 'speckit,user-story' `
    'Roster list (search, filters, pagination, mains + grouped alts), self-service character registration with inline validation, officer approvals queue, unlinked-character claims with claim queue, and the consolidated character detail hub (tabs).' `
    'Sign in as different roles: browse/search/filter roster, register a character (inline 400 errors), approve a pending character as Officer, claim an unlinked character (quickstart scenarios 3-4).' `
    'T025 [P] Vitest: roster table, registration validation, approvals/claims
T026 [P] Playwright e2e us2-roster.spec.ts
T027 Typed API services: Roster/Characters/Claims (features/roster/api/)
T028 Roster NgRx slice (features/roster/state/)
T029 Roster list: smart container + dumb RosterTableComponent (filters/pagination/triad)
T030 Character registration/edit form (typed reactive; class-in-config, level bounds, main/alt linkage)
T031 Officer approvals queue /roster/approvals
T032 Claims: unlinked browse + claim + officer queue
T033 Character detail hub /roster/characters/:id (tabs; US4-6 wire their tabs)' `
    'Depends on Foundational. Enhances US3+ (roster picker) but independent.'

New-Ticket '[001] US3: events, attendance, event roles, bulk point awards, corrections' 'speckit,user-story' `
    'Officer working screen: event create/edit/cancel (status + confirmation), attendance grid (roster picker, groups, leader flags, duplicate prevention), event role assignment, bulk awards with per-attendee overrides + idempotency, corrections after the fact, server-computed summaries.' `
    'An Officer creates an event, records attendance in groups, assigns a role, posts a bulk award with an override, corrects a misrecorded attendee, cancels the event (quickstart scenario 5).' `
    'T034 [P] Vitest: event form, attendance picker, bulk award logic, cancel confirm
T035 [P] Playwright e2e us3-events.spec.ts
T036 EventsApiService (CRUD/status/attendees/roles/bulk awards/summary)
T037 Events NgRx slice
T038 Events list page (status badges)
T039 Event create/edit form + cancel confirmation dialog
T040 Attendance grid (picker, groups, leader toggle, duplicate 409)
T041 Event role assignment (guild-configured roles)
T042 Bulk award dialog (default + overrides + idempotency + result summary)
T043 Corrections + server-computed summary display' `
    'Depends on Foundational. Roster picker (US2) enhances but does not block.'

New-Ticket '[001] US4: points standings, leaderboard, read-only ledger, officer adjustments' 'speckit,user-story' `
    'Per-character standings (earned/spent/balance/attendance % over date windows), leaderboard sorted by balance, transparent append-only ledger with no edit affordances, officer adjustments with reason.' `
    'View a character with known awards/charges, verify the math for a chosen window, browse the leaderboard, record an adjustment (quickstart scenario 6).' `
    'T044 [P] Vitest: window state, leaderboard sort, negative balances, adjustment form
T045 [P] Playwright e2e us4-points.spec.ts
T046 PointsApiService (standings/leaderboard/ledger/adjustments)
T047 Points NgRx slice
T048 Points explorer /points + standings & ledger tabs into character hub
T049 Officer adjustment dialog (amount + required reason)' `
    'Depends on Foundational. Character hub tabs wire into T033.'

New-Ticket '[001] US5: loot recording and history' 'speckit,user-story' `
    'Officers record loot awards (event-linked, character picker, item, amount, method Purchase/Free/RandomRoll); everyone browses history filtered by character and date range, newest first, with XLSX export.' `
    'An Officer records a charged purchase and a free award, then browses history by character and date range (quickstart scenario 7).' `
    'T050 [P] Vitest: loot form validation, history filters
T051 [P] Playwright e2e us5-loot.spec.ts
T052 LootApiService + NgRx slice
T053 Loot history page (filters, sort, pagination, export button)
T054 Record award form + loot tab into character hub' `
    'Depends on Foundational. Character hub tab wires into T033.'

New-Ticket '[001] US6: progression flags (values, queries by flag + state, leader-managed definitions)' 'speckit,user-story' `
    'Per-character progression values with definition-appropriate controls (boolean/multi-step/enum, state-set validated), roster queries by flag + state (who is keyed for X), leader-managed flag definitions.' `
    'An Officer sets boolean and multi-step flag values, a user filters by flag state, a Guild Leader defines a new flag (quickstart scenario 8).' `
    'T055 [P] Vitest: state-set validation controls, flag filter query
T056 [P] Playwright e2e us6-progression.spec.ts
T057 ProgressionApiService + NgRx slice
T058 Progression query view + progression tab into character hub
T059 Flag definition management (leader-only) + officer value editing' `
    'Depends on Foundational. Character hub tab wires into T033.'

New-Ticket '[001] US7: roster and event analytics' 'speckit,user-story' `
    'Analytics dashboard presenting server-computed roster composition (class/category counts, main/alt split, event-ready threshold) and per-event attendance summaries - no client recalculation.' `
    'View the analytics dashboard against a seeded mixed roster; counts and summaries match source data (quickstart scenario 9).' `
    'T060 [P] Vitest: stat card rendering, loading/empty/error triad
T061 [P] Playwright e2e us7-analytics.spec.ts
T062 AnalyticsApiService (roster stats + event summary)
T063 /analytics view (scannable stat cards, server-computed only)' `
    'Depends on Foundational. Independent of other stories.'

New-Ticket '[001] US8: event calendar (month view, upcoming, officer CRUD)' 'speckit,user-story' `
    'Month grid + upcoming list for all users; officer create/edit/delete of entries (date, optional time + timezone label, type, notes) with delete confirmation; times rendered in the user timezone.' `
    'An Officer creates entries for a month; a user browses the month view and upcoming list; delete requires confirmation (quickstart scenario 9).' `
    'T064 [P] Vitest: month-grid assembly, entry form, delete confirmation
T065 [P] Playwright e2e us8-calendar.spec.ts
T066 CalendarApiService + NgRx slice
T067 Calendar month view + upcoming list (LocalTimePipe)
T068 Officer entry management (CRUD + confirmation)' `
    'Depends on Foundational. Independent of other stories.'

New-Ticket '[001] Polish: dashboard, exports wiring, brand audit, accessibility, performance, coverage gate, quickstart validation' 'speckit,polish' `
    'Cross-cutting finish: personal dashboard (upcoming + own standings + recent events, deep-linked), export buttons wired into roster/points/loot/calendar, brand palette audit, accessibility pass (keyboard + ARIA + axe), performance pass (lazy chunks, OnPush, bundle budget), >=85% coverage gate verified, full quickstart validation, README.' `
    'All quickstart.md scenarios pass end-to-end against the seeded backend; coverage >=85%; axe scan clean on primary flows.' `
    'T069 Personal dashboard / (FR-027)
T070 [P] Export buttons in roster/points/loot/calendar (FR-029)
T071 [P] Brand palette audit (theme tokens only)
T072 [P] Accessibility pass (keyboard, ARIA, axe)
T073 Performance pass (lazy chunks, OnPush, budget; roster <2s @ ~1k chars)
T074 Coverage gate >=85% verified in CI wiring
T075 Full quickstart.md validation run; fix findings
T076 README update' `
    'T069 depends on US3/US4/US8 slices. Rest after their stories complete.'

Write-Host 'Done.'