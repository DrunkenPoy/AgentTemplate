# Standard start and Quick start

The entry request stays **Run START.md**. These modes change setup questions, not the template's purpose or verification requirements. For new setup, keep the language question first; offer the mode choice with or immediately after it. Carry both answers from the distribution entry point into a standalone template without asking again. Do not re-offer mode selection on resume unless the user asks to change it.

## Select a mode and disclose risk first

- **Standard start** (`standard`): follow the existing topic-by-topic interview. Research needed specialist roles and obtain approval before adding their assignments.
- **Quick start** (`quick`, user-facing Korean name: 빠른시작): use the defaults below, ask only unresolved essentials, and automatically assign the additional roles justified by research. This applies to software development, game development, and general work.

Before the user chooses Quick start, show this notice in the conversation's language:

> Quick start uses defaults and defers detailed questions, so its assumptions may miss your intended scope and need correction. It automatically assigns needed specialist agents; additional calls can increase usage/cost and time, and assigned providers receive the task materials needed for their roles. Agent research and review can still miss errors. We will show the applied settings and assignments. Existing approval limits, access permissions, and connection checks still apply.

If the user explicitly requests Quick start before seeing the notice, display it before applying defaults or assigning agents; do not add another confirmation just to repeat that mode request. Do not enable Quick start merely because the user is silent. Default to the existing standard flow when no mode has been selected.

Persist `startup.mode` and the actual displayed notice in `startup.riskNotice` in project.json, and link the mode decision in DECISIONS.md. A Quick start request is permission to apply its setup defaults and additional role assignments, not permission for unrelated tasks, new provider installation/account consent, external delivery, deployment, deletion, or merging. Keep those within the user's existing authorized scope. Show the notice again when explicitly switching from standard to quick.

## Quick start defaults and essential questions

Reuse saved answers first, then inspect project files and the current environment. Never replace an existing setting with a default on resume.

| Topic | Quick start behavior |
|---|---|
| Language | Keep the explicit first language choice; reuse a saved choice. |
| Template and target | Reuse the selected template and inspect saved project records as described in START.md. Ask only when available records and project evidence do not resolve the template or target. |
| Workspace | New projects use this template in place and single-project records. Preserve existing layouts and explicit copy requests; use a separate record when workspace/ is occupied. |
| Project name and purpose | Use observed metadata; ask for missing purpose in one short question. Propose an ID/name when unnamed; label it as a default. Never invent a project goal. |
| Goals and direction | Capture the stated goal. Propose a minimal scope and observable completion criteria from it, clearly labeled as provisional. Defer detailed audience, features, exclusions, deadline, and formatting questions until the first task that needs them. Resolve ambiguity that would change the type of work immediately. |
| Environment | Inspect files, tool availability, work location, and build/test commands instead of asking the user to repeat them. |
| Base AI configuration | Reuse selected providers/models. Otherwise present one compact configuration based on actually available tools/models and obtain the missing selection once. Do not invent model IDs. Keep at least one independent reviewer. |
| Additional agents | Research roles using the procedure below and apply justified assignments without a separate role-addition approval. Reuse the selected provider/model configuration. |
| Ollama | Use `unused` unless already selected or explicitly requested. |
| Skills and MCP | Assess needs and inspect existing connections. Defer optional additions; resolve required connections and any installation/access consent before dependent work. |
| User checkpoints | Reuse existing authorization. If absent, present plan/final checkpoints and the proposed execution scope together for one decision; Quick start does not fabricate `approvals.confirmed`. |
| Version control | Development retains git-pr and an evidence-backed base branch; ask when ambiguous. New general-work defaults to files unless the user selected Git. |
| Engine and deliverables | Detect an existing engine; ask for a missing engine on a new game. Use explicitly requested output formats; otherwise ask only the needed format choice. Never select an engine or substitute Markdown for requested office files by guessing. |

