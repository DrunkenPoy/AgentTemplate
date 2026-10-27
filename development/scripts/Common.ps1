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

function Get-NativeCommand($Provider) {
    $command = Get-Command -Name $Provider.command -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $command) { throw "Executable not found: $($Provider.command)" }
    if ([IO.Path]::GetExtension($command.Source) -ne '.exe') {
        throw 'Use a native .exe, or node.exe with the CLI entry file in prefixArguments. Do not pass a shell command string.'
    }
    $command.Source
}
