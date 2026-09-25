# Research: Guild Management Web UI (Feature 001)

**Date**: 2026-09-25
**Status**: Complete — all open decisions resolved for planning.

Decisions below were evaluated against the constitution (v1.2.0): free/OSS
only, Spartan UI + Tailwind + CDK, NgRx state, Vitest + Playwright, brand
palette, strict TypeScript + Angular ESLint.

---

## R1: Unit test runner — Vitest integration for Angular 22

- **Decision**: Use the Vitest support built into Angular's application
  builder (`@angular/build` unit-test experimental/stable support; `ng test`
  running Vitest) with the jsdom environment and `@angular/testing`/
  Angular Testing Library for component tests. Vitest's v8 coverage provider
  feeds the ≥85% gate (`vitest.config.ts` thresholds wired into CI and
  quality gates).
- **Rationale**: First-party runner support keeps `ng test`/CI wired into the
  Angular CLI toolchain (no parallel Karma path), matches constitution
  VII (Vitest mandated), and the coverage gate is a native Vitest feature.
  The scaffold's legacy `karma.conf.js`/Jasmine is removed.
- **Alternatives considered**: Analog's `@analogjs/vitest-angular` (solid
  plugin, but a third-party dependency for something the CLI now offers);
  keeping Jasmine/Karma (rejected — constitution mandates Vitest).

## R2: XLSX export mechanism

- **Decision**: Client-side export with **ExcelJS** (MIT), generating `.xlsx`
  workbooks from the same paged/filtered data the views display. A shared
  `ExportService` in `shared/export/` takes a column schema + row provider so
  each view (roster, standings, loot, calendar) reuses one implementation
  (DRY). Exports respect the active filters/window ("export what you see").
- **Rationale**: Avoids new backend scope (attendance/export endpoints are
  not in API feature 0001), keeps the export format/styling fully in the UI's
  control, and MIT satisfies the free/OSS constraint. Data volumes (~1,000
  rows) are trivial for client-side generation.
- **Alternatives considered**: Backend export endpoints in GuildApplicationAPI
  (deferred — adds backend scope; revisit if exports grow beyond client-
  practical sizes); SheetJS CE (Apache-2.0, but public npm releases have
  stagnated behind the vendor CDN).

## R3: NgRx pattern for domain state

