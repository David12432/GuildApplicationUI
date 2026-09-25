# Angular UI Framework Research

**Purpose:** Evaluate UI component frameworks for the Angular frontend of the
Guild Management Application (guild applications, events/points, loot tracking,
SignalR-powered chat and presence).

**Status:** Decided — Spartan UI chosen (2026-09-25). Retained for reference.

**Scope note (2026-09-25):** This decision applies to the Angular frontend,
which lives in **this repository** (GuildApplicationUI). It is intentionally
not part of the backend repo's constitution (GuildApplicationAPI governs
backend concerns only).

**Last updated:** 2026-09-25

---

## Evaluation Criteria

| Criterion | Weight | Notes |
|---|---|---|
| Out-of-the-box modern aesthetic | High | App should feel like a modern SaaS/community product, not an enterprise 2015 form |
| Component breadth (tables, calendars, charts) | High | Rosters, event calendars, loot/points dashboards are core |
| Active maintenance / Angular version support | High | Must track latest Angular (signals, standalone, new control flow) |
| Theming & dark mode | Medium | Design tokens preferred |
| Real-time UI ergonomics (SignalR binding) | Medium | Chat, presence, live updates |
| Licensing cost | **Hard requirement — MUST be free/OSS** | No paid or commercial-license frameworks; per project decision 2026-09-25 |
| Tailwind compatibility | Low–Medium | Decide Tailwind adoption first |

---

## Candidates

### 1. Spartan UI (`spartan.ng`) — most modern aesthetic

- The Angular equivalent of **shadcn/ui**: built on Tailwind CSS + Angular CDK
- Components are copied into your codebase — full ownership, no black-box library
- Dark mode, design tokens, Radix-inspired look out of the box
- Backed by the Angular Analog team
- **Best for:** a bespoke, modern community-app feel
- **Trade-offs:** newer project; fewer exotic/complex components (e.g., pivot
  tables); you own the component code and its maintenance

### 2. PrimeNG — best breadth + active development

- 90+ components including DataTables, charts, calendars, file upload
- Modern token-based theming architecture, Tailwind integration, multiple presets
- Free, very actively maintained, huge community
- **License: MIT (core library, themes, theming APIs).** PrimeTek monetizes
  adjacent offerings (premium templates, PrimeBlocks, Figma kits, PRO support),
  not the core. Verify no licensing changes before deciding — see Open
  Questions.
- **Best for:** data-heavy admin/dashboard interfaces — rosters, loot logs,
  event calendars — with least friction
- **Trade-offs:** "PrimeNG look" is recognizable; heavier styling system to learn

### 3. Angular Material — safest, official

- Maintained by the Angular team; guaranteed compatibility with the latest Angular
- Material 3 theming APIs available
- The underlying **CDK** is excellent regardless (dialogs, overlays, a11y)
- **Best for:** long-term stability, minimal risk, Material-acceptable aesthetics
- **Trade-offs:** most conservative out-of-the-box look; fewer complex data
  components

### 4. Taiga UI — dark horse

- 130+ components, deep customizability, genuinely modern feel
- Strong docs, active releases, production-proven at scale
- **Trade-offs:** smaller North American community

### 5. NG-ZORRO — Ant Design for Angular

- 70+ components, polished enterprise (Ant) aesthetic, frequent releases
- **Best for:** dense, information-rich admin layouts
- **Trade-offs:** enterprise look may not suit a gaming-community brand

### 6. ~~Kendo UI for Angular~~ — EXCLUDED (paid)

- Very complete component set, professional support, Figma kits
- **EXCLUDED:** commercial license — this project requires a free framework
  (per decision 2026-09-25). Nothing paid.

---

## Avoid

| Library | Reason |
|---|---|
| **Kendo UI for Angular** | Commercial license — project requires a free framework (nothing paid) |
| **Clarity (Angular)** | Deprecated/archived; Clarity moved to web components. Not viable for new Angular work |
| **Nebular** | Largely stalled development |

---

## Comparison Matrix

| | Spartan UI | PrimeNG | Angular Material | Taiga UI | NG-ZORRO |
|---|---|---|---|---|---|
| Modern OOTB look | ★★★★★ | ★★★★ | ★★★ | ★★★★ | ★★★★ |
| Component breadth | ★★★ | ★★★★★ | ★★★ | ★★★★★ | ★★★★ |
| Maintenance/velocity | ★★★★ | ★★★★★ | ★★★★★ | ★★★★ | ★★★★ |
| Tailwind-based | ✅ | Partial | ❌ | ❌ | ❌ |
| Dark mode OOTB | ✅ | ✅ | ✅ | ✅ | ✅ |
| License | OSS (free) | OSS (free) | OSS (free) | OSS (free) | OSS (free) |
| Risk | Newer project | Mature | Mature | Niche community | Mature |

---

## Fit for This Project

The guild app's core screens and their framework demands:

| Feature | Demands | Favors |
|---|---|---|
| Roster & member management | Big sortable/filterable tables | PrimeNG, NG-ZORRO |
| Event calendar & scheduling | Calendar/scheduler components | PrimeNG |
| Loot/points dashboards | Charts, data grids | PrimeNG |
| SignalR chat & presence | Lists, avatars, badges, overlays | Any (CDK helps) |
| Application review flows | Forms, steppers, dialogs | Any |
| Community brand feel | Custom theming, dark mode | Spartan UI, Taiga UI |

**Working shortlist:** Spartan UI (if Tailwind) vs PrimeNG (if not / max
breadth). Angular Material as the low-risk fallback. All shortlisted options
are free/OSS — commercial options are excluded per project constraint.

---

## Open Questions

- [x] Adopt Tailwind CSS as the styling foundation? **Resolved 2026-09-25:
      yes** — Spartan UI is built on Tailwind, so Tailwind is adopted with it
- [ ] Validate Spartan UI accessibility with axe (a11y audit on the spike)
- [ ] Prototype cost: build a one-screen spike (event calendar) in Spartan UI
- [ ] SignalR integration: any reactive-state synergy (NgRx signals store)?
- [ ] Verify Spartan UI latest release/GitHub activity — research dated
      2026-09-25 and version currency must be re-checked before implementation
- [x] Verify PrimeNG licensing status: **moot (2026-09-25)** — PrimeNG not
      chosen; Spartan UI selected instead

---

## Decision

**Chosen framework:** Spartan UI (`spartan.ng`) — Angular + Tailwind CSS +
Angular CDK

**Rationale:** Most modern out-of-the-box aesthetic of all free candidates;
shadcn/ui-style component ownership means no black-box library and full control
of component code; built on Tailwind + the Angular CDK; fully free/OSS, which
satisfies the hard "nothing paid" constraint; backed by the Angular Analog team.

**Decided on:** 2026-09-25
