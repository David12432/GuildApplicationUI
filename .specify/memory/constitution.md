# GuildApplicationUI Constitution

This project is the Angular web application (frontend) for the guild
management application. It is built on Angular 22 with Spartan UI as the
component framework (Tailwind CSS + Angular CDK), is delivered as a
containerized application (Docker, Linux), and consumes the
GuildApplicationAPI backend over HTTP (SignalR WebSockets are planned for a
future feature). This constitution defines the non-negotiable engineering
principles that govern all work in this repository.

## Core Principles

### I. Official Naming & Formatting Conventions

Adherence to standard Angular and TypeScript style guidelines keeps the
codebase consistent. All code MUST follow:

- **PascalCase** for classes, interfaces, types, services, components, and
  enums (e.g., `ApplicationForm`, `RosterService`).
- **camelCase** for variables, properties, methods, and parameters
  (e.g., `totalPoints`, `memberId`).
- **kebab-case** for file names (e.g., `roster-list.component.ts`), with the
  file suffix naming its kind (`.component.ts`, `.service.ts`, `.pipe.ts`).
- **One component/class per file**, named after the component or class it
  contains.
- Formatting MUST be enforced by the repo's Prettier configuration
  (`.prettierrc`); committed code MUST be Prettier-formatted.

### II. Modern Angular Features

Code MUST use current Angular idioms rather than legacy patterns:

- **Standalone components**: all components MUST be standalone (no NgModules
  for feature code).
- **Signals**: use Angular signals (`signal`, `computed`, `input()`,
  `output()`) as the default reactivity primitive.
- **New control flow**: use `@if`, `@for`, `@switch` template syntax instead
  of structural directives (`*ngIf`, `*ngFor`).
- **Typed forms**: prefer typed `FormGroup`/`FormControl` reactive forms with
  strict generic typing.
- **Modern dependency injection**: prefer the `inject()` function over
  constructor-based injection for better type safety and reusability inside
  functional utilities.

### III. Immutability and Type Safety

All types and bindings MUST favor immutability and compile-time safety:

- **Strict TypeScript**: the project's strict compiler settings MUST remain
  enabled; `any` MUST be avoided (use `unknown` and narrow with type guards).
- **Readonly by default**: interfaces and DTOs MUST use `readonly` properties;
  inputs MUST be treated as immutable.
- **OnPush change detection**: components MUST use
  `ChangeDetectionStrategy.OnPush` by default.

### IV. SOLID and DRY (NON-NEGOTIABLE)

All code MUST always follow the SOLID principles and the DRY principle:

- Apply the five core design patterns, particularly the Single Responsibility
  Principle: a component, service, or directive MUST have exactly one reason
  to change and perform one focused task.
- Duplication of logic, literals, or structure MUST be eliminated by
  extraction into a single, well-named abstraction (e.g., shared models,
  services, or Spartan UI primitives).

Rationale: SOLID and DRY are the primary defenses against entropy in a
component-heavy frontend; violating them compounds maintenance cost with every
feature.

### V. Spartan UI Component Framework (NON-NEGOTIABLE)

The UI MUST be built exclusively with Spartan UI on its Tailwind CSS +
Angular CDK foundation:

- All shared UI primitives (dialogs, dropdowns, tables, forms, tooltips) MUST
  come from Spartan UI (`spartan.ng`); inventing bespoke equivalents is
  prohibited unless Spartan UI lacks the component.
- Spartan UI components are copied into this codebase (shadcn/ui-style
  ownership); copied components live under a dedicated UI directory
  (e.g., `src/app/ui/`) and MUST be adapted to the project's conventions rather
  than treated as untouchable black boxes.
- Styling MUST use Tailwind CSS utility classes; ad-hoc component-scoped CSS
  MUST be reserved for cases Tailwind cannot express.
- **All UI frameworks and component libraries MUST be free/open-source;
  paid or commercial UI frameworks are prohibited** (project decision,
  2026-09-25).

### VI. Robust Resource and Error Management

All async work and subscriptions MUST be correct by construction:

- **Subscription hygiene**: observables MUST be managed with
  `takeUntilDestroyed` (or `async` pipe); manual `unsubscribe` bookkeeping MUST
  be avoided.
- **Specific error handling**: HTTP errors MUST flow through a central error
  interceptor; components MUST only catch and render errors relevant to them.
  Broad catches MUST NOT swallow errors silently.
- **Async patterns**: use `async`/`await` or the `async` pipe; blocking or
  nested subscription chains MUST be replaced with combinators or signals.

### VII. Test-First Quality (NON-NEGOTIABLE)

The application MUST be continuously validated by automated tests:

- **Unit test coverage MUST remain at or above 85% at all times.** A change
  that drops coverage below 85% MUST NOT be merged.
- Unit and component tests MUST use Vitest.
- End-to-end tests MUST use Playwright against the running application and,
  where feasible, the real GuildApplicationAPI backend.

Rationale: a community-facing guild management UI must not regress; enforced
coverage floors make quality an invariant rather than an aspiration.

### VIII. Domain-Driven Modular Architecture

Modularity and separation of concerns MUST structure the entire application:

- **Smart vs. dumb components**: stateful container (smart) components MUST be
  separated from pure presentation (dumb) components. Smart components handle
  data fetching, service injection, and state; dumb components interact only
  via `@Input()`/`@Output()`, keeping UI elements reusable and testable.
