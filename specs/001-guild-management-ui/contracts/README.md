# Contracts: Guild Management Web UI (Feature 001)

**Date**: 2026-09-25 | **Spec**: [spec.md](spec.md)

A SPA exposes two contracts: the HTTP API it consumes (upstream, owned by
GuildApplicationAPI feature 0001) and its route/UI contract (what the browser
sees). Both are documented here.

## Files

- [api-client.md](api-client.md) — the backend endpoints the typed domain
  services call, per feature domain, with error/session expectations.
- [ui-routes.md](ui-routes.md) — the application's routes, role gating,
  lazy-loading, and deep-linking contract.

The authoritative request/response schemas live in the backend repository:
`GuildApplicationAPI/specs/0001-guild-management-api/spec.md` (FR-011/FR-014).
This contract documents **consumption intent**, not duplicated schemas.