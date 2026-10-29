#requires -Version 7.0
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$TemplateRoot = Split-Path $PSScriptRoot -Parent

function Read-Json([string]$Path) {
    Get-Content -LiteralPath $Path -Raw -Encoding utf8 | ConvertFrom-Json -AsHashtable
}

function Save-Json([string]$Path, $Value) {
    $temporary = "$Path.$([guid]::NewGuid().ToString('N')).tmp"
    try {
        $Value | ConvertTo-Json -Depth 20 | Set-Content -LiteralPath $temporary -Encoding utf8
        Move-Item -LiteralPath $temporary -Destination $Path -Force
    } finally {
        if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary }
    }
}

function Assert-Id([string]$Value) {
    if ($Value -notmatch '^[a-z][a-z0-9-]{0,47}$' -or
        $Value -match '^(con|prn|aux|nul|com[0-9]|lpt[0-9])$') {
        throw 'ID must use lowercase letters, digits and hyphens; start with a letter; avoid Windows reserved names.'
    }
}

function Get-ProjectContext([string]$Project) {
    $directory = (Resolve-Path -LiteralPath $Project).Path
    $config = Read-Json (Join-Path $directory 'project.json')
    $local = Read-Json (Join-Path $directory 'project.local.json')
    $work = [IO.Path]::GetFullPath($local.workDirectory, $directory)
    @{ Directory = $directory; Config = $config; Local = $local; WorkDirectory = $work }
}

function Get-ConfigurationIssues($Context) {
    $config = $Context.Config
    $kind = (Read-Json (Join-Path $TemplateRoot 'template.json')).kind
    if ($config.kind -ne $kind) { 'Project kind does not match this template.' }
    if (-not $config.ContainsKey('language') -or [string]::IsNullOrWhiteSpace($config.language)) {
        'Interview required: language. Ask which language to use before continuing.'
    }
    foreach ($field in @('name', 'purpose', 'ollamaRole')) {
        if ([string]::IsNullOrWhiteSpace($config[$field])) { "Interview required: $field" }
    }
    if (@($config.completionCriteria).Count -eq 0) { 'Interview required: completionCriteria' }
    if ($config.coordinator -notin @('codex', 'claude')) { 'Select coordinator: codex or claude.' }
    if (-not $config.approvals.confirmed -or [string]::IsNullOrWhiteSpace($config.approvals.scope)) {
        'Interview required: approval checkpoints and authorized scope.'
    }
    if (-not $config.setupInterviewComplete) { 'Setup interview is incomplete.' }
    Get-StartupIssues $Context
    Get-IntegrationIssues $Context
    if (@($config.reviewers).Count -eq 0) { 'Select at least one reviewer.' }
    foreach ($role in @($config.worker) + @($config.reviewers)) {
        if ($role.provider -notin @('codex', 'claude', 'gemini', 'ollama') -or
            [string]::IsNullOrWhiteSpace($role.model)) { 'Each role needs a supported provider and an explicit model.' }
    }
    if ($kind -ne 'general-work' -and $config.versionControl.mode -ne 'git-pr') {
        'Development templates require git-pr completion.'
    }
    if ($config.versionControl.mode -notin @('git-pr', 'git', 'files')) { 'Select version control mode.' }
    if ($config.versionControl.mode -eq 'git-pr' -and
        [string]::IsNullOrWhiteSpace($config.versionControl.baseBranch)) { 'Confirm the PR base branch.' }
    if ($kind -eq 'game-development' -and [string]::IsNullOrWhiteSpace($config.engine)) { 'Select the game engine.' }
    if ($kind -eq 'general-work' -and @($config.deliverableFormats).Count -eq 0) { 'Select office deliverable formats.' }
    if (-not (Test-Path -LiteralPath $Context.WorkDirectory -PathType Container)) { 'Work directory does not exist.' }
}

