# Feature Specification: Guild Management Web UI (Roster, Events, Points, Loot, Progression, Calendar)

**Feature Branch**: `001-guild-management-ui`

**Created**: 2026-09-25

**Status**: Draft

**Input**: User description: "We will be created an Angular based front end application that is being used to manage a guild in the context of video games. This is a microservice architecture and will be consumeing web apis... utilizing spartan UIs components such as sheets, Dialog, Avatar, Select, Sidebar, Breadcrumb, etc. Please review the requirements doc found here -- E:\Repos\GuildApplicationAPI\specs\0001-guild-management-api."

**Reference**: All functionality is grounded in the backend specification
`E:\Repos\GuildApplicationAPI\specs\0001-guild-management-api\spec.md` (API feature 0001). This UI spec describes the web experience built on top of those APIs.

## Clarifications

### Session 2026-09-25

- Q: Should the app provide one consolidated character detail page that gathers that character's standings, point ledger, progression, and loot history, or keep those as separate surfaces? → A: One consolidated character detail page (tabs/sections in a single hub) — the character page is the anchor for all character-centric data.
- Q: When displaying an event's start time, should the app show the stored timezone label, convert to the viewer's local timezone, or both? → A: The API always returns UTC times; the UI displays times converted to the timezone each user configures in their settings page (officers still enter times with their original timezone label when creating events/entries).
- Q: What should the main dashboard (the post-sign-in landing page) show? → A: A personal dashboard — upcoming calendar entries, the signed-in user's own characters with their point standings, and recent events, each linking to its full section.
- Q: Should Officers be able to edit or remove attendance and recorded awards after the fact? → A: Yes — attendance (group, leader flag, roles) and awards are editable/removable from the event screen by Officers at any event status; the point ledger remains append-only (implies backend mutation endpoints — coordinate with GuildApplicationAPI feature 0001).
- Q: Should users be able to export data (roster, standings, loot history, calendar) to CSV or similar in v1? → A: Yes — users can export to an XLSX spreadsheet.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Sign in with Discord and browse a role-aware application (Priority: P1)

A guild member opens the web application in a browser and signs in with their
Discord account. Once signed in, they land on a modern application shell — a
collapsible sidebar for navigating between sections, a breadcrumb showing where
they are, and an avatar menu (profile, sign out). What each user sees and can do
is governed by their guild role: **Members** browse everything and manage only
their own characters; **Officers** additionally run events, attendance, loot,
and points; **Guild Leaders** can do everything, including configuration. Users
never see actions they are not permitted to perform, and the server remains the
final authority on every action.

**Why this priority**: Sign-in and role-aware navigation gate every other story;
the role model defines which controls appear throughout the UI.

**Independent Test**: Can be tested by signing in with a user of each role and
verifying the navigation options, visible actions, and page access match the
role matrix; unauthenticated visits redirect to the sign-in screen.

**Acceptance Scenarios**:

1. **Given** an unauthenticated visitor, **When** they open any page, **Then**
   they are redirected to a sign-in screen that offers Discord sign-in.
2. **Given** a user completes Discord sign-in, **When** the flow returns,
   **Then** they land on the main dashboard signed in, with their name and
   avatar in the shell.
3. **Given** a Member, **When** viewing event, points, or configuration pages,
   **Then** mutating controls are hidden or disabled; read views work.
4. **Given** an Officer, **When** browsing, **Then** operational actions
   (record events, attendance, loot, points) are available; configuration
   actions are hidden.
5. **Given** a Guild Leader, **When** browsing, **Then** all sections and
   configuration actions are available.
6. **Given** a signed-in user, **When** their session expires and they perform
   an action, **Then** they are redirected to sign-in and returned to where
   they were after re-authenticating.
7. **Given** the user's permission denied by the server despite a visible
   control, **When** the server responds with a forbidden error, **Then** a
   clear, friendly error message appears without data loss in the form being
   submitted.
8. **Given** any page, **When** the user navigates, **Then** the browser URL
   reflects the location so pages can be bookmarked, shared, and refreshed.
9. **Given** a signed-in user, **When** they set their display timezone in
   settings, **Then** all event and calendar times render in that timezone
   (converted from the UTC the API returns).
10. **Given** a signed-in user, **When** the dashboard loads, **Then** upcoming
    calendar entries, their own characters with point standings, and recent
    events are shown, each linking to its full section.

---

### User Story 2 - Browse and manage the roster (Priority: P2)