- **Decision**: Classic `@ngrx/store` + `@ngrx/effects` with **signal-based
  selectors** (NgRx's signals integration, e.g. `selectSignal`) and
  `@ngrx/entity` for large collections (roster, events, loot, ledger).
  Component-local UI state (dialog open, filter drafts) uses Angular
  `signal()` directly. Effects call the typed domain API services and hydrate
  stores; smart components read stores via signal selectors and dispatch
  actions; dumb components stay pure `@Input()`/`@Output()`.
- **Rationale**: Constitution mandates NgRx for domain/cross-cutting state and
  prefers signal-based APIs. Store/Effects with entity adapters is the
  battle-tested path for paginated, filterable collections and gives
  per-domain slice isolation matching the DDD folder structure.
- **Alternatives considered**: NgRx SignalStore only (leaner, but the
  selectors/effects + entity toolkit is stronger for large server-driven
  collections and devtools inspection); plain services with signals
  (rejected — constitution mandates NgRx for domain state).

## R4: Spartan UI + Tailwind compatibility with Angular 22

- **Decision**: Spartan UI (`spartan.ng`) CLI-generated primitives copied
  into `src/app/ui/`, styled by **Tailwind CSS v4** (CSS-first configuration)
  with the brand palette defined as theme tokens (`--color-primary:
  #2754F5`, white, warm gray/charcoal neutrals). Spartan's theming docs
  govern token wiring; primitives are owned code adapted to project
  conventions (constitution V).
- **Rationale**: Spartan UI is the locked framework decision (research doc,
  2026-09-25); Tailwind v4 is Spartan's current foundation and CSS-first
  tokens keep the palette in styles, not scattered magic values. Components
  needed for this feature: dialog, sheet, avatar, select, sidebar, breadcrumb,
  table, pagination, command/menu, tooltip, tabs, form controls, calendar-ish
  primitives plus custom month-grid dumb components.
- **Alternatives considered**: Tailwind v3 config-file theming (fine but
  legacy path for new installs); building primitives from CDK alone
  (rejected — re-invents Spartan; constitution prohibits bespoke
  equivalents).

## R5: Session/auth integration with the backend

- **Decision**: Assume the GuildApplicationAPI issues a **cookie-based session**
  (per its FR-001 "issues an API session; subsequent requests carry it") and
  the SPA is served same-origin in deployment (Aspire orchestration), with
  `withCredentials` and a dev-server proxy to the API in development. An
  auth interceptor handles `401` → redirect to sign-in with `returnUrl`;
  a role service exposes the active membership role as a signal for
  template gating. UI gating is advisory; the API remains authoritative
  (spec FR-002).
- **Rationale**: Cookies avoid token storage/cross-site complexity for a
  same-site SPA; the redirect flow matches the backend's OAuth callback
  design; the interceptor pattern keeps auth cross-cutting in `core/auth`.
- **Alternatives considered**: Bearer tokens (needs backend token issuance +
  client storage strategy — backend hasn't committed to it; cookie is the
  simpler default consistent with backend spec wording). **Coordination
  point**: if the backend's plan phase chooses tokens instead, only the
  interceptor changes — isolated in `core/http`.

## R6: Timezone storage and conversion

- **Decision**: Users pick an **IANA timezone identifier** (e.g.
  `America/New_York`) in settings; a `TimeDisplayService` formats API UTC
  timestamps into the configured zone using the platform `Intl` API
  (`Intl.DateTimeFormat` with `timeZone`), exposed through a pipe/directive
  used by all event/calendar views. Unconfigured users fall back to the
  browser-detected zone (`Intl.DateTimeFormat().resolvedOptions().timeZone`),
  overridable in settings. Officers still enter times with an explicit
  timezone label when creating events/entries (spec FR-026).
- **Rationale**: IANA identifiers handle DST correctly with zero libraries;
  `Intl` is built-in (no dependency, free); the fallback rule is defined in
  the spec (FR-025).
- **Alternatives considered**: UTC-offset-only storage (breaks across DST
  boundaries); `date-fns-tz` (only if `Intl` formatting proves insufficient
  — e.g., arbitrary-label display).

## R7: Linting setup

- **Decision**: Angular ESLint (`eslint` + `@angular-eslint` tooling, flat
  config) wired into the build pipeline and CI alongside Prettier
  (`.prettierrc` already present). Lint failures fail the build
  (constitution standards).
- **Rationale**: Constitution mandates Angular ESLint with strict TypeScript;
  flat config is the current ESLint standard.
- **Alternatives considered**: TSLint (deprecated); Biome (fast but weaker
  Angular/template awareness).

## R8: SignalR — explicitly deferred

- **Decision**: No `@microsoft/signalr` dependency in v1. The backend spec
  (0001) defers real-time until after the frontend exists; the constitution's
  SignalR standard activates with a future feature.
- **Rationale**: Spec assumption; adding dead client code violates YAGNI.
- **Alternatives considered**: Pre-wiring a realtime service stub (rejected —
  speculative until hub contracts exist).

---

## Coordination points with GuildApplicationAPI (feature 0001)

Carried from the spec clarifications — these may require backend-side work or
confirmations before/while implementing the matching UI tasks:

1. **Attendance/award corrections** (spec FR-028): confirm backend mutation
   endpoints for editing/removing attendance, event-role assignments, and
   correcting awards (ledger stays append-only).
2. **Session mechanism** (R5): confirm cookie-based sessions vs. tokens when
   the backend plan phase lands.
3. **Export data availability** (R2): client-side export relies on the same
   paginated list endpoints the views use; confirm pagination limits allow
   reasonable full-export pages (or per-view export queries).