function Get-StartupIssues($Context) {
    # Existing projects without mode records retain the standard workflow.
    if (-not $Context.Config.ContainsKey('startup')) { return }
    $startup = $Context.Config['startup']
    if ($startup -isnot [Collections.IDictionary] -or $startup['mode'] -notin @('standard', 'quick')) {
        'Select startup mode: standard or quick.'
        return
    }
    if ($startup.mode -eq 'quick' -and [string]::IsNullOrWhiteSpace($startup['riskNotice'])) {
        'Quick start requires a recorded prior risk notice. Follow guides/START-MODES.md.'
    }
    if ($startup['rolesReviewed'] -isnot [bool] -or $startup['rolesReviewed'] -ne $true -or
        $startup['roleResearch'] -isnot [array] -or $startup.roleResearch.Count -eq 0 -or
        @($startup.roleResearch | Where-Object { [string]::IsNullOrWhiteSpace($_) }).Count -gt 0) {
        'Research workflow roles and record the findings before assigning agents.'
    }
    if ($startup['assignments'] -isnot [array]) { 'Record startup role assignments as an array.'; return }
    $ids = @()
    $reviewerRoutes = @()
    foreach ($role in $startup.assignments) {
        if ($role -isnot [Collections.IDictionary]) { 'Invalid workflow role assignment.'; continue }
        try { Assert-Id $role['id'] } catch { 'Invalid workflow role ID.'; continue }
        if ($role.id -in $ids) { 'Duplicate workflow role ID.' }
        $ids += $role.id
        if ([string]::IsNullOrWhiteSpace($role['duty']) -or [string]::IsNullOrWhiteSpace($role['reason'])) {
            "Workflow role needs a duty and research rationale: $($role.id)"
        }
        $route = [string]$role['route']
        if ($route -ne 'worker') {
            if ($route -notmatch '^reviewer-(100|[1-9][0-9]?)$' -or
                [int]$Matches[1] -gt @($Context.Config.reviewers).Count) {
                "Workflow role has no configured execution route: $($role.id)"
            }
            if ($route -in $reviewerRoutes) { 'Each specialist reviewer needs a separate reviewer entry.' }
            $reviewerRoutes += $route
        }
        if ($role['approved'] -isnot [bool] -or ($startup.mode -eq 'standard' -and $role.approved -ne $true)) {
            "Standard start requires approval before adding workflow role: $($role.id)"
        }
    }
}

function Get-IntegrationIssues($Context, [switch]$CheckConnections) {
    $selection = $Context.Config['integrations']
    if ($selection -isnot [Collections.IDictionary] -or $selection['reviewed'] -isnot [bool] -or $selection['reviewed'] -ne $true -or
        $selection['items'] -isnot [array]) {
        'Interview required: skills and MCP requirements. Follow guides/INTEGRATIONS.md.'
        return
    }
    $ids = @()
    $consumers = @('coordinator', 'worker')
    for ($i = 1; $i -le @($Context.Config.reviewers).Count; $i++) { $consumers += "reviewer-$i" }
    foreach ($item in $selection.items) {
        if ($item -isnot [Collections.IDictionary]) { 'Invalid integration requirement.'; continue }
        try { Assert-Id $item['id'] } catch { 'Invalid integration ID.'; continue }
        if ($item.id -in $ids) { 'Duplicate integration ID.'; continue }
        $ids += $item.id
        if ($item['kind'] -notin @('skill', 'mcp') -or $item['required'] -isnot [bool] -or
            $item['consumers'] -isnot [array] -or $item.consumers.Count -eq 0 -or
            @($item.consumers | Where-Object { $_ -notin $consumers }).Count -gt 0) {
            "Invalid integration selection: $($item.id). Confirm kind, required, and assigned consumers."
            continue
        }
        if (-not $CheckConnections -or -not $item.required) { continue }
        $records = $Context.Local['integrations']
        $checks = if ($records -is [Collections.IDictionary]) { $records[$item.id] } else { $null }
        foreach ($consumer in $item.consumers) {
            $check = if ($checks -is [Collections.IDictionary]) { $checks[$consumer] } else { $null }
            if ($check -isnot [Collections.IDictionary] -or $check['status'] -ne 'verified' -or
                [string]::IsNullOrWhiteSpace($check['evidence']) -or
                [string]::IsNullOrWhiteSpace($check['client']) -or
                [string]::IsNullOrWhiteSpace($check['checkedAt'])) {
                "Required integration is unverified: $($item.id) for $consumer. Complete setup or record the blocking action."
            }
        }
    }
}

function Get-NativeCommand($Provider) {
    $command = Get-Command -Name $Provider.command -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $command) { throw "Executable not found: $($Provider.command)" }
    # Windows can only start .exe files without a shell; macOS/Linux run any executable file (including shebang scripts) directly.
    if ($IsWindows -and [IO.Path]::GetExtension($command.Source) -ne '.exe') {
        throw 'Use a native .exe, or node.exe with the CLI entry file in prefixArguments. Do not pass a shell command string.'
    }
    $command.Source
}
