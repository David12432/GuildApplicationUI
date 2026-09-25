# Architecture Documentation

System documentation for GuildApplicationUI, per the constitution v1.5.0
*System documentation* standard. Diagrams use the **C4 model** (C1–C4) in
Mermaid format, so they render on GitHub and stay diffable.

| Level | File | What it shows |
|---|---|---|
| **C1 — System Context** | [c1-system-context.md](c1-system-context.md) | The guild management system and everything it touches (users, backend API, Discord identity, future SignalR) |
| **C2 — Containers** | [c2-container.md](c2-container.md) | The deployable units: browser SPA, backend API service, SQL Server, and how they communicate |
| **C3 — Components** | [c3-component.md](c3-component.md) | The frontend's internal structure: core, Spartan UI primitives, shared, and the nine feature domains |
| **C4 — Code** | [c4-code.md](c4-code.md) | Code-level view of a representative domain (roster): the smart/dumb + NgRx pattern every domain follows |
| **Sequences** | [sequences.md](sequences.md) | Sequence diagrams for the primary user journeys (Discord sign-in, event bulk award, roster browse) |

## Maintenance rule (constitution v1.5.0)

Any pull request that changes the architecture or an integration surface MUST
update the affected diagram in the same PR. Sources of truth these diagrams
are derived from:

- `specs/001-guild-management-ui/plan.md` — structure decisions
- `specs/001-guild-management-ui/contracts/` — API client and route contracts
- `specs/001-guild-management-ui/data-model.md` — DTOs and state slices
- `GuildApplicationAPI/specs/0001-guild-management-api/spec.md` — backend surface

## C4 conventions used

- C1/C2/C3 are Mermaid flowcharts styled with C4 semantics (person, system,
  container, component) rather than Mermaid's deprecated C4 syntax
- C4 uses Mermaid `classDiagram`
- Dashed arrows indicate planned/future interactions; solid arrows are v1
- Every diagram names its abstraction level in the title