Users browse the guild roster: every player's main character and alts with
class, level, and progression status. The roster is presented as a responsive
list with search by name and filters by class, class category, level range, and
main/alt, with pagination. Members can register and edit their own characters
through a form (name, class, main/alt, level) validated against the guild's
configured class list and level bounds. When the guild requires approval,
members see their pending characters' status, and Officers see an approval
queue. Members can claim imported, unlinked characters; when claim approval is
on, they can track their claim's status.

**Why this priority**: Characters are the referential backbone of events,
points, loot, and progression — the roster is the most-consulted view.

**Independent Test**: Can be tested by signing in as different roles and
verifying roster browsing (search, filters, pagination), self-service character
registration, the officer approval queue, and the claim flow against a seeded
guild.

**Acceptance Scenarios**:

1. **Given** a seeded roster (~1,000 characters), **When** the user opens the
   roster, **Then** players load paginated with mains shown and their alts
   grouped beneath them.
2. **Given** the roster view, **When** the user searches a name or applies
   class/category/level/main-alt filters, **Then** results update and the
   active filters are visible and clearable.
3. **Given** a Member registering a character, **When** they submit an invalid
   name (duplicate, case-insensitive), unconfigured class, or out-of-range
   level, **Then** the form shows the specific field errors returned by the
   server.
4. **Given** the guild's character-approval setting is ON, **When** a Member
   registers a character, **Then** the UI shows it as pending and it does not
   appear in the roster; when an Officer approves it, **Then** it becomes
   visible.
5. **Given** an Officer, **When** opening the approval queue, **Then** pending
   characters list with member name, class, and level, and can be approved or
   rejected.
6. **Given** unlinked imported characters exist, **When** a Member searches or
   browses them and claims one, **Then** ownership transfers immediately
   (approval OFF) or the claim appears in the officer claims queue (approval
   ON) with approve/reject actions.
7. **Given** an Officer or Guild Leader, **When** editing any character or
   reassigning main/alt, **Then** it is permitted; a Member editing another
   player's character is blocked by the server with a friendly error.
8. **Given** the roster is loading, empty, or failed to load, **When** each
   state occurs, **Then** the UI shows a loading indicator, an empty state
   with guidance, or a retryable error — never a blank screen.

---

### User Story 3 - Run events: schedule, attendance, and point awards (Priority: P3)

Officers create and manage events — the guild's scheduled activities (e.g.
raids) — with name, location, date, and start time with timezone. On an event
page, officers record which characters attended, in which group, and whether
each was a group leader; they assign configurable event roles (e.g. Event
Leader, Loot Leader, Main Tank) to attendees. Officers post bulk point awards
with one default amount, optional per-attendee overrides, and see each
attendee's award result. Events carry a status (Scheduled/Completed/Cancelled);
cancelling keeps records for audit but clearly signals that the event no
longer counts toward totals.

**Why this priority**: Events drive the points economy; this is the Officers'
daily working screen.

**Independent Test**: Can be tested by an Officer creating an event, recording
attendance in groups, assigning roles, posting a bulk award with an override,
and verifying the event summary and each attendee's point result.

**Acceptance Scenarios**:

1. **Given** an Officer, **When** creating an event with name, location,
   date, and start time + timezone label, **Then** it appears in the events
   list after validation succeeds.
2. **Given** an event, **When** the officer adds attendees, **Then** a
   character picker (searchable, roster-driven) offers main and alt
   characters, and each attendee lands in the selected group with a
   group-leader toggle.
3. **Given** an attendee picker, **When** the same character is selected
   twice for one event, **Then** the UI prevents the duplicate or surfaces the
   server's conflict error clearly.
4. **Given** an event, **When** an officer assigns event roles from the
   guild's configured role list to attendees, **Then** assignments display on
   the event summary.
5. **Given** recorded attendance, **When** the officer posts a bulk award of N
   points with one attendee overridden to M, **Then** the confirmation shows
   the default amount for everyone and the override for that attendee.
6. **Given** an accidental double-submit of the same bulk award, **When** the
   second submission is sent, **Then** the UI does not create a second set of
   awards (buttons disable during submission; idempotency key reuse returns
   the original result).
7. **Given** an officer, **When** changing an event's status to Cancelled,
   **Then** a confirmation dialog warns that the event will be excluded from
   totals, and the event page clearly displays its cancelled status.
8. **Given** an event with attendance, **When** viewing its summary, **Then**
   attendee counts per class/category are shown without manual math.
