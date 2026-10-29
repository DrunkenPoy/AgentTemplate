# Verification scope

The initial release was checked on 2026-10-26 using Windows and PowerShell 7.6.5. macOS support was added afterwards and has not yet been verified by running the tests on a Mac.

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

The skills/MCP setup update passed 123 mock checks: 89 main, 14 edge, and 20 integration checks. The additional checks cover missing requirement interviews, optional vs required dependencies, per-consumer evidence, pending consent, blocked work, available provider probes, and re-verification on a new PC. No skill was installed and no live MCP service was called by these tests; recorded evidence is not an independent live connection test.

The 2026-10-29 startup-mode update passed 189 mock checks on Windows and PowerShell 7.6.5: 89 base, 14 edge, 20 integration, and 66 startup-mode checks. All three templates accept researched automatic role assignments in Quick start after a recorded risk notice and require explicit additional-role approval in Standard start. Checks cover specialist responsibility forwarding, independent read-only review, legacy/resume preservation, invalid routes, and required integrations. Recorded metadata does not prove that the notice was actually displayed or that role research was adequate; live model compliance and user experience were not tested.

With the full repository, run tests/Verify-Templates.ps1, then tests/Verify-Edges.ps1 and tests/Verify-Integrations.ps1 using the printed fixture path. Run tests/Verify-StartupModes.ps1 separately; it creates its own fixture. A standalone copied template can still execute START.md's setup checks.
