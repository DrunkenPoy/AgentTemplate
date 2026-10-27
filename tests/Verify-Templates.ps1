#requires -Version 7.0
[CmdletBinding()]
param()
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$pwsh = (Get-Process -Id $PID).Path
$fixture = Join-Path $root ".verification/$([guid]::NewGuid().ToString('N'))"
New-Item -ItemType Directory -Path $fixture -Force | Out-Null
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
function Json([string]$Path) { Get-Content -LiteralPath $Path -Raw | ConvertFrom-Json -AsHashtable }
function Save([string]$Path, $Value) { $Value | ConvertTo-Json -Depth 15 | Set-Content -LiteralPath $Path -Encoding utf8 }

foreach ($kind in @('development', 'game-development', 'general-work')) {
    $source = Join-Path $root $kind
    $manifest = Json (Join-Path $source 'template.json')
    Check ($manifest.kind -eq $kind) "$kind manifest"
    foreach ($entry in $manifest.preservedFiles.GetEnumerator()) {
        Check ((Get-FileHash (Join-Path $source $entry.Key)).Hash -eq $entry.Value) "$kind original $($entry.Key)"
    }
    foreach ($script in Get-ChildItem (Join-Path $source 'scripts') -Filter '*.ps1') {
        $tokens = $null; $parseErrors = $null
        $null = [Management.Automation.Language.Parser]::ParseFile($script.FullName, [ref]$tokens, [ref]$parseErrors)
        Check ($parseErrors.Count -eq 0) "$kind parses $($script.Name)"
        if ($kind -ne 'development') {
            Check ((Get-FileHash $script.FullName).Hash -eq (Get-FileHash (Join-Path $root "development/scripts/$($script.Name)")).Hash) "$kind shared $($script.Name)"
        }
    }
    $copy = Join-Path $fixture "$kind 한글 space"
    Copy-Item -LiteralPath $source -Destination $copy -Recurse
    $init = Join-Path $copy 'scripts/Initialize-Project.ps1'
    $null = Run $init @('-Id','sample','-Mode','single','-Name','한글 프로젝트')
    $project = Join-Path $copy 'workspace'
    $configPath = Join-Path $project 'project.json'
    Check ((Json $configPath).language -eq '') "$kind does not assume a language"
    $hash = (Get-FileHash $configPath).Hash
    $null = Run $init @('-Id','sample','-Mode','single','-Name','이름 변경 요청 없이 재개')
    Check ((Get-FileHash $configPath).Hash -eq $hash) "$kind resume preserves config"
    $null = Run $init @('-Id','other','-Mode','single','-Name','충돌') 1
    Check ((Get-FileHash $configPath).Hash -eq $hash) "$kind conflicting init preserves config"
    $null = Run $init @('-Id','../escape','-Mode','multi','-Name','invalid') 1
    Check (-not (Test-Path (Join-Path $copy 'escape'))) "$kind rejects traversal"
    $null = Run $init @('-Id','second','-Mode','multi','-Name','두 번째 프로젝트','-Language','Spanish')
    Check (Test-Path (Join-Path $copy 'projects/second/project.json')) "$kind multi-project isolation"
    Check ((Json (Join-Path $copy 'projects/second/project.json')).language -eq 'Spanish') "$kind persists selected language"
    $null = Run (Join-Path $copy 'scripts/Test-Setup.ps1') @('-Project',$project) 1
    Check (-not (Json (Join-Path $project 'setup-check.local.json')).configurationValid) "$kind incomplete interview rejected"
    Check (((Json (Join-Path $project 'setup-check.local.json')).issues -join "`n") -match 'Interview required: language') "$kind requests language interview"
    if ($kind -eq 'general-work') { $testCopy = $copy; $testProject = $project }
}

