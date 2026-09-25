# add-tickets-to-project-0001.ps1
# Adds all open "[001 ...]" issues to GitHub Project 3 (users/David12432/projects/3)
# and sets their Status field to "Backlog".
#
# WHY THIS SCRIPT: the stored git credential has repo scope but NOT project scope,
# so it can create issues but cannot touch the project board. You need a token with
# project access (GitHub -> Settings -> Developer settings -> Personal access tokens,
# classic token with "project" scope is simplest).
#
# ALTERNATIVE (preferred once done): `gh auth refresh -s project -s read:project`
# adds project scopes to the GitHub CLI keyring token; after that the agent can
# add items directly with `gh project item-add` and this script is unnecessary.
#
# Usage:
#   powershell -ExecutionPolicy Bypass -File Development_Scripts/add-tickets-to-project-0001.ps1 -Token <PAT>
#   (or set $env:GH_PROJECT_TOKEN, or run without -Token to be prompted)
#
# Idempotent: skips issues already on the board.

param([string]$Token = $env:GH_PROJECT_TOKEN)
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Owner = 'David12432'
$Repo   = 'GuildApplicationUI'
$ProjectNumber = 3

if (-not $Token) { $Token = Read-Host 'GitHub token with project (write) scope' }
if (-not $Token) { Write-Error 'No token provided.' }

$RestHeaders  = @{ Authorization = "Bearer $Token"; Accept = 'application/vnd.github+json' }
$GraphHeaders = @{ Authorization = "Bearer $Token"; Content-Type = 'application/json' }

function Invoke-GitHubGraph($query, $variables) {
    $payload = @{ query = $query; variables = $variables } | ConvertTo-Json -Depth 10
    $resp = Invoke-RestMethod -Method Post -Uri 'https://api.github.com/graphql' -Headers $GraphHeaders -Body $payload
    if ($resp.errors) { Write-Error ($resp.errors | ConvertTo-Json -Depth 10) }
    return $resp.data
}

# 1. Project id + Status field options
$projQuery = 'query($login:String!,$num:Int!){ user(login:$login){ projectV2(number:$num){ id title field(name:"Status"){ ... on ProjectV2SingleSelectField{ id options{ id name } } } } } }'
$proj = Invoke-GitHubGraph $projQuery @{ login = $Owner; num = $ProjectNumber }
$projectId = $proj.user.projectV2.id
$statusField = $proj.user.projectV2.field
Write-Host ("Project: " + $proj.user.projectV2.title)

$backlogOptionId = $null
if ($statusField) {
    $backlogOptionId = ($statusField.options | Where-Object { $_.name -eq 'Backlog' }).id
    if (-not $backlogOptionId) {
        Write-Warning ('No Status option named "Backlog". Options: ' + (($statusField.options | ForEach-Object { $_.name }) -join ', '))
        Write-Warning 'Items will be added without a Status value (they land in the default column).'
    }
}

# 2. Issues already on the board (for idempotency)
$itemsQuery = 'query($id:ID!,$end:String){ node(id:$id){ ... on ProjectV2{ items(first:100,after:$end){ pageInfo{ hasNextPage endCursor } nodes{ content{ ... on Issue{ number } } } } } } }'
$boardNumbers = New-Object System.Collections.Generic.HashSet[int]
$cursor = $null
do {
    $d = Invoke-GitHubGraph $itemsQuery @{ id = $projectId; end = $cursor }
    foreach ($n in $d.node.items.nodes) { if ($n.content) { [void]$boardNumbers.Add([int]$n.content.number) } }
    $hasNext = $d.node.items.pageInfo.hasNextPage
    $cursor = $d.node.items.pageInfo.endCursor
} while ($hasNext)

# 3. Open [001] issues
$issues = Invoke-RestMethod -Method Get -Uri "https://api.github.com/repos/$Owner/$Repo/issues?state=open&per_page=100" -Headers $RestHeaders
$tickets = $issues | Where-Object { $_.title -like '[001]*' -and -not $_.pull_request }
Write-Host ("Found " + $tickets.Count + " open [001] tickets.")

# 4. Add each to the project + set Status = Backlog
$addMutation = 'mutation($project:ID!,$content:ID!){ addProjectV2ItemById(input:{projectId:$project,contentId:$content}){ item{ id } } }'
$setMutation = 'mutation($project:ID!,$item:ID!,$field:ID!,$option:String!){ updateProjectV2ItemFieldValue(input:{projectId:$project,itemId:$item,fieldId:$field,value:{singleSelectOptionId:$option}}){ projectV2Item{ id } } }'

foreach ($t in $tickets) {
    if ($boardNumbers.Contains([int]$t.number)) { Write-Host ("SKIP on board: #" + $t.number); continue }
    $r = Invoke-GitHubGraph $addMutation @{ project = $projectId; content = $t.node_id }
    $itemId = $r.addProjectV2ItemById.item.id
    if ($backlogOptionId -and $statusField) {
        Invoke-GitHubGraph $setMutation @{ project = $projectId; item = $itemId; field = $statusField.id; option = $backlogOptionId } | Out-Null
        Write-Host ("ADDED to Backlog: #" + $t.number + " " + $t.title)
    } else {
        Write-Host ("ADDED (default column): #" + $t.number + " " + $t.title)
    }
}
Write-Host 'Done.'