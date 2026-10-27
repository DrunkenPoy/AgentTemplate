# Initial interview checklist

Ask one to three related questions at a time and wait for answers. Inspect facts that available tools can establish before asking the user. This is a sequence to follow, not a questionnaire to present all at once.

## First question: language

Before discussing workspace layout, tools, or project scope, ask:

> Which language would you like to use for our conversation and project documents?

Ask in the language of the user's opening message when clear, or English otherwise. Reuse an explicit choice already made in the current setup conversation. For an existing project, use its saved language without repeating this question. If an older project has no language field, ask once and add it while preserving all other settings.

Save the answer as project.json's language, record it in DECISIONS.md, and continue in that language. The distributed instructions remain in English; generated records, reports, handoffs, reviews, and deliverables use the chosen language. Localize form headings when filling them in, while preserving source quotations, code identifiers, filenames, JSON keys, and status tokens. Record explicit task-specific language overrides.

| Topic | Questions | Record |
|---|---|---|
| Language (first) | Language for conversation and project documents | language; DECISIONS.md |
| Workspace | One project or several; project name and purpose | Initialization arguments; name/purpose |
| Goals | Audience/users, scope and exclusions, acceptance criteria | PROJECT.md; completionCriteria |
| Environment | New/existing working folder, CLI/app, file and Windows command access | project.local.json; setup-state.json |
| Assigned AI | Claude Code/Codex coordinator; worker model; reviewer models, order, and count | coordinator; worker; reviewers |
| Ollama | Whether to use it; assigned responsibilities and selected model | ollamaRole; relevant provider/model |
| Skills and MCP | Required capabilities, existing connections, essential/optional additions, consumers, access and installation scope; follow [INTEGRATIONS.md](INTEGRATIONS.md) | integrations; local evidence in project.local.json |
| User checkpoints | When to obtain confirmation and what can proceed automatically | approvals.checkpoints/scope/confirmed |
| Deliverables and checks | Specialization questions, output formats, actual verification | PROJECT.md; engine/deliverableFormats |
| Version control | Development repository, PR base/host, and shared records; general-work Git/files choice | versionControl; PROJECT.md |

Complete the capability assessment even when no additional integration is needed: set integrations.reviewed to true and items to an empty array, recording the reason. Reuse previously authorized setup scope; resolve any missing access decision before installation. Store only portable requirements in shared settings.

Use unused for ollamaRole when Ollama is not selected. Do not install or invoke unselected providers. Each reviewer must specify a provider and an available model. Roles may share a provider, but implementation and review run in independent sessions.

Example configuration excerpt; replace values with actual answers, never apply this as an assumed decision:

~~~json
{
  "language": "User-selected language",
  "coordinator": "codex",
  "worker": {"provider": "codex", "model": "User-selected model ID"},
  "reviewers": [{"provider": "claude", "model": "User-selected model ID"}],
  "ollamaRole": "unused",
  "approvals": {
    "confirmed": true,
    "checkpoints": ["plan", "final"],
    "scope": "The automatic execution scope the user actually authorized"
  }
}
~~~

Set approvals.confirmed only after the user decides checkpoints and scope. A request to create a deliverable does not itself authorize external distribution. Development uses git-pr and a base branch confirmed from the actual repository. General work selects git-pr, git, or files during the interview.

After setup, agree **small/large task size with the user for every task plan**. Do not replace this with a one-time project-size decision. Revisit saved setup answers only when a change or unresolved conflict warrants it.
