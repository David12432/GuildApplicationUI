# C3 — Component Diagram

**Level:** C4 model, Level 3 (Components)
**Represents:** the frontend application's internal component structure —
the DDD organization mandated by constitution Principle VIII and plan.md.

```mermaid
flowchart TB
    subgraph Core["core/ - cross-cutting infrastructure"]
        direction LR
        Auth["auth<br/>AuthGuard, RoleGuard,<br/>auth facade, role signal"]
        Http["http<br/>ApiBaseService,<br/>auth + error interceptors<br/>ProblemDetails mapping"]
        ShellC["shell<br/>sidebar, breadcrumb,<br/>avatar menu"]
        TimeC["time<br/>TimeDisplayService,<br/>LocalTimePipe"]
    end

    subgraph UiPrimitives["ui/ - Spartan UI owned primitives"]
        Primitives["dialog - sheet - sidebar - breadcrumb - avatar<br/>select - table - tabs - tooltip - pagination<br/>button - input - checkbox - dropdown - card - form<br/>styled with brand tokens"]
    end

    subgraph Shared["shared/ - reusable building blocks"]
        Models["models<br/>readonly DTOs,<br/>PagedResult, ProblemDetails"]
        Export["export<br/>ExportService - ExcelJS"]
        States["state components<br/>loading / empty / retryable-error"]
    end

    subgraph Features["features/ - business domains, lazy-loaded routes, one NgRx slice each"]
        direction LR
        F1["dashboard"]
        F2["roster<br/>+ character detail hub"]
        F3["events<br/>attendance, bulk awards"]
        F4["points<br/>standings, leaderboard"]
        F5["loot"]
        F6["progression"]
        F7["analytics"]
        F8["calendar"]
        F9["settings<br/>timezone"]
    end

    User["Guild user"]
    User -->|"routes, guards"| Auth
    Features -->|"inject services"| Http
    Features -->|"template pipe"| TimeC
    Features -->|"render inside"| ShellC
    Features -->|"compose UI"| Primitives
    Features -->|"use DTOs + states"| Models
    Features -->|"XLSX export"| Export
    Http -->|"per-domain typed services<br/>in each feature"| Features

    style Features fill:#2754F5,color:#FFFFFF
    style Core fill:#444444,color:#FFFFFF
    style Primitives fill:#666666,color:#FFFFFF
    style Shared fill:#666666,color:#FFFFFF
```

## Notes

- **Smart vs dumb (Principle VIII)**: containers at feature roots read NgRx
  signal selectors and dispatch actions; presentation components live in
  `shared/` and `ui/` and communicate only via `@Input()`/`@Output()`.
- **One slice per domain**: each `features/<domain>/` owns its API service,
  NgRx slice (Store + Effects + entity + signal selectors), and views —
  data-model.md documents the nine slices.
- **Error contract**: `core/http` interceptors translate ProblemDetails into
  the per-domain UX (inline 400s, 401 redirect, friendly 403/409, 429 pacing,
  502/503 states) per contracts/api-client.md.
- **Cross-domain linking**: the character detail hub (roster) hosts tabs that
  other domains wire into (points, loot, progression) per tasks.md T033.