# Verification scope

The initial release was checked on 2026-10-26 using Windows and PowerShell 7.6.5.

- Initialization, configuration-preserving resume, invalid-ID rejection, and multi-project separation.
- Incomplete-interview rejection and selected configuration/executable checks.
- Mock Codex/Claude/Gemini prompt transport, Unicode input/output, and result handling.
- User-wait states for nonzero exits, empty output, BLOCKED responses, timeouts, and missing executables.
- Reviewer tool restrictions and revision-argument limits.
- Original development AGENTS.md/CLAUDE.md SHA-256 preservation.
- Local-settings recovery, task locking/reuse, and literal transport of shell-like text.
- Mock Ollama request payloads and success, failure, and truncated-response handling.

The initial mock suite passed 81 checks. Ollama responses were mocked at the API-function level; no HTTP server or model was started.

On 2026-10-27, the language update passed 103 mock checks (89 main checks and 14 edge checks), including language persistence, missing/blank language rejection, older configurations, resume behavior, and forwarding the selected language to workers and reviewers. Active English prompt content, Markdown links, and preserved instruction hashes were also checked.

Live model responses/authentication/limits, native Claude subagent calls, desktop connections, and actual office deliverables are outside this mock verification. Check real connections during START.md setup; distinguish executable discovery from a successful model call, and mark unperformed checks unverified. Language forwarding tests do not prove a model will obey the requested language in every response.

With the full repository, run tests/Verify-Templates.ps1, then tests/Verify-Edges.ps1 using the printed fixture path. A standalone copied template can still execute START.md's setup checks.
