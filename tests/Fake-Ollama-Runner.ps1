param([string]$Script, [string]$Project, [string]$TaskId)
function Invoke-RestMethod {
    param($Method, $Uri, $ContentType, $Body, $TimeoutSec)
    $payload = [Text.Encoding]::UTF8.GetString($Body) | ConvertFrom-Json -AsHashtable
    @{ method = $Method; uri = $Uri; payload = $payload } | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $env:WORKFLOW_TEST_CAPTURE -Encoding utf8
    if ($env:WORKFLOW_TEST_MODE -eq 'failure') { throw 'Simulated Ollama connection error' }
    if ($env:WORKFLOW_TEST_MODE -eq 'truncated') {
        return [pscustomobject]@{ done = $true; done_reason = 'length'; response = 'unfinished' }
    }
    [pscustomobject]@{ done = $true; done_reason = 'stop'; response = "한글 응답 READY`nWORKFLOW_STATUS: DONE" }
}
& $Script -Project $Project -TaskId $TaskId -Phase probe
exit $LASTEXITCODE
