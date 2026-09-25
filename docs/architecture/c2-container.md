# C2 — Container Diagram

**Level:** C4 model, Level 2 (Containers)
**Represents:** the deployable units of the guild management system and their
interactions, per the constitution v1.4.0 containerization standard.

```mermaid
flowchart TB
    subgraph Browser["User's Browser"]
        SPA["GuildApplicationUI<br/>---<br/>[SPA Container]<br/>Angular 22, TypeScript strict,<br/>Tailwind CSS v4 + Spartan UI,<br/>NgRx, Playwright-e2e'd<br/>---<br/>delivered as a Docker/Linux<br/>container image"]
    end

    subgraph BackendDeployment["GuildApplicationAPI Deployment - .NET Aspire orchestration, Docker/Linux"]
        API["GuildApplicationAPI<br/>---<br/>[API Container]<br/>.NET 10 minimal API,<br/>onion architecture,<br/>EF Core + LINQ-to-Entities<br/>---<br/>REST /api/v1, cookie sessions,<br/>Discord:UseStubAuth dev stub"]
        DB[("SQL Server<br/>[Database Container]<br/>database-per-service<br/>GuildManagementDb")]
        AppHost["Aspire AppHost<br/>[Orchestration]<br/>service discovery, orchestration"]
    end

    Discord["Discord<br/>[External]<br/>OAuth 2.0 provider"]

    MemberOfficer["Guild Users<br/>Member / Officer / Guild Leader"]
    MemberOfficer -->|"HTTPS"| SPA
    SPA -->|"HTTPS / JSON<br/>/api/v1 with cookie session<br/>401 re-auth redirect"| API
    API -->|"EF Core / SQL"| DB
    API -->|"OAuth code exchange<br/>users/@me profile fetch"| Discord
    AppHost -.->|"orchestrates"| API
    AppHost -.->|"provisions"| DB
    SPA -.->|"SignalR WebSockets<br/>planned, not v1"| API

    style SPA fill:#2754F5,color:#FFFFFF
    style API fill:#555555,color:#FFFFFF
```

## Notes

- **SPA container**: the Angular application is built to static assets and
  served from a Docker/Linux image (tasks.md T077, spec NFR-005); the
  production build is what the container runs.
- **API container**: owned by the GuildApplicationAPI repository — this
  diagram records only the integration surface the UI depends on
  (contracts/api-client.md is the authoritative consumption contract).
- **Sessions**: cookie-based with `withCredentials`; dev uses a proxy for
  `/api` (research.md R5 — swap point if the backend chooses tokens).
- **Times**: the API returns UTC; conversion to the user's configured
  timezone happens inside the SPA (research.md R6).