9. **Given** a misrecorded attendee or wrong group assignment, **When** an
   Officer edits or removes it on the event screen, **Then** the attendance
   list and the event summary update, and the ledger history remains
   append-only.

---

### User Story 4 - View points standings and leaderboard (Priority: P4)

Users view each character's point standing — total earned, total spent,
balance, events attended, and attendance percentage — over a selectable date
window. The standings leaderboard is sortable by balance and paginated, letting
members answer "where do I rank?" and officers audit the economy at a glance.
Point history (event awards, loot charges, adjustments) is visible as a
transparent ledger per character; the UI never allows editing or deleting
history.

**Why this priority**: The points economy is the system's core; transparent
standings build trust in it.

**Independent Test**: Can be tested by viewing a character with known awards
and charges, verifying earned/spent/balance and attendance % for a chosen date
window, and browsing the leaderboard sorted by balance.

**Acceptance Scenarios**:

1. **Given** a character with one event award of 4 and one loot charge of 3,
   **When** viewing their standings, **Then** earned = 4, spent = 3,
   balance = 1 are displayed.
2. **Given** the standings view, **When** the user selects or customizes the
   date window, **Then** the numbers and attendance % update for that window.
3. **Given** the leaderboard, **When** sorted by balance, **Then** ranking is
   displayed paginated with the signed-in user's own position easy to find.
4. **Given** a character with a negative balance, **When** viewing standings,
   **Then** the negative balance displays correctly (valid state).
5. **Given** a character's ledger, **When** viewing it, **Then** entries show
   type (event award, loot charge, adjustment), amount, date, and source
   (event or officer) — with no edit or delete affordances anywhere.
6. **Given** an Officer, **When** recording a manual adjustment, **Then** a
   dialog requires an amount and reason, and the new entry appears in the
   character's ledger.

---

### User Story 5 - Record and browse loot awards (Priority: P5)

Loot leaders record which item went to which character on which event, the
points charged, and the method (purchase, free, random roll). Anyone can browse
loot history filtered by date range or character, sorted newest first and
paginated.

**Why this priority**: Loot history drives point spending and reconciliation.

**Independent Test**: Can be tested by an Officer recording a charged purchase
and a free award, then browsing history by character and date range.

**Acceptance Scenarios**:

1. **Given** an event, **When** an officer records a loot award (character,
   item, amount, method), **Then** the award appears in the event's loot list
   and in global loot history.
2. **Given** a free or random-roll award, **When** recorded, **Then** the
   method label distinguishes it from purchases (amount shown as 0 or
   "free").
3. **Given** loot history, **When** filtered by character or date range,
   **Then** entries display sorted newest first, paginated.
4. **Given** a character not on the roster, **When** attempted in the loot
   form, **Then** the character picker only offers existing roster characters.

---

### User Story 6 - Track character progression (Priority: P6)

Officers record each character's progression against the guild's defined flags
(e.g. zone keys as booleans, multi-step key components, status enums like
epic Yes/No/Unknown), and users query progression across the roster — "who is
keyed for X?" Flag definitions are managed by Guild Leaders through the same
configuration surfaces.

**Why this priority**: Progression gates event eligibility.

**Independent Test**: Can be tested by an Officer setting flag values on
characters and a user filtering the roster by a flag state, seeing only
matching characters.

**Acceptance Scenarios**:

1. **Given** a character's detail view, **When** an Officer edits progression,
   **Then** the UI presents each flag with its definition-appropriate control
   (toggle, multi-step, status select) and rejects out-of-state values with
   inline validation.
2. **Given** the roster or a progression view, **When** filtering by flag and
   state (e.g. "Old Sebilis Key = keyed"), **Then** only matching characters
   return.
3. **Given** a main and an alt with different flag values, **When** each is
   viewed, **Then** values display per character independently.
4. **Given** a Guild Leader, **When** defining a new flag (boolean, multi-step
   with states, or enum states), **Then** a configuration form accepts the
   name and state set.

---

### User Story 7 - See roster and event analytics (Priority: P7)

Users view computed dashboards: roster composition per class and category,
split by main/alt and by "event-ready" (a configurable level threshold), plus
per-event attendance summaries. Numbers are computed by the backend — the UI
presents them, it never recalculates.

**Why this priority**: Derived data presented well replaces manual
spreadsheet math.

**Independent Test**: Can be tested by viewing the dashboard against a seeded
mixed roster and verifying the class/category counts and event summaries
match the source data.

**Acceptance Scenarios**:

1. **Given** a mixed roster, **When** viewing roster analytics, **Then**
   counts per class and category, split by main/alt and event-ready, display
   in a visual, scannable form.
