# GuildApplicationUI Constitution

This project is the Angular web application (frontend) for the guild
management application. It is built on Angular 22 with Spartan UI as the
component framework (Tailwind CSS + Angular CDK) and consumes the
GuildApplicationAPI backend over SignalR WebSockets and HTTP. This constitution
defines the non-negotiable engineering principles that govern all work in this
repository.

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
- Unit and component tests MUST use the project's configured test runner
  (Jasmine/Karma in the current scaffold).
- End-to-end tests MUST use Playwright against the running application and,
  where feasible, the real GuildApplicationAPI backend.

Rationale: a community-facing guild management UI must not regress; enforced
coverage floors make quality an invariant rather than an aspiration.

## Technology & Testing Standards

- **Platform**: Angular 22 (TypeScript, strict mode), scaffolded as a Visual
  Studio JavaScript project (`GuildApplicationUI.esproj`) inside
  `GuildApplicationUI.slnx`.
- **Component framework**: Spartan UI (`spartan.ng`) on Tailwind CSS and the
  Angular CDK. No other component library may be introduced.
- **Licensing**: all runtime and dev dependencies MUST be free/open-source;
  paid or commercially licensed packages are prohibited.
- **Real-time communication**: the SignalR JavaScript client MUST be used for
  WebSockets-based real-time functionality (chat, presence, live updates),
  connecting to GuildApplicationAPI's SignalR hubs.
- **API access**: HTTP calls to the backend MUST go through typed Angular
  services (one service per backend domain), never from components directly.
- **Unit tests**: Jasmine/Karma with the 85% minimum coverage floor enforced
  via automated coverage measurement.
- **End-to-end tests**: Playwright.
- **Accessibility**: Spartan UI primitives MUST keep their built-in ARIA
  behaviors; components MUST remain keyboard-navigable.

## Development Workflow & Quality Gates

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

**Version**: 1.0.0 | **Ratified**: 2026-09-25 | **Last Amended**: 2026-09-25