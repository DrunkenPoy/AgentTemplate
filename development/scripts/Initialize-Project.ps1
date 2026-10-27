#requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$Id,
    [Parameter(Mandatory)][ValidateSet('single', 'multi')][string]$Mode,
    [Parameter(Mandatory)][string]$Name,
    [string]$Language = ''
)
. "$PSScriptRoot/Common.ps1"
Assert-Id $Id
$template = Read-Json (Join-Path $TemplateRoot 'template.json')
$relative = if ($Mode -eq 'single') { 'workspace' } else { "projects/$Id" }
$projectDirectory = Join-Path $TemplateRoot $relative
$projectFile = Join-Path $projectDirectory 'project.json'

function Initialize-LocalSettings {
    $localPath = Join-Path $projectDirectory 'project.local.json'
    if (Test-Path -LiteralPath $localPath) { return }
    Save-Json $localPath @{
        workDirectory = 'work'
        integrations = @{}
        providers = @{
            codex = @{ command = 'codex'; prefixArguments = @() }
            claude = @{ command = 'claude'; prefixArguments = @() }
            gemini = @{ command = 'agy'; prefixArguments = @() }
            ollama = @{ endpoint = 'http://localhost:11434' }
        }
    }
    New-Item -ItemType Directory -Force -Path (Join-Path $projectDirectory 'work') | Out-Null
    Write-Output 'Created local settings for this PC; confirm the actual work directory and installed tools.'
}

if (Test-Path -LiteralPath $projectDirectory) {
    if (-not (Test-Path -LiteralPath $projectFile)) {
        throw 'The target directory already exists without project.json. Inspect it before continuing; nothing was overwritten.'
    }
    $existing = Read-Json $projectFile
    if ($existing.id -ne $Id -or $existing.kind -ne $template.kind -or $existing.mode -ne $Mode) {
        throw 'The existing project differs from this request. Choose the correct project; nothing was overwritten.'
    }
    Initialize-LocalSettings
    Write-Output "RESUME: $projectDirectory (existing files unchanged)"
    return
}

New-Item -ItemType Directory -Path $projectDirectory | Out-Null
foreach ($folder in @('work', 'tasks', 'handoffs', 'reviews', 'outputs', 'archive', 'runs')) {
    New-Item -ItemType Directory -Path (Join-Path $projectDirectory $folder) | Out-Null
}
$config = [ordered]@{
    schemaVersion = 1; id = $Id; name = $Name; mode = $Mode; kind = $template.kind
    language = $Language.Trim()
    purpose = ''; completionCriteria = @(); coordinator = $null
    worker = @{ provider = $null; model = $null }
    reviewers = @(); ollamaRole = ''; engine = ''; deliverableFormats = @()
    approvals = @{ confirmed = $false; checkpoints = @(); scope = '' }
    versionControl = @{ mode = $(if ($template.kind -eq 'general-work') { $null } else { 'git-pr' }); baseBranch = '' }
    setupInterviewComplete = $false
    integrations = @{ reviewed = $false; items = @() }
}
Save-Json $projectFile $config
Initialize-LocalSettings
Save-Json (Join-Path $projectDirectory 'setup-state.json') @{
    stage = 'interview'; completedTopics = @(); pendingQuestions = @()
    capabilities = @{ files = 'unverified'; windowsCommands = 'unverified'; providerCalls = 'unverified' }
    nextAction = 'Confirm the project language first, then follow guides/INTERVIEW.md and record the next unanswered topic.'
    updatedAt = [DateTimeOffset]::Now.ToString('o')
}
@'
# User decisions

Record each answer immediately. Do not treat unanswered questions as approval.
Use the selected project language when filling in this scaffold.

| ID | Date | Question / context | User decision | Applied to | Status |
|---|---|---|---|---|---|
'@ | Set-Content -LiteralPath (Join-Path $projectDirectory 'DECISIONS.md') -Encoding utf8
@'
# Active and pending tasks

Use the selected project language when filling in this scaffold.

| Task ID | Goal | Size (user decision) | Status | Owner | Next step | Handoff |
|---|---|---|---|---|---|---|
'@ | Set-Content -LiteralPath (Join-Path $projectDirectory 'BACKLOG.md') -Encoding utf8
@'
# Project overview

- Language:
- Purpose:
- Acceptance criteria:
- Scope and exclusions:
- Environment and tools:
- Build/test commands or deliverable verification methods:
- References:
- Known limitations:

Leave unanswered fields empty during setup. Fill them using interview answers and observed evidence in the selected project language.
'@ | Set-Content -LiteralPath (Join-Path $projectDirectory 'PROJECT.md') -Encoding utf8
Write-Output "CREATED: $projectDirectory (interview pending; no AI was called)"
