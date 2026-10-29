#requires -Version 7.0
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$pwsh = (Get-Process -Id $PID).Path
$fixture = Join-Path $root ('.verification/startup-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $fixture | Out-Null
$checks = [Collections.Generic.List[string]]::new()
function Check([bool]$Condition, [string]$Name) {
    if (-not $Condition) { throw "FAIL: $Name" }
    $checks.Add($Name)
}
function Run([string]$Script, [string[]]$Arguments, [int]$Expected = 0) {
    $output = & $pwsh -NoProfile -File $Script @Arguments 2>&1
    if ($LASTEXITCODE -ne $Expected) { throw "Unexpected exit $LASTEXITCODE (expected $Expected): $Script`n$($output -join "`n")" }
    $output -join "`n"
}
$oldMode = $env:WORKFLOW_TEST_MODE
$oldCapture = $env:WORKFLOW_TEST_CAPTURE
$env:WORKFLOW_TEST_MODE = 'success'
$env:WORKFLOW_TEST_CAPTURE = Join-Path $fixture 'capture.json'
try {
    foreach ($kind in @('development', 'game-development', 'general-work')) {
        $copy = Join-Path $fixture $kind
        Copy-Item -LiteralPath (Join-Path $root $kind) -Destination $copy -Recurse
        . (Join-Path $copy 'scripts/Common.ps1')
        $init = Join-Path $copy 'scripts/Initialize-Project.ps1'
        $invoke = Join-Path $copy 'scripts/Invoke-Agent.ps1'
        $null = Run $init @('-Id','sample','-Mode','single','-Name','Startup test','-Language','Korean','-StartMode','quick')
        $project = Join-Path $copy 'workspace'
        $context = Get-ProjectContext $project
        $config = $context.Config
        $configPath = Join-Path $project 'project.json'
        Check ($config.startup.mode -eq 'quick' -and $config.startup.riskNotice -eq '') "$kind stores mode without fabricating disclosure"
        $config.purpose = 'Verify startup policy and specialist routing'
        $config.completionCriteria = @('Policy checks and scoped provider transport pass')
        $config.coordinator = 'codex'
        $config.worker = @{ provider = 'codex'; model = 'fixture-model' }
        $config.reviewers = @(@{ provider = 'codex'; model = 'fixture-model' }, @{ provider = 'claude'; model = 'fixture-reviewer' })
        $config.ollamaRole = 'unused'
        $config.approvals = @{ confirmed = $true; checkpoints = @('plan'); scope = 'Fixture only' }
        $config.versionControl = @{ mode = 'git-pr'; baseBranch = 'fixture-base' }
        $config.engine = 'Fixture engine'
        $config.deliverableFormats = @('docx')
        $config.integrations = @{ reviewed = $true; items = @() }
        $config.setupInterviewComplete = $true
        $config.startup.rolesReviewed = $true
        $config.startup.roleResearch = @('PROJECT.md: this fixture needs an independent specialist check')
        $config.startup.assignments = @(
            @{ id = 'specialist-worker'; duty = 'WORKER_DUTY_SENTINEL'; reason = 'A separate scoped implementation task is needed'; route = 'worker'; approved = $false },
            @{ id = 'specialist-review'; duty = 'REVIEW_DUTY_SENTINEL'; reason = 'Independent specialty evidence is needed'; route = 'reviewer-2'; approved = $false }
        )
        foreach ($provider in @('codex', 'claude')) {
            $context.Local.providers[$provider] = @{ command = $pwsh; prefixArguments = @('-NoProfile','-File',(Join-Path $PSScriptRoot 'Fake-Provider.ps1')) }
        }
        Save-Json (Join-Path $project 'project.local.json') $context.Local
        Save-Json $configPath $config
        $blocked = Run $invoke @('-Project',$project,'-TaskId','no-notice','-Phase','probe') 1
        Check ($blocked -match 'prior risk notice' -and @(Get-ChildItem (Join-Path $project 'runs')).Count -eq 0) "$kind blocks calls before Quick start disclosure"
        $config.startup.riskNotice = 'Fixture notice: assumptions may need rework; extra agents increase usage, cost and time and receive scoped task materials; review can miss errors.'
        Check (@(Get-ConfigurationIssues $context).Count -eq 0) "$kind accepts researched automatic Quick start assignments"
        $config.startup.rolesReviewed = $false
        Check ((@(Get-ConfigurationIssues $context) -join "`n") -match 'Research workflow roles') "$kind rejects an unfinished role assessment"
        $config.startup.rolesReviewed = $true
        $evidence = $config.startup.roleResearch
        $config.startup.roleResearch = @(' ')
        Check (@(Get-StartupIssues $context).Count -gt 0) "$kind requires research evidence"
        $config.startup.roleResearch = $evidence
        $config.startup.mode = 'standard'
        Save-Json $configPath $config
        $blocked = Run $invoke @('-Project',$project,'-TaskId','no-approval','-Phase','probe') 1
        Check ($blocked -match 'requires approval' -and @(Get-ChildItem (Join-Path $project 'runs')).Count -eq 0) "$kind standard mode rejects unapproved additional agents before invocation"
        foreach ($role in $config.startup.assignments) { $role.approved = $true }
        Check (@(Get-ConfigurationIssues $context).Count -eq 0) "$kind standard mode accepts explicitly approved roles"
        $savedRoles = $config.startup.assignments
        $config.startup.assignments = @()
        Check (@(Get-ConfigurationIssues $context).Count -eq 0) "$kind permits evidence-backed base team without unnecessary roles"
        $config.startup.assignments = $savedRoles
        $config.startup.assignments[1].route = 'reviewer-3'
        Check ((@(Get-StartupIssues $context) -join "`n") -match 'execution route') "$kind rejects nonexistent reviewer routes"
        $config.startup.assignments[1].route = 'reviewer-2'
        $config.startup.assignments[1].id = 'specialist-worker'
        Check ((@(Get-StartupIssues $context) -join "`n") -match 'Duplicate') "$kind rejects ambiguous role IDs"
        $config.startup.assignments[1].id = 'specialist-review'
        $savedStartup = $config.startup
        $config.Remove('startup')
        Check (@(Get-ConfigurationIssues $context).Count -eq 0) "$kind preserves legacy configurations without startup metadata"
        $config.startup = $savedStartup
        $config.startup.mode = 'quick'
        foreach ($role in $config.startup.assignments) { $role.approved = $false }
        Save-Json $configPath $config
        $hash = (Get-FileHash $configPath).Hash
        $null = Run $init @('-Id','sample','-Mode','single','-Name','Changed','-StartMode','standard')
        Check ((Get-FileHash $configPath).Hash -eq $hash) "$kind resume preserves selected mode, risk notice, and assignments"
        $prompt = Join-Path $project 'PROJECT.md'
        $result = Run $invoke @('-Project',$project,'-TaskId','specialist-work','-AgentRole','specialist-worker','-Phase','work','-PromptFile',$prompt) | ConvertFrom-Json -AsHashtable
        $captured = Read-Json $env:WORKFLOW_TEST_CAPTURE
        Check ($result.agentRole -eq 'specialist-worker' -and $result.role -eq 'worker' -and $captured.input -match 'Responsibility: WORKER_DUTY_SENTINEL') "$kind specialist worker receives scoped responsibility"
        $result = Run $invoke @('-Project',$project,'-TaskId','specialist-review','-AgentRole','specialist-review','-Phase','review','-PromptFile',$prompt) | ConvertFrom-Json -AsHashtable
        $captured = Read-Json $env:WORKFLOW_TEST_CAPTURE
        Check ($result.provider -eq 'claude' -and $result.reviewer -eq 2 -and $result.model -eq 'fixture-reviewer' -and $captured.input -match 'Responsibility: REVIEW_DUTY_SENTINEL') "$kind routes specialist review to its configured independent model"
        Check ($captured.arguments -contains 'Read,Glob,Grep') "$kind specialist reviewer retains read-only tools"
        $result = Run $invoke @('-Project',$project,'-TaskId','indexed-review','-Role','reviewer','-Reviewer','2','-Phase','review','-PromptFile',$prompt) | ConvertFrom-Json -AsHashtable
        Check ($result.agentRole -eq 'specialist-review' -and (Read-Json $env:WORKFLOW_TEST_CAPTURE).input -match 'REVIEW_DUTY_SENTINEL') "$kind normal review sequence includes specialist responsibility"
        $blocked = Run $invoke @('-Project',$project,'-TaskId','conflict','-AgentRole','specialist-review','-Role','worker','-Phase','probe') 1
        Check ($blocked -match 'conflicts') "$kind rejects explicit route overrides"
        $blocked = Run $invoke @('-Project',$project,'-TaskId','review-write','-AgentRole','specialist-review','-Phase','work','-PromptFile',$prompt) 1
        Check ($blocked -match 'only review or probe') "$kind specialist reviewers cannot perform implementation"
        $blocked = Run $invoke @('-Project',$project,'-TaskId','unknown-role','-AgentRole','not-assigned','-Phase','probe') 1
        Check ($blocked -match 'not configured') "$kind cannot invoke unassigned specialists"
        Check ((Get-FileHash $configPath).Hash -eq $hash) "$kind calls leave assignment and approval records unchanged"
        $config.integrations.items = @(@{ id = 'review-source'; kind = 'mcp'; required = $true; consumers = @('reviewer-2') })
        Save-Json $configPath $config
        $blocked = Run $invoke @('-Project',$project,'-TaskId','missing-integration','-AgentRole','specialist-review','-Phase','review','-PromptFile',$prompt) 1
        Check ($blocked -match 'Required integration is unverified') "$kind Quick start preserves integration checks for additional reviewers"
        $config.integrations.items = @()
        $config.approvals.confirmed = $false
        Check ((@(Get-ConfigurationIssues $context) -join "`n") -match 'authorized scope') "$kind Quick start does not authorize unrelated execution scope"
    }
    $report = @{ checkedAt = [DateTimeOffset]::Now.ToString('o'); passed = $checks.Count; checks = @($checks); fixture = $fixture; liveModelCalls = 0 }
    Save-Json (Join-Path $fixture 'report.json') $report
    $report | ConvertTo-Json -Depth 5
} finally {
    $env:WORKFLOW_TEST_MODE = $oldMode
    $env:WORKFLOW_TEST_CAPTURE = $oldCapture
}
