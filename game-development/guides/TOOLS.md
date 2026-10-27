# Tool connections (Windows and macOS)

## PowerShell and local settings

Run helper scripts with PowerShell 7 or later using pwsh, not Windows PowerShell 5.1's powershell.exe. If unavailable, follow Microsoft's installation guide for [Windows](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows) or [macOS](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-macos) (for example, `brew install powershell/tap/powershell`). Do not bypass execution policy or organizational controls.

Initialization creates project.local.json, excluded from Git. Its workDirectory is relative to that JSON's folder or an actual absolute path. Recreate machine-specific settings on another PC. Keep tool paths and credentials out of shared project.json.

The shared language field belongs in project.json, not project.local.json, so another AI or PC can continue in the same language. Test-Setup and Invoke-Agent require a nonblank language; older projects must answer that interview question before invocation.

~~~json
{
  "workDirectory": "work",
  "providers": {
    "codex": {"command": "codex", "prefixArguments": []},
    "claude": {"command": "claude", "prefixArguments": []},
    "gemini": {"command": "agy", "prefixArguments": []},
    "ollama": {"endpoint": "http://localhost:11434"}
  }
}
~~~

command is an executable name or .exe path, not a shell command containing arguments. For an npm .cmd shim, use a native distribution or node.exe with the actual CLI JavaScript entry file in prefixArguments. Inspect the installed shim to identify that entry; do not guess. On macOS, the executable name or full path found on PATH (for example /opt/homebrew/bin/codex) works as is, including npm-installed CLIs; keep prefixArguments empty.

## Skills and MCP

Follow [INTEGRATIONS.md](INTEGRATIONS.md) for discovery, supported installation, account connection, per-consumer verification, and resume. These steps are performed by the setup AI through the current client's tools; the helper scripts validate recorded requirements/evidence and do not act as universal installers. Provider invocation checks below are separate from skill/MCP checks.

## Connecting providers

| Tool | Initial checks | Invocation |
|---|---|---|
| Codex | Executable, login, model, local codex exec --help | codex exec; instructions on stdin; workspace-write for work, read-only for inspection |
| Claude | Claude Code installation, login, model, local claude --help | claude --print; temporary role agent; JSON result handling |
| Gemini | Installed Antigravity agy login, model, and --help | agy --print; accept-edits for work, plan for inspection; sandbox enabled |
| Ollama | Running service and installed models from /api/tags | /api/generate with stream=false; save generated text |

CLI flags can vary by version. If local help does not match, record the adapter update needed before calling it. The Antigravity adapter targets a CLI supporting agy --print/--model/--mode/--sandbox; do not treat a different Gemini CLI as interchangeable.

Claude review exposes Read/Glob/Grep only. The coordinator runs builds/tests and supplies evidence. Claude work uses acceptEdits and may report an unmet permission requirement. Do not change global permissions or add bypass flags to suppress requests.

If nested Claude CLI execution is restricted, do not remove environment variables to evade that restriction. Use the coordinator's available native subagent tool for the same role and preserve its records. If unavailable, record the unsupported connection and explain where to resume.

Native subagents must receive the same selected project language as CLI calls. The helper injects the language into every worker/reviewer request and records it in result.json. READY, WORKFLOW_STATUS, and other protocol tokens remain unchanged regardless of output language.

Ollama has no file or command tools in this adapter. Pass needed text via InputFiles. Extract text and supply visual verification evidence for binary Word/PDF files. Do not claim it reviewed files it never received.

## Logs and failures

Each call writes its prompt, stdout/stderr, response, and result.json under runs/<task-id>-<timestamp>-<identifier>/. Because runs is excluded from Git, transfer evidence worth preserving to handoff/review records.

The default timeout is 900 seconds; adjust -TimeoutSeconds to the task. On timeout, stop that process tree and record needs_user. This does not revert changes made by the model; inspect them before retrying. Do not switch models automatically for timeout, connection, or usage errors.

For Git/PR completion, verify Git and host-tool authentication, such as gh auth status for GitHub. Setup verification does not require creating a real commit, push, or PR.

## References

- [Codex non-interactive execution](https://learn.chatgpt.com/docs/non-interactive-mode)
- [Programmatic Claude Code execution](https://code.claude.com/docs/en/headless)
- [Ollama generate API](https://docs.ollama.com/api/generate)

See the [validation record](VALIDATION.md). Distinguish release-time verification from checks in the current user's environment.
