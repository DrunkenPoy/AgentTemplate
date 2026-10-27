# Start here

Open this template folder where your AI can read it, then ask:

> Read START.md and guide me through initial setup. Ask questions one topic at a time, and resume existing settings when available.

The AI reading this document must **perform the setup**, not merely summarize it. Read [WORKFLOW.md](WORKFLOW.md), the [interview guide](guides/INTERVIEW.md), and the [specialization guide](guides/SPECIALIZATION.md). Follow applicable tool, user, and project instructions.

## 1. Select the language first

For a new project, the first interview question is:

> Which language would you like to use for our conversation and project documents?

Ask in the language of the user's opening message when clear; otherwise use English. If the user already explicitly selected a language in this conversation, including through the repository's START.md, reuse that answer. Do not infer a saved preference merely from the language of these English templates.

Conduct the remaining interview and write user-facing reports, project records, handoffs, reviews, and deliverables in the selected language. Keep reusable prompts and delegation instructions in English. Preserve source quotations, code identifiers, filenames, JSON keys, and status tokens. Record any explicit task-specific language override.

For an existing project, read project.json and reuse its language. If the field is missing or blank, ask this question before the rest of the interview and add the answer without resetting other settings. Change an existing language only at the user's request; do not automatically translate historical records.

## 2. Locate the workspace and check capabilities

1. Read template.json beside this file to identify the template kind.
2. Look for workspace/project.json and projects/*/project.json. If the target is clear, use it. If multiple existing projects make it unclear, ask which project to resume before editing anything.
3. For an existing project, read PROJECT.md, DECISIONS.md, BACKLOG.md, setup-state.json, and the latest handoff. Do not reset them.
4. Check file reading, file writing, Windows command execution, and agent invocation separately using the tools actually available. Do not assume an app's shell is the Windows host shell.
5. If commands are available, check for PowerShell 7's pwsh. If missing, use the official installation reference in the [tool guide](guides/TOOLS.md). Keep machine-specific paths out of shared files.

If files are inaccessible, explain how to connect the folder. In an attachment-only environment, provide interview answers and a resumable handoff without claiming that files were created or checked. For general-work desktop use, follow the [app guide](guides/APPS.md).

## 3. Initialize the workspace

After selecting the language, ask whether this folder will serve one project or several, and ask for the project name and purpose.

Propose a short English ID based on the project name. Run the appropriate command from this template folder, substituting the language the user actually selected:

~~~powershell
# One project: records are created in workspace/.
pwsh -NoProfile -File ./scripts/Initialize-Project.ps1 -Id example -Mode single -Name "Project name" -Language "Selected language"

# Several projects: records are created in projects/example/.
pwsh -NoProfile -File ./scripts/Initialize-Project.ps1 -Id example -Mode multi -Name "Project name" -Language "Selected language"
~~~

Run only the chosen mode. The command preserves existing settings on resume, including their language. A direct command without -Language creates an incomplete configuration; ask the language question before proceeding.

The default work/ folder holds new code or deliverables. For an existing repository or working folder, record its location in project.local.json's workDirectory instead of moving or copying it.

## 4. Interview and save each answer

Follow the [interview guide](guides/INTERVIEW.md) in order. Ask only one to three related questions at a time, wait for answers, and do not repeat resolved questions.

- Immediately record each answer in DECISIONS.md and its project.json field. Save the language decision too.
- Update setup-state.json's completedTopics, pendingQuestions, and nextAction.
- Localize headings and prose in newly filled project records to the selected language. Leave distributed English templates unchanged.
- Do not invent approvals, models, or answers for unresolved fields.
- If records cannot be saved, provide copyable decisions and a handoff and mark file persistence incomplete.

Set setupInterviewComplete to true only after the initial interview is complete. This does not establish that tools are connected.

## 5. Configure tools and verify connections

Follow the [tool guide](guides/TOOLS.md). Check only the selected tools and models; supporting an adapter does not require installing or calling every provider.

~~~powershell
pwsh -NoProfile -File ./scripts/Test-Setup.ps1 -Project ./workspace
~~~

For multi-project mode, use -Project ./projects/example. Distinguish unanswered questions from installation and path problems. A passing configuration check does not verify authentication, live model access, or app execution.

Perform a minimal connection check for each selected worker and reviewer within the project's agreed tool-use scope:

~~~powershell
pwsh -NoProfile -File ./scripts/Invoke-Agent.ps1 -Project ./workspace -TaskId setup-worker -Phase probe
pwsh -NoProfile -File ./scripts/Invoke-Agent.ps1 -Project ./workspace -TaskId setup-review -Role reviewer -Reviewer 1 -Phase probe
~~~

Check every reviewer by index. If a call fails or a usage limit is reached, explain the issue in the selected language and ask whether to wait/retry or change the assignment. Do not switch models automatically.

When Claude Code coordinates a Claude role, prefer its available native subagent tool. Pass the selected model, project language, and equivalent probe instructions, then record the result. If that tool is unavailable, check the CLI route without bypassing nested-session restrictions.

## 6. Save the setup handoff and plan the first task

1. Copy forms/SETUP-HANDOFF.md to the project's handoffs/00-setup.md and fill it with observed results in the selected language.
2. Complete PROJECT.md with the language, purpose, acceptance criteria, scope, and verification methods.
3. Set setup-state.json's stage to ready only after file persistence and the assigned agent calls have been checked. Otherwise use waiting-user or waiting-tools and record the reason and resumption steps.
4. Present the first requested task's plan and agree its small/large classification with the user. Follow the project's approval checkpoints.
5. Follow [WORKFLOW.md](WORKFLOW.md) for implementation, review, and revision. Setup alone does not authorize starting an unrequested task.

## Resume in another conversation or AI

Read this START.md again, then load the selected project's language, state, and next action without rerunning completed setup. Explicitly pass START.md, project settings, decisions, and the relevant plan/handoff to the next agent.

Never edit the development AGENTS.md or CLAUDE.md originals, including adding links. Keep additional rules in WORKFLOW.md and project records.