- **Domain-Driven Design organization**: code MUST be organized around
  business domains (e.g., auth, roster, events, points, loot, calendar)
  instead of technical file types (e.g., a global `components/` or
  `services/` folder), to keep the codebase scalable and cohesive.
- **Feature-based lazy loading**: feature routes MUST be lazy-loaded to
  minimize initial bundle size and speed up bootstrap.

Rationale: separation of concerns and domain cohesion are the primary
defenses against entanglement as the UI grows; they also make the smart/dumb
split directly testable.

## Technology & Testing Standards

- **Platform**: Angular 22 (TypeScript, strict mode), scaffolded as a Visual
  Studio JavaScript project (`GuildApplicationUI.esproj`) inside
  `GuildApplicationUI.slnx`.
- **Containerization**: The application MUST be containerized with Docker
  targeting Linux; production deployments MUST run the containerized build,
  consistent with the GuildApplicationAPI microservice container strategy.
- **System documentation**: The repository MUST maintain system documentation
  under `docs/`:
  - **UML diagrams** covering the core architecture and user flows (at
    minimum: a component diagram of the application's domains and state
    architecture, and sequence diagrams for the primary user journeys).
  - **A high-level integration diagram** depicting the system flows this
  frontend participates in — the GuildApplicationAPI endpoints, the Discord
  OAuth sign-in flow, and the data flows consumed by each feature domain.
  Documentation MUST be updated in the same pull request as any change that
  alters the architecture or an integration surface.
- **Component framework**: Spartan UI (`spartan.ng`) on Tailwind CSS and the
  Angular CDK. No other component library may be introduced.
- **Brand palette**: The application's color scheme MUST use the brand blue
  `#2754F5` as the primary accent, white `#FFFFFF` for bright space, and a
  warm gray or charcoal for neutral surfaces and text — grounding the bright
  space with a clean, modern transition. These colors MUST be defined as
  Tailwind theme tokens (consumed by Spartan UI theming); introducing colors
  outside this palette requires an explicit brand exception.
- **Licensing**: all runtime and dev dependencies MUST be free/open-source;
  paid or commercially licensed packages are prohibited.
- **Real-time communication**: the SignalR JavaScript client MUST be used for
  WebSockets-based real-time functionality (chat, presence, live updates),
  connecting to GuildApplicationAPI's SignalR hubs.
- **API access**: HTTP calls to the backend MUST go through typed Angular
  services (one service per backend domain), never from components directly.
- **State management**: NgRx MUST be used for domain and cross-cutting
  application state (store, selectors, effects); component-local UI state uses
  Angular signals. Prefer NgRx's signal-based APIs where available.
- **Linting**: Angular ESLint MUST be enabled alongside strict TypeScript
  compiler options; lint failures block the build.
- **Unit tests**: Vitest with the 85% minimum coverage floor enforced via
  automated coverage measurement.
- **End-to-end tests**: Playwright.
- **Accessibility**: Spartan UI primitives MUST keep their built-in ARIA
  behaviors; components MUST remain keyboard-navigable.

## Development Workflow & Quality Gates

- **Branch & PR workflow (NON-NEGOTIABLE)**: all work MUST be done on a
  feature branch — direct commits to `main` are prohibited. A pull request
  MUST be created and reviewed prior to merging to `main`; merges without
  a PR are prohibited.
- Pull requests that change the architecture or an integration surface MUST
  include updates to the system documentation (UML diagrams and the
  integration diagram) per the System documentation standard.
- **PR–ticket traceability (NON-NEGOTIABLE)**: every pull request MUST be
  recorded in the comments section of its respective GitHub ticket — a
  comment linking the PR when it is opened, and a follow-up comment noting
  the merge outcome. A ticket MUST always reflect the PRs that implement its
  work.
- All work follows the Spec Kit flow: constitution → specify → plan → tasks →
  implement, with `/speckit.clarify`, `/speckit.analyze`, and
  `/speckit.checklist` available to de-risk and validate artifacts.
- A feature or fix is complete only when its unit tests pass, coverage is at
  or above 85%, and its Playwright end-to-end tests (where applicable) pass.
- Code review MUST verify compliance with every principle in this
  constitution before approval; complexity outside these rules must be
  justified in writing.
- Refactoring toward SOLID/DRY compliance is performed as part of feature
  work, not deferred indefinitely.

## Governance

- This constitution supersedes all other engineering practices in this
  repository; where a conflict arises, the constitution wins.
- **Amendment procedure**: any amendment requires (1) a written proposal
  describing the change and its impact, (2) maintainer approval, and
  (3) a migration plan for code affected by the change, recorded as an
  amendment to this file.
- **Versioning policy**: the constitution uses semantic versioning —
  MAJOR for backward-incompatible principle removals/redefinitions,
  MINOR for new principles or materially expanded guidance,
  PATCH for clarifications and non-semantic refinements.
- **Compliance review**: all pull requests and code reviews MUST verify
  constitution compliance, including the 85% coverage gate and the
  free/OSS-only dependency constraint.

**Version**: 1.5.0 | **Ratified**: 2026-09-25 | **Last Amended**: 2026-09-25