2. **Given** an event, **When** viewing its summary, **Then** attendee count
   and class breakdown match the event's attendee list.
3. **Given** analytics loading, **When** data is large, **Then** the view
   remains responsive with clear loading states.

---

### User Story 8 - Maintain the event calendar (Priority: P8)

Officers maintain calendar entries — scheduled event days, server events,
guild events, community days — with date, optional time and timezone label.
All users browse a month view and an upcoming list so members know when
things happen.

**Why this priority**: Scheduling awareness detached from the points pipeline
— lowest priority.

**Independent Test**: Can be tested by an Officer creating entries for a month
and a user browsing the month view and upcoming list.

**Acceptance Scenarios**:

1. **Given** a month, **When** the user opens the calendar, **Then** all
   entries display with date, type, and notes in a familiar month grid plus
   an upcoming list.
2. **Given** an Officer, **When** creating or editing an entry with an
   optional start time, **Then** the timezone label is recorded alongside the
   time.
3. **Given** an Officer, **When** deleting an entry, **Then** a confirmation
   is required and the entry disappears from views.

### Edge Cases

- **Session expiry mid-task** — the user is redirected to sign-in and
  returned to their in-progress location; typed form data is not silently
  lost where technically avoidable.
- **Server validation errors (400)** — field-level errors from the backend
  map onto the offending form fields with human-readable messages.
- **Permission denied (403)** — if the server rejects an action the UI
  offered, a friendly error appears; the UI treats role rules as advisory
  (hide/disable) and the server as authoritative.
- **Rate limiting (429)** — the UI surfaces a "too many attempts" message and
  paces retries rather than silently failing.
- **Backend unavailable (503)** — a clear "service unavailable" state with
  retry replaces dead UI.
- **Upstream Discord failure during sign-in** — a friendly explanation and
  retry on the sign-in screen; no partial sign-in state.
- **Empty states** — new guild with no roster/events/loot shows helpful
  guidance instead of blank pages.
- **Large data** — roster of ~1,000 characters and long loot history must
  remain usable via pagination and filtering.
- **Cancelled events** — visibly marked and excluded from standings,
  attendance %, and analytics everywhere they appear.
- **Competing claims** — when claim approval is ON and several members claim
  the same character, officers see all pending claims; approving one rejects
  the rest, and the outcome is visible to the claimant.
- **Multi-membership accounts** — not supported in v1; the UI surfaces the
  backend's error clearly if it occurs.

## Requirements *(mandatory)*

### Functional Requirements

**Authentication & session**

- **FR-001**: The application MUST authenticate users via the backend's
  Discord OAuth flow (redirect-based); the UI MUST NOT handle Discord
  credentials itself and MUST redirect unauthenticated visitors to sign-in and
  return them to their intended location afterward.
- **FR-002**: The UI MUST gate navigation and actions per guild role
  (Member/Officer/Guild Leader) matching the backend's permission matrix —
  hiding or disabling unpermitted actions — while treating the server as the
  final authority and rendering its 401/403 outcomes gracefully.
- **FR-003**: The UI MUST provide session lifecycle affordances: sign out, a
  friendly session-expired experience with re-authentication, and a visible
  current-user identity (name, avatar).

**Application shell & navigation**

- **FR-004**: The application MUST present a consistent, modern shell using
  the project's component library (sidebar navigation, breadcrumbs, avatar
  menu, dialogs, sheets, selects) as defined by the constitution, with every
  route deep-linkable via URL.
- **FR-005**: The UI MUST provide per-view loading, empty, and error states
  (including retry) for every data surface; a blank screen MUST never appear.
- **FR-027**: The main dashboard (post-sign-in landing page) MUST surface, at
  minimum, upcoming calendar entries, the signed-in user's own characters
  with their point standings, and recent events; each surfaced item MUST
  deep-link to its full section.

**Roster**

- **FR-006**: The roster view MUST list players with their main and grouped
  alts (name, class, level), supporting search by name, filters (class,
  category, level range, main/alt), pagination, and clearable filters.
- **FR-007**: Members MUST be able to register and edit their own characters
  through validated forms (guild-configured class list, level bounds,
  case-insensitive name uniqueness), surfacing server field errors inline.
- **FR-008**: The UI MUST support the guild's character-approval workflow:
  members see pending status; Officers see and act on a pending-approvals
  queue (approve/reject).
