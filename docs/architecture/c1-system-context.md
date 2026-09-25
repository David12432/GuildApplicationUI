# C1 — System Context Diagram

**Level:** C4 model, Level 1 (System Context)
**Represents:** the guild management system and all external actors/systems it
interacts with, as of feature 001 (v1, HTTP-only).

```mermaid
flowchart TB
    Member["Member<br/>guild user with read access<br/>+ own-character management"]
    Officer["Officer<br/>operational management:<br/>events, attendance, loot, points"]
    Leader["Guild Leader<br/>full access including<br/>guild configuration"]
    UI["GuildApplicationUI<br/>[Web Application]<br/>Guild management web frontend<br/>Angular 22 SPA - Docker/Linux"]
    API["GuildApplicationAPI<br/>[Backend System]<br/>.NET 10 microservice system<br/>REST /api/v1: auth, roster, events,<br/>points, loot, progression, calendar"
    Discord["Discord<br/>[External System]<br/>OAuth 2.0 identity provider"]

    Member -->|"uses via browser (HTTPS)"| UI
    Officer -->|"uses via browser (HTTPS)"| UI
    Leader -->|"uses via browser (HTTPS)"| UI
    UI -->|"HTTPS / JSON requests<br/>cookie-based session"| API
    API -->|"OAuth 2.0 authorization-code flow"| Discord
    UI -.->|"WebSockets / SignalR<br/>(planned future feature, not v1)"| API

    style UI fill:#2754F5,color:#FFFFFF
    style API fill:#555555,color:#FFFFFF
```

## Notes

- **Actors**: one person, three roles (Member, Officer, Guild Leader) — the
  role matrix lives in `specs/001-guild-management-ui/contracts/ui-routes.md`;
  the API is always the authority on permissions (spec FR-002).
- **Identity**: users sign in with Discord via the backend's OAuth
  authorization-code flow; the UI never handles Discord credentials
  (spec FR-001).
- **Real-time**: dashed line marks the deferred SignalR integration — v1 is
  HTTP request/response only, per the spec assumption and research.md R8.
- **No other external systems** are integrated in v1.