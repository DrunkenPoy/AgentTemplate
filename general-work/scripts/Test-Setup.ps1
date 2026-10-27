#requires -Version 7.0
[CmdletBinding()]
param([Parameter(Mandatory)][string]$Project)
. "$PSScriptRoot/Common.ps1"
$context = Get-ProjectContext $Project
$issues = @(Get-ConfigurationIssues $context)
$template = Read-Json (Join-Path $TemplateRoot 'template.json')
foreach ($entry in $template.preservedFiles.GetEnumerator()) {
    $path = Join-Path $TemplateRoot $entry.Key
    if (-not (Test-Path -LiteralPath $path) -or (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash -ne $entry.Value) {
        $issues += "Preserved file differs or is missing: $($entry.Key)"
    }
}
$selected = @($context.Config.coordinator, $context.Config.worker.provider) + @($context.Config.reviewers | ForEach-Object { $_.provider })
$tools = @()
foreach ($provider in @($selected | Where-Object { $_ } | Sort-Object -Unique)) {
    try {
        if ($provider -eq 'ollama') {
            $endpoint = $context.Local.providers.ollama.endpoint.TrimEnd('/')
            $tags = Invoke-RestMethod -Uri "$endpoint/api/tags" -TimeoutSec 5
            $names = @($tags.models | ForEach-Object { $_.name })
            foreach ($role in @($context.Config.worker) + @($context.Config.reviewers)) {
                if ($role.provider -eq 'ollama' -and $role.model -notin $names) { throw "Ollama model not installed: $($role.model)" }
            }
            $tools += @{ provider = $provider; found = $true; detail = 'Service reachable; configured models present.' }
        } else {
            $path = Get-NativeCommand $context.Local.providers[$provider]
            $tools += @{ provider = $provider; found = $true; detail = $path }
        }
    } catch {
        $issues += $_.Exception.Message
        $tools += @{ provider = $provider; found = $false; detail = $_.Exception.Message }
    }
}
if ($context.Config.versionControl.mode -in @('git', 'git-pr') -and -not (Get-Command git -ErrorAction SilentlyContinue)) {
    $issues += 'Git is not installed or not on PATH.'
}
$report = @{
    checkedAt = [DateTimeOffset]::Now.ToString('o')
    configurationValid = ($issues.Count -eq 0)
    issues = $issues; tools = $tools
    liveCalls = 'unverified'; applicationAccess = 'unverified'
    note = 'Executable discovery does not verify login, model availability, write permissions, or app-to-Windows execution.'
}
Save-Json (Join-Path $context.Directory 'setup-check.local.json') $report
$report | ConvertTo-Json -Depth 8
if ($issues.Count -gt 0) { exit 1 }