- **FR-009**: The UI MUST support claiming unlinked imported characters:
  members browse/search unclaimed characters and claim; when claim approval
  is ON, Officers see a claims queue (approve/reject) and claimants see their
  claim status.

**Events**

- **FR-010**: Officers MUST be able to create, edit, and change the status of
  events (Scheduled/Completed/Cancelled) with name, location, date, and start
  time + timezone label, with a confirmation dialog for cancellation.
- **FR-011**: The event detail MUST let Officers record attendance (character
  picker from roster mains/alts, group assignment, group-leader flag) and
  assign the guild's configured event roles to attendees.
- **FR-012**: Officers MUST be able to post a bulk point award with a default
  amount and optional per-attendee overrides in one operation, with
  submission guards against accidental double-submission and a per-attendee
  result confirmation.
- **FR-013**: Event views MUST display server-computed summaries (attendee
  counts per class/category) without client-side recalculation.
- **FR-028**: Officers MUST be able to edit and remove attendance records and
  event-role assignments, and correct recorded point awards, from the event
  detail screen at any event status. All corrections MUST go through
  backend-supported operations; the point ledger MUST remain append-only
  wherever displayed — the UI MUST NOT offer direct editing of ledger history.

**Points**

- **FR-014**: The UI MUST display per-character standings (earned, spent,
  balance, events attended, attendance %) over a selectable date window, and
  a sortable-by-balance, paginated leaderboard.
- **FR-015**: The UI MUST display each character's point ledger (typed
  entries with source) read-only — no edit/delete affordances — and MUST
  provide Officers a dialog to record an adjustment with amount and required
  reason.

**Loot**

- **FR-016**: Officers MUST be able to record loot awards (character, item,
  points amount, method: purchase/free/random roll) linked to events, and all
  users MUST be able to browse loot history filtered by character and date
  range, sorted newest first, paginated.

**Progression**

- **FR-017**: The UI MUST let Officers set per-character progression values
  using definition-appropriate controls (boolean, multi-step, enum), with
  inline validation against the flag's state set.
- **FR-018**: The UI MUST let users filter characters by progression flag and
  state (e.g. "keyed for X"); Guild Leaders MUST be able to manage flag
  definitions (name, state-set shape) through configuration forms.

**Analytics & calendar**

- **FR-019**: The UI MUST present roster analytics (counts per class and
  category, split main/alt and event-ready) and per-event attendance
  summaries from server-computed data.
- **FR-020**: The UI MUST present a calendar month view and upcoming list for
  all users, with Officer create/edit/delete of entries (date, optional time +
  timezone label, type, notes) behind confirmations for destructive actions.

**Character detail**

- **FR-024**: The application MUST provide a consolidated character detail
  page for any roster character, gathering that character's standings, point
  ledger, progression values, and loot history in one hub (tabs or sections);
  every character-centric surface elsewhere in the app MUST link into this
  page for detail rather than duplicating it.

**User settings & time display**

- **FR-025**: The application MUST provide a user settings page including,
  at minimum, a display-timezone preference; times returned by the API in UTC
  MUST be displayed converted to the user's configured timezone. For users
  who have not set one, the UI MUST fall back to the browser-detected timezone,
  which the user can override in settings.
- **FR-026**: When Officers create events or calendar entries, the UI MUST
  capture the start time with its timezone label as entered and submit it for
  UTC normalization by the API.

**Data export**

- **FR-029**: Signed-in users MUST be able to export the data views they can
  read — roster, point standings/leaderboard, loot history, and calendar — to
  an XLSX spreadsheet file. Exports MUST respect the filters, search, and date
  window active in the view at the time of export (users export what they
  see), and MUST surface a clear in-progress and completion state.

**Cross-cutting quality**

- **FR-021**: All forms MUST validate client-side for immediate feedback AND
  render server-side validation errors inline per field; destructive actions
  MUST require confirmation dialogs.
- **FR-022**: The UI MUST be keyboard-navigable and preserve the component
  library's built-in accessibility behaviors; interactive controls MUST have
  visible focus states.
- **FR-023**: The UI MUST handle backend rate-limit (429), unavailable (503),
  and upstream-auth-failure responses with clear, human-readable messaging
  and non-destructive retry.

### Non-Functional Requirements

- **NFR-001 (Usability)**: An Officer unfamiliar with the app MUST be able to
  record a complete event with attendance and a bulk point award in under
  5 minutes without training.
- **NFR-002 (Performance)**: On a roster of ~1,000 characters, roster search
  and filter results MUST appear within 2 seconds on typical broadband; route
  changes MUST feel instant.
