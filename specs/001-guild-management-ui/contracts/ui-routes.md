# UI Route Contract

**Date**: 2026-09-25 | **Spec**: [spec.md](spec.md)

Every route is deep-linkable (spec US1 scenario 8), lazy-loaded per feature
(constitution VIII), and role-gated for navigation visibility while treating
the API as authoritative (spec FR-002). Roles: **M** = Member,
**O** = Officer, **L** = Guild Leader.

| Route | View | Roles (nav visibility) | Spec anchor |
|---|---|---|---|
| `/` | Personal dashboard — upcoming entries, own characters + standings, recent events | M+ | FR-027 |
| `/signin` | Sign-in with Discord (+ error states) | anonymous only | FR-001 |
| `/roster` | Roster list — search, filters, pagination, mains with grouped alts | M+ | FR-006 |
| `/roster/characters/:id` | **Character detail hub** — standings, ledger, progression, loot (tabs/sections) | M+ | FR-024 |
| `/roster/register` | Register own character (member+); edit any character (officer+) | M+ | FR-007 |
| `/roster/approvals` | Pending character approvals queue | O+ | FR-008 |
| `/roster/claims` | Unlinked characters + claim flow; claims queue (officer tab) | M (claim) / O+ (queue) | FR-009 |
| `/events` | Events list (paged, filterable) | M+ | FR-010 |
| `/events/new` | Create event | O+ | FR-010 |
| `/events/:id` | Event detail — attendance, roles, bulk awards, corrections, summary | M (view) / O+ (mutate) | FR-010–FR-013, FR-028 |
| `/points` | Standings explorer + leaderboard (date windows, sort by balance) | M+ | FR-014 |
| `/points/adjustments/new` | Officer adjustment dialog/route (amount + reason) | O+ | FR-015 |
| `/loot` | Loot history (filters: character, date range) | M+ | FR-016 |
| `/loot/new` | Record loot award (event-linked) | O+ | FR-016 |
| `/progression` | Flag-filtered character query ("who is keyed for X") | M+ | FR-018 |
| `/progression/definitions` | Flag definition management | L | FR-018 |
| `/analytics` | Roster stats + event summaries | M+ | FR-019 |
| `/calendar` | Calendar month view + upcoming | M+ | FR-020 |
| `/settings` | User settings — timezone preference | M+ | FR-025 |

## Route guards

- `AuthGuard`: unauthenticated → `/signin` with `returnUrl` (spec US1.1).
- `RoleGuard(role)`: blocks route activation for insufficient roles while
  nav items are also hidden (defense in depth; server still enforces 403).
- Data-resolver guards hydrate NgRx slices before activation to keep route
  changes instant (NFR-002).

## Shell contract

All authenticated routes render inside the app shell (`core/shell`):
collapsible sidebar (grouped by domain), breadcrumb trail reflecting the
current route, avatar menu (name, role, settings link, sign out), and
Spartan UI primitives throughout — dialogs for confirmations/destructive
actions, sheets for create/edit forms, selects for pickers (spec FR-004).

## Empty/error/loading states

Every data route implements the triad: skeleton/spinner loading, empty-state
guidance (e.g., new guild), and retryable error — no blank screens (FR-005,
SC-006).

## Export affordance

Roster, points, loot, and calendar views expose an "Export XLSX" action
respecting active filters (FR-029), via the shared `ExportService`
(research R2).