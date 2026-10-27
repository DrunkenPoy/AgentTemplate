#requires -Version 7.0
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Fixture)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$fixturePath = (Resolve-Path -LiteralPath $Fixture).Path
if (-not $fixturePath.StartsWith((Join-Path $root '.verification') + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Use a fixture created by Verify-Templates.ps1.'
}
$copy = Join-Path $fixturePath 'general-work 한글 space'
. (Join-Path $copy 'scripts/Common.ps1')
$project = Join-Path $copy 'workspace'
$context = Get-ProjectContext $project
$checksPassed = [Collections.Generic.List[string]]::new()
function Check([bool]$Condition, [string]$Name) {
    if (-not $Condition) { throw "FAIL: $Name" }
    $checksPassed.Add($Name)
}
function Issues { ,@(Get-IntegrationIssues $context -CheckConnections) }
$context.Config.Remove('integrations')
Check ((Issues).Count -gt 0) 'Older projects require the integration interview'
$context.Config.integrations = @{ reviewed = $false; items = @() }
Check ((Issues).Count -gt 0) 'Unresolved selection is not ready'
$context.Config.integrations.reviewed = $true
Check ((Issues).Count -eq 0) 'An assessed project can need no additional integrations'
$item = @{ id = 'reference-search'; kind = 'mcp'; required = $true; consumers = @('coordinator','worker') }
$context.Config.integrations.items = @($item)
$context.Local.integrations = @{}
Check ((Issues).Count -eq 2) 'Every required consumer needs local evidence'
$item.required = $false
Check ((Issues).Count -eq 0) 'Unavailable optional integration does not block readiness'
$item.required = $true
$verified = @{ status = 'verified'; client = 'Mock client'; checkedAt = [DateTimeOffset]::Now.ToString('o'); evidence = 'Mock read-only capability check' }
$context.Local.integrations[$item.id] = @{ coordinator = $verified.Clone() }
Check ((Issues).Count -eq 1) 'Coordinator access does not establish worker access'
$context.Local.integrations[$item.id].worker = $verified.Clone()
Check ((Issues).Count -eq 0) 'Evidence for all consumers satisfies the recorded gate'
$context.Local.integrations[$item.id].worker.evidence = ''
Check ((Issues).Count -eq 1) 'A verified label without evidence is insufficient'
$context.Local.integrations[$item.id].worker = $verified.Clone()
$context.Local.integrations[$item.id].worker.status = 'waiting-user'
Check ((Issues).Count -eq 1) 'Pending account consent prevents readiness'
$context.Local.integrations[$item.id].worker = $verified.Clone()
$item.kind = 'skill'
Check ((Issues).Count -eq 0) 'Skills require the same per-consumer evidence'
$item.consumers = @('reviewer-99')
Check ((Issues).Count -gt 0) 'Unassigned reviewers are rejected'
$item.consumers = @('coordinator','worker')
$context.Config.integrations.items = @($item, $item.Clone())
Check ((Issues).Count -gt 0) 'Duplicate requirement IDs are rejected'
$context.Config.integrations.items = @($item)
$context.Local.integrations = @{}
$context.Config.worker.provider = 'codex'
$pwsh = (Get-Process -Id $PID).Path
$context.Local.providers.codex = @{ command = $pwsh; prefixArguments = @('-NoProfile','-File',(Join-Path $PSScriptRoot 'Fake-Provider.ps1')) }
Save-Json (Join-Path $project 'project.json') $context.Config
Save-Json (Join-Path $project 'project.local.json') $context.Local
$env:WORKFLOW_TEST_MODE = 'success'
$env:WORKFLOW_TEST_CAPTURE = Join-Path $fixturePath 'integration-capture.json'
try {
    $invoke = Join-Path $copy 'scripts/Invoke-Agent.ps1'
    $null = & $pwsh -NoProfile -File $invoke -Project $project -TaskId integration-probe -Phase probe
    Check ($LASTEXITCODE -eq 0) 'Provider probes can run while integration setup is pending'
    $blocked = & $pwsh -NoProfile -File $invoke -Project $project -TaskId integration-work -PromptFile (Join-Path $project 'PROJECT.md') 2>&1
    Check ($LASTEXITCODE -ne 0 -and ($blocked -join "`n") -match 'Required integration is unverified') 'Non-probe work is blocked before invoking the provider'
    Check (@(Get-ChildItem (Join-Path $project 'runs') -Directory -Filter 'integration-work-*').Count -eq 0) 'Blocked work creates no provider run'
    $null = & $pwsh -NoProfile -File (Join-Path $copy 'scripts/Test-Setup.ps1') -Project $project
    Check ($LASTEXITCODE -ne 0) 'Setup check fails for missing required integration evidence'
    $context.Local.integrations[$item.id] = @{ coordinator = $verified.Clone(); worker = $verified.Clone() }
    Save-Json (Join-Path $project 'project.local.json') $context.Local
    $null = & $pwsh -NoProfile -File $invoke -Project $project -TaskId integration-work-ready -PromptFile (Join-Path $project 'PROJECT.md')
    Check ($LASTEXITCODE -eq 0) 'Verified required integrations allow a mock work call'
    $null = & $pwsh -NoProfile -File (Join-Path $copy 'scripts/Test-Setup.ps1') -Project $project
    Check ($LASTEXITCODE -eq 0) 'Setup check accepts complete recorded integration evidence'
    Remove-Item -LiteralPath (Join-Path $project 'project.local.json')
    $null = & $pwsh -NoProfile -File (Join-Path $copy 'scripts/Initialize-Project.ps1') -Id sample -Mode single -Name 'New machine'
    $fresh = Get-ProjectContext $project
    Check (@(Get-IntegrationIssues $fresh -CheckConnections).Count -eq 2) 'A new PC must reverify required integrations'
    Check ($fresh.Config.integrations.items.Count -eq 1) 'New PC retains the portable requirements'
} finally {
    Remove-Item Env:WORKFLOW_TEST_MODE, Env:WORKFLOW_TEST_CAPTURE -ErrorAction SilentlyContinue
}
$report = @{ passed = $checksPassed.Count; checks = @($checksPassed); liveModelCalls = 0; liveIntegrationCalls = 0 }
Save-Json (Join-Path $fixturePath 'integrations-report.json') $report
$report | ConvertTo-Json -Depth 5