- **NFR-003 (Responsiveness)**: The application MUST be usable on common
  desktop resolutions first, degrading gracefully to tablet widths; phone
  support is not required in v1.
- **NFR-004 (Availability)**: The UI MUST degrade gracefully when the backend
  is slow or unavailable (per FR-005/FR-023) rather than appearing broken.
- **NFR-005 (Deployment)**: The application MUST be packaged and delivered as
  a containerized build (Docker, Linux), deployable alongside the
  containerized GuildApplicationAPI microservices in the same deployment
  topology.

### Key Entities *(include if feature involves data)*

From the user's perspective (defined authoritatively by the backend spec):

- **User**: the Discord-authenticated person using the app, with an avatar and
  guild role (Member/Officer/Guild Leader).
- **Character**: a main or alt game character — name, class, level, main/alt
  designation, owner, approval status; alts group under their main.
- **Class**: guild-configured class name + category (e.g. categories like
  Tank/Healer/Damage).
- **Event**: a scheduled activity with name/location, date, start time +
  timezone label, status; attendees grouped with group-leader flags; event
  roles assigned to attendees.
- **PointsLedgerEntry**: an immutable point movement (event award, loot
  charge, adjustment) with its source; never editable.
- **PointsStanding** (computed): earned, spent, balance, events attended,
  attendance % over a date window.
- **LootAward**: item awarded to a character on an event, with points
  charged and method.
- **ProgressionFlag (definition + value)**: guild-defined flag (boolean,
  multi-step, or enum states) and each character's state for it.
- **CalendarEntry**: a scheduled entry (type, date, optional time + timezone
  label, notes).
- **GuildSetting**: guild-scoped switches the UI must respect, notably
  member-character approval and unlinked-character claim approval.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: A user of each role (Member, Officer, Guild Leader) can sign in
  and reach their permitted sections within 3 clicks, with impermissible
  actions never offered.
- **SC-002**: An Officer can record a complete event — creation, attendance
  in groups, one event role, and a bulk award with an override — in under
  5 minutes.
- **SC-003**: On a guild seeded with the reference workbook (~1,000
  characters, ~59 events, ~1,000 loot rows), roster search/filter results
  render in under 2 seconds and remain usable via pagination.
- **SC-004**: For at least 20 spot-checked characters, the UI's displayed
  standings (earned/spent/balance/attendance %) match the backend's computed
  values for a chosen date window.
- **SC-005**: 90% of first-time users complete the primary flows (sign-in,
  browse roster, view standings) unaided in usability testing.
- **SC-006**: Every data surface implements loading, empty, and error states;
  zero blank-screen states exist in end-to-end testing of the primary flows.
- **SC-007**: All interactive flows are operable by keyboard alone, and the
  component library's accessibility behaviors remain intact in automated
  accessibility checks.

## Assumptions

- The backend APIs exist per
  `E:\Repos\GuildApplicationAPI\specs\0001-guild-management-api\spec.md`
  (feature 0001), including role enforcement, pagination, validation
  semantics, and guild settings; the UI consumes them and does not
  re-implement business rules beyond presentation-layer feedback.
- **v1 is HTTP request/response only**: real-time updates via WebSockets are
  deferred until the backend exposes them (per backend spec assumption);
  the constitution's real-time standard activates in a later feature.
- The session mechanism (cookie vs. token) is a backend plan-time decision;
  the UI adapts to whatever the API issues.
- Single guild in v1; a user with no active membership sees a clear
  not-a-member state; multi-membership errors are surfaced readably.
- The guild is seeded from the reference workbook import for realistic
  volumes in testing; class/flag/role vocabulary is guild configuration, so
  the UI renders configured values and never hard-codes game vocabulary.
- Desktop-first responsive design; modern evergreen browsers; phone layouts
  are out of scope for v1.
- Engineering constraints — component library (Spartan UI), state management
  (NgRx), unit tests (Vitest, 85% floor), end-to-end tests (Playwright),
  smart/dumb component separation, domain-organized structure, lazy-loaded
  routes, strict TypeScript with Angular ESLint — are governed by this
  repo's constitution (v1.1.0) and are not restated as spec requirements.
- Dark/light theme support ships with the component library defaults; a
  theme toggle is a nice-to-have, not a v1 requirement.
- The mechanism for XLSX export (backend-provided export endpoints vs.
  client-side generation from the same paged data the views use) is a
  plan-time decision; if backend endpoints are chosen, coordinate with
  GuildApplicationAPI feature 0001.