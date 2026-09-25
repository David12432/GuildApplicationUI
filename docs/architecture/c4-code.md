# C4 — Code Diagram (Representative Domain: Roster)

**Level:** C4 model, Level 4 (Code)
**Represents:** the code-level pattern every feature domain follows, using
the roster domain (tasks.md T025–T033) as the worked example. Other domains
replicate this shape with their own entities and services.

```mermaid
classDiagram
    direction LR

    class RosterListComponent {
        <<smart container>>
        +inject_RosterApiService
        +inject_Store
        +players: Signal~PagedResult~Player~~
        +filters: Signal~RosterFilters~~
        +onFilterChanged(filters)
        +onPageChanged(page)
    }

    class RosterTableComponent {
        <<dumb presentational>>
        +INPUT players: PagedResult~Player~
        +INPUT filters: RosterFilters~
        +OUTPUT filterChanged: EventEmitter
        +OUTPUT pageChanged: EventEmitter
    }

    class RosterStore {
        <<ngrx Store slice - entity>>
        +players: EntityCollection
        +filters: RosterFilters~
        +pagination: PagingState~
    }

    class RosterEffects {
        <<ngrx Effects>>
        +loadRoster$()
        +registerCharacter$()
        +approveCharacter$()
        +claimCharacter$()
    }

    class RosterSelectors {
        <<signal-based selectors>>
        +selectPlayers()
        +selectFilters()
        +selectPagination()
    }

    class RosterApiService {
        <<typed API service>>
        +getRoster(filters): PagedResult~Player~
        +createCharacter(dto)
        +approveCharacter(id)
        +claimCharacter(id)
    }

    class RosterFilters {
        <<readonly DTO - shared/models>>
        +search: string~
        +classId: string~
        +category: string~
        +levelRange: Range~
        +mainAlt: MainAlt~
        +page: number
    }

    class Player {
        <<readonly DTO>>
        +id: string
        +name: string
        +mainCharacterId: string
        +characters: Character[]
    }

    class Character {
        <<readonly DTO>>
        +id: string
        +name: string
        +className: string
        +level: number~
        +isMain: boolean
        +approvalStatus: ActivePending
        +progression: Record~string,string~
    }

    RosterListComponent --> RosterSelectors : selectSignal reads
    RosterListComponent --> RosterStore : dispatch actions
    RosterListComponent --> RosterTableComponent : @Input() / @Output()
    RosterEffects --> RosterApiService : HTTP via core/http ApiBase
    RosterStore <.. RosterEffects : reducer updates
    RosterApiService --> Player : deserializes
    Player *-- Character : alts grouped under main
    RosterFilters --> RosterStore : filter state
```

## Notes

- **Constitution mappings**: smart/dumb separation (Principle VIII),
  `inject()` over constructor DI (Principle II), readonly DTOs (Principle III),
  one service per domain (Technology & Testing Standards).
- **Slices**: the NgRx slice composition (`Store` + `Effects` + entity +
  signal selectors) is the same in all nine domains — research.md R3.
- **Full field definitions**: see `specs/001-guild-management-ui/data-model.md`;
  this diagram shows shape, not the complete validation rule set.
- **Traceability**: task IDs for this domain appear in tasks.md Phase 4
  (T025–T033) and GitHub ticket #4.