$configPath = Join-Path $testProject 'project.json'
$config = Json $configPath
$config.language = 'Spanish'
$config.purpose = 'Transport verification only'
$config.completionCriteria = @('Test fixture')
$config.coordinator = 'codex'
$config.worker = @{ provider = 'codex'; model = 'fixture-model' }
$config.reviewers = @(@{ provider = 'claude'; model = 'fixture-model' })
$config.ollamaRole = 'unused'
$config.approvals = @{ confirmed = $true; checkpoints = @('plan'); scope = 'Test fixture only' }
$config.deliverableFormats = @('docx')
$config.versionControl.mode = 'files'
$config.setupInterviewComplete = $true
Save $configPath $config
$localPath = Join-Path $testProject 'project.local.json'
$local = Json $localPath
foreach ($provider in @('codex','claude','gemini')) {
    $local.providers[$provider] = @{ command = $pwsh; prefixArguments = @('-NoProfile','-File',(Join-Path $PSScriptRoot 'Fake-Provider.ps1')) }
}
Save $localPath $local
$invoke = Join-Path $testCopy 'scripts/Invoke-Agent.ps1'
foreach ($case in @('missing', 'blank')) {
    $incomplete = $config.Clone()
    if ($case -eq 'missing') { $incomplete.Remove('language') } else { $incomplete.language = '  ' }
    Save $configPath $incomplete
    $null = Run (Join-Path $testCopy 'scripts/Test-Setup.ps1') @('-Project',$testProject) 1
    Check (((Json (Join-Path $testProject 'setup-check.local.json')).issues -join "`n") -match 'Interview required: language') "$case language yields actionable setup issue"
    $rejection = Run $invoke @('-Project',$testProject,'-TaskId',"language-$case",'-Phase','probe') 1
    Check ($rejection -match 'Interview required: language') "$case language prevents agent invocation"
}
Save $configPath $config
$null = Run (Join-Path $testCopy 'scripts/Test-Setup.ps1') @('-Project',$testProject)
Check (Json (Join-Path $testProject 'setup-check.local.json')).configurationValid 'Complete config passes discovery without model calls'
$invoke = Join-Path $testCopy 'scripts/Invoke-Agent.ps1'
$env:WORKFLOW_TEST_CAPTURE = Join-Path $fixture 'captured.json'
$env:WORKFLOW_TEST_MODE = 'success'

foreach ($provider in @('codex','claude','gemini')) {
    $config.worker.provider = $provider
    Save $configPath $config
    $result = Run $invoke @('-Project',$testProject,'-TaskId',"probe-$provider",'-Phase','probe') | ConvertFrom-Json -AsHashtable
    Check ($result.status -eq 'responded') "$provider simulated response"
    Check ((Get-Content -LiteralPath $result.output -Raw) -match '한글 응답') "$provider UTF-8 output"
    $captured = Json $env:WORKFLOW_TEST_CAPTURE
    Check ($captured.input -match 'Connection check only') "$provider prompt transport"
    Check ($captured.input -match 'Output language: Spanish' -and $captured.input -notmatch 'Report in Korean') "$provider receives selected language"
    Check ($result.language -eq 'Spanish') "$provider records output language"
    if ($provider -eq 'claude') { Check ($captured.arguments -contains '--agent') 'Claude explicit role definition' }
}

$config.worker.provider = 'codex'
Save $configPath $config
foreach ($mode in @('failure','empty','blocked','timeout')) {
    $env:WORKFLOW_TEST_MODE = $mode
    $result = Run $invoke @('-Project',$testProject,'-TaskId',"fail-$mode",'-Phase','probe','-TimeoutSeconds','2') 1 | ConvertFrom-Json -AsHashtable
    Check ($result.status -eq 'needs_user') "$mode pauses for user"
    Check ($result.provider -eq 'codex') "$mode does not switch provider"
    Check ($result.reason.Length -gt 0) "$mode records reason"
}
$env:WORKFLOW_TEST_MODE = 'success'
$result = Run $invoke @('-Project',$testProject,'-TaskId','after-timeout','-Role','reviewer','-Phase','review','-PromptFile',(Join-Path $testProject 'PROJECT.md')) | ConvertFrom-Json -AsHashtable
Check ($result.status -eq 'responded') 'Independent reviewer response'
$captured = Json $env:WORKFLOW_TEST_CAPTURE
Check ($captured.arguments -contains 'Read,Glob,Grep') 'Claude reviewer tools limited to file inspection'
Check ($captured.input -match 'Output language: Spanish') 'Independent reviewer receives selected language'
$null = Run $invoke @('-Project',$testProject,'-TaskId','too-many','-Phase','probe','-Revision','4') 1
Check $true 'Fourth revision rejected'
$local.providers.codex.command = 'not-installed-workflow-fixture'
Save $localPath $local
$result = Run $invoke @('-Project',$testProject,'-TaskId','missing-tool','-Phase','probe') 1 | ConvertFrom-Json -AsHashtable
Check ($result.status -eq 'needs_user') 'Missing executable records actionable state'

$report = @{ checkedAt = [DateTimeOffset]::Now.ToString('o'); passed = $checks.Count; checks = @($checks); fixture = $fixture; liveModelCalls = 0 }
Save (Join-Path $fixture 'report.json') $report
$report | ConvertTo-Json -Depth 5
Remove-Item Env:WORKFLOW_TEST_MODE, Env:WORKFLOW_TEST_CAPTURE
