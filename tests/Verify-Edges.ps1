#requires -Version 7.0
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Fixture)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$pwsh = (Get-Process -Id $PID).Path
$root = Split-Path $PSScriptRoot -Parent
$fixturePath = (Resolve-Path -LiteralPath $Fixture).Path
if (-not $fixturePath.StartsWith((Join-Path $root '.verification') + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Use a fixture created by Verify-Templates.ps1.'
}
$copy = Join-Path $fixturePath 'general-work 한글 space'
$project = Join-Path $copy 'workspace'
$invoke = Join-Path $copy 'scripts/Invoke-Agent.ps1'
$configPath = Join-Path $project 'project.json'
$localPath = Join-Path $project 'project.local.json'
$checks = [Collections.Generic.List[string]]::new()
function Check([bool]$Condition, [string]$Name) { if (-not $Condition) { throw "FAIL: $Name" }; $checks.Add($Name) }
function Json([string]$Path) { Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable }
function Save([string]$Path, $Value) { $Value | ConvertTo-Json -Depth 12 | Set-Content -LiteralPath $Path -Encoding utf8 }
function Run([string]$Script, [string[]]$Arguments, [int]$Expected = 0) {
    $output = & $pwsh -NoProfile -File $Script @Arguments 2>&1
    if ($LASTEXITCODE -ne $Expected) { throw "Unexpected exit $LASTEXITCODE : $($output -join "`n")" }
    $output -join "`n"
}
$config = Json $configPath
$hash = (Get-FileHash -LiteralPath $configPath).Hash
Remove-Item -LiteralPath $localPath
$null = Run (Join-Path $copy 'scripts/Initialize-Project.ps1') @('-Id','sample','-Mode','single','-Name','다른 PC','-Language','French')
Check ((Get-FileHash -LiteralPath $configPath).Hash -eq $hash) 'New PC preserves shared answers'
Check ((Json $configPath).language -eq 'Spanish') 'Resume does not overwrite saved language'
Check (Test-Path -LiteralPath $localPath) 'New PC recreates missing local settings'
$local = Json $localPath
$local.providers.codex = @{ command = $pwsh; prefixArguments = @('-NoProfile','-File',(Join-Path $PSScriptRoot 'Fake-Provider.ps1')) }
Save $localPath $local
$env:WORKFLOW_TEST_CAPTURE = Join-Path $fixturePath 'edges-captured.json'
$env:WORKFLOW_TEST_MODE = 'success'
$config.worker.provider = 'codex'
Save $configPath $config
$prompt = Join-Path $fixturePath 'literal-prompt.md'
'한글 $(throw "must stay literal") & ; ` "quoted"' | Set-Content -LiteralPath $prompt -Encoding utf8
$result = Run $invoke @('-Project',$project,'-TaskId','literal-input','-Phase','plan','-PromptFile',$prompt) | ConvertFrom-Json -AsHashtable
Check ($result.status -eq 'responded') 'Shell-like prompt remains data'
Check ((Json $env:WORKFLOW_TEST_CAPTURE).input.Contains('$(throw "must stay literal")')) 'Literal prompt reaches provider unchanged'
$lock = [IO.File]::Open((Join-Path $project 'runs/duplicate.lock'), 'OpenOrCreate', 'ReadWrite', 'None')
try {
    $null = Run $invoke @('-Project',$project,'-TaskId','duplicate','-Phase','probe') 1
    Check $true 'Same task cannot execute concurrently'
} finally { $lock.Dispose() }
$result = Run $invoke @('-Project',$project,'-TaskId','duplicate','-Phase','probe') | ConvertFrom-Json -AsHashtable
Check ($result.status -eq 'responded') 'Released task lock can be reused'

$config.worker.provider = 'ollama'
$config.ollamaRole = 'Draft generation, fixture only'
Save $configPath $config
foreach ($mode in @('success','failure','truncated')) {
    $env:WORKFLOW_TEST_MODE = $mode
    $expected = if ($mode -eq 'success') { 0 } else { 1 }
    $result = Run (Join-Path $PSScriptRoot 'Fake-Ollama-Runner.ps1') @('-Script',$invoke,'-Project',$project,'-TaskId',"ollama-$mode") $expected | ConvertFrom-Json -AsHashtable
    Check ($result.status -eq $(if ($mode -eq 'success') { 'responded' } else { 'needs_user' })) "Ollama $mode handled"
}
$captured = Json $env:WORKFLOW_TEST_CAPTURE
Check ($captured.method -eq 'Post' -and $captured.uri.EndsWith('/api/generate')) 'Ollama endpoint and method'
Check ($captured.payload.stream -eq $false -and $captured.payload.model -eq 'fixture-model') 'Ollama selected model and nonstreaming payload'
Check ($captured.payload.prompt -match 'Connection check only') 'Ollama UTF-8 JSON prompt'
Check ($captured.payload.prompt -match 'Output language: Spanish') 'Ollama receives selected language'
Remove-Item Env:WORKFLOW_TEST_CAPTURE, Env:WORKFLOW_TEST_MODE
$report = @{ checkedAt = [DateTimeOffset]::Now.ToString('o'); passed = $checks.Count; checks = @($checks); liveModelCalls = 0 }
Save (Join-Path $fixturePath 'edges-report.json') $report
$report | ConvertTo-Json -Depth 5
