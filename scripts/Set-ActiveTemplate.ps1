#requires -Version 7.0
# Keeps one template folder active and archives (or deletes) the others so AI tools stop reading them.
# Archive: each unused folder becomes _archive/<name>.zip and the folder is removed. -Restore brings it back.
[CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Keep')]
param(
    [Parameter(Mandatory, ParameterSetName = 'Keep')]
    [ValidateSet('development', 'game-development', 'general-work')]
    [string]$Keep,
    [Parameter(ParameterSetName = 'Keep')]
    [ValidateSet('Archive', 'Delete')]
    [string]$Mode = 'Archive',
    [Parameter(Mandatory, ParameterSetName = 'Restore')]
    [ValidateSet('development', 'game-development', 'general-work', 'tests')]
    [string[]]$Restore
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression.FileSystem
$root = Split-Path $PSScriptRoot -Parent
$archive = Join-Path $root '_archive'
$templates = @('development', 'game-development', 'general-work')

function Get-RecordFolders([string]$Directory) {
    foreach ($name in @('workspace', 'projects')) {
        $path = Join-Path $Directory $name
        if (Test-Path -LiteralPath $path) { $path }
    }
}

if ($PSCmdlet.ParameterSetName -eq 'Restore') {
    foreach ($name in $Restore) {
        $zip = Join-Path $archive "$name.zip"
        $target = Join-Path $root $name
        if (-not (Test-Path -LiteralPath $zip)) { throw "No archive found: $zip" }
        if (Test-Path -LiteralPath $target) { throw "Folder already exists; restore skipped to avoid overwriting: $target" }
        if ($PSCmdlet.ShouldProcess($target, 'Restore from archive')) {
            [IO.Compression.ZipFile]::ExtractToDirectory($zip, $root)
            Remove-Item -LiteralPath $zip
            Write-Output "Restored: $name"
        }
    }
    exit 0
}

if (-not (Test-Path -LiteralPath (Join-Path $root "$Keep/START.md"))) { throw "Template to keep is missing: $Keep" }
# The tests exercise every template, so they are set aside together with the unused templates.
$targets = @(@($templates | Where-Object { $_ -ne $Keep }) + 'tests' |
    Where-Object { Test-Path -LiteralPath (Join-Path $root $_) })
if ($targets.Count -eq 0) { Write-Output 'Nothing to clean up.'; exit 0 }

if ($Mode -eq 'Delete') {
    # Deleting project records is irreversible; those folders must be archived instead.
    $records = @($targets | ForEach-Object { Get-RecordFolders (Join-Path $root $_) })
    if ($records.Count -gt 0) { throw "Project records found; use -Mode Archive instead:`n$($records -join "`n")" }
}

foreach ($name in $targets) {
    $source = Join-Path $root $name
    if ($Mode -eq 'Archive') {
        $zip = Join-Path $archive "$name.zip"
        if (Test-Path -LiteralPath $zip) { throw "Archive already exists; remove or restore it first: $zip" }
        if (-not $PSCmdlet.ShouldProcess($source, "Archive to $zip and remove folder")) { continue }
        New-Item -ItemType Directory -Path $archive -Force | Out-Null
        [IO.Compression.ZipFile]::CreateFromDirectory($source, $zip, [IO.Compression.CompressionLevel]::Optimal, $true)
        $expected = @(Get-ChildItem -LiteralPath $source -Recurse -File -Force).Count
        $stored = [IO.Compression.ZipFile]::OpenRead($zip)
        try { $actual = @($stored.Entries | Where-Object { $_.Name }).Count } finally { $stored.Dispose() }
        if ($actual -ne $expected) {
            Remove-Item -LiteralPath $zip
            throw "Archive verification failed for $name ($actual of $expected files); folder left unchanged."
        }
        Remove-Item -LiteralPath $source -Recurse -Force
        Write-Output "Archived: $name -> _archive/$name.zip"
    } elseif ($PSCmdlet.ShouldProcess($source, 'Delete folder')) {
        Remove-Item -LiteralPath $source -Recurse -Force
        Write-Output "Deleted: $name"
    }
}
