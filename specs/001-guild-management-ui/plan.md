# Implementation Plan: Guild Management Web UI

**Branch**: `001-guild-management-ui` | **Date**: 2026-09-25 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-guild-management-ui/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command; its definition describes the execution workflow.

## Summary

Build the Angular 22 single-page web application for guild management on top
of the GuildApplicationAPI (feature 0001): Discord sign-in with role-aware
navigation; roster browsing with self-service character registration,
approval and claim workflows; event creation with attendance, event roles,
and bulk point awards (with officer corrections); points standings and
leaderboard; loot recording and history; progression flag tracking; roster
analytics; and a calendar — all in a modern Spartan UI shell (sidebar,
breadcrumbs, dialogs, sheets) themed with the brand palette (#2754F5 /
#FFFFFF / warm gray-charcoal). State flows through NgRx (signal-based
selectivity) with smart/dumb component separation, domain-organized
feature folders, and lazy-loaded routes. Unit tests run on Vitest (85% floor),
end-to-end on Playwright. XLSX export ships client-side (ExcelJS). The API
returns UTC times; the UI converts them for display using each user's
settings-configured timezone.

## Technical Context

**Language/Version**: TypeScript 5.x (strict) on Angular 22 (standalone,
signals, new control flow).

**Primary Dependencies**: Spartan UI (`spartan.ng` — shadcn-style owned
components) on Tailwind CSS + Angular CDK; `@ngrx/store` +
`@ngrx/effects` with signal-based selectors; `@angular/router` (lazy
routes); Angular ESLint + Prettier; `exceljs` (XLSX export, MIT); timezone
handling via the platform `Intl` API with IANA identifiers
(`date-fns-tz` only if conversions exceed `Intl` capability). SignalR client
is **not** included in v1 (real-time deferred per spec assumption).

**Storage**: None client-side beyond the API session; server is the single
source of truth. No localStorage persistence of domain data in v1.

**Testing**: Vitest (via Angular's experimental `unit-test` builder or
Analog's Vitest plugin — resolved in research.md R1) with jsdom; Angular
Testing Library for component tests; Playwright for end-to-end; coverage
enforced at ≥85% (v8 coverage provider).

**Target Platform**: Evergreen browsers (last 2 versions of Chrome, Edge,
Firefox, Safari). Desktop-first responsive (≥1024px primary; degrades to
tablet ≥768px); phone not supported in v1.

**Project Type**: SPA web application consuming REST APIs
(`GuildApplicationAPI`, feature 0001, `/api/v1`).

**Performance Goals**: Roster search/filter renders < 2s on ~1,000 characters;
route changes feel instant (lazy chunks, OnPush, signals); initial bundle
kept minimal via route-level code splitting; WCAG-friendly keyboard operability
throughout.

**Constraints**: 85%+ unit coverage at all times; free/OSS dependencies only
(no paid packages); brand palette only (explicit exceptions for status
colors); strict TypeScript + Angular ESLint block builds; all times displayed
in the user's configured timezone (API returns UTC).

**Scale/Scope**: ~25 screens across 9 feature domains; reference data volume
~1,000 characters, ~59 events, ~1,000 loot rows; 3 roles (Member, Officer,
Guild Leader).

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

Constitution v1.2.0 gates evaluated against this plan:

| Principle | Gate evaluation |
|---|---|
| I. Naming & Formatting | PASS — PascalCase/camelCase/kebab-case conventions and Prettier enforced; one component per file |
| II. Modern Angular Features | PASS — standalone components, signals-first, `@if/@for/@switch`, typed forms, `inject()` |
| III. Immutability & Type Safety | PASS — strict TS, readonly DTOs, OnPush default |
| IV. SOLID & DRY | PASS — smart/dumb split, domain services, shared Spartan primitives |
| V. Spartan UI Component Framework | PASS — all UI primitives from Spartan UI; free/OSS only |
| VI. Resource & Error Management | PASS — `takeUntilDestroyed`/async pipe, central HTTP error interceptor, specific handling |
| VII. Test-First Quality | PASS — Vitest unit (85% floor), Playwright e2e planned from the start |
| VIII. Domain-Driven Modular Architecture | PASS — `features/<domain>` structure, smart/dumb components, lazy routes |
| Brand palette (Standards) | PASS — #2754F5 / #FFFFFF / warm gray-charcoal as Tailwind theme tokens |
| NgRx + ESLint (Standards) | PASS — NgRx for domain state, Angular ESLint blocks builds |

No violations — Complexity Tracking table not needed.

## Project Structure

### Documentation (this feature)

```text
specs/001-guild-management-ui/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
GuildApplicationUI/                 # Angular workspace (VS esproj wrapper)
├── src/
│   ├── app/
│   │   ├── core/                   # cross-cutting (non-domain)
│   │   │   ├── auth/               # auth state, guards, role service
│   │   │   ├── http/               # API base client, error interceptor
│   │   │   ├── shell/              # app shell: sidebar, breadcrumb, avatar menu
│   │   │   └── time/               # timezone display service + pipe
│   │   ├── ui/                     # Spartan UI owned primitives (helm, dialog, sheet, avatar, select, sidebar, breadcrumb, table, etc.)
│   │   ├── shared/                 # shared dumb components, pipes, validators, models
│   │   │   └── export/             # XLSX export service (ExcelJS)
│   │   └── features/               # DDD: one folder per business domain
│   │       ├── dashboard/          # personal dashboard (landing)
│   │       ├── roster/             # roster list, character detail hub, registration, approvals, claims
│   │       ├── events/             # event list/detail, attendance, roles, bulk awards
│   │       ├── points/             # standings, leaderboard, adjustments
│   │       ├── loot/               # loot history, record award
│   │       ├── progression/        # flag values, flag filters, definitions (leader)
│   │       ├── analytics/           # roster stats, event summaries
│   │       ├── calendar/           # month view, upcoming, entry CRUD
│   │       └── settings/           # user settings (timezone)
│   ├── environments/               # dev/prod API base URLs
│   └── styles/                     # Tailwind theme tokens (brand palette), global styles
├── e2e/                             # Playwright specs (one per user story)
└── specs/001-guild-management-ui/   # this feature's documentation
```

**Structure Decision**: Single Angular application, domain-organized under
`features/` (constitution Principle VIII), with shared presentation primitives
in `ui/` (Spartan owned components) and cross-cutting infrastructure in
`core/`. Smart (container) components live at feature roots; dumb components
live in `shared/` and `ui/` and communicate only via `@Input()`/`@Output()`.
Each feature route lazy-loads; feature state lives in per-domain NgRx
slices.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

No constitution violations — table intentionally empty.