Save defaults and provisional criteria separately from explicit user decisions in PROJECT.md and DECISIONS.md. Record deferred questions in setup-state.json with the task/stage that must resolve them. They are not completed interview topics. Before the first affected task, confirm its scope and completion criteria at the existing plan checkpoint. Missing required configuration still blocks setup: do not bypass Test-Setup or mark setup ready while assignments/connections/permissions are unresolved.

`setupInterviewComplete` means the selected mode's essential setup topics are resolved, not that deferred task requirements were answered. Show a short applied-settings summary rather than reopening each default as a question. Keep unused template folders by default in Quick start; cleanup can be requested later.

## Research and assign workflow roles in both modes

1. Search the workflow, SPECIALIZATION.md, project instructions, goals, source structure, and available skill/agent descriptions for responsibilities the work actually needs. When local evidence is insufficient, search relevant authoritative external documentation and record links and findings. If search is unavailable, record that limit; do not claim external research was done. No project materials should be placed in public search queries.
2. Identify gaps in the coordinator/worker/reviewer coverage. Examples might be accessibility review for a UI, gameplay testing for a game, or source verification for a research report. These are examples, not a mandatory roster. Add only roles with a concrete responsibility, scope, and expected output; an empty additions list is valid when the base team covers the work.
3. Record the search evidence and rationale, then present the proposed role, responsibility, execution route, provider/model, and expected additional calls. In Standard start, ask whether to add the proposed roles and record acceptance or rejection. In Quick start, announce and apply the justified roles without an extra approval question, after the risk notice. Do not silently switch selected models or add a new external provider.
4. Store the completed assessment in `startup.rolesReviewed`, source paths/URLs plus findings in `startup.roleResearch`, and active role assignments in `startup.assignments`. Keep rejected/deferred proposals in DECISIONS.md, outside the active assignments list. Record `approved: true` only for explicit role approval; automatic Quick start assignments use `approved: false` and the saved mode decision as their authorization.
5. Each assignment has `id`, `duty`, `reason`, `route`, and `approved`. A specialist worker uses `route: worker` and runs in its own scoped task/session using the configured worker provider/model. An additional independent reviewer gets a new entry in `reviewers` and `route: reviewer-N` (one-based index). The role is a responsibility, not a requirement to install another product. Run additional worker tasks only when their responsibilities are needed, and include every configured reviewer in the existing review sequence.
6. Use `Invoke-Agent.ps1 -AgentRole <id>` for a specialist call; it selects the recorded worker/reviewer route and includes that role's duty in the prompt. Give workers distinct task IDs and file ownership. For native calls, pass the same role record, selected model, language, scope, and instructions. Every reviewer must stay independent from implementation, even when models are shared. Probe newly configured reviewer entries and check each consumer's required integrations before dependent work.
7. On resume, reuse the mode, research, and assignments without rerunning the interview. Reassess when requirements change; obtain approval for additions in standard mode and announce justified automatic additions in quick mode. Switching to standard requires approval of previously automatic roles before further calls, or removing the declined assignments and updating reviewer/integration indices consistently. Old projects without `startup` continue as standard; before changing their agent setup, add the assessment and policy records without resetting any other settings.

Example of an automatic assignment in a Quick start project (replace the role and evidence with actual research):

~~~json
{
  "mode": "quick",
  "riskNotice": "The actual notice displayed to the user",
  "rolesReviewed": true,
  "roleResearch": ["PROJECT.md: UI acceptance criteria require keyboard navigation checks"],
  "assignments": [
    {"id": "accessibility-review", "duty": "Check keyboard navigation against the agreed UI criteria", "reason": "Independent UI verification is needed", "route": "reviewer-2", "approved": false}
  ]
}
~~~

This is the `startup` object, not a complete configuration. `reviewer-2` must exist in project.json's reviewers array. The scripts check recorded policy and routing; they cannot prove a notice was actually shown, research was sufficient, or a model followed the instructions. Preserve evidence in the setup handoff and verify real outcomes.
