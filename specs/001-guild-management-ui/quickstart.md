# Quickstart: Guild Management Web UI (Feature 001)

**Date**: 2026-09-25 | **Spec**: [spec.md](spec.md)

This is a validation guide — runnable scenarios proving the feature works
end-to-end. Implementation details live in tasks.md.

## Prerequisites

1. **Node.js** LTS (20+ or 22+) and npm.
2. **GuildApplicationAPI running locally** with a seeded guild (the reference
   workbook import — ~1,000 characters, ~59 events, ~1,000 loot rows).
   Follow `GuildApplicationAPI/specs/0001-guild-management-api/quickstart.md`
   for backend setup. In development the backend's Discord stub auth
   (`Discord:UseStubAuth=true`) provides test identities for each role.
3. **Playwright browsers** (`npx playwright install` once).

## Setup

```bash
cd E:\Repos\GuildApplicationUI\GuildApplicationUI
npm install
# Dev server proxies /api to the local backend (proxy target set in
# angular.json / vite dev-server config; adjust if the API port differs)
npm start        # ng serve --port 4200
```

## Automated validation

```bash
npm run test         # Vitest unit/component suite (watch or CI mode)
npm run test:coverage  # Vitest + v8 coverage — MUST report >= 85%
npx playwright test  # end-to-end against the dev server + running backend
```

Quality gates: coverage <85% or any lint failure blocks the change
(constitution VII + standards: `npm run lint` runs Angular ESLint).

## Scenario validation (manual, ~30 minutes)

Each scenario references the contract routes ([ui-routes.md](contracts/ui-routes.md))
and mirrors a spec user story. Expected outcomes quote the spec's acceptance
scenarios.

### 1. Sign-in & role awareness (US1, FR-001–FR-003)

- Open `http://localhost:4200` unauthenticated → redirected to `/signin`.
- Sign in via the backend stub (or Discord in a configured environment) as
  each seeded role: Member, Officer, Guild Leader.
- Expect: shell renders (sidebar, breadcrumb, avatar menu); sidebar shows
  only permitted sections — Member sees read views; Officer additionally sees
  event/loot operational actions; Guild Leader sees configuration (progression
  definitions, guild settings).

### 2. Dashboard (US1, FR-027)

- Land on `/`: upcoming calendar entries, your characters with point
  standings, and recent events render; each card deep-links to its section.

### 3. Roster & characters (US2, FR-006–FR-009)

- Browse `/roster`: mains with grouped alts; search "Kael"; filter by class
  and level range; clear filters; pagination works.
- Register a character (`/roster/register`): submit a duplicate name → inline
  field error; submit valid → appears (approval OFF) or shows pending
  (approval ON) per guild settings.
- As Officer: `/roster/approvals` → approve a pending character → it appears
  on the roster.
- Claim flow: `/roster/claims` → claim an unlinked character; with claim
  approval ON, officer approves it in the queue.

### 4. Character detail hub (US2/US4/US6, FR-024)

- Open `/roster/characters/:id` from any roster row: standings, point ledger,
  progression values, and loot history all render as tabs/sections; ledger
  offers no edit/delete controls.

### 5. Events, attendance, bulk awards (US3, FR-010–FR-013, FR-028)

- As Officer: `/events/new` → create an event (name, location, date, start
  time + timezone label).
- On the event: add attendees via the roster-driven picker into groups with
  leader flags; try adding the same character twice → prevented/conflict
  shown; assign an event role.
- Post a bulk award: default 4 with one override of 2 → per-attendee summary
  confirms the override; double-click is guarded (idempotent).
- Edit a misrecorded attendee's group / remove an attendee → summary updates.
- Cancel the event (confirmation dialog) → event marked cancelled; its
  numbers no longer appear in standings/analytics.

### 6. Standings & leaderboard (US4, FR-014–FR-015)

- `/points`: choose a date window; verify earned/spent/balance/attendance %
  (spot-check against seeded workbook values, spec SC-004); leaderboard
  sorts by balance; a negative balance displays correctly.
- As Officer: record an adjustment with reason → appears in the character's
  ledger.

### 7. Loot (US5, FR-016)

- As Officer: `/loot/new` → record a purchase (charge) and a free award;
  browse `/loot` filtered by character and date range, newest first.

### 8. Progression (US6, FR-017–FR-018)

- As Officer: set a boolean flag and a multi-step flag on characters →
  out-of-state values rejected inline.
- `/progression`: filter by flag + state → only matching characters return.
- As Guild Leader: `/progression/definitions` → define a new flag.

### 9. Analytics & calendar (US7–US8, FR-019–FR-020)

- `/analytics`: class/category counts split by main/alt and event-ready.
- `/calendar`: month view + upcoming list; as Officer create/edit/delete an
  entry (delete requires confirmation).

### 10. Timezone settings (US1.9, FR-025–FR-026)

- `/settings`: set timezone to a different IANA zone (e.g.
  `America/New_York`) → all event and calendar times render in that zone
  (converted from the API's UTC). Clear the setting → falls back to the
  browser timezone.

### 11. XLSX export (FR-029)

- On roster, points, loot, and calendar views with active filters: click
  Export → an `.xlsx` file downloads containing exactly the filtered rows
  (open in Excel/LibreOffice to verify).

### 12. Cross-cutting states (FR-005, FR-023)

- Stop the backend: views show a service-unavailable state with retry — no
  blank screens or silent failures.
- Expire a session (or clear cookies) mid-flow → redirected to sign-in and
  returned to the previous location after re-auth.

## Expected end state

All scenarios pass; `npm run test:coverage` ≥85%; `npx playwright test`
green against the running backend. The result matches the spec's success
criteria SC-001 through SC-007.