# Sequence Diagrams — Primary User Journeys

**Level:** UML sequence diagrams (constitution v1.5.0 System documentation
standard: sequence diagrams for the primary user journeys).
Derived from the spec's user stories (US1, US3, US2) and
contracts/api-client.md.

## 1. Discord Sign-In (US1)

```mermaid
sequenceDiagram
    actor User as Guild user
    participant SPA as GuildApplicationUI
    participant API as GuildApplicationAPI
    participant Discord as Discord OAuth

    User->>SPA: opens app (unauthenticated)
    SPA->>SPA: AuthGuard redirects to /signin with returnUrl
    User->>SPA: clicks Sign in with Discord
    SPA->>API: GET /api/v1/auth/login?returnUrl=...
    API-->>User: 302 redirect to Discord authorize
    User->>Discord: authorizes (or denies)
    alt consent denied
        Discord-->>API: callback with error param
        API-->>User: 302 to returnUrl with error indicator
        API-->>SPA: renders friendly sign-in error (no session)
    else consent granted
        Discord-->>API: callback with authorization code
        API->>Discord: code exchange + users/@me (5s timeout budget)
        Discord-->>API: access token + Discord profile
        API->>API: create/load identity + active membership (role)
        API-->>User: session cookie + redirect to returnUrl
        SPA->>API: GET /api/v1/auth/me
        API-->>SPA: user + role
        SPA-->>User: role-gated shell renders
    end
```

## 2. Event Bulk Point Award (US3, spec FR-012)

```mermaid
sequenceDiagram
    actor Officer as Officer
    participant SPA as GuildApplicationUI
    participant API as GuildApplicationAPI
    participant DB as SQL Server (append-only ledger)

    Officer->>SPA: opens event detail, clicks Award Points
    SPA->>SPA: bulk-award dialog: default amount + overrides
    Officer->>SPA: enters 4 default, 2 override for one attendee, submits
    SPA->>SPA: disables submit (double-click guard), generates idempotencyKey
    SPA->>API: POST /api/v1/events/{id}/awards/bulk (default, overrides, key)
    API->>API: validate attendees + awards
    API->>DB: one ledger entry per attendee (append-only)
    DB-->>API: per-attendee results
    API-->>SPA: 200 per-attendee award summary
    SPA-->>Officer: result confirmation (override=2, others=4)
    note over SPA,API: identical replay with same key returns original summary,<br/>no new ledger entries (spec FR-008/FR-012)
```

## 3. Roster Browse with Filters (US2, spec FR-006)

```mermaid
sequenceDiagram
    actor Member as Member
    participant SPA as GuildApplicationUI
    participant Store as NgRx roster slice
    participant API as GuildApplicationAPI

    Member->>SPA: navigates to /roster (lazy route loads)
    SPA->>Store: dispatch loadRoster (initial filters)
    Store->>API: GET /api/v1/roster?search=&class=&page=1
    API-->>Store: PagedResult<Player> (mains + nested alts, totals)
    Store-->>SPA: entity state updated
    SPA-->>Member: roster table renders (loading skeleton -> data)
    Member->>SPA: filters by class + level range
    SPA->>Store: dispatch loadRoster (updated filters)
    Store-->>SPA: new page state
    SPA-->>Member: table updates; filter chips shown, clearable
    note over SPA: empty state / retryable error states per FR-005;<br/>Export button exports the current filtered view to XLSX (FR-029)
```

## Notes

- All API responses carry **UTC** timestamps; `LocalTimePipe` renders them in
  the user's configured timezone (spec FR-025) — omitted here for brevity.
- 401 at any step redirects to `/signin` with `returnUrl` (spec US1.6).
- These journeys correspond to spec acceptance scenarios and are covered by
  the Playwright e2e specs (`e2e/us1-auth.spec.ts`, `e2e/us3-events.spec.ts`,
  `e2e/us2-roster.spec.ts`).