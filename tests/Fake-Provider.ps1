# 실제 계정·모델을 호출하지 않고 CLI 전송·실패 처리만 검증한다.
$received = if ($args -contains '--print' -and $args -contains '--sandbox') {
    $args[[Array]::IndexOf($args, '--print') + 1]
} else { [Console]::In.ReadToEnd() }
if ($env:WORKFLOW_TEST_CAPTURE) {
    @{ arguments = @($args); input = $received } | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $env:WORKFLOW_TEST_CAPTURE -Encoding utf8
}
switch ($env:WORKFLOW_TEST_MODE) {
    'failure' { [Console]::Error.WriteLine('simulated connection error'); exit 7 }
    'empty' { exit 0 }
    'timeout' { Start-Sleep -Seconds 10; exit 0 }
    'blocked' { Write-Output 'WORKFLOW_STATUS: BLOCKED'; exit 0 }
}
if ($args -contains 'json') {
    @{ is_error = $false; result = "한글 응답 READY`nWORKFLOW_STATUS: DONE" } | ConvertTo-Json -Compress
} else { Write-Output "한글 응답 READY`nWORKFLOW_STATUS: DONE" }
